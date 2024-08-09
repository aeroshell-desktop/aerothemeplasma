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
    KConfig config(":/effects/smodsnap/animation/animrc");
    KConfigGroup generalGroup(&config, "General");

    m_frames   = generalGroup.readEntry("frames", 0);
    m_speed    = generalGroup.readEntry("speed",  0);
    m_scale    = generalGroup.readEntry("scale",  1.0);
    int width  = generalGroup.readEntry("width",  0);
    int height = generalGroup.readEntry("height", 0);
    m_size     = QPoint(width, height);

    m_texture.resize(m_frames);

    for (int i = 0; i < m_frames; ++i)
    {
        m_texture[i].reset(new GLTexture(QPixmap(":/effects/smodsnap/animation/frame" + QString::number(i + 1))));
        m_texture[i]->setFilter(GL_LINEAR);
        m_texture[i]->setWrapMode(GL_CLAMP_TO_EDGE);
    }
}

void SmodSnapEffect::paintScreen(int mask, const QRegion &region, ScreenPaintData &data)
{
    effects->paintScreen(mask, region, data);

    if (anim1->m_active || anim2->m_active)
    {
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        ShaderManager::instance()->pushShader(m_shader.get());

        const auto scale = effects->renderTargetScale();

        if (!anim1->m_finished)
        {
            QMatrix4x4 mvp = data.projectionMatrix();
            mvp.translate(anim1->m_rect.x() * scale, anim1->m_rect.y() * scale);
            m_shader->setUniform(GLShader::ModelViewProjectionMatrix, mvp);
            GLTexture *texture = m_texture[anim1->m_frame].get();
            texture->bind();
            texture->render(anim1->m_rect, scale);
            texture->unbind();
        }

        if (!anim2->m_finished)
        {
            QMatrix4x4 mvp = data.projectionMatrix();
            mvp.translate(anim2->m_rect.x() * scale, anim2->m_rect.y() * scale);
            m_shader->setUniform(GLShader::ModelViewProjectionMatrix, mvp);
            GLTexture *texture = m_texture[anim2->m_frame].get();
            texture->bind();
            texture->render(anim2->m_rect, scale);
            texture->unbind();
        }

        ShaderManager::instance()->popShader();
        glDisable(GL_BLEND);
    }
}

}
