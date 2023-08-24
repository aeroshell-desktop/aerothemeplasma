/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2018 Alex Nemeth <alex.nemeth329@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <kwineffects.h>
#include <kwinglplatform.h>
#include <kwinglutils.h>

#include <KF5/KWayland/Server/blur_interface.h>
#include <KF5/KWayland/Server/display.h>
#include <KF5/KWayland/Server/surface_interface.h>
#include <QStack>
#include <QVector2D>
#include <QVector>
#include <QDir>
#include <QSharedMemory>

namespace KWin
{

static const int borderSize = 5;

class BlurShader;

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
    void drawWindow(EffectWindow *w, int mask, const QRegion &region, WindowPaintData &data) override;

    bool provides(Feature feature) override;
    bool isActive() const override;

    int requestedEffectChainPosition() const override
    {
        return 21;
    }

    bool eventFilter(QObject *watched, QEvent *event) override;

    bool blocksDirectScanout() const override;
    bool isWindowValid(KWin::EffectWindow *w);
    bool shouldColorize(KWin::EffectWindow *w);
    bool readMemory(bool* skipFunc);
public Q_SLOTS:
    void slotWindowAdded(KWin::EffectWindow *w);
    void slotWindowDeleted(KWin::EffectWindow *w);
    void slotPropertyNotify(KWin::EffectWindow *w, long atom);
    void slotScreenGeometryChanged();
    void setupDecorationConnections(EffectWindow *w);

private:
    QRect expand(const QRect &rect) const;
    QRegion expand(const QRegion &region) const;
    QRegion blurRegion(const EffectWindow *w, bool internal = true) const;
    QRegion decorationBlurRegion(const EffectWindow *w) const;
    bool decorationSupportsBlurBehind(const EffectWindow *w) const;
    bool shouldBlur(const EffectWindow *w, int mask, const WindowPaintData &data) const;
    void updateBlurRegion(EffectWindow *w);
    void doBlur(const QRegion &shape, const QRect &screen, const float opacity, const QMatrix4x4 &screenProjection, bool isDock, QRect windowRect, bool active = false, bool reflect = true);
    void uploadRegion(QVector2D *&map, const QRegion &region, const int downSampleIterations);
    Q_REQUIRED_RESULT bool uploadGeometry(GLVertexBuffer *vbo, const QRegion &blurRegion, const QRegion &windowRegion);

    void renderReflection(GLVertexBuffer *vbo, int vboStart, int blurRectCount, const QMatrix4x4 &screenProjection, QPoint windowPosition, QSize windowSize, float opacity);
    void renderColorization(GLVertexBuffer *vbo, int vboStart, int blurRectCount, const QMatrix4x4 &screenProjection, float opacity, bool active);
    void updateTexture();
private:
    BlurShader *m_shader;

    GLTexture* m_reflectionTexture;
    QString m_defaultTexturePath = QDir::homePath() + "/.emerald/theme/reflection.png";
    QString m_texturePath = "";
    bool m_translateTexture = true;
    bool m_enableColorization = true;
    QStringList m_excludedWindows;
    QStringList m_excludedWindowsColorization;

    QColor m_accentColor;
    QColor m_accentColorInactive;
    QColor m_accentColorInactiveTransparent;
    bool m_transparencyEnabled = true;
    bool m_firstTimeReconfigure = false;

    long net_wm_blur_region = 0;
    QRegion m_paintedArea; // keeps track of all painted areas (from bottom to top)
    QRegion m_currentBlur; // keeps track of the currently blured area of the windows(from bottom to top)

    int m_downSampleIterations = 1; // number of times the texture will be downsized to half size
    int m_offset;
    int m_expandSize;
    int m_scalingFactor;

    struct OffsetStruct
    {
        float minOffset;
        float maxOffset;
        int expandSize;
    };

    QVector<OffsetStruct> blurOffsets;

    struct BlurValuesStruct
    {
        int iteration;
        float offset;
    };

    QVector<BlurValuesStruct> blurStrengthValues;

    QMap<EffectWindow *, QMetaObject::Connection> windowBlurChangedConnections;
    QMap<const EffectWindow *, QRegion> blurRegions;

    QSharedMemory m_sharedMemory;
};

inline bool BlurEffect::provides(Effect::Feature feature)
{
    if (feature == Blur) {
        return true;
    }
    return KWin::Effect::provides(feature);
}

} // namespace KWin
