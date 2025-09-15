#pragma once

#include <chrono>

#include <QObject>
#include <QPointer>
#include <QPropertyAnimation>

#ifdef BUILD_KF6
#include "window.h"
#include "effect/effecthandler.h"
#include "effect/effectwindow.h"
#include "opengl/glshadermanager.h"
#include "opengl/glshader.h"
#include "opengl/gltexture.h"
#include "core/renderviewport.h"
#include "core/pixelgrid.h"
#else
#include <kwineffects.h>
#include <kwinglutils.h>
#endif

#include <KDecoration3/DecorationButton>
#include <SMOD/Decoration/BreezeDecoration>
typedef Breeze::Decoration SmodDecoration;


// TODO remove "+ 1.0" when I fix the textures
#define MINMAXGLOW_SML 9.0f
#define MINMAXGLOW_SMT 8.0f
#define CLOSEGLOW_SML  9.0f
#define CLOSEGLOW_SMT  8.0f

namespace KWin
{

enum WindowButtonsDPI
{
    DPI_100_PERCENT,
    DPI_125_PERCENT,
    DPI_150_PERCENT,
    DPI_175_PERCENT
};

class GlowHandler;

class SmodGlowEffect : public Effect
{
    Q_OBJECT

public:
    SmodGlowEffect();
    ~SmodGlowEffect() override;

    void reconfigure(ReconfigureFlags flags) override;
    void prePaintWindow(EffectWindow *w, WindowPrePaintData &data, std::chrono::milliseconds presentTime) override;
#ifdef BUILD_KF6
    void paintWindow(const RenderTarget &renderTarget, const RenderViewport &viewport, EffectWindow *w, int mask, QRegion region, WindowPaintData &data) override;
#else
    void paintWindow(EffectWindow *w, int mask, QRegion region, WindowPaintData &data) override;
#endif
    void postPaintWindow(EffectWindow *w) override;

    static bool supported();

    bool isActive() const override
    {
        return m_active;
    }

    int requestedEffectChainPosition() const override
    {
        return 23;
    }

private Q_SLOTS:
    void windowAdded(EffectWindow *w);
    void windowClosed(EffectWindow *w);
    void windowMaximizedStateChanged(EffectWindow *w, bool horizontal, bool vertical);
    void windowMinimized(EffectWindow *w);
    void windowStartUserMovedResized(EffectWindow *w);
    void windowDecorationChanged(EffectWindow *w);
    void effectWindowFullScreenChanged(EffectWindow* w);

private:
    void setupEffectHandlerConnections();
    void setupEffectWindowConnections(const EffectWindow *w);
    void registerWindow(const EffectWindow *w);
    void unregisterWindow(const EffectWindow *w);
    void loadTextures();
    void stopAllAnimations(const EffectWindow *w);
    QString currentlyRegisteredPath;


    bool m_resourcesFound = false;
    bool m_active = false;
    int previousDecorationCount = 0;
    std::unique_ptr<GLTexture> m_texture_minimize, m_texture_maximize, m_texture_close;
    std::unique_ptr<GLShader> m_shader;
    QHash<const EffectWindow*, GlowHandler*> windows = QHash<const EffectWindow*, GlowHandler*>();
    QRegion m_prevPaint = QRegion();
    QMatrix4x4 colorMatrix(const float &brightness, const float &saturation) const;

    WindowButtonsDPI m_current_dpi = DPI_100_PERCENT, m_next_dpi = DPI_100_PERCENT;
    bool m_needsDpiChange = false;
};

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

            QObject::connect(hoverAnimation, &QAbstractAnimation::finished, this, &GlowAnimationHandler::animFinished, Qt::UniqueConnection);
        } else {
            return;
        }

        hoverAnimation->setEasingCurve(QEasingCurve::OutQuad);
        hoverAnimation->setStartValue(m_hoverProgress);
        hoverAnimation->setEndValue(endValue);
        //hoverAnimation->setDuration(0.75 + qRound(100 * qAbs(m_hoverProgress - endValue)));
        hoverAnimation->setDuration( //(int)std::chrono::milliseconds(
#ifdef BUILD_KF6
            (int)(0.75 + qRound(100 * qAbs(m_hoverProgress - endValue))) * effects->animationTimeFactor()
#else
            (int)SmodGlowEffect::animationTime(0.75 + qRound(100 * qAbs(m_hoverProgress - endValue)))
#endif
        //)
        );

        hoverAnimation->start();
        Q_EMIT animStarted();
    }

    void stopHoverAnimation()
    {
        QPropertyAnimation *hoverAnimation = m_hoverAnimation.data();

        if (hoverAnimation)
        {
            hoverAnimation->stop();
            setHoverProgress(0.0);
            //Q_EMIT animFinished();
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
    ~GlowAnimationHandler()
    {
        if(!m_hoverAnimation.isNull())
            delete m_hoverAnimation;
    }

    QPointer<QPropertyAnimation> m_hoverAnimation = QPointer<QPropertyAnimation>();
    qreal m_hoverProgress = 0.0;
    QPoint pos = QPoint();

Q_SIGNALS:
    void animStarted();
    void animFinished();
};

class GlowHandler : public QObject
{
    Q_OBJECT

public:
    GlowHandler(QObject *parent = nullptr) : QObject(parent)
    {
        m_min   = new GlowAnimationHandler(this);
        m_max   = new GlowAnimationHandler(this);
        m_close = new GlowAnimationHandler(this);

        QObject::connect(m_min, &GlowAnimationHandler::animStarted, this, &GlowHandler::animStarted, Qt::UniqueConnection);
        QObject::connect(m_max, &GlowAnimationHandler::animStarted, this, &GlowHandler::animStarted, Qt::UniqueConnection);
        QObject::connect(m_close, &GlowAnimationHandler::animStarted, this, &GlowHandler::animStarted, Qt::UniqueConnection);

        QObject::connect(m_min, &GlowAnimationHandler::animFinished, this, &GlowHandler::animFinished, Qt::UniqueConnection);
        QObject::connect(m_max, &GlowAnimationHandler::animFinished, this, &GlowHandler::animFinished, Qt::UniqueConnection);
        QObject::connect(m_close, &GlowAnimationHandler::animFinished, this, &GlowHandler::animFinished, Qt::UniqueConnection);
    };

    ~GlowHandler()
    {
        delete m_min;
        delete m_max;
        delete m_close;
    }

    void stopAll()
    {
        m_min->stopHoverAnimation();
        m_max->stopHoverAnimation();
        m_close->stopHoverAnimation();
    }

    GlowAnimationHandler *m_min = nullptr, *m_max = nullptr, *m_close = nullptr;
    QRect m_min_rect = QRect(), m_max_rect = QRect(), m_close_rect = QRect();
    QRegion m_minimizePaintRegion = QRegion();
    QRegion m_maximizePaintRegion = QRegion();
    QRegion m_closePaintRegion = QRegion();
    QMetaObject::Connection m_decoration_connection = QMetaObject::Connection();
    bool m_needsRepaint = false;

public Q_SLOTS:
    void animStarted()
    {
        m_needsRepaint = true;
    }

    void animFinished()
    {
        // TODO redo this
        if (
            (m_min->m_hoverProgress == 0.0 ) //|| m_min->m_hoverProgress == 1.0)
            &&
            (m_max->m_hoverProgress == 0.0 ) //|| m_max->m_hoverProgress == 1.0)
            &&
            (m_close->m_hoverProgress == 0.0 ) //|| m_close->m_hoverProgress == 1.0)
        )
        {
            m_needsRepaint = false;
        }
    }
};



}
