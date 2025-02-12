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

#include <KDecoration3/DecorationButtonGroup>
#include <KDecoration3/DecorationShadow>

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
using KDecoration3::ColorGroup;
using KDecoration3::ColorRole;

static SizingMargins g_sizingmargins;
static QString g_themeName = "Aero";
static int g_shadowStrength = 255;
static QColor g_shadowColor = Qt::black;
static int g_lastBorderSize;

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

    const auto c = window();
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
    const auto c = window();
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
    const auto c = window();
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
    connect(s.get(), &KDecoration3::DecorationSettings::borderSizeChanged, this, &Decoration::recalculateBorders);

    // a change in font might cause the borders to change
    connect(s.get(), &KDecoration3::DecorationSettings::fontChanged, this, &Decoration::recalculateBorders);
    connect(s.get(), &KDecoration3::DecorationSettings::spacingChanged, this, &Decoration::recalculateBorders);

    // buttons
    connect(s.get(), &KDecoration3::DecorationSettings::spacingChanged, this, &Decoration::updateButtonsGeometryDelayed);
    connect(s.get(), &KDecoration3::DecorationSettings::decorationButtonsLeftChanged, this, &Decoration::updateButtonsGeometryDelayed);
    connect(s.get(), &KDecoration3::DecorationSettings::decorationButtonsRightChanged, this, &Decoration::updateButtonsGeometryDelayed);

    // full reconfiguration
    connect(s.get(), &KDecoration3::DecorationSettings::reconfigured, this, &Decoration::reconfigure);
    connect(s.get(), &KDecoration3::DecorationSettings::reconfigured, SettingsProvider::self(), &SettingsProvider::reconfigure, Qt::UniqueConnection);
    connect(s.get(), &KDecoration3::DecorationSettings::reconfigured, this, &Decoration::updateButtonsGeometryDelayed);

    connect(c, &KDecoration3::DecoratedWindow::adjacentScreenEdgesChanged, this, &Decoration::recalculateBorders);
    connect(c, &KDecoration3::DecoratedWindow::maximizedHorizontallyChanged, this, &Decoration::recalculateBorders);
    connect(c, &KDecoration3::DecoratedWindow::maximizedVerticallyChanged, this, &Decoration::recalculateBorders);
    connect(c, &KDecoration3::DecoratedWindow::shadedChanged, this, &Decoration::recalculateBorders);
    connect(c, &KDecoration3::DecoratedWindow::captionChanged, this, [this]() {
        // update the caption area
        update(titleBar());
        update(); // Prevents rendering artifacts with the text glow
    });

    connect(c, &KDecoration3::DecoratedWindow::activeChanged, this, &Decoration::updateAnimationState);
    connect(c, &KDecoration3::DecoratedWindow::widthChanged, this, &Decoration::updateTitleBar);
    connect(c, &KDecoration3::DecoratedWindow::maximizedChanged, this, &Decoration::updateTitleBar);
    //connect(c, &KDecoration3::DecoratedWindow::maximizedChanged, this, &Decoration::setOpaque);

    connect(c, &KDecoration3::DecoratedWindow::widthChanged, this, &Decoration::updateButtonsGeometry);
    connect(c, &KDecoration3::DecoratedWindow::maximizedChanged, this, &Decoration::updateButtonsGeometry);
    connect(c, &KDecoration3::DecoratedWindow::adjacentScreenEdgesChanged, this, &Decoration::updateButtonsGeometry);
    connect(c, &KDecoration3::DecoratedWindow::shadedChanged, this, &Decoration::updateButtonsGeometry);

    connect(c, &KDecoration3::DecoratedWindow::widthChanged, this, &Decoration::updateBlur);
    connect(c, &KDecoration3::DecoratedWindow::heightChanged, this, &Decoration::updateBlur);
    connect(c, &KDecoration3::DecoratedWindow::maximizedChanged, this, &Decoration::updateBlur);
    connect(c, &KDecoration3::DecoratedWindow::shadedChanged, this, &Decoration::updateBlur);

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
    const auto c = window();
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
        const auto c = window();
        m_shadowAnimation->setDirection(c->isActive() ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
        m_shadowAnimation->setEasingCurve(c->isActive() ? QEasingCurve::OutCubic : QEasingCurve::InCubic);
        if (m_shadowAnimation->state() != QAbstractAnimation::Running) {
            m_shadowAnimation->start();
        }

    } else {
        updateShadow();
    }

    if (m_animation->duration() > 0) {
        const auto c = window();
        m_animation->setDirection(c->isActive() ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
        if (m_animation->state() != QAbstractAnimation::Running) {
            m_animation->start();
        }

    } else {
        update();
    }
}


//________________________________________________________________
void Decoration::reconfigure()
{

    m_internalSettings = SettingsProvider::self()->internalSettings(this);

    SMOD::registerResource(m_internalSettings->decorationTheme());
    g_sizingmargins.loadSizingMargins();
    setScaledCornerRadius();

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

    {
        // Reload smodglow
        QDBusMessage message = QDBusMessage::createMethodCall("org.kde.KWin", "/Effects", "", "reconfigureEffect");
        QList<QVariant> args;
        args.append("smodglow");
        message.setArguments(args);
        bool result = QDBusConnection::sessionBus().send(message);
    }

}

//________________________________________________________________
void Decoration::recalculateBorders()
{
    const auto c = window();
    auto s = settings();

    // left, right and bottom borders
    auto margins_l= sizingMargins().frameLeftSizing();
    auto margins_r= sizingMargins().frameRightSizing();
    auto margins_b= sizingMargins().frameBottomSizing();
    int left = isMaximized() ? 0 : margins_l.width;
    int right = isMaximized() ? 0 : margins_r.width;
    int bottom = (c->isShaded() || isMaximized()) ? 0 : margins_b.height;

    // Increase titlebar height if the font is too large for the configured size
    QString testString = "Message Box qd";
    QFontMetrics fm(s->font());
    auto bounds = fm.boundingRect(testString);
    auto margins = sizingMargins().commonSizing();
    int limitedHeight = qMax(titlebarHeight(), bounds.height());
    int top = (isMaximized() ? limitedHeight+margins.titlebar_padding_maximized : limitedHeight+margins.titlebar_padding_normal) + 1;
    if (hideTitleBar()) top = bottom;

    // Hide inner borders
    auto t_m = sizingMargins().topSide();
    auto l_m = sizingMargins().leftSide();
    auto r_m = sizingMargins().rightSide();
    auto b_m = sizingMargins().bottomSide();

    if (hideInnerBorder())
    {
       left = left < l_m.margin_right ? 0 : left - l_m.margin_right;
       right = right < r_m.margin_left ? 0 : right - r_m.margin_left;
       top = top < t_m.margin_bottom ? 0 : top - t_m.margin_bottom;
       bottom = bottom < b_m.margin_top ? 0 : bottom - b_m.margin_top;
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

    // TODO is this needed?
    updateBlur();
}

//________________________________________________________________
void Decoration::createButtons()
{
    m_leftButtons = new KDecoration3::DecorationButtonGroup(KDecoration3::DecorationButtonGroup::Position::Left, this, &Button::create);
    m_rightButtons = new KDecoration3::DecorationButtonGroup(KDecoration3::DecorationButtonGroup::Position::Right, this, &Button::create);
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
        const int lessPadding = g_sizingmargins.frameRightSizing().inset;
        auto r_m = sizingMargins().rightSide();
        m_rightButtons->setPos(QPointF(
            size().width() - m_rightButtons->geometry().width() - borderRight() - (isMaximized() ? 2 : 0) + lessPadding - ((hideInnerBorder() && !isMaximized()) ? r_m.margin_left : 0), vPadding));

        m_rightButtons->setSpacing(g_sizingmargins.commonSizing().caption_button_spacing);
    }
    foreach (QPointer<KDecoration3::DecorationButton> button, m_rightButtons->buttons()) {
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
void Decoration::paint(QPainter *painter, const QRectF &repaintRegion)
{
    smodPaint(painter, repaintRegion);
    return;
}

//________________________________________________________________
SizingMargins Decoration::sizingMargins() const
{
    return g_sizingmargins;
}

QRect Decoration::buttonRect(KDecoration3::DecorationButtonType button) const
{

    int height = titlebarHeight()-1;
    int intendedWidth = g_sizingmargins.maximizeSizing().width;
    int width = 0;
    switch (button)
    {
        case KDecoration3::DecorationButtonType::Minimize:
            intendedWidth = g_sizingmargins.minimizeSizing().width;
            break;
        case KDecoration3::DecorationButtonType::Maximize:
            intendedWidth = g_sizingmargins.maximizeSizing().width;
            break;
        case KDecoration3::DecorationButtonType::Close:
            intendedWidth = g_sizingmargins.closeSizing().width;
            break;
        case KDecoration3::DecorationButtonType::Menu:
            height = titlebarHeight();
            break;
        default:
            break;
    }
    if(button == KDecoration3::DecorationButtonType::Menu) width = 16;
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
        auto c = window();
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
