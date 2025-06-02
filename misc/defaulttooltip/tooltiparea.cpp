/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2011 Artur Duque de Souza <asouza@kde.org>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2023 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "tooltiparea.h"
#include "appletquickitem.h"
#include "tooltipdialog.h"

#include <QDebug>
#include <QQmlEngine>
#include <QStandardPaths>

#include <KDirWatch>
#include <KSharedConfig>
#include <KWindowEffects>
#include <KWindowSystem>
#include <Plasma/Applet>

ToolTipDialog *ToolTipArea::s_dialog = nullptr;
int ToolTipArea::s_dialogUsers = 0;

ToolTipArea::ToolTipArea(QQuickItem *parent)
    : QQuickItem(parent)
    , m_tooltipsEnabledGlobally(false)
    , m_containsMouse(false)
    , m_location(Plasma::Types::Floating)
    , m_textFormat(Qt::AutoText)
    , m_active(true)
    , m_interactive(false)
    , m_timeout(-1)
    , m_usingDialog(false)
    , m_backgroundHints(PlasmaQuick::PlasmaWindow::SolidBackground)
    , m_windowTitle(QStringLiteral(""))
{
    setAcceptHoverEvents(true);
    setFiltersChildMouseEvents(true);

    m_showTimer.setSingleShot(true);
    connect(&m_showTimer, &QTimer::timeout, this, &ToolTipArea::showToolTip);

    loadSettings();

    const QString configFile = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) + QStringLiteral("/plasmarc");
    KDirWatch::self()->addFile(configFile);
    QObject::connect(KDirWatch::self(), &KDirWatch::created, this, &ToolTipArea::settingsChanged);
    QObject::connect(KDirWatch::self(), &KDirWatch::dirty, this, &ToolTipArea::settingsChanged);
}

ToolTipArea::~ToolTipArea()
{
    if (s_dialog && s_dialog->owner() == this) {
        s_dialog->setVisible(false);
    }

    if (m_usingDialog) {
        --s_dialogUsers;
    }

    if (s_dialogUsers == 0) {
        delete s_dialog;
        s_dialog = nullptr;
    }
}

void ToolTipArea::settingsChanged(const QString &file)
{
    if (!file.endsWith(QLatin1String("plasmarc"))) {
        return;
    }

    KSharedConfig::openConfig(QStringLiteral("plasmarc"))->reparseConfiguration();
    loadSettings();
}

void ToolTipArea::loadSettings()
{
    KConfigGroup cfg = KConfigGroup(KSharedConfig::openConfig(QStringLiteral("plasmarc")), QStringLiteral("PlasmaToolTips"));
    m_interval = cfg.readEntry("Delay", 700);
    m_tooltipsEnabledGlobally = (m_interval > 0);
}

QQuickItem *ToolTipArea::mainItem() const
{
    return m_mainItem.data();
}

ToolTipDialog *ToolTipArea::tooltipDialogInstance()
{
    if (!s_dialog) {
        s_dialog = new ToolTipDialog;
    }

    if (!m_usingDialog) {
        s_dialogUsers++;
        m_usingDialog = true;
    }

    return s_dialog;
}

void ToolTipArea::setMainItem(QQuickItem *mainItem)
{
    if (m_mainItem.data() != mainItem) {
        m_mainItem = mainItem;

        Q_EMIT mainItemChanged();

        if (!isValid() && s_dialog && s_dialog->owner() == this) {
            s_dialog->setVisible(false);
        }
    }
}

void ToolTipArea::showToolTip()
{
    if (!m_active) {
        return;
    }

    Q_EMIT aboutToShow();

    ToolTipDialog *dlg = tooltipDialogInstance();

    if (!mainItem()) {
        setMainItem(dlg->loadDefaultItem());
    }

    // Unset the dialog's old contents before reparenting the dialog.
    dlg->setMainItem(nullptr);

    Plasma::Types::Location location = m_location;
    if (m_location == Plasma::Types::Floating) {
        QQuickItem *p = parentItem();
        while (p) {
            PlasmaQuick::AppletQuickItem *appletItem = qobject_cast<PlasmaQuick::AppletQuickItem *>(p);
            if (appletItem) {
                location = appletItem->applet()->location();
                break;
            }
            p = p->parentItem();
        }
    }

    if (mainItem()) {
        mainItem()->setProperty("toolTip", QVariant::fromValue(this));
        mainItem()->setVisible(true);
    }

    connect(dlg, &ToolTipDialog::visibleChanged, this, &ToolTipArea::toolTipVisibleChanged, Qt::UniqueConnection);

    dlg->setHideTimeout(m_timeout);
    dlg->setOwner(this);
    dlg->setVisualParent(this);
    dlg->setMainItem(mainItem());
    dlg->setInteractive(m_interactive);

    switch (location) {
    case Plasma::Types::Floating:
    case Plasma::Types::Desktop:
    case Plasma::Types::FullScreen:
        dlg->setFloating(true);
        dlg->setPopupDirection(Qt::BottomEdge);
        break;
    case Plasma::Types::TopEdge:
        dlg->setFloating(false);
        dlg->setPopupDirection(Qt::BottomEdge);
        break;
    case Plasma::Types::BottomEdge:
        dlg->setFloating(false);
        dlg->setPopupDirection(Qt::TopEdge);
        break;
    case Plasma::Types::LeftEdge:
        dlg->setFloating(false);
        dlg->setPopupDirection(Qt::RightEdge);
        break;
    case Plasma::Types::RightEdge:
        dlg->setFloating(false);
        dlg->setPopupDirection(Qt::LeftEdge);
        break;
    }

    dlg->setBackgroundHints(m_backgroundHints);
    dlg->setTitle(m_windowTitle); // Wayland sees this just fine
    // Ugly hack to make this tooltip identifiable on X11
    if (KWindowSystem::isPlatformX11() && m_backgroundHints == PlasmaQuick::PlasmaWindow::StandardBackground) {
        Qt::WindowFlags flags = dlg->flags();
        dlg->setFlags(flags | Qt::Dialog);
    } else {
        Qt::WindowFlags flags = dlg->flags();
        dlg->setFlags(flags & ~Qt::Dialog);
    }

    dlg->setVisible(true);
    // In case the last owner triggered a dismiss but the dialog is still shown,
    // showEvent won't be reached and the old timeout will still be effective.
    // Call keepalive() to make it use the new timeout.
    dlg->keepalive();
}

void ToolTipArea::setWindowTitle(QString windowTitle)
{
    m_windowTitle = windowTitle;
}

QString ToolTipArea::mainText() const
{
    return m_mainText;
}

void ToolTipArea::setMainText(const QString &mainText)
{
    if (mainText == m_mainText) {
        return;
    }

    m_mainText = mainText;
    Q_EMIT mainTextChanged();

    if (!isValid() && s_dialog && s_dialog->owner() == this) {
        s_dialog->setVisible(false);
    }
}

QString ToolTipArea::subText() const
{
    return m_subText;
}

void ToolTipArea::setSubText(const QString &subText)
{
    if (subText == m_subText) {
        return;
    }

    m_subText = subText;
    Q_EMIT subTextChanged();

    if (!isValid() && s_dialog && s_dialog->owner() == this) {
        s_dialog->setVisible(false);
    }
}

int ToolTipArea::textFormat() const
{
    return m_textFormat;
}

void ToolTipArea::setTextFormat(int format)
{
    if (m_textFormat == format) {
        return;
    }

    m_textFormat = format;
    Q_EMIT textFormatChanged();
}

Plasma::Types::Location ToolTipArea::location() const
{
    return m_location;
}

void ToolTipArea::setLocation(Plasma::Types::Location location)
{
    if (m_location == location) {
        return;
    }
    m_location = location;
    Q_EMIT locationChanged();
}

void ToolTipArea::setActive(bool active)
{
    if (m_active == active) {
        return;
    }

    m_active = active;
    if (!active) {
        tooltipDialogInstance()->dismiss();
    }
    Q_EMIT activeChanged();
}

void ToolTipArea::setInteractive(bool interactive)
{
    if (m_interactive == interactive) {
        return;
    }

    m_interactive = interactive;

    Q_EMIT interactiveChanged();
}

void ToolTipArea::setTimeout(int timeout)
{
    m_timeout = timeout;
}
void ToolTipArea::setBackgroundHints(PlasmaQuick::PlasmaWindow::BackgroundHints backgroundHints)
{
    m_backgroundHints = backgroundHints;
}

void ToolTipArea::hideToolTip()
{
    m_showTimer.stop();
    tooltipDialogInstance()->dismiss();
}

void ToolTipArea::hideImmediately()
{
    m_showTimer.stop();
    tooltipDialogInstance()->setVisible(false);
}

QVariant ToolTipArea::icon() const
{
    if (m_icon.isValid()) {
        return m_icon;
    } else {
        return QString();
    }
}

void ToolTipArea::setIcon(const QVariant &icon)
{
    if (icon == m_icon) {
        return;
    }

    m_icon = icon;
    Q_EMIT iconChanged();
}

QVariant ToolTipArea::image() const
{
    if (m_image.isValid()) {
        return m_image;
    } else {
        return QString();
    }
}

void ToolTipArea::setImage(const QVariant &image)
{
    if (image == m_image) {
        return;
    }

    m_image = image;
    Q_EMIT imageChanged();
}

bool ToolTipArea::containsMouse() const
{
    return m_containsMouse;
}

void ToolTipArea::setContainsMouse(bool contains)
{
    if (m_containsMouse != contains) {
        m_containsMouse = contains;
        Q_EMIT containsMouseChanged();
    }
    if (!contains && tooltipDialogInstance()->owner() == this) {
        tooltipDialogInstance()->dismiss();
    }
}

void ToolTipArea::hoverEnterEvent(QHoverEvent *event)
{
    Q_UNUSED(event)
    setContainsMouse(true);

    if (!m_tooltipsEnabledGlobally) {
        return;
    }

    if (!isValid()) {
        return;
    }

    if (tooltipDialogInstance()->isVisible()) {
        // We signal the tooltipmanager that we're "potentially interested,
        // and ask to keep it open for a bit, so other items get the chance
        // to update the content before the tooltip hides -- this avoids
        // flickering
        // It need to be considered only when other items can deal with tooltip area
        if (m_active) {
            tooltipDialogInstance()->keepalive();
            // FIXME: showToolTip needs to be renamed in sync or something like that
            showToolTip();
        }
    } else {
        m_showTimer.start(m_interval);
    }
}

void ToolTipArea::hoverLeaveEvent(QHoverEvent *event)
{
    Q_UNUSED(event)
    setContainsMouse(false);
    m_showTimer.stop();
}

bool ToolTipArea::childMouseEventFilter(QQuickItem *item, QEvent *event)
{
    if (event->type() == QEvent::MouseButtonPress) {
        hideToolTip();
    }
    return QQuickItem::childMouseEventFilter(item, event);
}

bool ToolTipArea::isValid() const
{
    return m_mainItem || !mainText().isEmpty() || !subText().isEmpty();
}

#include "moc_tooltiparea.cpp"
