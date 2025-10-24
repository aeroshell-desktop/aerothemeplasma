/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include <optional>

#include "systemtray.h"

#include "plasmoidregistry.h"
#include "sortedsystemtraymodel.h"
#include "systemtraymodel.h"
#include "systemtraysettings.h"

#include <QGuiApplication>
#include <QMenu>
#include <QMetaMethod>
#include <QMetaObject>
#include <QQueue>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>
#include <qpa/qplatformscreen.h>

#include <Plasma/Applet>
#include <Plasma/Corona>
#include <Plasma/PluginLoader>
#include <Plasma5Support/ServiceJob>

#include <KAcceleratorManager>
#include <KActionCollection>
#include <KSharedConfig>
#include <KWindowSystem>

using namespace Qt::StringLiterals;

SystemTray::SystemTray(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
{
    setHasConfigurationInterface(true);
    setContainmentDisplayHints(Plasma::Types::ContainmentDrawsPlasmoidHeading | Plasma::Types::ContainmentForcesSquarePlasmoids);
}

SystemTray::~SystemTray()
{
    // When the applet is about to be deleted, delete now to avoid calling loadConfig()
    delete m_settings;
}

void SystemTray::init()
{
    // run this before doing any config restore
    migrateFromSystrayContainer();

    Containment::init();

    initSettingsAndRegistry();

    // we don't want to automatically propagate the activated signal from the Applet to the Containment
    // even if SystemTray is of type Containment, it is de facto Applet and should act like one
    connect(this, &Containment::appletAdded, this, [this](Plasma::Applet *applet) {
        disconnect(applet, &Applet::activated, this, &Applet::activated);
    });

    if (KWindowSystem::isPlatformWayland()) {
        auto config = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::NoGlobals);
        KConfigGroup kscreenGroup = config->group(QStringLiteral("KScreen"));
        m_xwaylandClientsScale = kscreenGroup.readEntry("XwaylandClientsScale", true);

        m_configWatcher = KConfigWatcher::create(config);
        connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) {
            if (group.name() == u"KScreen" && names.contains(QByteArrayLiteral("XwaylandClientsScale"))) {
                m_xwaylandClientsScale = group.readEntry("XwaylandClientsScale", true);
            }
        });
    }
}

void SystemTray::initSettingsAndRegistry()
{
    if (!m_settings) {
        m_settings = new SystemTraySettings(configScheme(), this);
        connect(m_settings, &SystemTraySettings::enabledPluginsChanged, this, &SystemTray::onEnabledAppletsChanged);
    }

    if (!m_plasmoidRegistry) {
        m_plasmoidRegistry = new PlasmoidRegistry(m_settings, this);
        connect(m_plasmoidRegistry, &PlasmoidRegistry::plasmoidEnabled, this, &SystemTray::startApplet);
        connect(m_plasmoidRegistry, &PlasmoidRegistry::plasmoidStopped, this, &SystemTray::stopApplet);
    }
}

void SystemTray::migrateFromSystrayContainer()
{
    // Search the old systray containment config group
    KConfigGroup rootCg(corona()->config(), QStringLiteral("Containments"));
    // NOTE: this function is called from tyhe constructor, so we can't use config() yet
    KConfigGroup ownCg = KConfigGroup(config());
    // old Configuration group of the old systray applet
    KConfigGroup oldAppletCg(&ownCg, QStringLiteral("Configuration"));
    const uint oldSystrayId = oldAppletCg.readEntry(QStringLiteral("SystrayContainmentId"), 0);

    if (oldSystrayId == 0) {
        return;
    }

    // Config group of the old systray containment
    KConfigGroup oldContCg = KConfigGroup(&rootCg, QString::number(oldSystrayId));

    // Copy everything all the applets inside, all the subgroup of any applet
    QQueue<QPair<KConfigGroup, KConfigGroup>> queue;
    queue.enqueue(qMakePair(oldContCg, ownCg));
    // Iterative Tree traversal of the systray configuration
    while (!queue.isEmpty()) {
        QPair<KConfigGroup, KConfigGroup> current = queue.dequeue();
        const KConfigGroup &currentSource = current.first;
        KConfigGroup &currentDest = current.second;

        // Copy all entries in the current group
        const QMap<QString, QString> entries = currentSource.entryMap();
        for (auto it = entries.constBegin(); it != entries.constEnd(); ++it) {
            currentDest.writeEntry(it.key(), currentSource.readEntry(it.key(), QString()));
        }

        const QStringList groups = currentSource.groupList();
        for (const QString &group : groups) {
            KConfigGroup sourceSubGroup = currentSource.group(group);
            KConfigGroup destSubGroup = currentDest.group(group);
            queue.enqueue(qMakePair(sourceSubGroup, destSubGroup));
        }
    }

    // Delete the the old systray
    bool oldSystrayInstantiated = false;
    for (Plasma::Containment *cont : corona()->containments()) {
        if (cont->id() == oldSystrayId) {
            delete cont;
            break;
        }
    }
    // To make sure the old containment is really gone from the config first delete then
    // remove the group, as destroy() might fail
    rootCg.deleteGroup(QString::number(oldSystrayId));

    // Delete the old unused key SystrayContainmentId in this systray
    oldAppletCg.deleteEntry(QStringLiteral("SystrayContainmentId"));

    for (Applet *a : applets()) {
        a->configChanged();
    }
}

void SystemTray::restoreContents(KConfigGroup &group)
{
    if (!isContainment()) {
        qWarning() << "Loaded as an applet, this shouldn't have happened";
        return;
    }

    KConfigGroup shortcutConfig(&group, u"Shortcuts"_s);
    QString shortcutText = shortcutConfig.readEntryUntranslated("global", QString());
    if (!shortcutText.isEmpty()) {
        setGlobalShortcut(QKeySequence(shortcutText));
    }

    // cache known config group ids for applets
    KConfigGroup cg = group.group(u"Applets"_s);
    for (const QString &group : cg.groupList()) {
        KConfigGroup appletConfig(&cg, group);
        QString plugin = appletConfig.readEntry("plugin");
        if (!plugin.isEmpty()) {
            m_configGroupIds[plugin] = group.toInt();
        }
    }

    initSettingsAndRegistry();
    m_plasmoidRegistry->init();
}

void SystemTray::showPlasmoidMenu(QQuickItem *appletInterface, int x, int y)
{
    if (!appletInterface) {
        return;
    }

    Plasma::Applet *applet = appletInterface->property("_plasma_applet").value<Plasma::Applet *>();

    QPointF pos = appletInterface->mapToScene(QPointF(x, y));

    if (appletInterface->window() && appletInterface->window()->screen()) {
        pos = appletInterface->window()->mapToGlobal(pos.toPoint());
    } else {
        pos = QPoint();
    }

    QMenu *desktopMenu = new QMenu;
    connect(this, &QObject::destroyed, desktopMenu, &QMenu::close);
    desktopMenu->setAttribute(Qt::WA_DeleteOnClose);

    // this is a workaround where Qt will fail to realize a mouse has been released

    // this happens if a window which does not accept focus spawns a new window that takes focus and X grab
    // whilst the mouse is depressed
    // https://bugreports.qt.io/browse/QTBUG-59044
    // this causes the next click to go missing

    // by releasing manually we avoid that situation
    auto ungrabMouseHack = [appletInterface]() {
        if (appletInterface->window() && appletInterface->window()->mouseGrabberItem()) {
            appletInterface->window()->mouseGrabberItem()->ungrabMouse();
        }
    };

    QTimer::singleShot(0, appletInterface, ungrabMouseHack);
    // end workaround

    Q_EMIT applet->contextualActionsAboutToShow();
    const auto contextActions = applet->contextualActions();
    for (QAction *action : contextActions) {
        if (action) {
            desktopMenu->addAction(action);
        }
    }

    if (applet->internalAction(QStringLiteral("configure"))) {
        desktopMenu->addAction(applet->internalAction(QStringLiteral("configure")));
    }

    if (desktopMenu->isEmpty()) {
        delete desktopMenu;
        return;
    }

    desktopMenu->adjustSize();

    if (QScreen *screen = appletInterface->window()->screen()) {
        const QRect geo = screen->availableGeometry();

        pos = QPoint(qBound(geo.left(), (int)pos.x(), geo.right() - desktopMenu->width()), //
                     qBound(geo.top(), (int)pos.y(), geo.bottom() - desktopMenu->height()));
    }

    KAcceleratorManager::manage(desktopMenu);
    desktopMenu->winId();
    desktopMenu->windowHandle()->setTransientParent(appletInterface->window());
    desktopMenu->popup(pos.toPoint());
}

void SystemTray::showStatusNotifierContextMenu(KJob *job, QQuickItem *statusNotifierIcon)
{
    if (QCoreApplication::closingDown() || !statusNotifierIcon) {
        // apparently an edge case can be triggered due to the async nature of all this
        // see: https://bugs.kde.org/show_bug.cgi?id=251977
        return;
    }

    Plasma5Support::ServiceJob *sjob = qobject_cast<Plasma5Support::ServiceJob *>(job);
    if (!sjob) {
        return;
    }

    QMenu *menu = qobject_cast<QMenu *>(sjob->result().value<QObject *>());

    if (menu && !menu->isEmpty()) {
        menu->adjustSize();
        const auto parameters = sjob->parameters();
        int x = parameters[QStringLiteral("x")].toInt();
        int y = parameters[QStringLiteral("y")].toInt();

        // try tofind the icon screen coordinates, and adjust the position as a poor
        // man's popupPosition

        QRect screenItemRect(statusNotifierIcon->mapToScene(QPointF(0, 0)).toPoint(), QSize(statusNotifierIcon->width(), statusNotifierIcon->height()));

        if (statusNotifierIcon->window()) {
            screenItemRect.moveTopLeft(statusNotifierIcon->window()->mapToGlobal(screenItemRect.topLeft()));
        }

        switch (location()) {
        case Plasma::Types::LeftEdge:
            x = screenItemRect.right();
            y = screenItemRect.top();
            break;
        case Plasma::Types::RightEdge:
            x = screenItemRect.left() - menu->width();
            y = screenItemRect.top();
            break;
        case Plasma::Types::TopEdge:
            x = screenItemRect.left();
            y = screenItemRect.bottom();
            break;
        case Plasma::Types::BottomEdge:
            x = screenItemRect.left();
            y = screenItemRect.top() - menu->height();
            break;
        default:
            x = screenItemRect.left();
            if (screenItemRect.top() - menu->height() >= statusNotifierIcon->window()->screen()->geometry().top()) {
                y = screenItemRect.top() - menu->height();
            } else {
                y = screenItemRect.bottom();
            }
        }

        KAcceleratorManager::manage(menu);
        menu->winId();
        menu->windowHandle()->setTransientParent(statusNotifierIcon->window());
        menu->popup(QPoint(x, y));
        // Workaround for QTBUG-59044
        if (auto item = statusNotifierIcon->window()->mouseGrabberItem()) {
            item->ungrabMouse();
        }
    }
}

QPointF SystemTray::popupPosition(QQuickItem *visualParent, int x, int y)
{
    if (!visualParent) {
        return QPointF(0, 0);
    }

    QPointF pos = visualParent->mapToScene(QPointF(x, y));

    QQuickWindow *const window = visualParent->window();
    if (window && window->screen()) {
        pos = window->mapToGlobal(pos.toPoint());
#if HAVE_X11
        if (KWindowSystem::isPlatformX11()) {
            const auto devicePixelRatio = window->screen()->devicePixelRatio();
            if (QGuiApplication::screens().size() == 1) {
                return pos * devicePixelRatio;
            }

            const QRect geometry = window->screen()->geometry();
            const QRect nativeGeometry = window->screen()->handle()->geometry();
            const QPointF nativeGlobalPosOnCurrentScreen = (pos - geometry.topLeft()) * devicePixelRatio;

            return nativeGeometry.topLeft() + nativeGlobalPosOnCurrentScreen;
        }
#endif

        if (KWindowSystem::isPlatformWayland()) {
            if (!m_xwaylandClientsScale) {
                return pos;
            }

            const qreal devicePixelRatio = window->devicePixelRatio();

            if (QGuiApplication::screens().size() == 1) {
                return pos * devicePixelRatio;
            }

            const QRect geometry = window->screen()->geometry();
            const QRect nativeGeometry = window->screen()->handle()->geometry();
            const QPointF nativeGlobalPosOnCurrentScreen = (pos - geometry.topLeft()) * devicePixelRatio;

            return nativeGeometry.topLeft() + nativeGlobalPosOnCurrentScreen;
        }
    }

    return QPoint();
}

bool SystemTray::isSystemTrayApplet(const QString &appletId)
{
    if (m_plasmoidRegistry) {
        return m_plasmoidRegistry->isSystemTrayApplet(appletId);
    }
    return false;
}

SystemTrayModel *SystemTray::systemTrayModel()
{
    if (!m_systemTrayModel) {
        m_systemTrayModel = new SystemTrayModel(this);

        m_plasmoidModel = new PlasmoidModel(m_settings, m_plasmoidRegistry, m_systemTrayModel);
        connect(this, &SystemTray::appletAdded, m_plasmoidModel, &PlasmoidModel::addApplet);
        connect(this, &SystemTray::appletRemoved, m_plasmoidModel, &PlasmoidModel::removeApplet);
        for (auto applet : applets()) {
            m_plasmoidModel->addApplet(applet);
        }

        m_statusNotifierModel = new StatusNotifierModel(m_settings, m_systemTrayModel);

        m_systemTrayModel->addSourceModel(m_plasmoidModel);
        m_systemTrayModel->addSourceModel(m_statusNotifierModel);
    }

    return m_systemTrayModel;
}

QAbstractItemModel *SystemTray::sortedSystemTrayModel()
{
    if (!m_sortedSystemTrayModel) {
        m_sortedSystemTrayModel = new SortedSystemTrayModel(SortedSystemTrayModel::SortingType::SystemTray, this);
        m_sortedSystemTrayModel->setSourceModel(systemTrayModel());
    }
    return m_sortedSystemTrayModel;
}

QAbstractItemModel *SystemTray::configSystemTrayModel()
{
    if (!m_configSystemTrayModel) {
        m_configSystemTrayModel = new SortedSystemTrayModel(SortedSystemTrayModel::SortingType::ConfigurationPage, this);
        m_configSystemTrayModel->setSourceModel(systemTrayModel());
    }
    return m_configSystemTrayModel;
}

void SystemTray::onEnabledAppletsChanged()
{
    // remove all that are not allowed anymore
    const auto appletsList = applets();
    for (Plasma::Applet *applet : appletsList) {
        // Here it should always be valid.
        // for some reason it not always is.
        if (!applet->pluginMetaData().isValid()) {
            applet->config().parent().deleteGroup();
            delete applet;
        } else {
            const QString task = applet->pluginMetaData().pluginId();
            if (!m_settings->isEnabledPlugin(task)) {
                // in those cases we do delete the applet config completely
                // as they were explicitly disabled by the user
                applet->config().parent().deleteGroup();
                delete applet;
                m_configGroupIds.remove(task);
            }
        }
    }
}

void SystemTray::startApplet(const QString &pluginId)
{
    const auto appletsList = applets();
    for (Plasma::Applet *applet : appletsList) {
        if (!applet->pluginMetaData().isValid()) {
            continue;
        }

        // only allow one instance per applet
        if (pluginId == applet->pluginMetaData().pluginId()) {
            // Applet::destroy doesn't delete the applet from Containment::applets in the same event
            // potentially a dbus activated service being restarted can be added in this time.
            if (!applet->destroyed()) {
                return;
            }
        }
    }

    qDebug() << "Adding applet:" << pluginId;

    // known one, recycle the id to reuse old config
    if (m_configGroupIds.contains(pluginId)) {
        Applet *applet = Plasma::PluginLoader::self()->loadApplet(pluginId, m_configGroupIds.value(pluginId), QVariantList());
        // this should never happen unless explicitly wrong config is hand-written or
        //(more likely) a previously added applet is uninstalled
        if (!applet) {
            qWarning() << "Unable to find applet" << pluginId;
            return;
        }
        applet->setProperty("org.kde.plasma:force-create", true);
        addApplet(applet);
        // create a new one automatic id, new config group
    } else {
        Applet *applet = createApplet(pluginId, QVariantList() << u"org.kde.plasma:force-create"_s);
        if (applet) {
            m_configGroupIds[pluginId] = applet->id();
        }
    }
}

void SystemTray::stopApplet(const QString &pluginId)
{
    const auto appletsList = applets();
    for (Plasma::Applet *applet : appletsList) {
        if (applet->pluginMetaData().isValid() && pluginId == applet->pluginMetaData().pluginId()) {
            delete applet;
        }
    }
}

void SystemTray::stackItemBefore(QQuickItem *newItem, QQuickItem *beforeItem)
{
    if (!newItem || !beforeItem) {
        return;
    }
    newItem->stackBefore(beforeItem);
}

void SystemTray::stackItemAfter(QQuickItem *newItem, QQuickItem *afterItem)
{
    if (!newItem || !afterItem) {
        return;
    }
    newItem->stackAfter(afterItem);
}

K_PLUGIN_CLASS(SystemTray)

#include "systemtray.moc"

#include "moc_systemtray.cpp"
