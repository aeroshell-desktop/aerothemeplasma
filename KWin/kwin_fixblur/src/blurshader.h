/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2018 Alex Nemeth <alex.nemeth329@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <kwinglutils.h>

#include <QMatrix4x4>
#include <QObject>
#include <QVector2D>
#include <QVector4D>

namespace KWin
{

class BlurShader : public QObject
{
    Q_OBJECT

public:
    BlurShader(QObject *parent = nullptr);
    ~BlurShader() override;

    bool isValid() const;

    void bind(bool color = false);
    void unbind();

    void setModelViewProjectionMatrix(const QMatrix4x4 &matrix, bool color = false);
    void setOpacity(float opacity, bool color = false);
    void setScreenResolution(const QSize &screenResolution);
    void setWindowSize(const QSize &windowSize);
    void setWindowPosition(const QPoint &pos);
    void setTranslateTexture(bool translate);
    void setColor(QColor color);

private:
    std::unique_ptr<GLShader> m_shaderReflectsample;
    std::unique_ptr<GLShader> m_shaderColorsample;

    int m_screenResolutionLocationReflectsample;
    int m_windowPosLocationReflectsample;
    int m_opacityLocationReflectsample;
    int m_mvpMatrixLocationReflectsample;
    int m_windowSizeLocationReflectsample;
    int m_translateTextureLocationReflectsample;

    int m_colorLocationColorsample;
    int m_mvpMatrixLocationColorsample;
    int m_opacityLocationColorsample;

    QMatrix4x4 m_matrixReflectsample;
    QMatrix4x4 m_matrixColorsample;
    QVector4D m_colorColorsample;
    bool m_valid = false;
    Q_DISABLE_COPY(BlurShader);
};

inline bool BlurShader::isValid() const
{
    return m_valid;
}

} // namespace KWin
