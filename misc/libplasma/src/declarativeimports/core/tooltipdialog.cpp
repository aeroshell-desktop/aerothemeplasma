/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "tooltipdialog.h"

#include <QDebug>
#include <QFile>
#include <QPlatformSurfaceEvent>
#include <QQmlEngine>
#include <QQuickItem>

#include <KWindowSystem>
#include <plasmaquick/sharedqmlengine.h>

#include "plasmashellwaylandintegration.h"

ToolTipDialog::ToolTipDialog()
    : PopupPlasmaWindow(QStringLiteral("widgets/tooltip"))
    , m_qmlObject(nullptr)
    , m_hideTimeout(-1)
    , m_interactive(false)
    , m_owner(nullptr)
{
    Qt::WindowFlags flags = Qt::WindowDoesNotAcceptFocus | Qt::WindowStaysOnTopHint;
    if (KWindowSystem::isPlatformX11()) {
        flags |= Qt::ToolTip | Qt::BypassWindowManagerHint;
    } else {
        flags |= Qt::FramelessWindowHint;
        PlasmaShellWaylandIntegration::get(this)->setRole(QtWayland::org_kde_plasma_surface::role_tooltip);
    }
    setFlags(flags);

    connect(this, &PlasmaWindow::backgroundHintsChanged, this, &ToolTipDialog::updateSize);

    m_hideTimer.setSingleShot(true);
    connect(&m_hideTimer, &QTimer::timeout, this, [this]() {
        setVisible(false);
    });

    connect(this, &PlasmaQuick::PlasmaWindow::mainItemChanged, this, [this]() {
        if (m_lastMainItem) {
            disconnect(m_lastMainItem, &QQuickItem::implicitWidthChanged, this, &ToolTipDialog::updateSize);
            disconnect(m_lastMainItem, &QQuickItem::implicitHeightChanged, this, &ToolTipDialog::updateSize);
        }
        m_lastMainItem = mainItem();

        if (!m_lastMainItem) {
            return;
        }
        connect(m_lastMainItem, &QQuickItem::implicitWidthChanged, this, &ToolTipDialog::updateSize);
        connect(m_lastMainItem, &QQuickItem::implicitHeightChanged, this, &ToolTipDialog::updateSize);
        updateSize();
    });
}

ToolTipDialog::~ToolTipDialog()
{
}

void ToolTipDialog::updateSize()
{
    QScreen *s = screen();
    if (!s) {
        return;
    }
    QSize popupSize = QSize(mainItem()->implicitWidth(), mainItem()->implicitHeight());
    popupSize = popupSize.grownBy(padding());
    popupSize = popupSize.boundedTo(s->geometry().size());
    if (!popupSize.isEmpty()) {
        resize(popupSize);
    }
}

QQuickItem *ToolTipDialog::loadDefaultItem()
{
    if (!m_qmlObject) {
        m_qmlObject = new PlasmaQuick::SharedQmlEngine(this);
    }

    if (!m_qmlObject->rootObject()) {
        m_qmlObject->setSourceFromModule("org.kde.plasma.core", "DefaultToolTip");
    }

    return qobject_cast<QQuickItem *>(m_qmlObject->rootObject());
}

void ToolTipDialog::showEvent(QShowEvent *event)
{
    keepalive();

    PlasmaQuick::PopupPlasmaWindow::showEvent(event);
}

void ToolTipDialog::hideEvent(QHideEvent *event)
{
    m_hideTimer.stop();
    PlasmaQuick::PopupPlasmaWindow::hideEvent(event);
}

bool ToolTipDialog::event(QEvent *e)
{
    if (e->type() == QEvent::Enter) {
        if (m_interactive) {
            m_hideTimer.stop();
        }
    } else if (e->type() == QEvent::Leave) {
        dismiss();
    }

    return PopupPlasmaWindow::event(e);
}

QObject *ToolTipDialog::owner() const
{
    return m_owner;
}

void ToolTipDialog::setOwner(QObject *owner)
{
    m_owner = owner;
}

void ToolTipDialog::dismiss()
{
    m_hideTimer.start(200);
}

void ToolTipDialog::keepalive()
{
    if (m_hideTimeout > 0) {
        m_hideTimer.start(m_hideTimeout);
    } else {
        m_hideTimer.stop();
    }
}

bool ToolTipDialog::interactive()
{
    return m_interactive;
}

void ToolTipDialog::setInteractive(bool interactive)
{
    m_interactive = interactive;
}

void ToolTipDialog::valueChanged(const QVariant &value)
{
    setPosition(value.toPoint());
}

void ToolTipDialog::setHideTimeout(int timeout)
{
    m_hideTimeout = timeout;
}

int ToolTipDialog::hideTimeout() const
{
    return m_hideTimeout;
}

#include "moc_tooltipdialog.cpp"
