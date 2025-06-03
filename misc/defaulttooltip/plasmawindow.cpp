/*
    SPDX-FileCopyrightText: 2023 David Edmundson <davidedmundson@kde.org>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "plasmawindow.h"

#include "dialogbackground_p.h"
#include "dialogshadows_p.h"

#include <QMarginsF>
#include <QQuickItem>

#include <KWindowEffects>
#include <KWindowSystem>
#include <KX11Extras>

#include <Plasma/Theme>

using namespace Plasma;

namespace PlasmaQuick
{
class PlasmaWindowPrivate
{
public:
    PlasmaWindowPrivate(PlasmaWindow *_q)
        : q(_q)
    {
    }
    void handleFrameChanged();
    void updateMainItemGeometry();
    PlasmaWindow *q;
    DialogShadows *shadows;
    // Keep a theme instance as a memeber to create one as soon as possible,
    // as Theme creation will set KSvg to correctly fetch images form the Plasma Theme.
    // This makes sure elements are correct, both in the dialog surface and the shadows.
    Plasma::Theme theme;
    QPointer<QQuickItem> mainItem;
    DialogBackground *dialogBackground;
    PlasmaWindow::BackgroundHints backgroundHints = PlasmaWindow::StandardBackground;
    QString svgPrefix;
};

PlasmaWindow::PlasmaWindow(const QString &svgPrefix)
    : QQuickWindow()
    , d(new PlasmaWindowPrivate(this))
{
    setColor(QColor(Qt::transparent));
    setFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
    d->svgPrefix = svgPrefix;
    d->shadows = DialogShadows::instance(svgPrefix);
    d->dialogBackground = new DialogBackground(contentItem());
    d->dialogBackground->setImagePath(svgPrefix);
    connect(d->dialogBackground, &DialogBackground::fixedMarginsChanged, this, [this]() {
        d->updateMainItemGeometry();
        Q_EMIT paddingChanged();
    });
    connect(d->dialogBackground, &DialogBackground::maskChanged, this, [this]() {
        d->handleFrameChanged();
    });

    d->shadows->addWindow(this, d->dialogBackground->enabledBorders());
}

PlasmaWindow::~PlasmaWindow()
{
}

void PlasmaWindow::setMainItem(QQuickItem *mainItem)
{
    if (d->mainItem == mainItem)
        return;

    if (d->mainItem) {
        d->mainItem->setParentItem(nullptr);
    }

    d->mainItem = mainItem;
    Q_EMIT mainItemChanged();

    if (d->mainItem) {
        mainItem->setParentItem(contentItem());
        d->updateMainItemGeometry();
    }
}

QQuickItem *PlasmaWindow::mainItem() const
{
    return d->mainItem;
}

static KSvg::FrameSvg::EnabledBorders edgeToBorder(Qt::Edges edges)
{
    KSvg::FrameSvg::EnabledBorders borders = KSvg::FrameSvg::EnabledBorders(0);

    if (edges & Qt::Edge::TopEdge) {
        borders |= KSvg::FrameSvg::EnabledBorder::TopBorder;
    }
    if (edges & Qt::Edge::BottomEdge) {
        borders |= KSvg::FrameSvg::EnabledBorder::BottomBorder;
    }
    if (edges & Qt::Edge::LeftEdge) {
        borders |= KSvg::FrameSvg::EnabledBorder::LeftBorder;
    }
    if (edges & Qt::Edge::RightEdge) {
        borders |= KSvg::FrameSvg::EnabledBorder::RightBorder;
    }

    return borders;
}

static Qt::Edges bordersToEdge(KSvg::FrameSvg::EnabledBorders borders)
{
    Qt::Edges edges;
    if (borders & KSvg::FrameSvg::EnabledBorder::TopBorder) {
        edges |= Qt::Edge::TopEdge;
    }
    if (borders & KSvg::FrameSvg::EnabledBorder::BottomBorder) {
        edges |= Qt::Edge::BottomEdge;
    }
    if (borders & KSvg::FrameSvg::EnabledBorder::LeftBorder) {
        edges |= Qt::Edge::LeftEdge;
    }
    if (borders & KSvg::FrameSvg::EnabledBorder::RightBorder) {
        edges |= Qt::Edge::RightEdge;
    }
    return edges;
}

void PlasmaWindow::setBorders(Qt::Edges bordersToShow)
{
    d->dialogBackground->setEnabledBorders(edgeToBorder(bordersToShow));
    d->shadows->setEnabledBorders(this, d->dialogBackground->enabledBorders());
    Q_EMIT bordersChanged();
}

Qt::Edges PlasmaWindow::borders()
{
    return bordersToEdge(d->dialogBackground->enabledBorders());
}

void PlasmaWindow::showEvent(QShowEvent *e)
{
    // EWMH states that the state is reset every hide
    // Qt supports external factors setting state before the next show
    if (KWindowSystem::isPlatformX11()) {
        KX11Extras::setState(winId(), NET::SkipTaskbar | NET::SkipPager | NET::SkipSwitcher);
    }
    QQuickWindow::showEvent(e);
}

void PlasmaWindow::resizeEvent(QResizeEvent *e)
{
    QQuickWindow::resizeEvent(e);
    const QSize windowSize = e->size();
    d->dialogBackground->setSize(windowSize);
    if (d->mainItem) {
        const QSize contentSize = windowSize.shrunkBy(padding());
        d->mainItem->setSize(contentSize);
    }
}

void PlasmaWindowPrivate::handleFrameChanged()
{
    const QRegion mask = dialogBackground->mask();
    KWindowEffects::enableBlurBehind(q, theme.blurBehindEnabled(), mask);
    KWindowEffects::enableBackgroundContrast(q,
                                             theme.backgroundContrastEnabled(),
                                             theme.backgroundContrast(),
                                             theme.backgroundIntensity(),
                                             theme.backgroundSaturation(),
                                             mask);

    if (!KWindowSystem::isPlatformX11() || KX11Extras::compositingActive()) {
        q->setMask(QRegion());
    } else {
        q->setMask(mask);
    }
}

void PlasmaWindowPrivate::updateMainItemGeometry()
{
    if (!mainItem) {
        return;
    }
    const QMargins frameMargins = q->padding();
    const QSize windowSize = q->size();

    mainItem->setX(frameMargins.left());
    mainItem->setY(frameMargins.top());

    const QSize contentSize = windowSize.shrunkBy(frameMargins);
    mainItem->setSize(contentSize);
}

QMargins PlasmaWindow::padding() const
{
    return QMargins(d->dialogBackground->leftMargin(),
                    d->dialogBackground->topMargin(),
                    d->dialogBackground->rightMargin(),
                    d->dialogBackground->bottomMargin());
}

PlasmaWindow::BackgroundHints PlasmaWindow::backgroundHints() const
{
    return d->backgroundHints;
}

void PlasmaWindow::setBackgroundHints(BackgroundHints hints)
{
    if (d->backgroundHints == hints) {
        return;
    }
    d->backgroundHints = hints;

    auto prefix = QStringLiteral("");
    if (d->backgroundHints == PlasmaWindow::SolidBackground) {
        prefix = QStringLiteral("solid/");
    }
    d->dialogBackground->setImagePath(prefix + d->svgPrefix);
    d->shadows->removeWindow(this);
    d->shadows = DialogShadows::instance(prefix + d->svgPrefix);
    d->shadows->addWindow(this, d->dialogBackground->enabledBorders());

    Q_EMIT backgroundHintsChanged();
}

qreal PlasmaWindow::topPadding() const
{
    return d->dialogBackground->topMargin();
}

qreal PlasmaWindow::bottomPadding() const
{
    return d->dialogBackground->bottomMargin();
}

qreal PlasmaWindow::leftPadding() const
{
    return d->dialogBackground->leftMargin();
}

qreal PlasmaWindow::rightPadding() const
{
    return d->dialogBackground->rightMargin();
}
}

#include "moc_plasmawindow.cpp"
