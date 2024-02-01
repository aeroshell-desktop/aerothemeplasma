/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2018 Alex Nemeth <alex.nemeth329@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "blurshader.h"

#include <kwineffects.h>

static void ensureResources()
{
    Q_INIT_RESOURCE(blur);
}

namespace KWin
{

BlurShader::BlurShader(QObject *parent)
    : QObject(parent)
{
    ensureResources();

    m_shaderReflectsample = ShaderManager::instance()->generateShaderFromFile(
        ShaderTrait::MapTexture,
        QStringLiteral(":/effects/blur/shaders/vertex.vert"),
        QStringLiteral(":/effects/blur/shaders/reflect.frag"));

    m_shaderColorsample = ShaderManager::instance()->generateShaderFromFile(
        ShaderTrait::MapTexture,
        QStringLiteral(":/effects/blur/shaders/vertex.vert"),
        QStringLiteral(":/effects/blur/shaders/color.frag"));

    m_valid = m_shaderReflectsample->isValid() && m_shaderColorsample->isValid();

    if (m_valid) {
        m_mvpMatrixLocationReflectsample = m_shaderReflectsample->uniformLocation("modelViewProjectionMatrix");
        m_opacityLocationReflectsample = m_shaderReflectsample->uniformLocation("opacity");
        m_screenResolutionLocationReflectsample = m_shaderReflectsample->uniformLocation("screenResolution");
        m_windowPosLocationReflectsample = m_shaderReflectsample->uniformLocation("windowPos");
        m_windowSizeLocationReflectsample = m_shaderReflectsample->uniformLocation("windowSize");
        m_translateTextureLocationReflectsample = m_shaderReflectsample->uniformLocation("translate");

        m_colorLocationColorsample = m_shaderColorsample->uniformLocation("color");
        m_mvpMatrixLocationColorsample = m_shaderColorsample->uniformLocation("modelViewProjectionMatrix");
        m_opacityLocationColorsample = m_shaderColorsample->uniformLocation("opacity");

        QMatrix4x4 modelViewProjection;
        const QSize screenSize = effects->virtualScreenSize();
        modelViewProjection.ortho(0, screenSize.width(), screenSize.height(), 0, 0, 65535);

        // Add default values to the uniforms of the shaders
        ShaderManager::instance()->pushShader(m_shaderReflectsample.get());
        m_shaderReflectsample->setUniform(m_mvpMatrixLocationReflectsample, modelViewProjection);
        m_shaderReflectsample->setUniform(m_opacityLocationReflectsample, float(1.0));
        m_shaderReflectsample->setUniform(m_screenResolutionLocationReflectsample, QVector2D(1.0, 1.0));
        m_shaderReflectsample->setUniform(m_windowPosLocationReflectsample, QVector2D(1.0, 1.0));
        m_shaderReflectsample->setUniform(m_windowSizeLocationReflectsample, QVector2D(1.0, 1.0));
        m_shaderReflectsample->setUniform(m_translateTextureLocationReflectsample, float(1.0));

        ShaderManager::instance()->popShader();

        ShaderManager::instance()->pushShader(m_shaderColorsample.get());
        m_shaderColorsample->setUniform(m_mvpMatrixLocationColorsample, modelViewProjection);
        m_shaderColorsample->setUniform(m_colorLocationColorsample, QVector4D(0,0,0,1));
        m_shaderColorsample->setUniform(m_opacityLocationColorsample, float(1.0));
        ShaderManager::instance()->popShader();
    }
}

BlurShader::~BlurShader()
{
}
void BlurShader::setColor(QColor col)
{
    if(!isValid()) return;
    QVector4D vec(col.redF(), col.greenF(), col.blueF(), col.alphaF());

    m_colorColorsample = vec;
    m_shaderColorsample->setUniform(m_colorLocationColorsample, m_colorColorsample);
    return;
    if(vec == m_colorColorsample) {
        return;
    }

}
void BlurShader::setTranslateTexture(bool translate)
{
    if(!isValid()) return;

    m_shaderReflectsample->setUniform(m_translateTextureLocationReflectsample, translate ? float(1.0) : float(0.0));
}

void BlurShader::setModelViewProjectionMatrix(const QMatrix4x4 &matrix, bool color)
{
    if (!isValid()) {
        return;
    }

    if(color)
    {
        if(matrix == m_matrixColorsample)
        {
            return;
        }
        m_matrixColorsample = matrix;
        m_shaderColorsample->setUniform(m_mvpMatrixLocationColorsample, matrix);
        return;
    }

    if (matrix == m_matrixReflectsample) {
        return;
    }

    m_matrixReflectsample = matrix;
    m_shaderReflectsample->setUniform(m_mvpMatrixLocationReflectsample, matrix);
}

void BlurShader::setOpacity(float opacity, bool color)
{
    if (!isValid()) {
        return;
    }
    if(color) m_shaderColorsample->setUniform(m_opacityLocationColorsample, opacity);
    else m_shaderReflectsample->setUniform(m_opacityLocationReflectsample, opacity);
}

void BlurShader::setScreenResolution(const QSize &screenResolution)
{
    if (!isValid()) {
        return;
    }
    const QVector2D screenSize(screenResolution.width(), screenResolution.height());
    m_shaderReflectsample->setUniform(m_screenResolutionLocationReflectsample, screenSize);
}

void BlurShader::setWindowSize(const QSize &windowSize)
{
    const QVector2D wSize(windowSize.width(), windowSize.height());
    m_shaderReflectsample->setUniform(m_windowSizeLocationReflectsample, wSize);
}

void BlurShader::setWindowPosition(const QPoint &pos)
{
    m_shaderReflectsample->setUniform(m_windowPosLocationReflectsample, QVector2D(pos.x(), pos.y()));
}

void BlurShader::bind(bool color)
{
    if (!isValid()) {
        return;
    }
    if(color)
    {
        ShaderManager::instance()->pushShader(m_shaderColorsample.get());
    }
    else
        ShaderManager::instance()->pushShader(m_shaderReflectsample.get());
}

void BlurShader::unbind()
{
    ShaderManager::instance()->popShader();
}

} // namespace KWin
