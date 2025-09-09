#include "smodglow.h"
#include "smod.h"
#include <QVector2D>

namespace KWin
{

QMatrix4x4 SmodGlowEffect::colorMatrix(const float &brightness, const float &saturation) const
{
    QMatrix4x4 saturationMatrix;
    if (saturation != 1.0) {
        const qreal r = (1.0 - saturation) * .2126;
        const qreal g = (1.0 - saturation) * .7152;
        const qreal b = (1.0 - saturation) * .0722;

        saturationMatrix = QMatrix4x4(r + saturation, r, r, 0.0,
                                      g, g + saturation, g, 0.0,
                                      b, b, b + saturation, 0.0,
                                      0, 0, 0, 1.0);
    }

    QMatrix4x4 brightnessMatrix;
    if (brightness != 1.0) {
        brightnessMatrix = QMatrix4x4(brightness, 0, 0, 0,
                                      0, brightness, 0, 0,
                                      0, 0, brightness, 0,
                                      0, 0, 0, brightness);
    }

    return saturationMatrix * brightnessMatrix;
}
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
    double hdr_brightness_correction = 1.0;

    // HDR brightness must be handled by color management in the compositor.
    if (w->screen()->highDynamicRange())
    {
        hdr_brightness_correction = w->screen()->brightnessSetting();
    }

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
    int uniform_colormatrix = m_shader->uniformLocation("colorMatrix");
    const auto scale = viewport.scale();
    QMatrix4x4 colorMat = colorMatrix(data.brightness() * hdr_brightness_correction, data.saturation());

    {
        GLTexture *m_preferred_texture = handler->m_menu->m_textureType == QStringLiteral("minimize") ? m_texture_minimize.get() : m_texture_maximize.get();
        float opacity = handler->m_menu->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_menu_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_menu_rect.x() * scale, handler->m_menu_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_preferred_texture->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        m_preferred_texture->render(pixelGeometry.size());
    }

    {
        GLTexture *m_preferred_texture = handler->m_pin->m_textureType == QStringLiteral("minimize") ? m_texture_minimize.get() : m_texture_maximize.get();
        float opacity = handler->m_pin->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_pin_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_pin_rect.x() * scale, handler->m_pin_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_preferred_texture->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        m_preferred_texture->render(pixelGeometry.size());
    }

    {
        GLTexture *m_preferred_texture = handler->m_shade->m_textureType == QStringLiteral("minimize") ? m_texture_minimize.get() : m_texture_maximize.get();
        float opacity = handler->m_shade->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_shade_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_shade_rect.x() * scale, handler->m_shade_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_preferred_texture->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        m_preferred_texture->render(pixelGeometry.size());
    }

    {
        GLTexture *m_preferred_texture = handler->m_underlap->m_textureType == QStringLiteral("minimize") ? m_texture_minimize.get() : m_texture_maximize.get();
        float opacity = handler->m_underlap->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_underlap_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_underlap_rect.x() * scale, handler->m_underlap_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_preferred_texture->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        m_preferred_texture->render(pixelGeometry.size());
    }

    {
        GLTexture *m_preferred_texture = handler->m_overlap->m_textureType == QStringLiteral("minimize") ? m_texture_minimize.get() : m_texture_maximize.get();
        float opacity = handler->m_overlap->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_overlap_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_overlap_rect.x() * scale, handler->m_overlap_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_preferred_texture->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        m_preferred_texture->render(pixelGeometry.size());
    }


    {
        GLTexture *m_preferred_texture = handler->m_help->m_textureType == QStringLiteral("minimize") ? m_texture_minimize.get() : m_texture_maximize.get();
        float opacity = handler->m_help->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_help_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_help_rect.x() * scale, handler->m_help_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_preferred_texture->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        m_preferred_texture->render(pixelGeometry.size());
    }

    {
        GLTexture *m_preferred_texture = handler->m_min->m_textureType == QStringLiteral("minimize") ? m_texture_minimize.get() : m_texture_maximize.get();
        float opacity = handler->m_min->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_min_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_min_rect.x() * scale, handler->m_min_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_preferred_texture->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        m_preferred_texture->render(pixelGeometry.size());
    }

    {
        GLTexture *m_preferred_texture = handler->m_max->m_textureType == QStringLiteral("minimize") ? m_texture_minimize.get() : m_texture_maximize.get();
        float opacity = handler->m_max->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_max_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_max_rect.x() * scale, handler->m_max_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, MINMAXGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, MINMAXGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_preferred_texture->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        m_preferred_texture->render(pixelGeometry.size());
    }

    {
        float opacity = handler->m_close->hoverProgress() * w->opacity() * data.opacity();
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(handler->m_close_rect, scale));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(handler->m_close_rect.x() * scale, handler->m_close_rect.y() * scale);
        m_shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        m_shader->setUniform(uniform_opacity, opacity);
        m_shader->setUniform(uniform_bordertop, CLOSEGLOW_SMT);
        m_shader->setUniform(uniform_borderleft, CLOSEGLOW_SML);
        m_shader->setUniform(uniform_targetrect, QVector2D(pixelGeometry.width(), pixelGeometry.height()));
        m_shader->setUniform(uniform_colormatrix, colorMat);
        QSize rect = m_texture_close.get()->size();
        m_shader->setUniform(uniform_texturerect, QVector2D(rect.width(), rect.height()));
        GLTexture *texture = m_texture_close.get();
        texture->render(pixelGeometry.size());
    }
    ShaderManager::instance()->popShader();
    glDisable(GL_BLEND);
}

}
