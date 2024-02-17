/*
 * based on Kwin Feedback effect
 * based on StartupId in KRunner by Lubos Lunak
 *
 * SPDX-FileCopyrightText: 2001 Lubos Lunak <l.lunak@kde.org>
 * SPDX-FileCopyrightText: 2010 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2020 David Redondo <kde@david-redondo.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "smodwindowbuttons.h"
#include "smod.h"

#include <kwinglutils.h>

#include <SMOD/Decoration/BreezeDecoration>

// internally the SMOD decoration is in the Breeze namespace
// use a typedef to avoid confusion
typedef Breeze::Decoration SmodDecoration;

//Q_LOGGING_CATEGORY(KWIN_EFFECT_SMODWINDOWBUTTONS, "kwin.effect.smodwindowbuttons", QtWarningMsg)

static void ensureResources()
{
    Q_INIT_RESOURCE(smodwindowbuttons);
}

namespace KWin
{

SmodWindowButtonsEffect::SmodWindowButtonsEffect()
    : m_active(true)
{
    connect(effects, &EffectsHandler::windowAdded, this, &SmodWindowButtonsEffect::windowAdded);
    connect(effects, &EffectsHandler::windowClosed, this, &SmodWindowButtonsEffect::windowClosed);
    connect(effects, &EffectsHandler::windowMaximizedStateChanged, this, &SmodWindowButtonsEffect::windowMaximizedStateChanged);
    connect(effects, &EffectsHandler::windowMinimized, this, &SmodWindowButtonsEffect::windowMinimized);
    connect(effects, &EffectsHandler::windowStartUserMovedResized, this, &SmodWindowButtonsEffect::windowStartUserMovedResized);

    reconfigure(ReconfigureAll);

    // is this needed?
    //effects->makeOpenGLContextCurrent();

    m_texture_close.reset(new GLTexture(QPixmap(":/effects/smodwindowbuttons/textures/close")));
    m_texture_close->setFilter(GL_LINEAR);
    m_texture_close->setWrapMode(GL_CLAMP_TO_EDGE);

    m_texture_maximize.reset(new GLTexture(QPixmap(":/effects/smodwindowbuttons/textures/maximize")));
    m_texture_maximize->setFilter(GL_LINEAR);
    m_texture_maximize->setWrapMode(GL_CLAMP_TO_EDGE);

    m_texture_minimize.reset(new GLTexture(QPixmap(":/effects/smodwindowbuttons/textures/minimize")));
    m_texture_minimize->setFilter(GL_LINEAR);
    m_texture_minimize->setWrapMode(GL_CLAMP_TO_EDGE);

    m_shader = ShaderManager::instance()->generateShaderFromFile(
        ShaderTrait::MapTexture,
        QString(),
        QStringLiteral(":/effects/smodwindowbuttons/shaders/shader.frag")
    );
}

SmodWindowButtonsEffect::~SmodWindowButtonsEffect()
{
}

void SmodWindowButtonsEffect::windowAdded(KWin::EffectWindow *w)
{
    qDebug() << "Window added: " << w->windowClass();

    registerWindow(w);
}

void SmodWindowButtonsEffect::registerWindow(KWin::EffectWindow *w)
{
    if (w && w->hasDecoration() && !windows.contains(w))
    {
        // In order to access our custom signal we need to cast to the correct class
        SmodDecoration *decoration = qobject_cast<SmodDecoration*>(w->decoration());

        // if the cast was unsuccessful (the loaded decoration plugin is not SMOD) then return
        if (!decoration)
        {
            qDebug() << "bad cast. not a SMOD decoration";
            return;
        }

        // Attempt to connect to the decoration signal.
        auto connection = QObject::connect(decoration, &SmodDecoration::buttonHoverStatus, this,
        [w, this](KDecoration2::DecorationButtonType button, bool hovered, QPoint pos) {

            GlowAnimationHandler *anim;

            switch (button)
            {
                case KDecoration2::DecorationButtonType::Minimize:
                    qDebug() << w->windowClass() << "  " << "Minimize button hovered " << "x:" << pos.x() << " y:" << pos.y();
                    anim = this->windows.value(w)->m_min;
                    anim->pos = pos + QPoint(-10, -9);
                    break;
                case KDecoration2::DecorationButtonType::Maximize:
                    qDebug() << w->windowClass() << "  " << "Maximize button hovered " << "x:" << pos.x() << " y:" << pos.y();
                    anim = this->windows.value(w)->m_max;
                    anim->pos = pos + QPoint(-10, -9);
                    break;
                case KDecoration2::DecorationButtonType::Close:
                    qDebug() << w->windowClass() << "  " << "Close button hovered " << "x:" << pos.x() << " y:" << pos.y();
                    anim = this->windows.value(w)->m_close;
                    anim->pos = pos + QPoint(-10, -9);
                    break;
                default:
                    return;
            }

            anim->startHoverAnimation(hovered ? 1.0 : 0.0);
        });

        if (!connection)
        {
            qDebug() << "Failed to connect to signal buttonHoverStatus";
            return;
        }

        windows.insert(w, new GlowHandler(this));
    }
}

void SmodWindowButtonsEffect::windowClosed(KWin::EffectWindow *w)
{
    if (windows.contains(w))
    {
        windows.value(w)->stopAll();
        windows.remove(w);
    }
}

void SmodWindowButtonsEffect::windowMaximizedStateChanged(KWin::EffectWindow *w, bool horizontal, bool vertical)
{
    Q_UNUSED(horizontal)
    Q_UNUSED(vertical)

    if (windows.contains(w))
    {
        windows.value(w)->stopAll();
    }
}

void SmodWindowButtonsEffect::windowMinimized(KWin::EffectWindow *w)
{
    if (windows.contains(w))
    {
        windows.value(w)->stopAll();
    }
}

void SmodWindowButtonsEffect::windowStartUserMovedResized(KWin::EffectWindow *w)
{
    if (windows.contains(w))
    {
        windows.value(w)->stopAll();
    }
}

bool SmodWindowButtonsEffect::supported()
{
    return effects->isOpenGLCompositing();
}

void SmodWindowButtonsEffect::reconfigure(Effect::ReconfigureFlags flags)
{
    Q_UNUSED(flags)

    SMOD::registerResource("buttongloweffecttextures");

    if (effects->compositingType() == OpenGLCompositing)
    {
        ensureResources();
    }

    const auto windowlist = effects->stackingOrder();

    for (EffectWindow *window : windowlist)
    {
        registerWindow(window);
    }
}

void SmodWindowButtonsEffect::prePaintWindow(EffectWindow *w, WindowPrePaintData &data, std::chrono::milliseconds presentTime)
{
    if (m_active)
    {
        GLTexture *texture = nullptr, *texture2 = nullptr, *texture3 = nullptr;
        QRegion paintRegion, paintRegion2;

            texture = m_texture_close.get();
            m_currentGeometry = QRect(w->pos().toPoint() + QPoint(w->width(), 0) + QPoint(-66, -8), texture->size());

            texture2 = m_texture_maximize.get();
            m_currentGeometry2 = QRect(w->pos().toPoint() + QPoint(w->width(), 0) + QPoint(-106, -8), texture2->size());

            texture3 = m_texture_minimize.get();
            m_currentGeometry3 = QRect(w->pos().toPoint() + QPoint(w->width(), 0) + QPoint(-206, -8), texture3->size());

            if (windows.contains(w))
            {
                if (windows.value(w))
                {
                    m_currentGeometry = QRect(w->pos().toPoint() + windows.value(w)->m_close->pos, texture->size());
                    m_currentGeometry2 = QRect(w->pos().toPoint() + windows.value(w)->m_max->pos, texture2->size());
                    m_currentGeometry3 = QRect(w->pos().toPoint() + windows.value(w)->m_min->pos, texture3->size());
                }
            }

            paintRegion = m_currentGeometry.united(m_currentGeometry2);
            paintRegion2 = paintRegion.united(m_currentGeometry3);

            data.paint = data.paint.united(paintRegion2);
    }

    effects->prePaintWindow(w, data, presentTime);
}

void SmodWindowButtonsEffect::paintWindow(EffectWindow *w, int mask, QRegion region, WindowPaintData &data)
{
    effects->paintWindow(w, mask, region, data);

    if (!w->hasDecoration())
    {
        return;
    }

    if (m_active)
    {
        GLTexture *texture, *texture2, *texture3;
        texture = m_texture_close.get();
        texture2 = m_texture_maximize.get();
        texture3 = m_texture_minimize.get();

        m_currentGeometry = QRect(w->pos().toPoint() + QPoint(w->width(), 0) + QPoint(-66, -8), texture->size());
        m_currentGeometry2 = QRect(w->pos().toPoint() + QPoint(w->width(), 0) + QPoint(-100, -8), texture2->size());
        m_currentGeometry3 = QRect(w->pos().toPoint() + QPoint(w->width(), 0) + QPoint(-200, -8), texture3->size());


        if (windows.contains(w))
		{
			if (windows.value(w))
			{
                m_currentGeometry = QRect(w->pos().toPoint() + windows.value(w)->m_close->pos, texture->size());
                m_currentGeometry2 = QRect(w->pos().toPoint() + windows.value(w)->m_max->pos, texture2->size());
                m_currentGeometry3 = QRect(w->pos().toPoint() + windows.value(w)->m_min->pos, texture3->size());
			}
		}

        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

        texture->bind();

        ShaderManager::instance()->pushShader(m_shader.get());

        float opacity = 0.0f;

		if (windows.contains(w))
		{
			if (windows.value(w))
			{
                opacity = windows.value(w)->m_close->hoverProgress();
			}
		}

        const auto scale = effects->renderTargetScale();

        {
            QMatrix4x4 mvp = data.projectionMatrix();

            int uniform_opacity = ShaderManager::instance()->getBoundShader()->uniformLocation("opacity");

            mvp.translate(m_currentGeometry.x() * scale, m_currentGeometry.y() * scale);
            ShaderManager::instance()->getBoundShader()->setUniform(GLShader::ModelViewProjectionMatrix, mvp);
            ShaderManager::instance()->getBoundShader()->setUniform(uniform_opacity, opacity);
            texture->render(m_currentGeometry, scale);

            ShaderManager::instance()->popShader();
            texture->unbind();
            glDisable(GL_BLEND);
        }

        {
            if (windows.contains(w))
            {
                if (windows.value(w))
                {
                    opacity = windows.value(w)->m_max->hoverProgress();
                    m_currentGeometry2 = QRect(w->pos().toPoint() + windows.value(w)->m_max->pos, texture2->size());
                }
            }


            glEnable(GL_BLEND);
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

            texture2->bind();
            ShaderManager::instance()->pushShader(m_shader.get());

            QMatrix4x4 mvp = data.projectionMatrix();

            int uniform_opacity = ShaderManager::instance()->getBoundShader()->uniformLocation("opacity");

            mvp.translate(m_currentGeometry2.x() * scale, m_currentGeometry2.y() * scale);
            ShaderManager::instance()->getBoundShader()->setUniform(GLShader::ModelViewProjectionMatrix, mvp);
            ShaderManager::instance()->getBoundShader()->setUniform(uniform_opacity, opacity);
            texture2->render(m_currentGeometry2, scale);

            ShaderManager::instance()->popShader();
            texture2->unbind();
            glDisable(GL_BLEND);
        }

        {
            if (windows.contains(w))
            {
                if (windows.value(w))
                {
                    opacity = windows.value(w)->m_min->hoverProgress();
                    m_currentGeometry3 = QRect(w->pos().toPoint() + windows.value(w)->m_min->pos, texture3->size());
                }
            }


            glEnable(GL_BLEND);
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

            texture3->bind();
            ShaderManager::instance()->pushShader(m_shader.get());

            QMatrix4x4 mvp = data.projectionMatrix();

            int uniform_opacity = ShaderManager::instance()->getBoundShader()->uniformLocation("opacity");

            mvp.translate(m_currentGeometry3.x() * scale, m_currentGeometry3.y() * scale);
            ShaderManager::instance()->getBoundShader()->setUniform(GLShader::ModelViewProjectionMatrix, mvp);
            ShaderManager::instance()->getBoundShader()->setUniform(uniform_opacity, opacity);
            texture3->render(m_currentGeometry3, scale);

            ShaderManager::instance()->popShader();
            texture3->unbind();
            glDisable(GL_BLEND);
        }
    }
}

void SmodWindowButtonsEffect::postPaintWindow(EffectWindow *w)
{
    if (m_active)
    {
        effects->addRepaint(m_currentGeometry);
        effects->addRepaint(m_currentGeometry2);
        effects->addRepaint(m_currentGeometry3);
    }

    effects->postPaintWindow(w);
}

}
