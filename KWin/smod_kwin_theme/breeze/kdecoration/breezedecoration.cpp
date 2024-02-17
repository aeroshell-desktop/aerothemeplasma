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
#include "config/breezeconfigwidget.h"

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
#include <QDir>
#include <QPainter>
#include <QPainterPath>
#include <QResource>
#include <QTextStream>
#include <QTimer>

#include <cmath>

#include "smod/qgraphicsgloweffect.h"

#define INNER_BORDER_SIZE 2

K_PLUGIN_FACTORY_WITH_JSON(BreezeDecoFactory, "smod.json", registerPlugin<Breeze::Decoration>(); registerPlugin<Breeze::Button>();
                           registerPlugin<Breeze::ConfigWidget>();)

namespace
{
struct ShadowParams {
    ShadowParams()
        : offset(QPoint(0, 0))
        , radius(0)
        , opacity(0)
    {
    }

    ShadowParams(const QPoint &offset, int radius, qreal opacity)
        : offset(offset)
        , radius(radius)
        , opacity(opacity)
    {
    }

    QPoint offset;
    int radius;
    qreal opacity;
};

struct CompositeShadowParams {
    CompositeShadowParams() = default;

    CompositeShadowParams(const QPoint &offset, const ShadowParams &shadow1, const ShadowParams &shadow2)
        : offset(offset)
        , shadow1(shadow1)
        , shadow2(shadow2)
    {
    }

    bool isNone() const
    {
        return qMax(shadow1.radius, shadow2.radius) == 0;
    }

    QPoint offset;
    ShadowParams shadow1;
    ShadowParams shadow2;
};

const CompositeShadowParams s_shadowParams[] = {
    // None
    CompositeShadowParams(),
    // Small
    CompositeShadowParams(QPoint(0, 4), ShadowParams(QPoint(0, 0), 16, 1), ShadowParams(QPoint(0, -2), 8, 0.4)),
    // Medium
    CompositeShadowParams(QPoint(0, 8), ShadowParams(QPoint(0, 0), 32, 0.9), ShadowParams(QPoint(0, -4), 16, 0.3)),
    // Large
    CompositeShadowParams(QPoint(0, 12), ShadowParams(QPoint(0, 0), 48, 0.8), ShadowParams(QPoint(0, -6), 24, 0.2)),
    // Very large
    CompositeShadowParams(QPoint(0, 16), ShadowParams(QPoint(0, 0), 64, 0.7), ShadowParams(QPoint(0, -8), 32, 0.1)),
};

inline CompositeShadowParams lookupShadowParams(int size)
{
    switch (size) {
    case Breeze::InternalSettings::ShadowNone:
        return s_shadowParams[0];
    case Breeze::InternalSettings::ShadowSmall:
        return s_shadowParams[1];
    case Breeze::InternalSettings::ShadowMedium:
        return s_shadowParams[2];
    case Breeze::InternalSettings::ShadowLarge:
        return s_shadowParams[3];
    case Breeze::InternalSettings::ShadowVeryLarge:
        return s_shadowParams[4];
    default:
        // Fallback to the Large size.
        return s_shadowParams[3];
    }
}
}

namespace Breeze
{
using KDecoration2::ColorGroup;
using KDecoration2::ColorRole;

//________________________________________________________________
static int g_sDecoCount = 0;
static int g_shadowSizeEnum = InternalSettings::ShadowLarge;
static int g_shadowStrength = 255;
static QColor g_shadowColor = Qt::black;
static QSharedPointer<KDecoration2::DecorationShadow> g_sShadow;
static QSharedPointer<KDecoration2::DecorationShadow> g_sShadowInactive;
static int g_lastBorderSize;
static QColor g_lastOutlineColor;

//________________________________________________________________
Decoration::Decoration(QObject *parent, const QVariantList &args)
    : KDecoration2::Decoration(parent, args)
    , m_animation(new QVariantAnimation(this))
    , m_shadowAnimation(new QVariantAnimation(this))
{
    g_sDecoCount++;
}

//________________________________________________________________
Decoration::~Decoration()
{
    g_sDecoCount--;
    if (g_sDecoCount == 0) {
        // last deco destroyed, clean up shadow
        g_sShadow.clear();
    }
}

//________________________________________________________________
void Decoration::setOpacity(qreal value)
{
    if (m_opacity == value) {
        return;
    }
    m_opacity = value;
    update();
}

//________________________________________________________________
QColor Decoration::titleBarColor() const
{
    return QColor(Qt::transparent);

    const auto c = client().toStrongRef();
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
    const auto c = client().toStrongRef();
    if (m_animation->state() == QAbstractAnimation::Running) {
        return KColorUtils::mix(c->color(ColorGroup::Inactive, ColorRole::Foreground), c->color(ColorGroup::Active, ColorRole::Foreground), m_opacity);
    } else {
        return c->color(c->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::Foreground);
    }
}

//________________________________________________________________
void Decoration::init()
{
    QResource::registerResource(QDir::homePath() + "/.local/share/smod/decoration.smod.rcc");

    const auto c = client().toStrongRef();

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

    reconfigure();
    updateTitleBar();
    auto s = settings();
    connect(s.data(), &KDecoration2::DecorationSettings::borderSizeChanged, this, &Decoration::recalculateBorders);

    // a change in font might cause the borders to change
    connect(s.data(), &KDecoration2::DecorationSettings::fontChanged, this, &Decoration::recalculateBorders);
    connect(s.data(), &KDecoration2::DecorationSettings::spacingChanged, this, &Decoration::recalculateBorders);

    // buttons
    connect(s.data(), &KDecoration2::DecorationSettings::spacingChanged, this, &Decoration::updateButtonsGeometryDelayed);
    connect(s.data(), &KDecoration2::DecorationSettings::decorationButtonsLeftChanged, this, &Decoration::updateButtonsGeometryDelayed);
    connect(s.data(), &KDecoration2::DecorationSettings::decorationButtonsRightChanged, this, &Decoration::updateButtonsGeometryDelayed);

    // full reconfiguration
    connect(s.data(), &KDecoration2::DecorationSettings::reconfigured, this, &Decoration::reconfigure);
    connect(s.data(), &KDecoration2::DecorationSettings::reconfigured, SettingsProvider::self(), &SettingsProvider::reconfigure, Qt::UniqueConnection);
    connect(s.data(), &KDecoration2::DecorationSettings::reconfigured, this, &Decoration::updateButtonsGeometryDelayed);

    connect(c.data(), &KDecoration2::DecoratedClient::adjacentScreenEdgesChanged, this, &Decoration::recalculateBorders);
    connect(c.data(), &KDecoration2::DecoratedClient::maximizedHorizontallyChanged, this, &Decoration::recalculateBorders);
    connect(c.data(), &KDecoration2::DecoratedClient::maximizedVerticallyChanged, this, &Decoration::recalculateBorders);
    connect(c.data(), &KDecoration2::DecoratedClient::shadedChanged, this, &Decoration::recalculateBorders);
    connect(c.data(), &KDecoration2::DecoratedClient::captionChanged, this, [this]() {
        // update the caption area
        update(titleBar());
    });

    connect(c.data(), &KDecoration2::DecoratedClient::activeChanged, this, &Decoration::updateAnimationState);
    connect(c.data(), &KDecoration2::DecoratedClient::widthChanged, this, &Decoration::updateTitleBar);
    connect(c.data(), &KDecoration2::DecoratedClient::maximizedChanged, this, &Decoration::updateTitleBar);
    //connect(c.data(), &KDecoration2::DecoratedClient::maximizedChanged, this, &Decoration::setOpaque);

    connect(c.data(), &KDecoration2::DecoratedClient::widthChanged, this, &Decoration::updateButtonsGeometry);
    connect(c.data(), &KDecoration2::DecoratedClient::maximizedChanged, this, &Decoration::updateButtonsGeometry);
    connect(c.data(), &KDecoration2::DecoratedClient::adjacentScreenEdgesChanged, this, &Decoration::updateButtonsGeometry);
    connect(c.data(), &KDecoration2::DecoratedClient::shadedChanged, this, &Decoration::updateButtonsGeometry);

    connect(c.data(), &KDecoration2::DecoratedClient::widthChanged, this, &Decoration::updateBlur);
    connect(c.data(), &KDecoration2::DecoratedClient::heightChanged, this, &Decoration::updateBlur);
    connect(c.data(), &KDecoration2::DecoratedClient::maximizedChanged, this, &Decoration::updateBlur);
    connect(c.data(), &KDecoration2::DecoratedClient::shadedChanged, this, &Decoration::updateBlur);

    createButtons();
    updateShadow();
}

//________________________________________________________________
void Decoration::updateTitleBar()
{
    // The titlebar rect has margins around it so the window can be resized by dragging a decoration edge.
    auto s = settings();
    const auto c = client().toStrongRef();
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
        const auto c = client().toStrongRef();
        m_shadowAnimation->setDirection(c->isActive() ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
        m_shadowAnimation->setEasingCurve(c->isActive() ? QEasingCurve::OutCubic : QEasingCurve::InCubic);
        if (m_shadowAnimation->state() != QAbstractAnimation::Running) {
            m_shadowAnimation->start();
        }

    } else {
        updateShadow();
    }

    if (m_animation->duration() > 0) {
        const auto c = client().toStrongRef();
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
            return 0;
        case InternalSettings::BorderNoSides:
            return bottom ? qMax(4, baseSize) : 0;
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
            return 0;
        case KDecoration2::BorderSize::NoSides:
            return bottom ? qMax(4, baseSize) : 0;
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
    QResource::registerResource(QDir::homePath() + "/.local/share/smod/decoration.smod.rcc");

    m_internalSettings = SettingsProvider::self()->internalSettings(this);

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
}

//________________________________________________________________
void Decoration::recalculateBorders()
{
    const auto c = client().toStrongRef();
    auto s = settings();

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

    top = isMaximized() ? 22 : 30;

    if (hideInnerBorder())
    {
        left = left < INNER_BORDER_SIZE ? 0 : left - INNER_BORDER_SIZE;
        right = right < INNER_BORDER_SIZE ? 0 : right - INNER_BORDER_SIZE;
        top = top < INNER_BORDER_SIZE ? 0 : top - INNER_BORDER_SIZE;
        bottom = bottom < INNER_BORDER_SIZE ? 0 : bottom - INNER_BORDER_SIZE;
    }

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

    // Update shadows and clear outline to make sure outline changes when borders are changed
    updateShadow();

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
        const int lessPadding = hideInnerBorder() ? 0 : INNER_BORDER_SIZE;
        m_rightButtons->setPos(QPointF(
            size().width() - m_rightButtons->geometry().width() - borderRight() - (isMaximized() ? 2 : 0) + lessPadding, vPadding));
    }

    update();

    return;

    // adjust button position
    const int bHeight = captionHeight() + (isTopEdge() ? s->smallSpacing() * Metrics::TitleBar_TopMargin : 0);
    const int bWidth = buttonHeight();
    const int verticalOffset = (isTopEdge() ? s->smallSpacing() * Metrics::TitleBar_TopMargin : 0) + (captionHeight() - buttonHeight()) / 2;
    foreach (const QPointer<KDecoration2::DecorationButton> &button, m_leftButtons->buttons() + m_rightButtons->buttons()) {
        button.data()->setGeometry(QRectF(QPoint(0, 0), QSizeF(bWidth, bHeight)));
        static_cast<Button *>(button.data())->setOffset(QPointF(0, verticalOffset));
        static_cast<Button *>(button.data())->setIconSize(QSize(bWidth, bWidth));
    }

    // left buttons
    if (!m_leftButtons->buttons().isEmpty()) {
        // spacing
        m_leftButtons->setSpacing(s->smallSpacing() * Metrics::TitleBar_ButtonSpacing);

        // padding
        const int vPadding = isTopEdge() ? 0 : s->smallSpacing() * Metrics::TitleBar_TopMargin;
        const int hPadding = s->smallSpacing() * Metrics::TitleBar_SideMargin;
        if (isLeftEdge()) {
            // add offsets on the side buttons, to preserve padding, but satisfy Fitts law
            auto button = static_cast<Button *>(m_leftButtons->buttons().front().data());
            button->setGeometry(QRectF(QPoint(0, 0), QSizeF(bWidth + hPadding, bHeight)));
            button->setFlag(Button::FlagFirstInList);
            button->setHorizontalOffset(hPadding);

            m_leftButtons->setPos(QPointF(0, vPadding));

        } else {
            m_leftButtons->setPos(QPointF(hPadding + borderLeft(), vPadding));
        }
    }

    // right buttons
    if (!m_rightButtons->buttons().isEmpty()) {
        // spacing
        m_rightButtons->setSpacing(s->smallSpacing() * Metrics::TitleBar_ButtonSpacing);

        // padding
        const int vPadding = isTopEdge() ? 0 : s->smallSpacing() * Metrics::TitleBar_TopMargin;
        const int hPadding = s->smallSpacing() * Metrics::TitleBar_SideMargin;
        if (isRightEdge()) {
            auto button = static_cast<Button *>(m_rightButtons->buttons().back().data());
            button->setGeometry(QRectF(QPoint(0, 0), QSizeF(bWidth + hPadding, bHeight)));
            button->setFlag(Button::FlagLastInList);

            m_rightButtons->setPos(QPointF(size().width() - m_rightButtons->geometry().width(), vPadding));

        } else {
            m_rightButtons->setPos(QPointF(size().width() - m_rightButtons->geometry().width() - hPadding - borderRight(), vPadding));
        }
    }

    update();
}

//________________________________________________________________
void Decoration::paint(QPainter *painter, const QRect &repaintRegion)
{
    smodPaint(painter, repaintRegion);

    return;

    // TODO: optimize based on repaintRegion
    auto c = client().toStrongRef();
    auto s = settings();

    // paint background
    if (!c->isShaded()) {
        painter->fillRect(rect(), Qt::transparent);
        painter->save();
        painter->setRenderHint(QPainter::Antialiasing);
        painter->setPen(Qt::NoPen);
        painter->setBrush(c->color(c->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::Frame));

        // clip away the top part
        if (!hideTitleBar()) {
            painter->setClipRect(0, borderTop(), size().width(), size().height() - borderTop(), Qt::IntersectClip);
        }

        if (s->isAlphaChannelSupported()) {
            painter->drawRoundedRect(rect(), m_scaledCornerRadius, m_scaledCornerRadius);
        } else {
            painter->drawRect(rect());
        }

        painter->restore();
    }

    if (!hideTitleBar()) {
        paintTitleBar(painter, repaintRegion);
    }

    if (hasBorders() && !s->isAlphaChannelSupported()) {
        painter->save();
        painter->setRenderHint(QPainter::Antialiasing, false);
        painter->setBrush(Qt::NoBrush);
        painter->setPen(c->isActive() ? c->color(ColorGroup::Active, ColorRole::TitleBar) : c->color(ColorGroup::Inactive, ColorRole::Foreground));

        painter->drawRect(rect().adjusted(0, 0, -1, -1));
        painter->restore();
    }
}

//________________________________________________________________
void Decoration::paintTitleBar(QPainter *painter, const QRect &repaintRegion)
{
    const auto c = client().toStrongRef();
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
        auto c = client().toStrongRef();
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

//________________________________________________________________
void Decoration::updateShadow()
{
    auto s = settings();
    auto c = client().toStrongRef();
    auto outlineColor = c->color(c->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::TitleBar);
    auto backgroundColor = c->color(c->isActive() ? ColorGroup::Active : ColorGroup::Inactive, ColorRole::Frame);
    // Bind lightness between 0.1 and 1.0 so it can never be completely black.
    // Outlines only have transparency if alpha channel is supported
    outlineColor.setHslF(outlineColor.hslHueF(),
                         outlineColor.hslSaturationF(),
                         qBound(0.1, outlineColor.lightnessF(), 1.0),
                         s->isAlphaChannelSupported() ? 0.9 : 1.0);
    outlineColor.lightnessF() >= 0.5 ? outlineColor = outlineColor.darker(170) : outlineColor = outlineColor.lighter(170);

    // Animated case, no cached shadow object
    if ((m_shadowAnimation->state() == QAbstractAnimation::Running) && (m_shadowOpacity != 0.0) && (m_shadowOpacity != 1.0)) {
        setShadow(createShadowObject(0.5 + m_shadowOpacity * 0.5, outlineColor));
        return;
    }

    if (g_shadowSizeEnum != m_internalSettings->shadowSize() || g_shadowStrength != m_internalSettings->shadowStrength()
        || g_shadowColor != m_internalSettings->shadowColor()) {
        g_sShadow.clear();
        g_sShadowInactive.clear();
        g_shadowSizeEnum = m_internalSettings->shadowSize();
        g_shadowStrength = m_internalSettings->shadowStrength();
        g_shadowColor = m_internalSettings->shadowColor();
    }

    auto &shadow = (c->isActive()) ? g_sShadow : g_sShadowInactive;
    if (!shadow || g_lastBorderSize != borderSize(true) || g_lastOutlineColor != outlineColor) {
        // Update both active and inactive shadows so outline stays consistent between the two
        g_sShadow = createShadowObject(1.0, outlineColor);
        g_sShadowInactive = createShadowObject(0.5, outlineColor);
        g_lastBorderSize = borderSize(true);
        g_lastOutlineColor = outlineColor;
    }
    setShadow(shadow);
}

//________________________________________________________________
QSharedPointer<KDecoration2::DecorationShadow> Decoration::createShadowObject(const float strengthScale, const QColor &outlineColor)
{
    CompositeShadowParams params = lookupShadowParams(m_internalSettings->shadowSize());
    if (params.isNone()) {
        // If shadows are disabled, set shadow opacity to 0.
        // This allows the outline effect to show up without the shadow effect.
        params = CompositeShadowParams(QPoint(0, 4), ShadowParams(QPoint(0, 0), 16, 0), ShadowParams(QPoint(0, -2), 8, 0));
    }

    auto withOpacity = [](const QColor &color, qreal opacity) -> QColor {
        QColor c(color);
        c.setAlphaF(opacity);
        return c;
    };

    const QSize boxSize =
        BoxShadowRenderer::calculateMinimumBoxSize(params.shadow1.radius).expandedTo(BoxShadowRenderer::calculateMinimumBoxSize(params.shadow2.radius));

    BoxShadowRenderer shadowRenderer;
    shadowRenderer.setBorderRadius(m_scaledCornerRadius + 0.5);
    shadowRenderer.setBoxSize(boxSize);

    const qreal strength = m_internalSettings->shadowStrength() / 255.0 * strengthScale;
    shadowRenderer.addShadow(params.shadow1.offset, params.shadow1.radius, withOpacity(m_internalSettings->shadowColor(), params.shadow1.opacity * strength));
    shadowRenderer.addShadow(params.shadow2.offset, params.shadow2.radius, withOpacity(m_internalSettings->shadowColor(), params.shadow2.opacity * strength));

    QImage shadowTexture = shadowRenderer.render();

    QPainter painter(&shadowTexture);
    painter.setRenderHint(QPainter::Antialiasing);

    QRect outerRect = shadowTexture.rect();

    QRect boxRect(QPoint(0, 0), boxSize);
    boxRect.moveCenter(outerRect.center());

    // Mask out inner rect.
    const QMargins padding = QMargins(
        boxRect.left() - outerRect.left() - Metrics::Shadow_Overlap - params.offset.x(),
        boxRect.top() - outerRect.top() - Metrics::Shadow_Overlap - params.offset.y(),
        outerRect.right() - boxRect.right() - Metrics::Shadow_Overlap + params.offset.x(),
        outerRect.bottom() - boxRect.bottom() - Metrics::Shadow_Overlap + params.offset.y());

    const QRect innerRect = outerRect - padding;

    painter.setPen(Qt::NoPen);
    painter.setBrush(Qt::black);
    painter.setCompositionMode(QPainter::CompositionMode_DestinationOut);
    painter.drawRoundedRect(innerRect, m_scaledCornerRadius + 0.5, m_scaledCornerRadius + 0.5);


#if 0
    // Draw window outline
    const qreal outlineWidth = 1.001;
    const qreal penOffset = outlineWidth / 2;

    QRectF outlineRect = innerRect + QMarginsF(penOffset, penOffset, penOffset, penOffset);
    qreal cornerSize = m_scaledCornerRadius * 2;
    QRectF cornerRect(outlineRect.x(), outlineRect.y(), cornerSize, cornerSize);
    QPainterPath outlinePath;

    outlinePath.arcMoveTo(cornerRect, 180);
    outlinePath.arcTo(cornerRect, 180, -90);
    cornerRect.moveTopRight(outlineRect.topRight());
    outlinePath.arcTo(cornerRect, 90, -90);

    // Check if border size is "no borders" or "no side-borders"
    if (borderSize(true) == 0) {
        outlinePath.lineTo(outlineRect.bottomRight());
        outlinePath.lineTo(outlineRect.bottomLeft());
    } else {
        cornerRect.moveBottomRight(outlineRect.bottomRight());
        outlinePath.arcTo(cornerRect, 0, -90);
        cornerRect.moveBottomLeft(outlineRect.bottomLeft());
        outlinePath.arcTo(cornerRect, 270, -90);
    }
    outlinePath.closeSubpath();

    painter.setPen(QPen(outlineColor, outlineWidth));
    painter.setBrush(Qt::NoBrush);
    painter.setCompositionMode(QPainter::CompositionMode_Source);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.drawPath(outlinePath);
#endif

    painter.end();

    auto ret = QSharedPointer<KDecoration2::DecorationShadow>::create();
    ret->setPadding(padding);
    ret->setInnerShadowRect(QRect(outerRect.center(), QSize(1, 1)));
    ret->setShadow(shadowTexture);


    return ret;
}

void Decoration::setScaledCornerRadius()
{
    m_scaledCornerRadius = Metrics::Frame_FrameRadius * settings()->smallSpacing();
}

void Decoration::updateBlur()
{
    const int radius = isMaximized() ? 0 : 6;

    QPainterPath path;
    path.addRoundedRect(rect(), radius, radius);

    setBlurRegion(QRegion(path.toFillPolygon().toPolygon()));

    updateShadow();
}

void Decoration::smodPaint(QPainter *painter, const QRect &repaintRegion)
{
    painter->fillRect(rect(), Qt::transparent);

    smodPaintGlow(painter, repaintRegion);
    smodPaintOuterBorder(painter, repaintRegion);
    smodPaintInnerBorder(painter, repaintRegion);
    smodPaintTitleBar(painter, repaintRegion);
}

void Decoration::smodPaintGlow(QPainter *painter, const QRect &repaintRegion)
{
    auto c = client().toStrongRef();

    int SIDEBAR_HEIGHT = qMax(50, (size().height() / 4));

    painter->setOpacity(0.75);

    if (c->isActive())
    {
        if (isMaximized())
        {
            QPixmap nwCorner(":/smod/decoration/framecornereffect");
            painter->drawPixmap(0, 0, nwCorner, 4, 4, nwCorner.width() - 4, nwCorner.height() - 4);

            QPixmap neCorner = nwCorner.transformed(QTransform().scale(-1, 1));
            //QPixmap neCorner(":/smod/decoration/ne-corner");
            painter->drawPixmap(size().width() - (neCorner.width() - 4), 0, neCorner, 0, 4, neCorner.width() - 4, neCorner.height() - 4);
        }
        else
        {
            QPixmap nwCorner(":/smod/decoration/framecornereffect");
            painter->drawPixmap(0, 0, nwCorner);

            QPixmap neCorner = nwCorner.transformed(QTransform().scale(-1, 1));
            //QPixmap neCorner(":/smod/decoration/ne-corner");
            painter->drawPixmap(size().width() - neCorner.width(), 0, neCorner);

            painter->setOpacity(1.0);

            // 7x116
            QPixmap sidehighlight(":/smod/decoration/sidehighlight");
            painter->drawPixmap(0, 0, 7, SIDEBAR_HEIGHT, sidehighlight);
            painter->drawPixmap(size().width() - 7, 0, 7, SIDEBAR_HEIGHT, sidehighlight);
        }
    }
    else
    {
        if (isMaximized())
        {
            QPixmap nwCorner(":/smod/decoration/framecornereffect-unfocus");
            painter->drawPixmap(0, 0, nwCorner, 4, 4, nwCorner.width() - 4, nwCorner.height() - 4);

            QPixmap neCorner = nwCorner.transformed(QTransform().scale(-1, 1));
            //QPixmap neCorner(":/smod/decoration/ne-corner");
            painter->drawPixmap(size().width() - (neCorner.width() - 4), 0, neCorner, 0, 4, neCorner.width() - 4, neCorner.height() - 4);
        }
        else
        {
            QPixmap nwCorner(":/smod/decoration/framecornereffect-unfocus");
            painter->drawPixmap(0, 0, nwCorner);

            QPixmap neCorner = nwCorner.transformed(QTransform().scale(-1, 1));
            //QPixmap neCorner(":/smod/decoration/ne-corner");
            painter->drawPixmap(size().width() - neCorner.width(), 0, neCorner);

            painter->setOpacity(1.0);

            // 7x116
            QPixmap sidehighlight(":/smod/decoration/sidehighlight-unfocus");
            painter->drawPixmap(0, 0, 7, SIDEBAR_HEIGHT, sidehighlight);
            painter->drawPixmap(size().width() - 7, 0, 7, SIDEBAR_HEIGHT, sidehighlight);
        }
    }

    painter->setOpacity(1.0);
}

void Decoration::smodPaintOuterBorder(QPainter *painter, const QRect &repaintRegion)
{
    if (isMaximized())
    {
        return;
    }

    auto c = client().toStrongRef();

    QPixmap nw, n, ne, e, se, s, sw, w;

    if (c->isActive())
    {
        nw = QPixmap(":/smod/decoration/nw");
        n = QPixmap(":/smod/decoration/n");
        ne = QPixmap(":/smod/decoration/ne");
        e = QPixmap(":/smod/decoration/e");
        se = QPixmap(":/smod/decoration/se");
        s = QPixmap(":/smod/decoration/s");
        sw = QPixmap(":/smod/decoration/sw");
        w = QPixmap(":/smod/decoration/w");
    }
    else
    {
        nw = QPixmap(":/smod/decoration/nw-unfocus");
        n = QPixmap(":/smod/decoration/n-unfocus");
        ne = QPixmap(":/smod/decoration/ne-unfocus");
        e = QPixmap(":/smod/decoration/e-unfocus");
        se = QPixmap(":/smod/decoration/se-unfocus");
        s = QPixmap(":/smod/decoration/s-unfocus");
        sw = QPixmap(":/smod/decoration/sw-unfocus");
        w = QPixmap(":/smod/decoration/w-unfocus");
    }

#if 0
    if (c->isActive())
    {
        painter->save();
        QPen pen(Qt::white, 0);
        painter->setPen(pen);
        painter->drawRoundedRect(rect().x() + 1, rect().y() + 1, rect().width() - 2, rect().height() - 2, 6, 6);
        painter->restore();
    }
#endif
    int PIX_RIGHT = size().width() - 9;
    int PIX_BOTTOM = size().height() - 9;

    painter->drawPixmap(0, 0, nw);

    painter->drawTiledPixmap(9, 0, PIX_RIGHT - 9, 9, n);

    painter->drawPixmap(PIX_RIGHT, 0, ne);

    painter->drawTiledPixmap(PIX_RIGHT, 9, 9, PIX_BOTTOM - 9, e);

    painter->drawPixmap(PIX_RIGHT, PIX_BOTTOM, se);

    painter->drawTiledPixmap(9, PIX_BOTTOM, PIX_RIGHT - 9, 9, s);

    painter->drawPixmap(0, PIX_BOTTOM, sw);

    painter->drawTiledPixmap(0, 9, 9, PIX_BOTTOM - 9, w);
}

void Decoration::smodPaintInnerBorder(QPainter *painter, const QRect &repaintRegion)
{
    if (hideInnerBorder())
    {
        return;
    }

    auto c = client().toStrongRef();

    QPixmap nw, n, ne, e, se, s, sw, w;

    if (c->isActive())
    {
        nw = QPixmap(":/smod/decoration/nw-inner");
        n = QPixmap(":/smod/decoration/n-inner");
        ne = QPixmap(":/smod/decoration/ne-inner");
        e = QPixmap(":/smod/decoration/e-inner");
        se = QPixmap(":/smod/decoration/se-inner");
        s = QPixmap(":/smod/decoration/s-inner");
        sw = QPixmap(":/smod/decoration/sw-inner");
        w = QPixmap(":/smod/decoration/w-inner");
    }
    else
    {
        nw = QPixmap(":/smod/decoration/nw-unfocus-inner");
        n = QPixmap(":/smod/decoration/n-unfocus-inner");
        ne = QPixmap(":/smod/decoration/ne-unfocus-inner");
        e = QPixmap(":/smod/decoration/e-unfocus-inner");
        se = QPixmap(":/smod/decoration/se-unfocus-inner");
        s = QPixmap(":/smod/decoration/s-unfocus-inner");
        sw = QPixmap(":/smod/decoration/sw-unfocus-inner");
        w = QPixmap(":/smod/decoration/w-unfocus-inner");
    }

    // left
    painter->drawTiledPixmap(
        borderLeft() - INNER_BORDER_SIZE,
        borderTop(),
        INNER_BORDER_SIZE,
        size().height() - borderBottom() - borderTop(),
        w);

    // right
    painter->drawTiledPixmap(
        size().width() - borderRight(),
        borderTop(),
        INNER_BORDER_SIZE,
        size().height() - borderBottom() - borderTop(),
        e);

    // bottom
    painter->drawTiledPixmap(
        borderLeft(),
        size().height() - borderBottom(),
        size().width() - borderLeft() - borderRight(),
        INNER_BORDER_SIZE,
        s);

    // top
    painter->drawTiledPixmap(
        borderLeft(),
        borderTop() - INNER_BORDER_SIZE,
        size().width() - borderLeft() - borderRight(),
        INNER_BORDER_SIZE,
        n);

    painter->drawPixmap(borderLeft() - INNER_BORDER_SIZE, borderTop() - INNER_BORDER_SIZE, nw);
    painter->drawPixmap(size().width() - borderRight(), borderTop() - INNER_BORDER_SIZE, ne);
    painter->drawPixmap(size().width() - borderRight(), size().height() - borderBottom(), se);
    painter->drawPixmap(borderLeft() - INNER_BORDER_SIZE, size().height() - borderBottom(), sw);
}

void Decoration::smodPaintTitleBar(QPainter *painter, const QRect &repaintRegion)
{
    if (hideTitleBar())
    {
        return;
    }

    if (!hideCaption())
    {
        const auto c = client().toStrongRef();
        const bool active = c->isActive();

        QRect captionRect(m_leftButtons->geometry().right() + 4 + (c->isMaximized() ? 5 : 0), 0, m_rightButtons->geometry().left() - m_leftButtons->geometry().right() - 4, borderTop());
        QString caption = settings()->fontMetrics().elidedText(c->caption(), Qt::ElideMiddle, captionRect.width());
        QStringList programname = caption.split(" — ");
        caption.remove(" — " + programname.at(programname.size()-1));
        caption.prepend(" ");
        caption.append(" ");
        int blurWidth = settings()->fontMetrics().width(caption + "..JO");
        int blurHeight = settings()->fontMetrics().height();
        //factory()->setTitleTextWidth(blurWidth);
        //factory()->setTitleTextHeight(blurHeight);
        //factory()->setMaximized(c->isMaximized());

        //if (drawTitle)
        //{
        QColor shadowColor = QColor(0, 0, 0, 255);
        QColor textColor = c->color(active ? KDecoration2::ColorGroup::Active : KDecoration2::ColorGroup::Inactive, KDecoration2::ColorRole::Foreground);
        int textHaloXOffset = 1;
        int textHaloYOffset = 1;
        int textHaloSize = 2;
        //if (!config->useKWinTextColors) {
        //    alpha_color &c = fs->text_halo;
        //    shadowColor = QColor::fromRgbF(c.color.r, c.color.g, c.color.b, c.alpha);
        //    c = fs->text;
        //    textColor = QColor::fromRgbF(c.color.r, c.color.g, c.color.b, c.alpha);
        //}
        captionRect.setHeight(captionRect.height() & -2);
        painter->setFont(settings()->font());
        painter->setPen(shadowColor);
    //    painter->drawText(captionRect.adjusted(1, 1, 1, 1), Qt::AlignVCenter, caption);
        painter->setPen(textColor);
        //Qt::Alignment alignment = Qt::AlignHCenter;
        Qt::Alignment alignment = Qt::AlignLeft;
        //if (ws->tobj_layout) {
        //    alignment = parseTitleAlignment(ws->tobj_layout);
        //}
        QLabel temp_label(caption);
        QGraphicsGlowEffect temp_effect;
        temp_effect.setColor(QColor::fromRgb(255, 255, 255, 0));
        temp_effect.setBlurRadius(7);
        temp_label.setGraphicsEffect(&temp_effect);

        int captionHeight = captionRect.height() * 0.8;
        QPixmap final_label(blurWidth, captionHeight);
        final_label.fill(QColor::fromRgb(0,0,0,0));
        QPainter *ptr = new QPainter(&final_label);
        QPainterPath path;
        path.addRoundedRect(0, 0, blurWidth, captionHeight, 12,12);
        ptr->fillPath(path, QColor::fromRgb(255,255,255, active ? 186 : 148));
        delete ptr;

        if(!caption.trimmed().isEmpty())
        {
            QPixmap blur_effect = temp_effect.drawBlur(final_label);
            painter->drawPixmap(QRect(captionRect.x()*0.7,captionRect.y(),blurWidth,captionRect.height()), blur_effect);
            painter->drawText(captionRect, alignment | Qt::AlignVCenter | Qt::TextSingleLine, caption);
        }
    }

    m_leftButtons->paint(painter, repaintRegion);
    m_rightButtons->paint(painter, repaintRegion);

    foreach (QPointer<KDecoration2::DecorationButton> button, m_rightButtons->buttons()) {
        static_cast<Button *>(button.data())->smodPaintGlow(painter, repaintRegion);
    }
}

} // namespace

#include "breezedecoration.moc"
