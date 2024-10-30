#include "smodglow.h"
#include "smod.h"

namespace KWin
{

void SmodGlowEffect::loadTextures()
{
    QString dpiSuffix = QStringLiteral("");

    if (m_next_dpi != m_current_dpi)
    {
        switch(m_next_dpi)
        {
            case DPI_125_PERCENT:
                dpiSuffix = QStringLiteral("@1.25x");
                break;
            case DPI_150_PERCENT:
                dpiSuffix = QStringLiteral("@1.5x");
                break;
            default:
                break;
        }

        m_current_dpi = m_next_dpi;
        m_needsDpiChange = false;
    }

    m_texture_minimize = GLTexture::upload(QPixmap(QStringLiteral(":/effects/smodglow/textures/minimize") + dpiSuffix));
    m_texture_minimize->setFilter(GL_LINEAR);
    m_texture_minimize->setWrapMode(GL_CLAMP_TO_EDGE);

    m_texture_maximize = GLTexture::upload(QPixmap(QStringLiteral(":/effects/smodglow/textures/maximize") + dpiSuffix));
    m_texture_maximize->setFilter(GL_LINEAR);
    m_texture_maximize->setWrapMode(GL_CLAMP_TO_EDGE);

    m_texture_close = GLTexture::upload(QPixmap(QStringLiteral(":/effects/smodglow/textures/close") + dpiSuffix));
    m_texture_close->setFilter(GL_LINEAR);
    m_texture_close->setWrapMode(GL_CLAMP_TO_EDGE);
}

void SmodGlowEffect::paintWindow(const RenderTarget &renderTarget, const RenderViewport &viewport, EffectWindow *w, int mask, QRegion region, WindowPaintData &data)
{
    effects->paintWindow(renderTarget, viewport, w, mask, region, data);

    bool scaled = !qFuzzyCompare(data.xScale(), 1.0) && !qFuzzyCompare(data.yScale(), 1.0);
    bool translated = data.xTranslation() || data.yTranslation();
    if ((scaled || (translated || (mask & PAINT_WINDOW_TRANSFORMED))))
    {
        return;
    }

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
    const auto scale = viewport.scale();

    {
        float opacity = handler->m_min->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_min_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_min_rect.x(), handler->m_min_rect.y());
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        GLTexture *texture = m_texture_minimize.get();
        texture->render(pixelGeometry.size());
    }

    {
        float opacity = handler->m_max->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_max_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_max_rect.x(), handler->m_max_rect.y());
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        GLTexture *texture = m_texture_maximize.get();
        texture->render(pixelGeometry.size());
    }

    {
        float opacity = handler->m_close->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_close_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_close_rect.x(), handler->m_close_rect.y());
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        GLTexture *texture = m_texture_close.get();
        texture->render(pixelGeometry.size());
    }

    ShaderManager::instance()->popShader();
    glDisable(GL_BLEND);
}

}
