/*
    SPDX-FileCopyrightText: 2009 Marco Martin <notmart@gmail.com>
    SPDX-FileCopyrightText: 2009 Matthieu Gallien <matthieu_gallien@yahoo.fr>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "statusnotifieritemsource.h"
#include "statusnotifieritemservice.h"
#include "systemtraytypes.h"

#include <KIconColors>
#include <KIconEngine>
#include <KIconLoader>
#include <Plasma/Theme>

#include <QApplication>
#include <QDBusMessage>
#include <QDBusPendingCall>
#include <QDBusPendingReply>
#include <QDebug>
#include <QIcon>
#include <QImage>
#include <QPainter>
#include <QPixmap>
#include <QSysInfo>
#include <QVariantMap>

#include <netinet/in.h>

#include <dbusmenuimporter.h>

Q_GLOBAL_STATIC(Plasma::Theme, s_theme)

class PlasmaDBusMenuImporter : public DBusMenuImporter
{
public:
    PlasmaDBusMenuImporter(const QString &service, const QString &path, KIconLoader *iconLoader, QObject *parent)
        : DBusMenuImporter(service, path, parent)
        , m_iconLoader(iconLoader)
    {
    }

protected:
    QIcon iconForName(const QString &name) override
    {
        return QIcon(new KIconEngine(name, m_iconLoader));
    }

private:
    KIconLoader *m_iconLoader;
};

StatusNotifierItemSource::StatusNotifierItemSource(const QString &notifierItemId, QObject *parent)
    : QObject(parent)
    , m_customIconLoader(nullptr)
    , m_menuImporter(nullptr)
    , m_refreshing(false)
    , m_needsReRefreshing(false)
{
    setObjectName(notifierItemId);
    qDBusRegisterMetaType<KDbusImageStruct>();
    qDBusRegisterMetaType<KDbusImageVector>();
    qDBusRegisterMetaType<KDbusToolTipStruct>();

    m_servicename = notifierItemId;

    int slash = notifierItemId.indexOf(u'/');
    if (slash == -1) {
        qWarning() << "Invalid notifierItemId:" << notifierItemId;
        m_valid = false;
        m_statusNotifierItemInterface = nullptr;
        return;
    }
    QString service = notifierItemId.left(slash);
    QString path = notifierItemId.mid(slash);

    m_statusNotifierItemInterface = new org::kde::StatusNotifierItem(service, path, QDBusConnection::sessionBus(), this);

    m_refreshTimer.setSingleShot(true);
    m_refreshTimer.setInterval(10);
    connect(&m_refreshTimer, &QTimer::timeout, this, &StatusNotifierItemSource::performRefresh);

    m_valid = !service.isEmpty() && m_statusNotifierItemInterface->isValid();
    if (m_valid) {
        connect(m_statusNotifierItemInterface, &OrgKdeStatusNotifierItem::NewTitle, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface, &OrgKdeStatusNotifierItem::NewIcon, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface, &OrgKdeStatusNotifierItem::NewAttentionIcon, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface, &OrgKdeStatusNotifierItem::NewOverlayIcon, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface, &OrgKdeStatusNotifierItem::NewToolTip, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface, &OrgKdeStatusNotifierItem::NewStatus, this, &StatusNotifierItemSource::syncStatus);
        connect(m_statusNotifierItemInterface, &OrgKdeStatusNotifierItem::NewMenu, this, &StatusNotifierItemSource::refreshMenu);
        refresh();
    }

    connect(s_theme, &Plasma::Theme::themeChanged, this, &StatusNotifierItemSource::reloadIcon);
}

StatusNotifierItemSource::~StatusNotifierItemSource()
{
    delete m_statusNotifierItemInterface;
}

KIconLoader *StatusNotifierItemSource::iconLoader() const
{
    return m_customIconLoader ? m_customIconLoader : KIconLoader::global();
}

QIcon StatusNotifierItemSource::attentionIcon() const
{
    return m_attentionIcon;
}

QString StatusNotifierItemSource::attentionIconName() const
{
    return m_attentionIconName;
}

QString StatusNotifierItemSource::attentionMovieName() const
{
    return m_attentionMovieName;
}

QString StatusNotifierItemSource::category() const
{
    return m_category;
}

QIcon StatusNotifierItemSource::icon() const
{
    return m_icon;
}

QString StatusNotifierItemSource::iconName() const
{
    return m_iconName;
}

QString StatusNotifierItemSource::iconThemePath() const
{
    return m_iconThemePath;
}

QString StatusNotifierItemSource::id() const
{
    return m_id;
}

bool StatusNotifierItemSource::itemIsMenu() const
{
    return m_itemIsMenu;
}

QString StatusNotifierItemSource::overlayIconName() const
{
    return m_overlayIconName;
}

QString StatusNotifierItemSource::status() const
{
    return m_status;
}

QString StatusNotifierItemSource::title() const
{
    return m_title;
}

QString StatusNotifierItemSource::toolTipSubTitle() const
{
    return m_toolTipSubTitle;
}

QString StatusNotifierItemSource::toolTipTitle() const
{
    return m_toolTipTitle;
}

QString StatusNotifierItemSource::windowId() const
{
    return m_windowId;
}

Plasma5Support::Service *StatusNotifierItemSource::createService()
{
    return new StatusNotifierItemService(this);
}

void StatusNotifierItemSource::syncStatus(const QString &status)
{
    m_status = status;
    Q_EMIT dataUpdated();
}

void StatusNotifierItemSource::refreshMenu()
{
    if (m_menuImporter) {
        delete m_menuImporter;
        m_menuImporter = nullptr;
    }
    refresh();
}

void StatusNotifierItemSource::refresh()
{
    if (!m_refreshTimer.isActive()) {
        m_refreshTimer.start();
    }
}

void StatusNotifierItemSource::performRefresh()
{
    if (m_refreshing) {
        m_needsReRefreshing = true;
        return;
    }

    m_refreshing = true;
    QDBusMessage message = QDBusMessage::createMethodCall(m_statusNotifierItemInterface->service(),
                                                          m_statusNotifierItemInterface->path(),
                                                          QStringLiteral("org.freedesktop.DBus.Properties"),
                                                          QStringLiteral("GetAll"));

    message << m_statusNotifierItemInterface->interface();
    QDBusPendingCall call = m_statusNotifierItemInterface->connection().asyncCall(message);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, this);
    connect(watcher, &QDBusPendingCallWatcher::finished, this, &StatusNotifierItemSource::refreshCallback);
}

/**
  \todo add a smart pointer to guard call and to automatically delete it at the end of the function
  */
void StatusNotifierItemSource::refreshCallback(QDBusPendingCallWatcher *call)
{
    m_refreshing = false;
    if (m_needsReRefreshing) {
        m_needsReRefreshing = false;
        performRefresh();
        call->deleteLater();
        return;
    }

    QDBusPendingReply<QVariantMap> reply = *call;
    if (reply.isError()) {
        m_valid = false;
    } else {
        // IconThemePath (handle this one first, because it has an impact on
        // others)
        QVariantMap properties = reply.argumentAt<0>();
        QString path = properties[QStringLiteral("IconThemePath")].toString();

        if (!path.isEmpty() && path != m_iconThemePath) {
            if (!m_customIconLoader) {
                m_customIconLoader = new KIconLoader(QString(), QStringList(), this);
            }
            // FIXME: If last part of path is not "icons", this won't work!
            QString appName;
            auto tokens = QStringView(path).split(u'/', Qt::SkipEmptyParts);
            if (tokens.length() >= 3 && tokens.takeLast() == QLatin1String("icons"))
                appName = tokens.takeLast().toString();

            // icons may be either in the root directory of the passed path or in a appdir format
            // i.e hicolor/32x32/iconname.png

            m_customIconLoader->reconfigure(appName, QStringList(path));

            // add app dir requires an app name, though this is completely unused in this context
            m_customIconLoader->addAppDir(appName.size() ? appName : QStringLiteral("unused"), path);

            connect(m_customIconLoader, &KIconLoader::iconChanged, this, [=, this] {
                m_customIconLoader->reconfigure(appName, QStringList(path));
                m_customIconLoader->addAppDir(appName.size() ? appName : QStringLiteral("unused"), path);
            });
        }
        m_iconThemePath = path;

        m_category = properties[QStringLiteral("Category")].toString();
        m_status = properties[QStringLiteral("Status")].toString();
        m_title = properties[QStringLiteral("Title")].toString();
        m_id = properties[QStringLiteral("Id")].toString();
        m_windowId = properties[QStringLiteral("WindowId")].toString();
        m_itemIsMenu = properties[QStringLiteral("ItemIsMenu")].toBool();

        // Attention Movie
        m_attentionMovieName = properties[QStringLiteral("AttentionMovieName")].toString();

        QIcon overlay;

        // Overlay icon
        {
            m_overlayIconName = QString();

            const QString iconName = properties[QStringLiteral("OverlayIconName")].toString();
            if (!iconName.isEmpty()) {
                overlay = QIcon(new KIconEngine(iconName, KIconColors(Plasma::Theme::globalPalette()), iconLoader()));
                if (!overlay.isNull()) {
                    m_overlayIconName = iconName;
                }
            }
            if (overlay.isNull()) {
                KDbusImageVector image;
                properties[QStringLiteral("OverlayIconPixmap")].value<QDBusArgument>() >> image;
                if (!image.isEmpty()) {
                    overlay = imageVectorToPixmap(image);
                }
            }
        }

        auto loadIcon = [this, &properties, &overlay](const QString &iconKey, const QString &pixmapKey) -> std::tuple<QIcon, QString> {
            if (QString iconName = properties[iconKey].toString(); !iconName.isEmpty()) {
                if (!iconName.endsWith(QStringLiteral("-symbolic")) && !QDir::isAbsolutePath(iconName)
                    && iconLoader()->hasIcon(iconName + QStringLiteral("-symbolic"))) {
                    iconName += QStringLiteral("-symbolic");
                }
                QIcon icon = QIcon(new KIconEngine(iconName, KIconColors(Plasma::Theme::globalPalette()), iconLoader(), {m_overlayIconName}));
                if (!icon.isNull()) {
                    if (!overlay.isNull() && m_overlayIconName.isEmpty()) {
                        overlayIcon(&icon, &overlay);
                    }
                    return {icon, iconName};
                }
            }
            KDbusImageVector image;
            properties[pixmapKey].value<QDBusArgument>() >> image;
            if (!image.isEmpty()) {
                QIcon icon = imageVectorToPixmap(image);
                if (!icon.isNull() && !overlay.isNull()) {
                    overlayIcon(&icon, &overlay);
                }
                return {icon, QString()};
            }
            return {};
        };

        std::tie(m_icon, m_iconName) = loadIcon(QStringLiteral("IconName"), QStringLiteral("IconPixmap"));
        std::tie(m_attentionIcon, m_attentionIconName) = loadIcon(QStringLiteral("AttentionIconName"), QStringLiteral("AttentionIconPixmap"));

        // ToolTip
        {
            KDbusToolTipStruct toolTip;
            properties[QStringLiteral("ToolTip")].value<QDBusArgument>() >> toolTip;
            if (toolTip.title.isEmpty()) {
                m_toolTipTitle = QString();
                m_toolTipSubTitle = QString();
            } else {
                m_toolTipTitle = toolTip.title;
                m_toolTipSubTitle = toolTip.subTitle;
            }

            // Some applications, such as Discord, seem to prefer to
            // only set the tooltip title, and no title. This results in a
            // system tray entry that has the correct name when hovered,
            // but no name in the system tray settings. To avoid this, if
            // we have a tooltip title but no title, we will use the
            // former as the latter. In the example of Discord, this is
            // the only information we can use to guess the correct name.
            if (m_title.isEmpty() && !m_toolTipTitle.isEmpty()) {
                m_title = m_toolTipTitle;
            }
        }

        // Menu
        if (qobject_cast<QApplication *>(QCoreApplication::instance()) && !m_menuImporter) {
            QString menuObjectPath = properties[QStringLiteral("Menu")].value<QDBusObjectPath>().path();
            if (!menuObjectPath.isEmpty()) {
                if (menuObjectPath == QLatin1String("/NO_DBUSMENU")) {
                    // This is a hack to make it possible to disable DBusMenu in an
                    // application. The string "/NO_DBUSMENU" must be the same as in
                    // KStatusNotifierItem::setContextMenu().
                    qWarning() << "DBusMenu disabled for this application";
                } else {
                    m_menuImporter = new PlasmaDBusMenuImporter(m_statusNotifierItemInterface->service(), menuObjectPath, iconLoader(), this);
                    connect(m_menuImporter, &PlasmaDBusMenuImporter::menuUpdated, this, [this](QMenu *menu) {
                        if (menu == m_menuImporter->menu()) {
                            contextMenuReady();
                        }
                    });
                }
            }
        }
    }

    Q_EMIT dataUpdated();
    call->deleteLater();
}

void StatusNotifierItemSource::reloadIcon()
{
    if (!m_iconName.isEmpty()) {
        m_icon = QIcon(new KIconEngine(m_iconName, KIconColors(Plasma::Theme::globalPalette()), iconLoader(), {m_overlayIconName}));
    }

    if (!m_attentionIconName.isEmpty()) {
        m_attentionIcon = QIcon(new KIconEngine(m_attentionIconName, KIconColors(Plasma::Theme::globalPalette()), iconLoader(), {m_overlayIconName}));
    }

    Q_EMIT dataUpdated();
}

void StatusNotifierItemSource::contextMenuReady()
{
    Q_EMIT contextMenuReady(m_menuImporter->menu());
}

QPixmap StatusNotifierItemSource::KDbusImageStructToPixmap(const KDbusImageStruct &image) const
{
    // swap from network byte order if we are little endian
    if (QSysInfo::ByteOrder == QSysInfo::LittleEndian) {
        uint *uintBuf = (uint *)image.data.data();
        for (uint i = 0; i < image.data.size() / sizeof(uint); ++i) {
            *uintBuf = ntohl(*uintBuf);
            ++uintBuf;
        }
    }
    if (image.width == 0 || image.height == 0) {
        return QPixmap();
    }

    // avoid a deep copy of the image data
    // we need to keep a reference to the image.data alive for the lifespan of the image, even if the image is copied
    // we create a new QByteArray with a shallow copy of the original data on the heap, then delete this in the QImage cleanup
    auto dataRef = new QByteArray(image.data);

    QImage iconImage(
        reinterpret_cast<const uchar *>(dataRef->data()),
        image.width,
        image.height,
        QImage::Format_ARGB32,
        [](void *ptr) {
            delete static_cast<QByteArray *>(ptr);
        },
        dataRef);
    return QPixmap::fromImage(std::move(iconImage));
}

QIcon StatusNotifierItemSource::imageVectorToPixmap(const KDbusImageVector &vector) const
{
    QIcon icon;

    for (int i = 0; i < vector.size(); ++i) {
        icon.addPixmap(KDbusImageStructToPixmap(vector[i]));
    }

    return icon;
}

void StatusNotifierItemSource::overlayIcon(QIcon *icon, QIcon *overlay)
{
    QIcon tmp;
    QPixmap m_iconPixmap = icon->pixmap(KIconLoader::SizeSmall, KIconLoader::SizeSmall);

    QPainter p(&m_iconPixmap);

    const int size = KIconLoader::SizeSmall / 2;
    p.drawPixmap(QRect(size, size, size, size), overlay->pixmap(size, size), QRect(0, 0, size, size));
    p.end();
    tmp.addPixmap(m_iconPixmap);

    // if an m_icon exactly that size wasn't found don't add it to the vector
    m_iconPixmap = icon->pixmap(KIconLoader::SizeSmallMedium, KIconLoader::SizeSmallMedium);
    if (m_iconPixmap.width() == KIconLoader::SizeSmallMedium) {
        const int size = KIconLoader::SizeSmall / 2;
        QPainter p(&m_iconPixmap);
        p.drawPixmap(QRect(m_iconPixmap.width() - size, m_iconPixmap.height() - size, size, size), overlay->pixmap(size, size), QRect(0, 0, size, size));
        p.end();
        tmp.addPixmap(m_iconPixmap);
    }

    m_iconPixmap = icon->pixmap(KIconLoader::SizeMedium, KIconLoader::SizeMedium);
    if (m_iconPixmap.width() == KIconLoader::SizeMedium) {
        const int size = KIconLoader::SizeSmall / 2;
        QPainter p(&m_iconPixmap);
        p.drawPixmap(QRect(m_iconPixmap.width() - size, m_iconPixmap.height() - size, size, size), overlay->pixmap(size, size), QRect(0, 0, size, size));
        p.end();
        tmp.addPixmap(m_iconPixmap);
    }

    m_iconPixmap = icon->pixmap(KIconLoader::SizeLarge, KIconLoader::SizeLarge);
    if (m_iconPixmap.width() == KIconLoader::SizeLarge) {
        const int size = KIconLoader::SizeSmall;
        QPainter p(&m_iconPixmap);
        p.drawPixmap(QRect(m_iconPixmap.width() - size, m_iconPixmap.height() - size, size, size), overlay->pixmap(size, size), QRect(0, 0, size, size));
        p.end();
        tmp.addPixmap(m_iconPixmap);
    }

    // We can't do 'm_icon->addPixmap()' because if 'm_icon' uses KIconEngine,
    // it will ignore the added pixmaps. This is not a bug in KIconEngine,
    // QIcon::addPixmap() doc says: "Custom m_icon engines are free to ignore
    // additionally added pixmaps".
    *icon = tmp;
    // hopefully huge and enormous not necessary right now, since it's quite costly
}

void StatusNotifierItemSource::activate(int x, int y)
{
    if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
        QDBusMessage message = QDBusMessage::createMethodCall(m_statusNotifierItemInterface->service(),
                                                              m_statusNotifierItemInterface->path(),
                                                              m_statusNotifierItemInterface->interface(),
                                                              QStringLiteral("Activate"));

        message << x << y;
        QDBusPendingCall call = m_statusNotifierItemInterface->connection().asyncCall(message);
        QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, this);
        connect(watcher, &QDBusPendingCallWatcher::finished, this, &StatusNotifierItemSource::activateCallback);
    }
}

void StatusNotifierItemSource::activateCallback(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<void> reply = *call;
    Q_EMIT activateResult(!reply.isError());
    call->deleteLater();
}

void StatusNotifierItemSource::secondaryActivate(int x, int y)
{
    if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
        m_statusNotifierItemInterface->call(QDBus::NoBlock, QStringLiteral("SecondaryActivate"), x, y);
    }
}

void StatusNotifierItemSource::scroll(int delta, const QString &direction)
{
    if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
        m_statusNotifierItemInterface->call(QDBus::NoBlock, QStringLiteral("Scroll"), delta, direction);
    }
}

void StatusNotifierItemSource::contextMenu(int x, int y)
{
    if (m_menuImporter) {
        m_menuImporter->updateMenu();
    } else {
        qWarning() << "Could not find DBusMenu interface, falling back to calling ContextMenu()";
        if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
            m_statusNotifierItemInterface->call(QDBus::NoBlock, QStringLiteral("ContextMenu"), x, y);
        }
    }
}

void StatusNotifierItemSource::provideXdgActivationToken(const QString &token)
{
    if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
        m_statusNotifierItemInterface->ProvideXdgActivationToken(token);
    }
}

#include "moc_statusnotifieritemsource.cpp"
