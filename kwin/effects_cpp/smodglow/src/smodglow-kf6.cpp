#include "smodglow.h"
#include "smod.h"
#include <QVector2D>
#include <SMOD/Decoration/BreezeDecoration>

typedef Breeze::Decoration SmodDecoration;


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

    m_texture_minimize = GLTexture::upload(SmodDecoration::minimize_glow() /*QPixmap(QStringLiteral(":/effects/smodglow/textures/minimize") + dpiSuffix*/);
    if(!m_texture_minimize)
    {
        printf("Wrong min\n");
        m_active = false;
        return;
    }
    m_texture_minimize->setFilter(GL_LINEAR);
    m_texture_minimize->setWrapMode(GL_CLAMP_TO_EDGE);

    m_texture_maximize = GLTexture::upload(SmodDecoration::maximize_glow() /*QPixmap(QStringLiteral(":/effects/smodglow/textures/maximize") + dpiSuffix*/);
    if(!m_texture_maximize)
    {
        printf("Wrong max\n");
        m_active = false;
        return;
    }

    m_texture_maximize->setFilter(GL_LINEAR);
    m_texture_maximize->setWrapMode(GL_CLAMP_TO_EDGE);

    m_texture_close = GLTexture::upload(SmodDecoration::close_glow() /*QPixmap(QStringLiteral(":/effects/smodglow/textures/close") + dpiSuffix*/);
    if(!m_texture_close)
    {
        printf("Wrong close\n");
        m_active = false;
        return;
    }

    m_texture_close->setFilter(GL_LINEAR);
    m_texture_close->setWrapMode(GL_CLAMP_TO_EDGE);
    m_active = true;
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
    int uniform_bordertop = m_shader->uniformLocation("bordertop");
    int uniform_borderleft = m_shader->uniformLocation("borderleft");
    int uniform_targetrect = m_shader->uniformLocation("targetrect");
    int uniform_texturerect = m_shader->uniformLocation("texturerect");
    const auto scale = viewport.scale();

    {
        float opacity = handler->m_min->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_min_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_min_rect.x(), handler->m_min_rect.y());
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        QSize rect = m_texture_minimize.get()->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
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
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        QSize rect = m_texture_maximize.get()->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
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
        m_shader->setUniform(uniform_bordertop, CLOSEGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, CLOSEGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        QSize rect = m_texture_close.get()->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        GLTexture *texture = m_texture_close.get();
        texture->render(pixelGeometry.size());
    }
    ShaderManager::instance()->popShader();
    glDisable(GL_BLEND);
}

}
