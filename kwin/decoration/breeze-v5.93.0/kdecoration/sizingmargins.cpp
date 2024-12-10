#include "sizingmargins.h"

namespace Breeze {

SizingMargins::SizingMargins() {}

SizingMargins::~SizingMargins() {}

void SizingMargins::loadSizingMargins()
{
    QSettings settings(":/smod/decoration/sizingmargins", QSettings::IniFormat);
    // GlowSizing
    m_glowSizing.margin_left = settings.value("Glow/margin_left", 24).toInt();
    m_glowSizing.margin_right = settings.value("Glow/margin_right", 25).toInt();
    m_glowSizing.margin_top = settings.value("Glow/margin_top", 17).toInt();
    m_glowSizing.margin_bottom = settings.value("Glow/margin_bottom", 18).toInt();

    m_glowSizing.active_opacity = settings.value("Glow/active_opacity", 255).toInt() / 255.0;
    m_glowSizing.inactive_opacity = settings.value("Glow/inactive_opacity", 179).toInt() / 255.0;

    // ShadowSizing
    m_shadowSizing.margin_left = settings.value("Shadow/margin_left", 30).toInt();
    m_shadowSizing.margin_top = settings.value("Shadow/margin_top", 31).toInt();
    m_shadowSizing.margin_right = settings.value("Shadow/margin_right", 29).toInt();
    m_shadowSizing.margin_bottom = settings.value("Shadow/margin_bottom", 37).toInt();
    m_shadowSizing.padding_left = settings.value("Shadow/padding_left", 14).toInt();
    m_shadowSizing.padding_top = settings.value("Shadow/padding_top", 14).toInt();
    m_shadowSizing.padding_right = settings.value("Shadow/padding_right", 20).toInt();
    m_shadowSizing.padding_bottom = settings.value("Shadow/padding_bottom", 20).toInt();

    // CommonSizing
    m_commonSizing.height = settings.value("Common/height", 21).toInt();
    m_commonSizing.corner_radius = settings.value("Common/corner_radius", 6).toInt();
    m_commonSizing.alternative = settings.value("Common/alternative", false).toBool();
    m_commonSizing.enable_glow = settings.value("Common/enable_glow", false).toBool();
    m_commonSizing.caption_button_spacing = settings.value("Common/caption_button_spacing", 0).toInt();
    m_commonSizing.caption_button_align_vcenter = settings.value("Common/caption_button_align_vcenter", false).toBool();


    // CloseSizing
    m_closeSizing.width = settings.value("Close/width", 49).toInt();
    m_closeSizing.margin_left = settings.value("Close/margin_left", 20).toInt();
    m_closeSizing.margin_top = settings.value("Close/margin_top", 6).toInt();
    m_closeSizing.margin_right = settings.value("Close/margin_right", 20).toInt();
    m_closeSizing.margin_bottom = settings.value("Close/margin_bottom", 8).toInt();

    // MaximizeSizing
    m_maximizeSizing.width = settings.value("Maximize/width", 27).toInt();
    m_maximizeSizing.margin_left = settings.value("Maximize/margin_left", 12).toInt();
    m_maximizeSizing.margin_top = settings.value("Maximize/margin_top", 6).toInt();
    m_maximizeSizing.margin_right = settings.value("Maximize/margin_right", 12).toInt();
    m_maximizeSizing.margin_bottom = settings.value("Maximize/margin_bottom", 8).toInt();

    // MinimizeSizing
    m_minimizeSizing.width = settings.value("Minimize/width", 29).toInt();
    m_minimizeSizing.margin_left = settings.value("Minimize/margin_left", 12).toInt();
    m_minimizeSizing.margin_top = settings.value("Minimize/margin_top", 6).toInt();
    m_minimizeSizing.margin_right = settings.value("Minimize/margin_right", 12).toInt();
    m_minimizeSizing.margin_bottom = settings.value("Minimize/margin_bottom", 8).toInt();

    m_frameTopSizing.outer_inset = settings.value("FrameTop/outer_inset", 2).toInt();
    m_frameTopSizing.inner_inset = settings.value("FrameTop/inner_inset", 2).toInt();
    m_frameLeftSizing.outer_inset = settings.value("FrameLeft/outer_inset", 2).toInt();
    m_frameLeftSizing.inner_inset = settings.value("FrameLeft/inner_inset", 2).toInt();
    m_frameRightSizing.outer_inset = settings.value("FrameRight/outer_inset", 2).toInt();
    m_frameRightSizing.inner_inset = settings.value("FrameRight/inner_inset", 2).toInt();
    m_frameBottomSizing.outer_inset = settings.value("FrameBottom/outer_inset", 2).toInt();
    m_frameBottomSizing.inner_inset = settings.value("FrameBottom/inner_inset", 2).toInt();

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
BorderFrame SizingMargins::frameTopSizing() const
{
    return m_frameTopSizing;
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

}
