/*
    SPDX-FileCopyrightText: 2023 David Edmundson <davidedmundson@kde.org>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "popupplasmawindow.h"

#include <kwindoweffects.h>
#include <kwindowsystem.h>
#include <KConfigGroup>
#include <KSharedConfig>

#include "debug_p.h"
#include <QGuiApplication>
#include <QScreen>
#include <qnamespace.h>
#include <qtmetamacros.h>

#include "plasmashellwaylandintegration.h"
#include "transientplacementhint_p.h"
#include "utils.h"

namespace PlasmaQuick
{

class PopupPlasmaWindowPrivate
{
public:
    PopupPlasmaWindowPrivate(PopupPlasmaWindow *_q);

    void updateEffectivePopupDirection(const QRect &anchorRect, const QRect &relativePopupPosition);
    void updateSlideEffect(const QRect &globalPosition);
    void updatePosition();
    void updatePositionX11(const QPoint &position);
    void updatePositionWayland(const QPoint &position);
    void updateBorders(const QRect &globalPosition);
    void updateVisualParentWindow();

    PopupPlasmaWindow *q;
    QPointer<QQuickItem> m_visualParent;
    QPointer<QQuickWindow> m_visualParentWindow;
    PopupPlasmaWindow::RemoveBorders m_removeBorderStrategy = PopupPlasmaWindow::Never;
    bool m_needsReposition = false;
    bool m_floating = false;
    bool m_animated = false;
    int m_margin = 0;
    Qt::Edge m_popupDirection = Qt::TopEdge;
    Qt::Edge m_effectivePopupDirection = Qt::TopEdge;
    Qt::Edges m_nearbyBorders;
};

PopupPlasmaWindowPrivate::PopupPlasmaWindowPrivate(PopupPlasmaWindow *_q)
    : q(_q)
{
}

/*!
 * PopupPlasmaWindowPrivate::updateSlideEffect
 * @param anchorRect - the rect around where the popup should be placed relative to the parent window
 * @param relativePopupPosition - the final rect of the popup relative to the parent window
 *
 * This is based purely on position in prepartion for being called in a wayland configure event
 */
void PopupPlasmaWindowPrivate::updateEffectivePopupDirection(const QRect &anchorRect, const QRect &relativePopupPosition)
{
    Qt::Edge effectivePopupDirection = Qt::TopEdge;
    if (m_popupDirection == Qt::TopEdge || m_popupDirection == Qt::BottomEdge) {
        if (relativePopupPosition.center().y() >= anchorRect.center().y()) {
            effectivePopupDirection = Qt::BottomEdge;
        } else {
            effectivePopupDirection = Qt::TopEdge;
        }
    }
    if (m_popupDirection == Qt::LeftEdge || m_popupDirection == Qt::RightEdge) {
        if (relativePopupPosition.center().x() >= anchorRect.center().x()) {
            effectivePopupDirection = Qt::RightEdge;
        } else {
            effectivePopupDirection = Qt::LeftEdge;
        }
    }

    if (effectivePopupDirection != m_effectivePopupDirection) {
        Q_EMIT q->effectivePopupDirectionChanged();
        m_effectivePopupDirection = effectivePopupDirection;
    }
}

void PopupPlasmaWindowPrivate::updateSlideEffect(const QRect &globalPosition)
{
    KWindowEffects::SlideFromLocation slideLocation = KWindowEffects::NoEdge;

    int slideOffset = -1;
    QScreen *screen = QGuiApplication::screenAt(globalPosition.center());
    if (screen && m_margin > 0) {
        const QRect screenGeometry = screen->geometry();
        switch (m_effectivePopupDirection) {
        case Qt::TopEdge:
            slideOffset = screenGeometry.bottom() - globalPosition.bottom() - m_margin;
            break;
        case Qt::BottomEdge:
            slideOffset = globalPosition.top() - screenGeometry.top() - m_margin;
            break;
        case Qt::LeftEdge:
            slideOffset = screenGeometry.right() - globalPosition.right() - m_margin;
            break;
        case Qt::RightEdge:
            slideOffset = globalPosition.left() - screenGeometry.left() - m_margin;
            break;
        }
    }

    if (!m_animated) {
        KWindowEffects::slideWindow(q, slideLocation);
        return;
    }
    switch (m_effectivePopupDirection) {
    case Qt::TopEdge:
        slideLocation = KWindowEffects::BottomEdge;
        break;
    case Qt::BottomEdge:
        slideLocation = KWindowEffects::TopEdge;
        break;
    case Qt::LeftEdge:
        slideLocation = KWindowEffects::RightEdge;
        break;
    case Qt::RightEdge:
        slideLocation = KWindowEffects::LeftEdge;
        break;
    }
    KWindowEffects::slideWindow(q, slideLocation, slideOffset);
}

void PopupPlasmaWindowPrivate::updatePosition()
{
    m_needsReposition = false;

    if (!m_visualParent || !m_visualParent->window()) {
        qCWarning(LOG_PLASMAQUICK) << "Exposed with no visual parent. Window positioning broken.";
        return;
    }
    q->setTransientParent(m_visualParent->window());
    TransientPlacementHint placementHint;
    QRectF parentAnchorRect = QRectF(m_visualParent->mapToScene(QPointF(0, 0)), m_visualParent->size());
    if (!m_floating) {
        QRect windowVisibleRect = m_visualParent->window()->mask().boundingRect();
        // pad parentAnchorRect to the window it's in, so that the popup appears outside the panel
        // even if the tooltip area does not fill it
        if (m_popupDirection == Qt::TopEdge || m_popupDirection == Qt::BottomEdge) {
            parentAnchorRect.setTop(windowVisibleRect.top());
            // QRect::bottom() is off by one
            parentAnchorRect.setBottom(windowVisibleRect.bottom() + 1);
        }
        if (m_popupDirection == Qt::LeftEdge || m_popupDirection == Qt::RightEdge) {
            parentAnchorRect.setLeft(windowVisibleRect.left());
            // QRect::right() is off by one
            parentAnchorRect.setRight(windowVisibleRect.right() + 1);
        }
    }

    placementHint.setParentAnchorArea(parentAnchorRect.toRect());
    placementHint.setParentAnchor(m_popupDirection);
    placementHint.setPopupAnchor(PlasmaQuickPrivate::oppositeEdge(m_popupDirection));
    placementHint.setConstrainByAnchorWindow(true);
    placementHint.setFlipConstraintAdjustments(m_floating ? Qt::Vertical : Qt::Orientations());
    placementHint.setMargin(m_margin);

    QRect popupPosition = TransientPlacementHelper::popupRect(q, placementHint);

    QRect relativePopupPosition = popupPosition;
    if (m_visualParent->window()) {
        relativePopupPosition = relativePopupPosition.translated(-m_visualParent->window()->position());
    }
    updateEffectivePopupDirection(parentAnchorRect.toRect(), relativePopupPosition);
    updateSlideEffect(popupPosition);

    if(m_floating && q->backgroundHints() != PlasmaQuick::PlasmaWindow::StandardBackground && m_popupDirection == 0) {

        KConfigGroup mousecfg(KSharedConfig::openConfig(QStringLiteral("kcminputrc")), QStringLiteral("Mouse"));
        const int cursorSize  = mousecfg.readEntry(QStringLiteral("cursorSize"), 24);
        QPoint mousePos = QCursor::pos() + QPoint(0, cursorSize*0.75);

        QScreen *screen = QGuiApplication::screenAt(mousePos);
        if (screen) {
            const QRect screenGeometry = screen->geometry();
            int diffX = qMax(0, mousePos.x() + popupPosition.width() - (screenGeometry.x() + screenGeometry.width()));
            int diffY = qMax(0, mousePos.y() + popupPosition.height() - (screenGeometry.y() + screenGeometry.height()));
            mousePos -= QPoint(diffX, diffY);
            popupPosition = QRect(mousePos, popupPosition.size());
        }
    }

    if (KWindowSystem::isPlatformX11()) {
        updatePositionX11(popupPosition.topLeft());
    } else if (KWindowSystem::isPlatformWayland()) {
        updatePositionWayland(popupPosition.topLeft());
    }

    updateBorders(popupPosition);
}

void PopupPlasmaWindowPrivate::updatePositionX11(const QPoint &position)
{
    q->setPosition(position);
}

void PopupPlasmaWindowPrivate::updatePositionWayland(const QPoint &position)
{
    // still update's Qt internal reference as it's used by the next dialog
    // this can be dropped when we're using true semantic positioning in the backend
    q->setPosition(position);

    PlasmaShellWaylandIntegration::get(q)->setPosition(position);
}

void PopupPlasmaWindowPrivate::updateBorders(const QRect &globalPosition)
{
    // disables borders for the edges that are touching the screen edge

    QScreen *screen = QGuiApplication::screenAt(globalPosition.center());
    if (!screen) {
        return;
    }
    const QRect screenGeometry = screen->geometry();

    Qt::Edges enabledBorders = Qt::LeftEdge | Qt::RightEdge | Qt::TopEdge | Qt::BottomEdge;

    if (m_removeBorderStrategy & PopupPlasmaWindow::AtScreenEdges) {
        if (globalPosition.top() - m_margin <= screenGeometry.top()) {
            enabledBorders.setFlag(Qt::TopEdge, false);
        }
        if (globalPosition.bottom() + m_margin >= screenGeometry.bottom()) {
            enabledBorders.setFlag(Qt::BottomEdge, false);
        }
        if (globalPosition.left() - m_margin <= screenGeometry.left()) {
            enabledBorders.setFlag(Qt::LeftEdge, false);
        }
        if (globalPosition.right() + m_margin >= screenGeometry.right()) {
            enabledBorders.setFlag(Qt::RightEdge, false);
        }
    }
    if (m_removeBorderStrategy & PopupPlasmaWindow::AtPanelEdges) {
        switch (m_popupDirection) {
        case Qt::LeftEdge:
            enabledBorders.setFlag(Qt::RightEdge, false);
            break;
        case Qt::RightEdge:
            enabledBorders.setFlag(Qt::LeftEdge, false);
            break;
        case Qt::BottomEdge:
            enabledBorders.setFlag(Qt::TopEdge, false);
            break;
        case Qt::TopEdge:
        default:
            enabledBorders.setFlag(Qt::BottomEdge, false);
            break;
        }
    }

    Qt::Edges newNearbyBorders = ~enabledBorders;
    if (newNearbyBorders.testFlag(Qt::LeftEdge) && newNearbyBorders.testFlag(Qt::RightEdge)) {
        newNearbyBorders.setFlag(Qt::LeftEdge, false);
        newNearbyBorders.setFlag(Qt::RightEdge, false);
    }
    if (newNearbyBorders.testFlag(Qt::TopEdge) && newNearbyBorders.testFlag(Qt::BottomEdge)) {
        newNearbyBorders.setFlag(Qt::TopEdge, false);
        newNearbyBorders.setFlag(Qt::BottomEdge, false);
    }
    newNearbyBorders.setFlag(PlasmaQuickPrivate::oppositeEdge(m_effectivePopupDirection), true);

    if (newNearbyBorders != m_nearbyBorders) {
        m_nearbyBorders = newNearbyBorders;
        Q_EMIT q->nearbyBordersChanged();
    }

    if (m_margin) {
        q->setBorders(Qt::LeftEdge | Qt::RightEdge | Qt::TopEdge | Qt::BottomEdge);
        return;
    }

    q->setBorders(enabledBorders);
}

void PopupPlasmaWindowPrivate::updateVisualParentWindow()
{
    if (m_visualParentWindow) {
        QObject::disconnect(m_visualParentWindow, &QQuickWindow::yChanged, q, &PopupPlasmaWindow::queuePositionUpdate);
        QObject::disconnect(m_visualParentWindow, &QQuickWindow::xChanged, q, &PopupPlasmaWindow::queuePositionUpdate);
    }

    m_visualParentWindow = m_visualParent ? m_visualParent->window() : nullptr;

    if (m_visualParentWindow) {
        QObject::connect(m_visualParentWindow, &QQuickWindow::yChanged, q, &PopupPlasmaWindow::queuePositionUpdate);
        QObject::connect(m_visualParentWindow, &QQuickWindow::xChanged, q, &PopupPlasmaWindow::queuePositionUpdate);
    }
}

PopupPlasmaWindow::PopupPlasmaWindow(const QString &svgPrefix)
    : PlasmaWindow(svgPrefix)
    , d(new PopupPlasmaWindowPrivate(this))
{
}

PopupPlasmaWindow::~PopupPlasmaWindow()
{
}

void PopupPlasmaWindow::setVisualParent(QQuickItem *item)
{
    if (item == d->m_visualParent) {
        return;
    }

    if (d->m_visualParent) {
        disconnect(d->m_visualParent, SIGNAL(windowChanged(QQuickWindow *)), this, SLOT(updateVisualParentWindow()));
    }

    d->m_visualParent = item;
    d->updateVisualParentWindow();

    if (d->m_visualParent) {
        connect(d->m_visualParent, SIGNAL(windowChanged(QQuickWindow *)), this, SLOT(updateVisualParentWindow()));
    }

    Q_EMIT visualParentChanged();
    queuePositionUpdate();
}

QQuickItem *PopupPlasmaWindow::visualParent() const
{
    return d->m_visualParent;
}

Qt::Edge PopupPlasmaWindow::popupDirection() const
{
    return d->m_popupDirection;
}

void PopupPlasmaWindow::setPopupDirection(Qt::Edge popupDirection)
{
    if (popupDirection == d->m_popupDirection) {
        return;
    }
    d->m_popupDirection = popupDirection;

    if (isExposed()) {
        qCWarning(LOG_PLASMAQUICK) << "location should be set before showing popup window";
    }
    queuePositionUpdate();

    Q_EMIT popupDirectionChanged();
}

Qt::Edge PopupPlasmaWindow::effectivePopupDirection() const
{
    return d->m_effectivePopupDirection;
}

bool PopupPlasmaWindow::floating() const
{
    return d->m_floating;
}

void PopupPlasmaWindow::setFloating(bool floating)
{
    if (floating == d->m_floating) {
        return;
    }
    d->m_floating = floating;
    queuePositionUpdate();
    Q_EMIT floatingChanged();
}

bool PopupPlasmaWindow::animated() const
{
    return d->m_animated;
}

void PopupPlasmaWindow::setAnimated(bool animated)
{
    d->m_animated = animated;
    queuePositionUpdate();
    Q_EMIT animatedChanged();
}

PopupPlasmaWindow::RemoveBorders PopupPlasmaWindow::removeBorderStrategy() const
{
    return d->m_removeBorderStrategy;
}

void PopupPlasmaWindow::setRemoveBorderStrategy(PopupPlasmaWindow::RemoveBorders strategy)
{
    if (d->m_removeBorderStrategy == strategy) {
        return;
    }

    d->m_removeBorderStrategy = strategy;
    queuePositionUpdate(); // This will update borders as well
    Q_EMIT removeBorderStrategyChanged();
}

int PopupPlasmaWindow::margin() const
{
    return d->m_margin;
}

Qt::Edges PopupPlasmaWindow::nearbyBorders() const
{
    return d->m_nearbyBorders;
}

void PopupPlasmaWindow::setMargin(int margin)
{
    if (d->m_margin == margin) {
        return;
    }

    d->m_margin = margin;
    // Margin is used to animate applets when the panel switches
    // from floating to not floating, so we immediately update the
    // position instead of using queuePositionUpdate, which would
    // only run at the end of the animation.
    queuePositionUpdate();
    update();
    Q_EMIT marginChanged();
}

bool PopupPlasmaWindow::event(QEvent *event)
{
    switch (event->type()) {
    case QEvent::UpdateRequest:
        if (d->m_needsReposition) {
            d->updatePosition();
        }
        break;
    case QEvent::Show:
        d->updatePosition();
        break;
    case QEvent::Resize:
        d->updatePosition();
        break;
    default:
        break;
    }
    return PlasmaQuick::PlasmaWindow::event(event);
}

void PopupPlasmaWindow::queuePositionUpdate()
{
    d->m_needsReposition = true;
}
}

#include "moc_popupplasmawindow.cpp"
