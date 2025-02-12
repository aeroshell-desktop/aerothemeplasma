/*
 * SPDX-FileCopyrightText: 2024 Souris
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "smodsnap.h"
#include "smod.h"

#include <KDecoration3/Decoration>
#include <KDecoration3/DecoratedWindow>

static void ensureResources()
{
    Q_INIT_RESOURCE(smodsnap);
}

namespace KWin
{

SmodSnapEffect::SmodSnapEffect()
{
    connect(effects, &EffectsHandler::windowAdded, this, &SmodSnapEffect::windowAdded);

    reconfigure(ReconfigureAll);

    // NOTE is this needed?
    //effects->makeOpenGLContextCurrent();

    anim1 = new SnapAnimation();
    anim2 = new SnapAnimation();

    loadTextures();

    m_shader = ShaderManager::instance()->generateShaderFromFile(
        ShaderTrait::MapTexture,
        QString(),
        QStringLiteral(":/effects/smodsnap/shaders/shader.frag")
    );
}

SmodSnapEffect::~SmodSnapEffect()
{
    if (anim1) delete anim1;
    if (anim2) delete anim2;
}

bool SmodSnapEffect::supported()
{
    return effects->isOpenGLCompositing() && SMOD::resourceExists(QStringLiteral("snapeffecttextures"));
}

void SmodSnapEffect::reconfigure(Effect::ReconfigureFlags flags)
{
    Q_UNUSED(flags)

    SMOD::registerResource(QStringLiteral("snapeffecttextures"));

    if (effects->compositingType() == OpenGLCompositing)
    {
        ensureResources();
    }
}

void SmodSnapEffect::windowAdded(KWin::EffectWindow *w)
{
    auto min = [&](int a, int b) -> int
    {
        return a > b ? b : a;
    };
    if (w->isOutline())
    {
        if (!anim1->m_active)
        {
            anim1->m_active = true;
            anim1->m_finished = false;
            anim1->m_frame = 0;
            anim1->m_progress = 0;
            anim1->m_lastPresentTime = std::chrono::milliseconds{0};

            const QPoint framesize = m_size * m_scale;
#if IS_KF6
            const QPoint pos = effects->cursorPos().toPoint() - (framesize / 2);
#else
            const QPoint pos = effects->cursorPos() - (framesize / 2);
#endif

            int dx = w->screen()->geometry().width() - effects->cursorPos().toPoint().x();
            int dy = w->screen()->geometry().height() - effects->cursorPos().toPoint().y();
            printf("%d, %d, %d, %d\n", dx, dy, effects->cursorPos().toPoint().x(), effects->cursorPos().toPoint().y());
            //right side: dx < pos.x
            //bottom side: dy < pos.y
            int rightSide = min(dx, pos.x());
            int bottomSide = min(dy, pos.y());


            anim1->m_rect = QRect(pos, QSize(framesize.x(), framesize.y()));
        }
        else if (!anim2->m_active)
        {
            anim2->m_active = true;
            anim2->m_finished = false;
            anim2->m_frame = 0;
            anim2->m_progress = 0;
            anim2->m_lastPresentTime = std::chrono::milliseconds{0};

            const QPoint framesize = m_size * m_scale;
#if IS_KF6
            const QPoint pos = effects->cursorPos().toPoint() - (framesize / 2);
#else
            const QPoint pos = effects->cursorPos() - (framesize / 2);
#endif
            anim2->m_rect = QRect(pos, QSize(framesize.x(), framesize.y()));
        }
    }
}

void SmodSnapEffect::prePaintScreen(ScreenPrePaintData &data, std::chrono::milliseconds presentTime)
{
    if (anim1->m_active)
    {
        int time = 0;
        if (anim1->m_lastPresentTime.count()) {
            time = (presentTime - anim1->m_lastPresentTime).count();
        }
        anim1->m_lastPresentTime = presentTime;

        // NOTE we need to do (m_frames + 1) here so the last frame
        // will play for the same amount of time as the rest
        anim1->m_progress = (anim1->m_progress + time) % (m_speed * (m_frames + 1));
        anim1->m_frame = (int)((qreal)anim1->m_progress / (qreal)m_speed) % (m_frames + 1);

        if (anim1->m_frame == m_frames)
        {
            anim1->m_finished = true;
        }
        else
        {
            data.paint = data.paint.united(anim1->m_rect);
        }
    }

    if (anim2->m_active)
    {
        int time = 0;
        if (anim2->m_lastPresentTime.count()) {
            time = (presentTime - anim2->m_lastPresentTime).count();
        }
        anim2->m_lastPresentTime = presentTime;

        // NOTE we need to do (m_frames + 1) here so the last animation frame
        // will play for the same amount of time as the rest
        anim2->m_progress = (anim2->m_progress + time) % (m_speed * (m_frames + 1));
        anim2->m_frame = qRound((qreal)anim2->m_progress / (qreal)m_speed) % (m_frames + 1);

        if (anim2->m_frame == m_frames)
        {
            anim2->m_finished = true;
        }
        else
        {
            data.paint = data.paint.united(anim2->m_rect);
        }
    }

    effects->prePaintScreen(data, presentTime);
}

void SmodSnapEffect::postPaintScreen()
{
    if (anim1->m_active)
    {
        effects->addRepaint(anim1->m_rect);

        if (anim1->m_finished)
        {
            anim1->m_active = false;
        }
    }

    if (anim2->m_active)
    {
        effects->addRepaint(anim2->m_rect);

        if (anim2->m_finished)
        {
            anim2->m_active = false;
        }
    }

    effects->postPaintScreen();
}

}
