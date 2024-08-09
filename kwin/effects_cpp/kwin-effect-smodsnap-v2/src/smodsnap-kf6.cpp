/*
 * SPDX-FileCopyrightText: 2024 Souris
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "smodsnap.h"

#include <KConfig>
#include <KConfigGroup>

namespace KWin
{

void SmodSnapEffect::loadTextures()
{
    KConfig config(QStringLiteral(":/effects/smodsnap/animation/animrc"));
    KConfigGroup generalGroup(&config, QStringLiteral("General"));

    m_frames   = generalGroup.readEntry("frames", 0);
    m_speed    = generalGroup.readEntry("speed",  0);
    m_scale    = generalGroup.readEntry("scale",  1.0);
    int width  = generalGroup.readEntry("width",  0);
    int height = generalGroup.readEntry("height", 0);
    m_size     = QPoint(width, height);

    m_texture.resize(m_frames);

    for (int i = 0; i < m_frames; ++i)
    {
        m_texture[i] = GLTexture::upload(QPixmap(QStringLiteral(":/effects/smodsnap/animation/frame") + QString::number(i + 1)));
        m_texture[i]->setFilter(GL_LINEAR);
        m_texture[i]->setWrapMode(GL_CLAMP_TO_EDGE);
    }
}

void SmodSnapEffect::paintScreen(const RenderTarget &renderTarget, const RenderViewport &viewport, int mask, const QRegion &region, Output *screen)
{
    effects->paintScreen(renderTarget, viewport, mask, region, screen);

    if (anim1->m_active || anim2->m_active)
    {
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        ShaderManager::instance()->pushShader(m_shader.get());

        const auto scale = viewport.scale();

        if (!anim1->m_finished)
        {
            const QRectF pixelGeometry = snapToPixelGridF(scaledRect(anim1->m_rect, scale));
            QMatrix4x4 mvp = viewport.projectionMatrix();
            mvp.translate(anim1->m_rect.x(), anim1->m_rect.y());
            m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
            GLTexture *texture = m_texture[anim1->m_frame].get();
            texture->render(pixelGeometry.size());
        }

        if (!anim2->m_finished)
        {
            const QRectF pixelGeometry = snapToPixelGridF(scaledRect(anim2->m_rect, scale));
            QMatrix4x4 mvp = viewport.projectionMatrix();
            mvp.translate(anim2->m_rect.x(), anim2->m_rect.y());
            m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
            GLTexture *texture = m_texture[anim2->m_frame].get();
            texture->render(pixelGeometry.size());
        }

        ShaderManager::instance()->popShader();
        glDisable(GL_BLEND);
    }
}

}
