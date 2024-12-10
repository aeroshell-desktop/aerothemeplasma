/*
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 * SPDX-FileCopyrightText: 2018 Vlad Zahorodnii <vlad.zahorodnii@kde.org>
 * SPDX-FileCopyrightText: 2021 Paul McAuley <kde@paulmcauley.com>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "breezedecoration.h"

#include "breezesettingsprovider.h"

#include "breezebutton.h"

#include "breezeboxshadowrenderer.h"

#include <KDecoration2/DecorationButtonGroup>
#include <KDecoration2/DecorationShadow>

#include <KColorUtils>
#include <KConfigGroup>
#include <KPluginFactory>
#include <KSharedConfig>

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QPainter>
#include <QPainterPath>
#include <QTextStream>
#include <QTimer>

#include "smod/smod.h"

K_PLUGIN_FACTORY_WITH_JSON(BreezeDecoFactory, "smod.json", registerPlugin<Breeze::Decoration>(); registerPlugin<Breeze::Button>();)


namespace Breeze
{
using KDecoration2::ColorGroup;
using KDecoration2::ColorRole;

static SizingMargins g_sizingmargins;
static QString g_themeName = "Aero";
//________________________________________________________________
static int g_shadowStrength = 255;
static QColor g_shadowColor = Qt::black;
static int g_lastBorderSize;

//________________________________________________________________


//________________________________________________________________
void Decoration::setOpacity(qreal value)
{
    if (m_opacity == value) {
        return;
    }
    m_opacity = value;
    update();
}
QString Decoration::themeName()
{
    return SMOD::currentlyRegisteredPath;
}
QPixmap Decoration::minimize_glow()
{
    return QPixmap(QStringLiteral(":/effects/smodglow/textures/minimize"));
}
QPixmap Decoration::maximize_glow()
{
    return QPixmap(QStringLiteral(":/effects/smodglow/textures/maximize"));
}
QPixmap Decoration::close_glow()
{
    return QPixmap(QStringLiteral(":/effects/smodglow/textures/close"));
}
bool Decoration::glowEnabled()
{
    if(g_sizingmargins.loaded())
        return g_sizingmargins.commonSizing().enable_glow;
    else return false;
}


//________________________________________________________________
QColor Decoration::titleBarColor() const
{
    return QColor(Qt::transparent);

    const auto c = client();
    if (hideTitleBar()) {
        return c->color(ColorGroup::Inactive, ColorRole::TitleBar);
    } else if (m_animation->state() == QAbstractAnimation::Running) {
        return KColorUtils::mix(c->color(ColorGroup::Inactive, ColorRole::TitleBar), c->color(ColorGroup::Active, ColorRole::TitleBar), m_opacity);
    } else {
        return c->color(c->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::TitleBar);
    }
}

//________________________________________________________________
QColor Decoration::fontColor() const
{
    const auto c = client();
    if (m_animation->state() == QAbstractAnimation::Running) {
        return KColorUtils::mix(c->color(ColorGroup::Inactive, ColorRole::Foreground), c->color(ColorGroup::Active, ColorRole::Foreground), m_opacity);
    } else {
        return c->color(c->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::Foreground);
    }
}

//________________________________________________________________
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
bool Decoration::init()
#else
void Decoration::init()
#endif
{

    reconfigure();
    SMOD::registerResource(m_internalSettings->decorationTheme());

    g_sizingmargins.loadSizingMargins();
    const auto c = client();
    // active state change animation
    // It is important start and end value are of the same type, hence 0.0 and not just 0
    m_animation->setStartValue(0.0);
    m_animation->setEndValue(1.0);
    // Linear to have the same easing as Breeze animations
    m_animation->setEasingCurve(QEasingCurve::Linear);
    connect(m_animation, &QVariantAnimation::valueChanged, this, [this](const QVariant &value) {
        setOpacity(value.toReal());
    });

    m_shadowAnimation->setStartValue(0.0);
    m_shadowAnimation->setEndValue(1.0);
    m_shadowAnimation->setEasingCurve(QEasingCurve::OutCubic);
    connect(m_shadowAnimation, &QVariantAnimation::valueChanged, this, [this](const QVariant &value) {
        m_shadowOpacity = value.toReal();
        updateShadow();
    });

    // use DBus connection to update on breeze configuration change
    auto dbus = QDBusConnection::sessionBus();
    dbus.connect(QString(),
                 QStringLiteral("/KGlobalSettings"),
                 QStringLiteral("org.kde.KGlobalSettings"),
                 QStringLiteral("notifyChange"),
                 this,
                 SLOT(reconfigure()));

    dbus.connect(QStringLiteral("org.kde.KWin"),
                 QStringLiteral("/org/kde/KWin"),
                 QStringLiteral("org.kde.KWin.TabletModeManager"),
                 QStringLiteral("tabletModeChanged"),
                 QStringLiteral("b"),
                 this,
                 SLOT(onTabletModeChanged(bool)));

    auto message = QDBusMessage::createMethodCall(QStringLiteral("org.kde.KWin"),
                                                  QStringLiteral("/org/kde/KWin"),
                                                  QStringLiteral("org.freedesktop.DBus.Properties"),
                                                  QStringLiteral("Get"));
    message.setArguments({QStringLiteral("org.kde.KWin.TabletModeManager"), QStringLiteral("tabletMode")});
    auto call = new QDBusPendingCallWatcher(dbus.asyncCall(message), this);
    connect(call, &QDBusPendingCallWatcher::finished, this, [this, call]() {
        QDBusPendingReply<QVariant> reply = *call;
        if (!reply.isError()) {
            onTabletModeChanged(reply.value().toBool());
        }

        call->deleteLater();
    });

    updateTitleBar();
    auto s = settings();
    connect(s.get(), &KDecoration2::DecorationSettings::borderSizeChanged, this, &Decoration::recalculateBorders);

    // a change in font might cause the borders to change
    connect(s.get(), &KDecoration2::DecorationSettings::fontChanged, this, &Decoration::recalculateBorders);
    connect(s.get(), &KDecoration2::DecorationSettings::spacingChanged, this, &Decoration::recalculateBorders);

    // buttons
    connect(s.get(), &KDecoration2::DecorationSettings::spacingChanged, this, &Decoration::updateButtonsGeometryDelayed);
    connect(s.get(), &KDecoration2::DecorationSettings::decorationButtonsLeftChanged, this, &Decoration::updateButtonsGeometryDelayed);
    connect(s.get(), &KDecoration2::DecorationSettings::decorationButtonsRightChanged, this, &Decoration::updateButtonsGeometryDelayed);

    // full reconfiguration
    connect(s.get(), &KDecoration2::DecorationSettings::reconfigured, this, &Decoration::reconfigure);
    connect(s.get(), &KDecoration2::DecorationSettings::reconfigured, SettingsProvider::self(), &SettingsProvider::reconfigure, Qt::UniqueConnection);
    connect(s.get(), &KDecoration2::DecorationSettings::reconfigured, this, &Decoration::updateButtonsGeometryDelayed);

    connect(c, &KDecoration2::DecoratedClient::adjacentScreenEdgesChanged, this, &Decoration::recalculateBorders);
    connect(c, &KDecoration2::DecoratedClient::maximizedHorizontallyChanged, this, &Decoration::recalculateBorders);
    connect(c, &KDecoration2::DecoratedClient::maximizedVerticallyChanged, this, &Decoration::recalculateBorders);
    connect(c, &KDecoration2::DecoratedClient::shadedChanged, this, &Decoration::recalculateBorders);
    connect(c, &KDecoration2::DecoratedClient::captionChanged, this, [this]() {
        // update the caption area
        update(titleBar());
    });

    connect(c, &KDecoration2::DecoratedClient::activeChanged, this, &Decoration::updateAnimationState);
    connect(c, &KDecoration2::DecoratedClient::widthChanged, this, &Decoration::updateTitleBar);
    connect(c, &KDecoration2::DecoratedClient::maximizedChanged, this, &Decoration::updateTitleBar);
    //connect(c, &KDecoration2::DecoratedClient::maximizedChanged, this, &Decoration::setOpaque);

    connect(c, &KDecoration2::DecoratedClient::widthChanged, this, &Decoration::updateButtonsGeometry);
    connect(c, &KDecoration2::DecoratedClient::maximizedChanged, this, &Decoration::updateButtonsGeometry);
    connect(c, &KDecoration2::DecoratedClient::adjacentScreenEdgesChanged, this, &Decoration::updateButtonsGeometry);
    connect(c, &KDecoration2::DecoratedClient::shadedChanged, this, &Decoration::updateButtonsGeometry);

    connect(c, &KDecoration2::DecoratedClient::widthChanged, this, &Decoration::updateBlur);
    connect(c, &KDecoration2::DecoratedClient::heightChanged, this, &Decoration::updateBlur);
    connect(c, &KDecoration2::DecoratedClient::maximizedChanged, this, &Decoration::updateBlur);
    connect(c, &KDecoration2::DecoratedClient::shadedChanged, this, &Decoration::updateBlur);

    createButtons();
    updateShadow();
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    return true;
#endif
}

//________________________________________________________________
void Decoration::updateTitleBar()
{
    // The titlebar rect has margins around it so the window can be resized by dragging a decoration edge.
    auto s = settings();
    const auto c = client();
    const bool maximized = isMaximized();
    const int width = maximized ? c->width() : c->width() - 2 * s->smallSpacing() * Metrics::TitleBar_SideMargin;
    const int height = maximized ? borderTop() : borderTop() - s->smallSpacing() * Metrics::TitleBar_TopMargin;
    const int x = maximized ? 0 : s->smallSpacing() * Metrics::TitleBar_SideMargin;
    const int y = maximized ? 0 : s->smallSpacing() * Metrics::TitleBar_TopMargin;
    setTitleBar(QRect(x, y, width, height));
}

//________________________________________________________________
void Decoration::updateAnimationState()
{
    if (m_shadowAnimation->duration() > 0) {
        const auto c = client();
        m_shadowAnimation->setDirection(c->isActive() ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
        m_shadowAnimation->setEasingCurve(c->isActive() ? QEasingCurve::OutCubic : QEasingCurve::InCubic);
        if (m_shadowAnimation->state() != QAbstractAnimation::Running) {
            m_shadowAnimation->start();
        }

    } else {
        updateShadow();
    }

    if (m_animation->duration() > 0) {
        const auto c = client();
        m_animation->setDirection(c->isActive() ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
        if (m_animation->state() != QAbstractAnimation::Running) {
            m_animation->start();
        }

    } else {
        update();
    }
}

//________________________________________________________________
int Decoration::borderSize(bool bottom) const
{
    const int baseSize = settings()->smallSpacing();
    if (m_internalSettings && (m_internalSettings->mask() & BorderSize)) {
        switch (m_internalSettings->borderSize()) {
        case InternalSettings::BorderNone:
            return outlinesEnabled() ? 1 : 0;
        case InternalSettings::BorderNoSides:
            return bottom ? qMax(4, baseSize) : outlinesEnabled() ? 1 : 0;
        default:
        case InternalSettings::BorderTiny:
            return bottom ? qMax(4, baseSize) : baseSize;
        case InternalSettings::BorderNormal:
            return baseSize * 2;
        case InternalSettings::BorderLarge:
            return baseSize * 3;
        case InternalSettings::BorderVeryLarge:
            return baseSize * 4;
        case InternalSettings::BorderHuge:
            return baseSize * 5;
        case InternalSettings::BorderVeryHuge:
            return baseSize * 6;
        case InternalSettings::BorderOversized:
            return baseSize * 10;
        }

    } else {
        switch (settings()->borderSize()) {
        case KDecoration2::BorderSize::None:
            return outlinesEnabled() ? 1 : 0;
        case KDecoration2::BorderSize::NoSides:
            return bottom ? qMax(4, baseSize) : outlinesEnabled() ? 1 : 0;
        default:
        case KDecoration2::BorderSize::Tiny:
            return bottom ? qMax(4, baseSize) : baseSize;
        case KDecoration2::BorderSize::Normal:
            return baseSize * 4;
        case KDecoration2::BorderSize::Large:
            return baseSize * 3;
        case KDecoration2::BorderSize::VeryLarge:
            return baseSize * 4;
        case KDecoration2::BorderSize::Huge:
            return baseSize * 5;
        case KDecoration2::BorderSize::VeryHuge:
            return baseSize * 6;
        case KDecoration2::BorderSize::Oversized:
            return baseSize * 10;
        }
    }
}

//________________________________________________________________
void Decoration::reconfigure()
{

    m_internalSettings = SettingsProvider::self()->internalSettings(this);


    SMOD::registerResource(m_internalSettings->decorationTheme());
    g_sizingmargins.loadSizingMargins();
    setScaledCornerRadius();

    // animation

    KSharedConfig::Ptr config = KSharedConfig::openConfig();
    const KConfigGroup cg(config, QStringLiteral("KDE"));

    m_animation->setDuration(0);
    // Syncing anis between client and decoration is troublesome, so we're not using
    // any animations right now.
    // m_animation->setDuration( cg.readEntry("AnimationDurationFactor", 1.0f) * 100.0f );

    // But the shadow is fine to animate like this!
    m_shadowAnimation->setDuration(cg.readEntry("AnimationDurationFactor", 1.0f) * 100.0f);

    // borders
    recalculateBorders();

    // shadow
    updateShadow();

    updateButtonsGeometryDelayed();
    update();


}

//________________________________________________________________
void Decoration::recalculateBorders()
{
    const auto c = client();
    auto s = settings();
    //auto d = qobject_cast<Decoration *>(decoration());


    // left, right and bottom borders
    int left = isMaximized() ? 0 : borderSize();
    int right = isMaximized() ? 0 : borderSize();
    int bottom = (c->isShaded() || isMaximized()) ? 0 : borderSize(true);

    int top = 0;
    if (hideTitleBar()) {
        top = bottom;
    } else {
        QFontMetrics fm(s->font());
        top += qMax(fm.height(), buttonHeight());

        // padding below
        const int baseSize = s->smallSpacing();
        top += baseSize * Metrics::TitleBar_BottomMargin;

        // padding above
        top += baseSize * Metrics::TitleBar_TopMargin;
    }

    top = isMaximized() ? titlebarHeight()+1 : titlebarHeight()+9;

    /*if (hideInnerBorder())
    {
        left = left < INNER_BORDER_SIZE ? 0 : left - INNER_BORDER_SIZE;
        right = right < INNER_BORDER_SIZE ? 0 : right - INNER_BORDER_SIZE;
        top = top < INNER_BORDER_SIZE ? 0 : top - INNER_BORDER_SIZE;
        bottom = bottom < INNER_BORDER_SIZE ? 0 : bottom - INNER_BORDER_SIZE;
    }*/

    left   = qMax(0, left);
    right  = qMax(0, right);
    top    = qMax(0, top);
    bottom = qMax(0, bottom);

    setBorders(QMargins(left, top, right, bottom));

    // extended sizes
    const int extSize = s->largeSpacing();
    int extSides = 0;
    int extBottom = 0;
    if (hasNoBorders()) {
        if (!isMaximizedHorizontally()) {
            extSides = extSize;
        }
        if (!isMaximizedVertically()) {
            extBottom = extSize;
        }

    } else if (hasNoSideBorders() && !isMaximizedHorizontally()) {
        extSides = extSize;
    }

    setResizeOnlyBorders(QMargins(extSides, 0, extSides, extBottom));

    // TODO is this needed?
    updateBlur();
}

//________________________________________________________________
void Decoration::createButtons()
{
    m_leftButtons = new KDecoration2::DecorationButtonGroup(KDecoration2::DecorationButtonGroup::Position::Left, this, &Button::create);
    m_rightButtons = new KDecoration2::DecorationButtonGroup(KDecoration2::DecorationButtonGroup::Position::Right, this, &Button::create);
    updateButtonsGeometry();
}

//________________________________________________________________
void Decoration::updateButtonsGeometryDelayed()
{
    QTimer::singleShot(0, this, &Decoration::updateButtonsGeometry);
}

//________________________________________________________________
void Decoration::updateButtonsGeometry()
{
    const auto s = settings();

    // left buttons
    if (!m_leftButtons->buttons().isEmpty()) {
        const int vPadding = isMaximized() ? 0 : s->smallSpacing() * Metrics::TitleBar_TopMargin;
        const int hPadding = 0; //s->smallSpacing() * Metrics::TitleBar_SideMargin;
        m_leftButtons->setPos(QPointF(hPadding + borderLeft(), vPadding));
    }

    if (!m_rightButtons->buttons().isEmpty()) {
        const int vPadding = isMaximized() ? -1 : 1;
        const int lessPadding = g_sizingmargins.frameRightSizing().inner_inset;
        m_rightButtons->setPos(QPointF(
            size().width() - m_rightButtons->geometry().width() - borderRight() - (isMaximized() ? 2 : 0) + lessPadding, vPadding));

        m_rightButtons->setSpacing(g_sizingmargins.commonSizing().caption_button_spacing);
    }
    foreach (QPointer<KDecoration2::DecorationButton> button, m_rightButtons->buttons()) {
        static_cast<Button *>(button.data())->updateGeometry();
    }

    if(g_sizingmargins.commonSizing().caption_button_align_vcenter)
    {
        auto p = m_rightButtons->pos();
        m_rightButtons->setPos(QPointF(p.x(), borderTop() / 2.0f - m_rightButtons->geometry().height() / 2.0f));
    }
    update();

    return;
}

//________________________________________________________________
void Decoration::paint(QPainter *painter, const QRect &repaintRegion)
{
    smodPaint(painter, repaintRegion);
    return;
}

//________________________________________________________________
void Decoration::paintTitleBar(QPainter *painter, const QRect &repaintRegion)
{
    const auto c = client();
    const QRect frontRect(QPoint(0, 0), QSize(size().width(), borderTop()));
    const QRect backRect(QPoint(0, 0), QSize(size().width(), borderTop()));

    QBrush frontBrush;
    QBrush backBrush(this->titleBarColor());

    if (!backRect.intersects(repaintRegion)) {
        return;
    }

    painter->save();
    painter->setPen(Qt::NoPen);

    // render a linear gradient on title area
    if (c->isActive() && m_internalSettings->drawBackgroundGradient()) {
        QLinearGradient gradient(0, 0, 0, frontRect.height());
        gradient.setColorAt(0.0, titleBarColor().lighter(120));
        gradient.setColorAt(0.8, titleBarColor());

        frontBrush = gradient;

    } else {
        frontBrush = titleBarColor();

        painter->setBrush(titleBarColor());
    }

    auto s = settings();
    if (isMaximized() || !s->isAlphaChannelSupported()) {
        painter->setBrush(backBrush);
        painter->drawRect(backRect);

        painter->setBrush(frontBrush);
        painter->drawRect(frontRect);

    } else if (c->isShaded()) {
        painter->setBrush(backBrush);
        painter->drawRoundedRect(backRect, m_scaledCornerRadius, m_scaledCornerRadius);

        painter->setBrush(frontBrush);
        painter->drawRoundedRect(frontRect, m_scaledCornerRadius, m_scaledCornerRadius);

    } else {
        painter->setClipRect(backRect, Qt::IntersectClip);

        auto drawThe = [=](const QRect &r) {
            // the rect is made a little bit larger to be able to clip away the rounded corners at the bottom and sides
            painter->drawRoundedRect(r.adjusted(isLeftEdge() ? -m_scaledCornerRadius : 0,
                                                isTopEdge() ? -m_scaledCornerRadius : 0,
                                                isRightEdge() ? m_scaledCornerRadius : 0,
                                                m_scaledCornerRadius),
                                     m_scaledCornerRadius,
                                     m_scaledCornerRadius);
        };

        painter->setBrush(backBrush);
        drawThe(backRect);

        painter->setBrush(frontBrush);
        drawThe(frontRect);
    }

    painter->restore();

    // draw caption
    painter->setFont(s->font());
    painter->setPen(fontColor());
    const auto cR = captionRect();
    const QString caption = painter->fontMetrics().elidedText(c->caption(), Qt::ElideMiddle, cR.first.width());
    painter->drawText(cR.first, cR.second | Qt::TextSingleLine, caption);

    // draw all buttons
    m_leftButtons->paint(painter, repaintRegion);
    m_rightButtons->paint(painter, repaintRegion);

    /*foreach (QPointer<KDecoration2::DecorationButton> button, m_rightButtons->buttons()) {
        static_cast<Button *>(button.data())->smodPaintGlow(painter, repaintRegion);
    }*/
}
SizingMargins Decoration::sizingMargins() const
{
    return g_sizingmargins;
}


QRect Decoration::buttonRect(KDecoration2::DecorationButtonType button) const
{

    int height = titlebarHeight()-1;
    int intendedWidth = g_sizingmargins.maximizeSizing().width;
    int width = 0;
    switch (button)
    {
        case KDecoration2::DecorationButtonType::Minimize:
            intendedWidth = g_sizingmargins.minimizeSizing().width;
            break;
        case KDecoration2::DecorationButtonType::Maximize:
            intendedWidth = g_sizingmargins.maximizeSizing().width;
            break;
        case KDecoration2::DecorationButtonType::Close:
            intendedWidth = g_sizingmargins.closeSizing().width;
            break;
        case KDecoration2::DecorationButtonType::Menu:
            height = titlebarHeight();
            break;
        default:
            break;
    }
    if(button == KDecoration2::DecorationButtonType::Menu) width = 16;
    else width = (int)((float)titlebarHeight() * ((float)intendedWidth / 21.0) + 0.5f);
    return QRect(0, 0, width, height);
}
int Decoration::titlebarHeight() const
{
    return internalSettings()->titlebarSize();
}
//________________________________________________________________
int Decoration::buttonHeight() const
{
    const int baseSize = m_tabletMode ? settings()->gridUnit() * 2 : settings()->gridUnit();
    switch (m_internalSettings->buttonSize()) {
    case InternalSettings::ButtonTiny:
        return baseSize;
    case InternalSettings::ButtonSmall:
        return baseSize * 1.5;
    default:
    case InternalSettings::ButtonDefault:
        return baseSize * 2;
    case InternalSettings::ButtonLarge:
        return baseSize * 2.5;
    case InternalSettings::ButtonVeryLarge:
        return baseSize * 3.5;
    }
}

void Decoration::onTabletModeChanged(bool mode)
{
    m_tabletMode = mode;
    recalculateBorders();
    updateButtonsGeometry();
}

//________________________________________________________________
int Decoration::captionHeight() const
{
    return hideTitleBar() ? borderTop() : borderTop() - settings()->smallSpacing() * (Metrics::TitleBar_BottomMargin + Metrics::TitleBar_TopMargin) - 1;
}

//________________________________________________________________
QPair<QRect, Qt::Alignment> Decoration::captionRect() const
{
    if (hideTitleBar()) {
        return qMakePair(QRect(), Qt::AlignCenter);
    } else {
        auto c = client();
        const int leftOffset = m_leftButtons->buttons().isEmpty()
            ? Metrics::TitleBar_SideMargin * settings()->smallSpacing()
            : m_leftButtons->geometry().x() + m_leftButtons->geometry().width() + Metrics::TitleBar_SideMargin * settings()->smallSpacing();

        const int rightOffset = m_rightButtons->buttons().isEmpty()
            ? Metrics::TitleBar_SideMargin * settings()->smallSpacing()
            : size().width() - m_rightButtons->geometry().x() + Metrics::TitleBar_SideMargin * settings()->smallSpacing();

        const int yOffset = settings()->smallSpacing() * Metrics::TitleBar_TopMargin;
        const QRect maxRect(leftOffset, yOffset, size().width() - leftOffset - rightOffset, captionHeight());

        switch (m_internalSettings->titleAlignment()) {
        case InternalSettings::AlignLeft:
            return qMakePair(maxRect, Qt::AlignVCenter | Qt::AlignLeft);

        case InternalSettings::AlignRight:
            return qMakePair(maxRect, Qt::AlignVCenter | Qt::AlignRight);

        case InternalSettings::AlignCenter:
            return qMakePair(maxRect, Qt::AlignCenter);

        default:
        case InternalSettings::AlignCenterFullWidth: {
            // full caption rect
            const QRect fullRect = QRect(0, yOffset, size().width(), captionHeight());
            QRect boundingRect(settings()->fontMetrics().boundingRect(c->caption()).toRect());

            // text bounding rect
            boundingRect.setTop(yOffset);
            boundingRect.setHeight(captionHeight());
            boundingRect.moveLeft((size().width() - boundingRect.width()) / 2);

            if (boundingRect.left() < leftOffset) {
                return qMakePair(maxRect, Qt::AlignVCenter | Qt::AlignLeft);
            } else if (boundingRect.right() > size().width() - rightOffset) {
                return qMakePair(maxRect, Qt::AlignVCenter | Qt::AlignRight);
            } else {
                return qMakePair(fullRect, Qt::AlignCenter);
            }
        }
        }
    }
}

void Decoration::setScaledCornerRadius()
{
    m_scaledCornerRadius = Metrics::Frame_FrameRadius * settings()->smallSpacing();
}
} // namespace

#include "breezedecoration.moc"
