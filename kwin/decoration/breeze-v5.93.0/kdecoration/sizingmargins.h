#pragma once

#include <QFile>
#include <QString>
#include <QSettings>

namespace Breeze
{
struct ButtonSizingMargins
{
    int width;
    int margin_left;
    int margin_top;
    int margin_right;
    int margin_bottom;
};

struct CommonSizing
{
    int height;
    int corner_radius;
    bool alternative;
    bool enable_glow;
    int caption_button_spacing;
    bool caption_button_align_vcenter;
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

struct BorderFrame
{
    int outer_inset;
    int inner_inset;
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
    ButtonSizingMargins maximizeSizing() const;
    ButtonSizingMargins minimizeSizing() const;
    ButtonSizingMargins closeSizing() const;
    BorderFrame frameTopSizing() const;
    BorderFrame frameLeftSizing() const;
    BorderFrame frameRightSizing() const;
    BorderFrame frameBottomSizing() const;
    bool loaded() const;

private:
    bool m_loaded = false;
    GlowSizing m_glowSizing;
    ShadowSizing m_shadowSizing;
    CommonSizing m_commonSizing;
    ButtonSizingMargins m_maximizeSizing;
    ButtonSizingMargins m_minimizeSizing;
    ButtonSizingMargins m_closeSizing;
    BorderFrame m_frameTopSizing;
    BorderFrame m_frameLeftSizing;
    BorderFrame m_frameRightSizing;
    BorderFrame m_frameBottomSizing;
};
}
