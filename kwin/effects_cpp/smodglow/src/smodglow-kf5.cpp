#include "smodglow.h"
#include "smod.h"

namespace KWin
{

void SmodGlowEffect::loadTextures()
{
    QString dpiSuffix = "";

    if (m_next_dpi != m_current_dpi)
    {
        switch(m_next_dpi)
        {
            case DPI_125_PERCENT:
                dpiSuffix = "@1.25x";
                break;
            case DPI_150_PERCENT:
                dpiSuffix = "@1.5x";
                break;
            case DPI_175_PERCENT:
                dpiSuffix = "@1.75x";
                break;
            default:
                break;
        }

        m_current_dpi = m_next_dpi;
        m_needsDpiChange = false;
    }

    m_texture_minimize.reset(new GLTexture(QPixmap(":/effects/smodglow/textures/minimize" + dpiSuffix)));
    m_texture_minimize->setFilter(GL_LINEAR);
    m_texture_minimize->setWrapMode(GL_CLAMP_TO_EDGE);

    m_texture_maximize.reset(new GLTexture(QPixmap(":/effects/smodglow/textures/maximize" + dpiSuffix)));
    m_texture_maximize->setFilter(GL_LINEAR);
    m_texture_maximize->setWrapMode(GL_CLAMP_TO_EDGE);

    m_texture_close.reset(new GLTexture(QPixmap(":/effects/smodglow/textures/close" + dpiSuffix)));
    m_texture_close->setFilter(GL_LINEAR);
    m_texture_close->setWrapMode(GL_CLAMP_TO_EDGE);
}

void SmodGlowEffect::paintWindow(EffectWindow *w, int mask, QRegion region, WindowPaintData &data)
{
    effects->paintWindow(w, mask, region, data);

    if (!(windows.contains(w) && windows.value(w) && w->hasDecoration()))
    {
        return;
    }

    GlowHandler *handler = windows.value(w);

    if (!handler->m_needsRepaint)
    {
        return;
    }

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    ShaderManager::instance()->pushShader(m_shader.get());

    int uniform_opacity = m_shader->uniformLocation("opacity");
    const auto scale = effects->renderTargetScale();

    {
        float opacity = handler->m_min->hoverProgress();
        QMatrix4x4 mvp = data.projectionMatrix();
        mvp.translate(handler->m_min_rect.x() * scale, handler->m_min_rect.y() * scale);
        m_shader->setUniform(GLShader::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        GLTexture *texture = m_texture_minimize.get();
        texture->bind();
        texture->render(handler->m_min_rect, scale);
        texture->unbind();
    }

    {
        float opacity = handler->m_max->hoverProgress();
        QMatrix4x4 mvp = data.projectionMatrix();
        mvp.translate(handler->m_max_rect.x() * scale, handler->m_max_rect.y() * scale);
        m_shader->setUniform(GLShader::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        GLTexture *texture = m_texture_maximize.get();
        texture->bind();
        texture->render(handler->m_max_rect, scale);
        texture->unbind();
    }

    {
        float opacity = handler->m_close->hoverProgress();
        QMatrix4x4 mvp = data.projectionMatrix();
        mvp.translate(handler->m_close_rect.x() * scale, handler->m_close_rect.y() * scale);
        m_shader->setUniform(GLShader::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        GLTexture *texture = m_texture_close.get();
        texture->bind();
        texture->render(handler->m_close_rect, scale);
        texture->unbind();
    }

    ShaderManager::instance()->popShader();
    glDisable(GL_BLEND);
}

}
