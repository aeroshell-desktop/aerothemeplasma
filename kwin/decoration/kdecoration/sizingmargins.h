#pragma once

#include <QFile>
#include <QString>
#include <QSettings>

namespace Breeze
{
struct ButtonSizingMargins
{
    int width;
    int margin_left;    // Used to render the caption buttons properly
    int margin_top;
    int margin_right;
    int margin_bottom;
    int content_left;   // Used for glyph positioning and alignment
    int content_top;
    int content_right;
    int content_bottom;
};

struct CommonSizing
{
    int height;                         // Titlebar height
    int titlebar_padding_normal;        // Space between the caption button and the inner border of the titlebar
    int titlebar_padding_maximized;     // The same as above but for the maximized state
    int corner_radius;
    bool alternative;
    bool enable_glow;
    int caption_button_spacing;
    bool caption_button_align_vcenter;
    bool group_buttons;                 // Whether buttons should be grouped depending on their placement
};

struct ShadowSizing
{
    int margin_left;
    int margin_top;
    int margin_right;
    int margin_bottom;
    int padding_left;
    int padding_top;
    int padding_right;
    int padding_bottom;
};

struct GlowSizing
{
    int margin_left;
    int margin_right;
    int margin_top;
    int margin_bottom;
    float active_opacity;
    float inactive_opacity;
};

struct FrameMargins
{
    int width = 0;
    int margin_left = 0;
    int margin_right = 0;
    int margin_top = 0;
    int margin_bottom = 0;
};
struct BorderFrame
{
    int width = 0;
    int height = 0;
    int inset = 0;
};

class SizingMargins
{
public:
    SizingMargins();
    ~SizingMargins();
    void loadSizingMargins();

    GlowSizing glowSizing() const;
    ShadowSizing shadowSizing() const;
    CommonSizing commonSizing() const;

    ButtonSizingMargins menuSizing() const;
    ButtonSizingMargins pinSizing() const;
    ButtonSizingMargins shadeSizing() const;
    ButtonSizingMargins overlapSizing() const;
    ButtonSizingMargins underlapSizing() const;

    ButtonSizingMargins helpSizing() const;
    ButtonSizingMargins maximizeSizing() const;
    ButtonSizingMargins minimizeSizing() const;
    ButtonSizingMargins closeSizing() const;
    ButtonSizingMargins closeLoneSizing() const;

    BorderFrame frameLeftSizing() const;
    BorderFrame frameRightSizing() const;
    BorderFrame frameBottomSizing() const;

    FrameMargins topLeftCorner() const;
    FrameMargins topRightCorner() const;
    FrameMargins bottomLeftCorner() const;
    FrameMargins bottomRightCorner() const;

    FrameMargins leftSide() const;
    FrameMargins rightSide() const;
    FrameMargins topSide() const;
    FrameMargins bottomSide() const;
    bool loaded() const;

private:
    bool m_loaded = false;
    GlowSizing m_glowSizing;
    ShadowSizing m_shadowSizing;
    CommonSizing m_commonSizing;

    ButtonSizingMargins m_menuSizing;
    ButtonSizingMargins m_pinSizing;
    ButtonSizingMargins m_shadeSizing;
    ButtonSizingMargins m_underlapSizing;
    ButtonSizingMargins m_overlapSizing;

    ButtonSizingMargins m_helpSizing;
    ButtonSizingMargins m_maximizeSizing;
    ButtonSizingMargins m_minimizeSizing;
    ButtonSizingMargins m_closeSizing;
    ButtonSizingMargins m_closeLoneSizing;

    BorderFrame m_frameLeftSizing;
    BorderFrame m_frameRightSizing;
    BorderFrame m_frameBottomSizing;

    FrameMargins m_topLeftCorner;
    FrameMargins m_topRightCorner;
    FrameMargins m_bottomLeftCorner;
    FrameMargins m_bottomRightCorner;
    FrameMargins m_leftSide;
    FrameMargins m_rightSide;
    FrameMargins m_topSide;
    FrameMargins m_bottomSide;
};
}
