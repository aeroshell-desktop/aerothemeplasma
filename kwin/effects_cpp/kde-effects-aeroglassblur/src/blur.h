/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2018 Alex Nemeth <alex.nemeth329@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include "effect/effect.h"
#include "opengl/glutils.h"
#include "window.h"

#include <QList>
#include <QFile>
#include <QSharedMemory>
#include <QDir>
#include <KSvg/FrameSvg>
#include <QDBusConnection>
#include <QDBusMessage>
#include <KConfigWatcher>
#include <KSharedConfig>

#include <unordered_map>

namespace KWin
{

class BlurManagerInterface;

struct BlurRenderData
{
    /// Temporary render targets needed for the Dual Kawase algorithm, the first texture
    /// contains not blurred background behind the window, it's cached.
    std::vector<std::unique_ptr<GLTexture>> textures;
    std::vector<std::unique_ptr<GLFramebuffer>> framebuffers;
};

struct BlurEffectData
{
    /// The region that should be blurred behind the window
    std::optional<QRegion> content;

    /// The region that should be blurred behind the frame
    std::optional<QRegion> frame;

    /// The render data per screen. Screens can have different color spaces.
    std::unordered_map<Output *, BlurRenderData> render;
};

class BlurEffect : public KWin::Effect
{
    Q_OBJECT

public:
    BlurEffect();
    ~BlurEffect() override;

    static bool supported();
    static bool enabledByDefault();

    void reconfigure(ReconfigureFlags flags) override;
    void prePaintScreen(ScreenPrePaintData &data, std::chrono::milliseconds presentTime) override;
    void prePaintWindow(EffectWindow *w, WindowPrePaintData &data, std::chrono::milliseconds presentTime) override;
    void drawWindow(const RenderTarget &renderTarget, const RenderViewport &viewport, EffectWindow *w, int mask, const QRegion &region, WindowPaintData &data) override;
    QMatrix4x4 colorMatrix(const float &brightness, const float &saturation) const;

    //FF stuff
    QRegion applyBlurRegion(KWin::EffectWindow *w);
    QRegion getForcedNewRegion();
    bool isFirefoxWindowValid(KWin::EffectWindow *w);

    bool provides(Feature feature) override;
    bool isActive() const override;

    int requestedEffectChainPosition() const override
    {
        return 20;
    }

    bool eventFilter(QObject *watched, QEvent *event) override;

    bool blocksDirectScanout() const override;

public Q_SLOTS:
    void slotWindowAdded(KWin::EffectWindow *w);
    void slotWindowDeleted(KWin::EffectWindow *w);
    void slotScreenRemoved(KWin::Output *screen);
    void slotPropertyNotify(KWin::EffectWindow *w, long atom);
    void setupDecorationConnections(EffectWindow *w);

    void slotWindowMaximizedStateChanged(KWin::EffectWindow *w, bool horizontal, bool vertical);
    void slotMinimizedChanged(KWin::EffectWindow *w);

private:
    void initBlurStrengthValues();
    QRegion blurRegion(EffectWindow *w, bool noRoundedCorners = false);
    QRegion decorationBlurRegion(const EffectWindow *w) const;
    bool decorationSupportsBlurBehind(const EffectWindow *w) const;
    bool shouldBlur(const EffectWindow *w, int mask, const WindowPaintData &data) const;
    bool shouldForceBlur(const EffectWindow *w) const;
    bool scaledOrTransformed(const EffectWindow *w, int mask, const WindowPaintData &data) const;
    bool shouldHaveCornerGlow(const EffectWindow *w) const;
    void updateBlurRegion(EffectWindow *w);
    void blur(const RenderTarget &renderTarget, const RenderViewport &viewport, EffectWindow *w, int mask, const QRegion &region, WindowPaintData &data);

    void ensureReflectTexture();
    bool readMemory(bool* skipFunc);
    bool treatAsActive(const EffectWindow *w);

private:
    struct
    {
        std::unique_ptr<GLTexture> sideGlowTexture;
        std::unique_ptr<GLTexture> sideGlowTexture_unfocus;
        std::unique_ptr<GLShader> shader;

        int colorMatrixLocation;
        int textureSizeLocation;
        int windowPosLocation;
        int windowSizeLocation;
        int mvpMatrixLocation;
        int opacityLocation;
        int scaleYLocation;

    } m_glowPass;
    struct
    {
	std::unique_ptr<GLShader> shader;
	std::unique_ptr<GLTexture> reflectTexture;
        int mvpMatrixLocation;
        int colorMatrixLocation;
        int screenResolutionLocation;
        int windowPosLocation;
        int windowSizeLocation;
        int opacityLocation;
        int translateTextureLocation;
    } m_reflectPass;
    struct
    {
        std::unique_ptr<GLShader> shader;
        int mvpMatrixLocation;
        int offsetLocation;
        int halfpixelLocation;
        int colorMatrixLocation;
    } m_downsamplePass;

    struct
    {
        std::unique_ptr<GLShader> shader;
        int mvpMatrixLocation;
        int colorMatrixLocation;
        int offsetLocation;
        int halfpixelLocation;

        int basicColorizationLocation;
        int aeroColorRLocation;
        int aeroColorGLocation;
        int aeroColorBLocation;
        int aeroColorALocation;
        int aeroColorBalanceLocation;
        int aeroAfterglowBalanceLocation;
        int aeroBlurBalanceLocation;
        int aeroColorizeLocation;
    } m_upsamplePass;

    bool m_valid = false;
    long net_wm_blur_region = 0;
    QRegion m_paintedArea; // keeps track of all painted areas (from bottom to top)
    QRegion m_currentBlur; // keeps track of the currently blured area of the windows(from bottom to top)
    Output *m_currentScreen = nullptr;

    size_t m_iterationCount; // number of times the texture will be downsized to half size
    int m_offset;
    int m_expandSize;
    QStringList m_windowClasses;
    QStringList m_windowClassesColorization;
    QStringList m_firefoxWindows;
    bool m_blurMatching;
    bool m_blurNonMatching;
    bool m_blurMenus;
    bool m_blurDocks;
    bool m_paintAsTranslucent;

    QString m_texturePath;
    bool m_translateTexture;
    bool m_firstTimeConfig;

    int m_reflectionIntensity;
    int m_aeroIntensity;
    int m_aeroHue;
    int m_aeroSaturation;
    int m_aeroBrightness;

    float m_aeroColorR;
    float m_aeroColorG;
    float m_aeroColorB;
    float m_aeroColorA;

    int m_aeroPrimaryBalance;
    int m_aeroSecondaryBalance;
    int m_aeroBlurBalance;

    int m_aeroPrimaryBalanceInactive;
    int m_aeroBlurBalanceInactive;

    bool m_transparencyEnabled;
    bool m_basicColorization;
    bool m_maximizeColorization;
    bool m_enableCornerGlow;

    struct OffsetStruct
    {
        float minOffset;
        float maxOffset;
        int expandSize;
    };

    QList<OffsetStruct> blurOffsets;

    struct BlurValuesStruct
    {
        int iteration;
        float offset;
    };

    QList<BlurValuesStruct> blurStrengthValues;

    QMap<EffectWindow *, QMetaObject::Connection> windowBlurChangedConnections;
    QMap<EffectWindow *, QMetaObject::Connection> windowExpandedGeometryChangedConnections;
    std::unordered_map<EffectWindow *, BlurEffectData> m_windows;
    std::list<EffectWindow*> m_maximizedWindows;

    static BlurManagerInterface *s_blurManager;
    static QTimer *s_blurManagerRemoveTimer;
    QSharedMemory m_sharedMemory;

    KSvg::FrameSvg defaultSvg;

};

inline bool BlurEffect::provides(Effect::Feature feature)
{
    if (feature == Blur) {
        return true;
    }
    return KWin::Effect::provides(feature);
}

} // namespace KWin
