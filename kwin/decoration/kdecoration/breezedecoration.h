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

#include <KDecoration3/DecoratedWindow>
#include <KDecoration3/Decoration>
#include <KDecoration3/DecorationSettings>

#include <QPalette>
#include <QVariant>
#include <QVariantAnimation>
#include <QByteArray>
#include <iostream>

#define INNER_BORDER_SIZE 2

// This is absolutely needed in Qt6
// even though it absolutely wasn't needed in Qt5
// funny
#if defined(MYSHAREDLIB_LIBRARY)
#  define MYSHAREDLIB_EXPORT Q_DECL_EXPORT
#else
#  define MYSHAREDLIB_EXPORT Q_DECL_IMPORT
#endif

namespace KDecoration3
{
class DecorationButton;
class DecorationButtonGroup;
}

namespace Breeze
{
class MYSHAREDLIB_EXPORT Decoration : public KDecoration3::Decoration
{
    Q_OBJECT

public:
    //* constructor
    explicit Decoration(QObject *parent = nullptr, const QVariantList &args = QVariantList());

    //* destructor
    virtual ~Decoration();

    //* paint
    void paint(QPainter *painter, const QRectF &repaintRegion) override;

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

    QRect buttonRect(KDecoration3::DecorationButtonType button) const;

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
    inline bool isPersonalizeKCM() const;
    inline bool isPolkit() const;
    //@}

Q_SIGNALS:
    void buttonHoverStatus(KDecoration3::DecorationButtonType button, bool hovered, QPoint pos);

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
    void smodPaint(QPainter *painter, const QRectF &repaintRegion);
    void smodPaintGlow(QPainter *painter, const QRectF &repaintRegion);
    void smodPaintOuterBorder(QPainter *painter, const QRectF &repaintRegion);
    void smodPaintTitleBar(QPainter *painter, const QRectF &repaintRegion);
    void updateShadow(bool reconfigured = false);
    std::shared_ptr<KDecoration3::DecorationShadow> smodCreateShadow(bool active);
    void setScaledCornerRadius();

    //*@name border size
    //@{
    inline bool hasBorders() const;
    inline bool hasNoBorders() const;
    inline bool hasNoSideBorders() const;
    //@}

    inline bool outlinesEnabled() const;

    InternalSettingsPtr m_internalSettings;
    KDecoration3::DecorationButtonGroup *m_leftButtons = nullptr;
    KDecoration3::DecorationButtonGroup *m_rightButtons = nullptr;

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
        return settings()->borderSize() > KDecoration3::BorderSize::NoSides;
    }
}

bool Decoration::hasNoBorders() const
{
    if (m_internalSettings && m_internalSettings->mask() & BorderSize) {
        return m_internalSettings->borderSize() == InternalSettings::BorderNone;
    } else {
        return settings()->borderSize() == KDecoration3::BorderSize::None;
    }
}

bool Decoration::hasNoSideBorders() const
{
    if (m_internalSettings && m_internalSettings->mask() & BorderSize) {
        return m_internalSettings->borderSize() == InternalSettings::BorderNoSides;
    } else {
        return settings()->borderSize() == KDecoration3::BorderSize::NoSides;
    }
}

bool Decoration::isMaximized() const
{
    return window()->isMaximized() && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isMaximizedHorizontally() const
{
    return window()->isMaximizedHorizontally() && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isMaximizedVertically() const
{
    return window()->isMaximizedVertically() && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isLeftEdge() const
{
    const auto c = window();
    return (c->isMaximizedHorizontally() || c->adjacentScreenEdges().testFlag(Qt::LeftEdge)) && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isRightEdge() const
{
    const auto c = window();
    return (c->isMaximizedHorizontally() || c->adjacentScreenEdges().testFlag(Qt::RightEdge)) && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isTopEdge() const
{
    const auto c = window();
    return (c->isMaximizedVertically() || c->adjacentScreenEdges().testFlag(Qt::TopEdge)) && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::isBottomEdge() const
{
    const auto c = window();
    return (c->isMaximizedVertically() || c->adjacentScreenEdges().testFlag(Qt::BottomEdge)) && !m_internalSettings->drawBorderOnMaximizedWindows();
}

bool Decoration::hideTitleBar() const
{
    return m_internalSettings->hideTitleBar() && !window()->isShaded();
}

bool Decoration::isGadgetExplorer() const
{
    const auto c = window();
    if(c->caption() == QStringLiteral("plasmashell_explorer") && (c->windowClass() == QStringLiteral("plasmashell plasmashell") || c->windowClass() == QStringLiteral("plasmashell org.kde.plasmashell"))) return true;
    return false;
}
bool Decoration::isPersonalizeKCM() const
{
    if(window()->windowClass() == QStringLiteral("systemsettings systemsettings") && window()->caption().startsWith(QStringLiteral("aerothemeplasma-personalize"))) return true;
    return false;
}

bool Decoration::isPolkit() const
{
    const auto c = window();
    if((c->windowClass() == QStringLiteral("polkit-kde-authentication-agent-1 polkit-kde-authentication-agent-1")) || c->windowClass() == QStringLiteral("polkit-kde-manager polkit-kde-manager") || c->windowClass() == QStringLiteral(" org.kde.polkit-kde-authentication-agent-1")) return true;
    return false;
}
bool Decoration::hideIcon() const
{
    if(isPersonalizeKCM() || isGadgetExplorer() || isPolkit()) return true;
    return m_internalSettings->hideIcon() && !window()->isShaded();
}

bool Decoration::hideCaption() const
{
    // Personalization page
    if(isPersonalizeKCM() || isGadgetExplorer()) return true;
    return m_internalSettings->hideCaption() && !window()->isShaded();
}

bool Decoration::hideInnerBorder() const
{
    // Personalization page
    if(isPersonalizeKCM() || isGadgetExplorer()) return true;
    return m_internalSettings->hideInnerBorder() && !window()->isShaded();
}

bool Decoration::outlinesEnabled() const
{
    return true;
}
}
