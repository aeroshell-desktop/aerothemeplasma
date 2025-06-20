/*
 * SPDX-FileCopyrightText: 2024 Souris
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <chrono>

#include <QObject>

#define IS_KF6 QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)

#if IS_KF6
#include "effect/effecthandler.h"
#include "effect/effectwindow.h"
#include "opengl/glshadermanager.h"
#include "opengl/glshader.h"
#include "opengl/gltexture.h"
#include "core/renderviewport.h"
#include "core/pixelgrid.h"
#else
#include <kwineffects.h>
#include <kwinglutils.h>
#endif

namespace KWin
{

class SnapAnimation : public QObject
{
    Q_OBJECT

public:
    SnapAnimation() {};

    bool m_active = false;
    bool m_finished = false;
    int m_frame = 0;
    int m_progress = 0;
    std::chrono::milliseconds m_lastPresentTime = std::chrono::milliseconds{0};
    QRect m_rect = QRect();
};

class SmodSnapEffect : public Effect
{
    Q_OBJECT

public:
    SmodSnapEffect();
    ~SmodSnapEffect() override;

    void reconfigure(ReconfigureFlags flags) override;
    void prePaintScreen(ScreenPrePaintData &data, std::chrono::milliseconds presentTime) override;
#if IS_KF6
    void paintScreen(const RenderTarget &renderTarget, const RenderViewport &viewport, int mask, const QRegion &region, Output *screen) override;
#else
    void paintScreen(int mask, const QRegion &region, ScreenPaintData &data) override;
#endif
    void postPaintScreen() override;

    static bool supported();

    bool isActive() const override
    {
        return true;
    }

    int requestedEffectChainPosition() const override
    {
        return 90;
    }

private Q_SLOTS:
    void windowAdded(KWin::EffectWindow *w);

private:
    void loadTextures();

    SnapAnimation *anim1 = nullptr, *anim2 = nullptr;

    int m_frames = 0;
    int m_speed = 0;
    qreal m_scale = 1.0;
    QPoint m_size = QPoint();
    bool needsToMoveAway = false;
    std::vector<std::unique_ptr<GLTexture>> m_texture;
    std::unique_ptr<GLShader> m_shader;
    KWin::EffectWindow *m_window = nullptr;
    bool m_window_valid = false;
    bool m_window_checked_valid = false;
};

}
