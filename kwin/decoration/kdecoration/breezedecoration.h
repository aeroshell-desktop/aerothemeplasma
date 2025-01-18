/*
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "breeze.h"
#include "breezesettings.h"
#include "sizingmargins.h"

#include <KDecoration2/DecoratedClient>
#include <KDecoration2/Decoration>
#include <KDecoration2/DecorationSettings>

#include <QPalette>
#include <QVariant>
#include <QVariantAnimation>
#include <QByteArray>

#define INNER_BORDER_SIZE 2

// This is absolutely needed in Qt6
// even though it absolutely wasn't needed in Qt5
// funny
#if defined(MYSHAREDLIB_LIBRARY)
#  define MYSHAREDLIB_EXPORT Q_DECL_EXPORT
#else
#  define MYSHAREDLIB_EXPORT Q_DECL_IMPORT
#endif

namespace KDecoration2
{
class DecorationButton;
class DecorationButtonGroup;
}

namespace Breeze
{
class MYSHAREDLIB_EXPORT Decoration : public KDecoration2::Decoration
{
    Q_OBJECT

public:
    //* constructor
    explicit Decoration(QObject *parent = nullptr, const QVariantList &args = QVariantList());

    //* destructor
    virtual ~Decoration();

    //* paint
    void paint(QPainter *painter, const QRect &repaintRegion) override;

    SizingMargins sizingMargins() const;

    //* internal settings
    InternalSettingsPtr internalSettings() const
    {
        return m_internalSettings;
    }

    qreal animationsDuration() const
    {
        return m_animation->duration();
    }

    //* caption height
    int captionHeight() const;

    //* button height
    int buttonHeight() const;

    int titlebarHeight() const;
    static QString themeName();
    static QPixmap minimize_glow();
    static QPixmap maximize_glow();
    static QPixmap close_glow();
    static int decorationCount();
    static bool glowEnabled();

    QRect buttonRect(KDecoration2::DecorationButtonType button) const;

    //*@name active state change animation
    //@{
    void setOpacity(qreal);

    qreal opacity() const
    {
        return m_opacity;
    }

    //@}

    //*@name colors
    //@{
    QColor titleBarColor() const;
    QColor fontColor() const;
    //@}

    //*@name maximization modes
    //@{
    inline bool isMaximized() const;
    inline bool isMaximizedHorizontally() const;
    inline bool isMaximizedVertically() const;

    inline bool isLeftEdge() const;
    inline bool isRightEdge() const;
    inline bool isTopEdge() const;
    inline bool isBottomEdge() const;

    inline bool hideTitleBar() const;
    inline bool hideIcon() const;
    inline bool hideCaption() const;
    inline bool hideInnerBorder() const;

    inline bool isGadgetExplorer() const;
    //@}

Q_SIGNALS:
    void buttonHoverStatus(KDecoration2::DecorationButtonType button, bool hovered, QPoint pos);

public Q_SLOTS:
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    bool init() override;
#else
    void init() override;
#endif

private Q_SLOTS:
    void reconfigure();
    void recalculateBorders();
    void updateButtonsGeometry();
    void updateButtonsGeometryDelayed();
    void updateTitleBar();
    void updateAnimationState();
    void updateBlur();
    void onTabletModeChanged(bool mode);

private:
    //* return the rect in which caption will be drawn
    QPair<QRect, Qt::Alignment> captionRect() const;

    void createButtons();
    void smodPaint(QPainter *painter, const QRect &repaintRegion);
    void smodPaintGlow(QPainter *painter, const QRect &repaintRegion);
    void smodPaintOuterBorder(QPainter *painter, const QRect &repaintRegion);
    void smodPaintTitleBar(QPainter *painter, const QRect &repaintRegion);
    void updateShadow();
    std::shared_ptr<KDecoration2::DecorationShadow> smodCreateShadow(bool active);
    void setScaledCornerRadius();

    //*@name border size
    //@{
    int borderSize(bool bottom = false) const;
    inline bool hasBorders() const;
    inline bool hasNoBorders() const;
    inline bool hasNoSideBorders() const;
    //@}

    inline bool outlinesEnabled() const;

    InternalSettingsPtr m_internalSettings;
    KDecoration2::DecorationButtonGroup *m_leftButtons = nullptr;
    KDecoration2::DecorationButtonGroup *m_rightButtons = nullptr;

    //* active state change animation
    QVariantAnimation *m_animation;
    QVariantAnimation *m_shadowAnimation;

    //* active state change opacity
    qreal m_opacity = 0;
    qreal m_shadowOpacity = 0;

    //*frame corner radius, scaled according to DPI
    qreal m_scaledCornerRadius = 3;

    bool m_tabletMode = false;
};

bool Decoration::hasBorders() const
{
    if (m_internalSettings && m_internalSettings->mask() & BorderSize) {
        return m_internalSettings->borderSize() > InternalSettings::BorderNoSides;
    } else {
        return settings()->borderSize() > KDecoration2::BorderSize::NoSides;
    }
}

bool Decoration::hasNoBorders() const
{
    if (m_internalSettings && m_internalSettings->mask() & BorderSize) {
        return m_internalSettings->borderSize() == InternalSettings::BorderNone;
    } else {
        return settings()->borderSize() == KDecoration2::BorderSize::None;
    }
}

bool Decoration::hasNoSideBorders() const
{
    if (m_internalSettings && m_internalSettings->mask() & BorderSize) {
        return m_internalSettings->borderSize() == InternalSettings::BorderNoSides;
    } else {
        return settings()->borderSize() == KDecoration2::BorderSize::NoSides;
    }
}

bool Decoration::isMaximized() const
{
    return client()->isMaximized() && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isMaximizedHorizontally() const
{
    return client()->isMaximizedHorizontally() && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isMaximizedVertically() const
{
    return client()->isMaximizedVertically() && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isLeftEdge() const
{
    const auto c = client();
    return (c->isMaximizedHorizontally() || c->adjacentScreenEdges().testFlag(Qt::LeftEdge)) && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isRightEdge() const
{
    const auto c = client();
    return (c->isMaximizedHorizontally() || c->adjacentScreenEdges().testFlag(Qt::RightEdge)) && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isTopEdge() const
{
    const auto c = client();
    return (c->isMaximizedVertically() || c->adjacentScreenEdges().testFlag(Qt::TopEdge)) && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isBottomEdge() const
{
    const auto c = client();
    return (c->isMaximizedVertically() || c->adjacentScreenEdges().testFlag(Qt::BottomEdge)) && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::hideTitleBar() const
{
    return m_internalSettings->hideTitleBar() && !client()->isShaded();
}

bool Decoration::isGadgetExplorer() const
{
    const auto c = client();
    if(c->caption() == QStringLiteral("plasmashell_explorer") && c->windowClass() == QStringLiteral("plasmashell plasmashell")) return true;
    return false;
}
bool Decoration::hideIcon() const
{
    if(isGadgetExplorer()) return true;
    return m_internalSettings->hideIcon() && !client()->isShaded();
}

bool Decoration::hideCaption() const
{
    if(isGadgetExplorer()) return true;
    return m_internalSettings->hideCaption() && !client()->isShaded();
}

bool Decoration::hideInnerBorder() const
{
    if(isGadgetExplorer()) return true;
    return m_internalSettings->hideInnerBorder() && !client()->isShaded();
}

bool Decoration::outlinesEnabled() const
{
    return true;
}
}
