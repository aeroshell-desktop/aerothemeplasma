#include "sizingmargins.h"

namespace Breeze {

SizingMargins::SizingMargins() {}

SizingMargins::~SizingMargins() {}

void SizingMargins::loadSizingMargins()
{
    QSettings settings(":/smod/decoration/sizingmargins", QSettings::IniFormat);
    // GlowSizing
    m_glowSizing.margin_left   = settings.value("Glow/margin_left",   24).toInt();
    m_glowSizing.margin_right  = settings.value("Glow/margin_right",  25).toInt();
    m_glowSizing.margin_top    = settings.value("Glow/margin_top",    17).toInt();
    m_glowSizing.margin_bottom = settings.value("Glow/margin_bottom", 18).toInt();

    m_glowSizing.active_opacity   = settings.value("Glow/active_opacity",   255).toInt() / 255.0;
    m_glowSizing.inactive_opacity = settings.value("Glow/inactive_opacity", 179).toInt() / 255.0;

    // ShadowSizing
    m_shadowSizing.margin_left    = settings.value("Shadow/margin_left",    30).toInt();
    m_shadowSizing.margin_top     = settings.value("Shadow/margin_top",     31).toInt();
    m_shadowSizing.margin_right   = settings.value("Shadow/margin_right",   29).toInt();
    m_shadowSizing.margin_bottom  = settings.value("Shadow/margin_bottom",  37).toInt();
    m_shadowSizing.padding_left   = settings.value("Shadow/padding_left",   14).toInt();
    m_shadowSizing.padding_top    = settings.value("Shadow/padding_top",    14).toInt();
    m_shadowSizing.padding_right  = settings.value("Shadow/padding_right",  20).toInt();
    m_shadowSizing.padding_bottom = settings.value("Shadow/padding_bottom", 20).toInt();

    // CommonSizing
    m_commonSizing.height                       = settings.value("Common/height",                      21).toInt();
    m_commonSizing.titlebar_padding_normal      = settings.value("Common/titlebar_padding_normal",      8).toInt();
    m_commonSizing.titlebar_padding_maximized   = settings.value("Common/titlebar_padding_maximized",   0).toInt();
    m_commonSizing.corner_radius                = settings.value("Common/corner_radius",                6).toInt();
    m_commonSizing.caption_button_spacing       = settings.value("Common/caption_button_spacing",       0).toInt();
    m_commonSizing.alternative                  = settings.value("Common/alternative",                  false).toBool();
    m_commonSizing.enable_glow                  = settings.value("Common/enable_glow",                  false).toBool();
    m_commonSizing.caption_button_align_vcenter = settings.value("Common/caption_button_align_vcenter", false).toBool();

    // CloseSizing
    m_closeSizing.width             = settings.value("Close/width",           49).toInt();
    m_closeSizing.margin_left       = settings.value("Close/margin_left",     20).toInt();
    m_closeSizing.margin_top        = settings.value("Close/margin_top",       6).toInt();
    m_closeSizing.margin_right      = settings.value("Close/margin_right",    20).toInt();
    m_closeSizing.margin_bottom     = settings.value("Close/margin_bottom",    8).toInt();
    m_closeSizing.content_left      = settings.value("Close/content_left",     1).toInt();
    m_closeSizing.content_right     = settings.value("Close/content_right",    2).toInt();
    m_closeSizing.content_top       = settings.value("Close/content_top",      2).toInt();
    m_closeSizing.content_bottom    = settings.value("Close/content_bottom",   4).toInt();

    // MaximizeSizing
    m_maximizeSizing.width          = settings.value("Maximize/width",        27).toInt();
    m_maximizeSizing.margin_left    = settings.value("Maximize/margin_left",  12).toInt();
    m_maximizeSizing.margin_top     = settings.value("Maximize/margin_top",    6).toInt();
    m_maximizeSizing.margin_right   = settings.value("Maximize/margin_right", 12).toInt();
    m_maximizeSizing.margin_bottom  = settings.value("Maximize/margin_bottom", 8).toInt();
    m_maximizeSizing.content_left   = settings.value("Maximize/content_left",  2).toInt();
    m_maximizeSizing.content_right  = settings.value("Maximize/content_right", 1).toInt();
    m_maximizeSizing.content_top    = settings.value("Maximize/content_top",   2).toInt();
    m_maximizeSizing.content_bottom = settings.value("Maximize/content_bottom",4).toInt();

    // MinimizeSizing
    m_minimizeSizing.width          = settings.value("Minimize/width",        29).toInt();
    m_minimizeSizing.margin_left    = settings.value("Minimize/margin_left",  12).toInt();
    m_minimizeSizing.margin_top     = settings.value("Minimize/margin_top",    6).toInt();
    m_minimizeSizing.margin_right   = settings.value("Minimize/margin_right", 12).toInt();
    m_minimizeSizing.margin_bottom  = settings.value("Minimize/margin_bottom", 8).toInt();
    m_minimizeSizing.content_left   = settings.value("Minimize/content_left",  3).toInt();
    m_minimizeSizing.content_right  = settings.value("Minimize/content_right", 1).toInt();
    m_minimizeSizing.content_top    = settings.value("Minimize/content_top",   2).toInt();
    m_minimizeSizing.content_bottom = settings.value("Minimize/content_bottom",4).toInt();

    m_frameLeftSizing.width    = settings.value("FrameLeft/width",    9).toInt();
    m_frameLeftSizing.inset    = settings.value("FrameLeft/inset",    2).toInt();
    m_frameRightSizing.width   = settings.value("FrameRight/width",   9).toInt();
    m_frameRightSizing.inset   = settings.value("FrameRight/inset",   2).toInt();
    m_frameBottomSizing.height = settings.value("FrameBottom/height", 9).toInt();

    m_topLeftCorner.width         = settings.value("TopLeft/width",         9).toInt();
    m_topLeftCorner.margin_left   = settings.value("TopLeft/margin_left",   6).toInt();
    m_topLeftCorner.margin_right  = settings.value("TopLeft/margin_right",  2).toInt();
    m_topLeftCorner.margin_top    = settings.value("TopLeft/margin_top",    6).toInt();
    m_topLeftCorner.margin_bottom = settings.value("TopLeft/margin_bottom", 2).toInt();

    m_topRightCorner.width         = settings.value("TopRight/width",         9).toInt();
    m_topRightCorner.margin_left   = settings.value("TopRight/margin_left",   2).toInt();
    m_topRightCorner.margin_right  = settings.value("TopRight/margin_right",  6).toInt();
    m_topRightCorner.margin_top    = settings.value("TopRight/margin_top",    6).toInt();
    m_topRightCorner.margin_bottom = settings.value("TopRight/margin_bottom", 2).toInt();

    m_bottomLeftCorner.width         = settings.value("BottomLeft/width",         9).toInt();
    m_bottomLeftCorner.margin_left   = settings.value("BottomLeft/margin_left",   6).toInt();
    m_bottomLeftCorner.margin_right  = settings.value("BottomLeft/margin_right",  2).toInt();
    m_bottomLeftCorner.margin_top    = settings.value("BottomLeft/margin_top",    2).toInt();
    m_bottomLeftCorner.margin_bottom = settings.value("BottomLeft/margin_bottom", 6).toInt();

    m_bottomRightCorner.width         = settings.value("BottomRight/width",         9).toInt();
    m_bottomRightCorner.margin_left   = settings.value("BottomRight/margin_left",   2).toInt();
    m_bottomRightCorner.margin_right  = settings.value("BottomRight/margin_right",  6).toInt();
    m_bottomRightCorner.margin_top    = settings.value("BottomRight/margin_top",    2).toInt();
    m_bottomRightCorner.margin_bottom = settings.value("BottomRight/margin_bottom", 6).toInt();

    m_leftSide.margin_left      = settings.value("Left/margin_left",       2).toInt();
    m_leftSide.margin_right     = settings.value("Left/margin_right",      6).toInt();
    m_rightSide.margin_left     = settings.value("Right/margin_left",      6).toInt();
    m_rightSide.margin_right    = settings.value("Right/margin_right",     2).toInt();
    m_topSide.margin_top        = settings.value("Top/margin_top",         6).toInt();
    m_topSide.margin_bottom     = settings.value("Top/margin_bottom",      2).toInt();
    m_bottomSide.margin_top     = settings.value("Bottom/margin_top",      2).toInt();
    m_bottomSide.margin_bottom  = settings.value("Bottom/margin_bottom",   6).toInt();

    m_loaded = true;

}
bool SizingMargins::loaded() const
{
    return m_loaded;
}
GlowSizing SizingMargins::glowSizing() const
{
    return m_glowSizing;
}
ShadowSizing SizingMargins::shadowSizing() const
{
    return m_shadowSizing;
}
CommonSizing SizingMargins::commonSizing() const
{
    return m_commonSizing;
}
ButtonSizingMargins SizingMargins::maximizeSizing() const
{
    return m_maximizeSizing;
}
ButtonSizingMargins SizingMargins::minimizeSizing() const
{
    return m_minimizeSizing;
}
ButtonSizingMargins SizingMargins::closeSizing() const
{
    return m_closeSizing;
}
BorderFrame SizingMargins::frameLeftSizing() const
{
    return m_frameLeftSizing;
}
BorderFrame SizingMargins::frameRightSizing() const
{
    return m_frameRightSizing;
}
BorderFrame SizingMargins::frameBottomSizing() const
{
    return m_frameBottomSizing;
}

FrameMargins SizingMargins::topLeftCorner() const
{
    return m_topLeftCorner;
}
FrameMargins SizingMargins::topRightCorner() const
{
    return m_topRightCorner;
}
FrameMargins SizingMargins::bottomLeftCorner() const
{
    return m_bottomLeftCorner;
}
FrameMargins SizingMargins::bottomRightCorner() const
{
    return m_bottomRightCorner;
}
FrameMargins SizingMargins::leftSide() const
{
    return m_leftSide;
}
FrameMargins SizingMargins::rightSide() const
{
    return m_rightSide;
}
FrameMargins SizingMargins::topSide() const
{
    return m_topSide;
}
FrameMargins SizingMargins::bottomSide() const
{
    return m_bottomSide;
}
}
