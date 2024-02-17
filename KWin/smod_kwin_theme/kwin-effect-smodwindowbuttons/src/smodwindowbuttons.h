#pragma once

/*
    KWin - the KDE window manager
    This file is part of the KDE project.

    SPDX-FileCopyrightText: 2010 Martin Gräßlin <mgraesslin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include <chrono>

#include <QObject>
#include <QPropertyAnimation>

#include <kwineffects.h>
#include <kwinglutils.h>

#include <KDecoration2/DecorationButton>

namespace KWin
{

class GlowAnimationHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal hoverProgress READ hoverProgress WRITE setHoverProgress);

public:
    GlowAnimationHandler(QObject *parent = nullptr) : QObject(parent), m_hoverProgress(0.0) {};

    void startHoverAnimation(qreal endValue)
    {
        QPropertyAnimation *hoverAnimation = m_hoverAnimation.data();

        if (hoverAnimation)
        {
            if (hoverAnimation->endValue() == endValue)
            {
                return;
            }

            hoverAnimation->stop();
        } else if (m_hoverProgress != endValue)
        {
            hoverAnimation = new QPropertyAnimation(this, "hoverProgress");
            m_hoverAnimation = hoverAnimation;
        } else {
            return;
        }

        hoverAnimation->setEasingCurve(QEasingCurve::OutQuad);
        hoverAnimation->setStartValue(m_hoverProgress);
        hoverAnimation->setEndValue(endValue);
        hoverAnimation->setDuration(0.75 + qRound(150 * qAbs(m_hoverProgress - endValue)));
        hoverAnimation->start();
    }

    void stopHoverAnimation()
    {
        QPropertyAnimation *hoverAnimation = m_hoverAnimation.data();

        if (hoverAnimation)
        {
            hoverAnimation->stop();
            setHoverProgress(0.0);
        }
    }

    qreal hoverProgress() const
    {
        return m_hoverProgress;
    };

    void setHoverProgress(qreal hoverProgress)
    {
        if (m_hoverProgress != hoverProgress)
        {
            m_hoverProgress = hoverProgress;
        }
    }

    QPointer<QPropertyAnimation> m_hoverAnimation;
    qreal m_hoverProgress;
    QPoint pos;
};

class GlowHandler : public QObject
{
    Q_OBJECT

public:
    GlowHandler(QObject *parent = nullptr) : QObject(parent)
    {
        m_min = new GlowAnimationHandler(this);
        m_max = new GlowAnimationHandler(this);
        m_close = new GlowAnimationHandler(this);
    };

    void stopAll()
    {
        m_min->stopHoverAnimation();
        m_max->stopHoverAnimation();
        m_close->stopHoverAnimation();
    }

    GlowAnimationHandler *m_min, *m_max, *m_close;
};

class SmodWindowButtonsEffect : public Effect
{
    Q_OBJECT

public:
    SmodWindowButtonsEffect();
    ~SmodWindowButtonsEffect() override;

    void reconfigure(ReconfigureFlags flags) override;
    void prePaintWindow(EffectWindow *w, WindowPrePaintData &data, std::chrono::milliseconds presentTime) override;
    void paintWindow(EffectWindow *w, int mask, QRegion region, WindowPaintData &data) override;
    void postPaintWindow(EffectWindow *w) override;

    static bool supported();

    bool isActive() const override
    {
        return m_active;
    }

    int requestedEffectChainPosition() const override
    {
        return 90;
    }

private Q_SLOTS:
    void windowAdded(KWin::EffectWindow *w);
    void windowClosed(KWin::EffectWindow *w);
    void windowMaximizedStateChanged(KWin::EffectWindow *w, bool horizontal, bool vertical);
    void windowMinimized(KWin::EffectWindow *w);
    void windowStartUserMovedResized(KWin::EffectWindow *w);

private:
    void registerWindow(KWin::EffectWindow *w);

    bool m_active;
    std::unique_ptr<GLTexture> m_texture_close, m_texture_maximize, m_texture_minimize;
    QRect m_currentGeometry, m_currentGeometry2, m_currentGeometry3;
    std::unique_ptr<GLShader> m_shader;
    QHash<const EffectWindow*, GlowHandler*> windows;
};
}
