/*
    KWin - the KDE window manager
    This file is part of the KDE project.

    SPDX-FileCopyrightText: 2010 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2020 David Redondo <kde@david-redondo.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
#include "startupfeedback.h"
// Qt
#include <QApplication>
#include <QDBusConnectionInterface>
#include <QDBusServiceWatcher>
#include <QFile>
#include <QPainter>
#include <QSize>
#include <QStandardPaths>
#include <QStyle>
#include <QTimer>
// KDE
#include <KConfigGroup>
#if KWIN_BUILD_X11
#include <KSelectionOwner>
#endif
#include <KSharedConfig>
#include <KWindowSystem>
// KWin
#include "core/output.h"
#include "core/pixelgrid.h"
#include "core/rendertarget.h"
#include "core/renderviewport.h"
#include "cursor.h"
#include "cursorsource.h"
#include "effect/effecthandler.h"
#include "opengl/glutils.h"

// based on StartupId in KRunner by Lubos Lunak
// SPDX-FileCopyrightText: 2001 Lubos Lunak <l.lunak@kde.org>

Q_LOGGING_CATEGORY(KWIN_STARTUPFEEDBACK, "kwin_effect_startupfeedback", QtWarningMsg)

static void ensureResources()
{
    // Must initialize resources manually because the effect is a static lib.
    Q_INIT_RESOURCE(startupfeedback);
}

namespace KWin
{

// number of key frames for bouncing animation
static const int BOUNCE_FRAMES = 20;
// duration between two key frames in msec
static const int BOUNCE_FRAME_DURATION = 30;
// duration of one bounce animation
static const int BOUNCE_DURATION = BOUNCE_FRAME_DURATION * BOUNCE_FRAMES;
// number of key frames for blinking animation
static const int BLINKING_FRAMES = 5;
// duration between two key frames in msec
static const int BLINKING_FRAME_DURATION = 100;
// duration of one blinking animation
static const int BLINKING_DURATION = BLINKING_FRAME_DURATION * BLINKING_FRAMES;
// const int color_to_pixmap[] = { 0, 1, 2, 3, 2, 1 };
static const int FRAME_TO_BOUNCE_YOFFSET[] = {
    -5, -1, 2, 5, 8, 10, 12, 13, 15, 15, 15, 15, 14, 12, 10, 8, 5, 2, -1, -5};
static const QSize BOUNCE_SIZES[] = {
    QSize(16, 16), QSize(14, 18), QSize(12, 20), QSize(18, 14), QSize(20, 12)};
static const int FRAME_TO_BOUNCE_TEXTURE[] = {
    0, 0, 0, 1, 2, 2, 1, 0, 3, 4, 4, 3, 0, 1, 2, 2, 1, 0, 0, 0};
static const int FRAME_TO_BLINKING_COLOR[] = {
    0, 1, 2, 3, 2, 1};
static const QColor BLINKING_COLORS[] = {
    Qt::black, Qt::darkGray, Qt::lightGray, Qt::white, Qt::white};
static const int s_startupDefaultTimeout = 5;

StartupFeedbackEffect::StartupFeedbackEffect()
    : m_bounceSizesRatio(1.0)
#if KWIN_BUILD_X11
    , m_startupInfo(new KStartupInfo(KStartupInfo::CleanOnCantDetect, this))
    , m_selection(nullptr)
#endif
    , m_active(false)
    , m_frame(0)
    , m_progress(0)
    , m_lastPresentTime(std::chrono::milliseconds::zero())
    , m_type(BouncingFeedback)
    , m_cursorSize(24)
    , m_configWatcher(KConfigWatcher::create(KSharedConfig::openConfig("klaunchfeedbackrc", KConfig::NoGlobals)))
    , m_splashVisible(false)
    , m_mouseCur(Cursors::self()->mouse())
{
#if KWIN_BUILD_X11
    // TODO: move somewhere that is x11-specific
    if (KWindowSystem::isPlatformX11()) {
        m_selection = new KSelectionOwner("_KDE_STARTUP_FEEDBACK", effects->xcbConnection(), effects->x11RootWindow(), this);
        m_selection->claim(true);
    }
    connect(m_startupInfo, &KStartupInfo::gotNewStartup, this, [](const KStartupInfoId &id, const KStartupInfoData &data) {
        const auto icon = QIcon::fromTheme(data.findIcon(), QIcon::fromTheme(QStringLiteral("system-run")));
        Q_EMIT effects->startupAdded(id.id(), icon);
    });
    connect(m_startupInfo, &KStartupInfo::gotRemoveStartup, this, [](const KStartupInfoId &id, const KStartupInfoData &data) {
        Q_EMIT effects->startupRemoved(id.id());
    });
    connect(m_startupInfo, &KStartupInfo::gotStartupChange, this, [](const KStartupInfoId &id, const KStartupInfoData &data) {
        const auto icon = QIcon::fromTheme(data.findIcon(), QIcon::fromTheme(QStringLiteral("system-run")));
        Q_EMIT effects->startupChanged(id.id(), icon);
    });
#endif

    connect(effects, &EffectsHandler::startupAdded, this, &StartupFeedbackEffect::gotNewStartup);
    connect(effects, &EffectsHandler::startupRemoved, this, &StartupFeedbackEffect::gotRemoveStartup);
    connect(effects, &EffectsHandler::startupChanged, this, &StartupFeedbackEffect::gotStartupChange);

    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this]() {
        reconfigure(ReconfigureAll);
    });
    reconfigure(ReconfigureAll);

    m_splashVisible = QDBusConnection::sessionBus().interface()->isServiceRegistered(QStringLiteral("org.kde.KSplash"));
    auto serviceWatcher = new QDBusServiceWatcher(QStringLiteral("org.kde.KSplash"), QDBusConnection::sessionBus(), QDBusServiceWatcher::WatchForOwnerChange, this);
    connect(serviceWatcher, &QDBusServiceWatcher::serviceRegistered, this, [this] {
        m_splashVisible = true;
        stop();
    });
    connect(serviceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, [this] {
        m_splashVisible = false;
        gotRemoveStartup({}); // Start the next feedback
    });
}

StartupFeedbackEffect::~StartupFeedbackEffect()
{
}

bool StartupFeedbackEffect::supported()
{
    return effects->isOpenGLCompositing();
}

void StartupFeedbackEffect::reconfigure(Effect::ReconfigureFlags flags)
{
    KConfigGroup c = m_configWatcher->config()->group(QStringLiteral("FeedbackStyle"));
    const bool busyCursor = c.readEntry("BusyCursor", true);

    c = m_configWatcher->config()->group(QStringLiteral("BusyCursorSettings"));
    m_timeout = std::chrono::seconds(c.readEntry("Timeout", s_startupDefaultTimeout));
#if KWIN_BUILD_X11
    m_startupInfo->setTimeout(m_timeout.count());
#endif
    const bool busyBlinking = c.readEntry("Blinking", false);
    const bool busyBouncing = c.readEntry("Bouncing", true);
    if (!busyCursor) {
        m_type = NoFeedback;
    } else if (busyBouncing) {
        m_type = BouncingFeedback;
    } else if (busyBlinking) {
        m_type = BlinkingFeedback;
        if (effects->compositingType() == OpenGLCompositing) {
            ensureResources();
            m_blinkingShader = ShaderManager::instance()->generateShaderFromFile(ShaderTrait::MapTexture, QString(), QStringLiteral(":/effects/startupfeedback/shaders/blinking-startup.frag"));
            if (m_blinkingShader->isValid()) {
                qCDebug(KWIN_STARTUPFEEDBACK) << "Blinking Shader is valid";
            } else {
                qCDebug(KWIN_STARTUPFEEDBACK) << "Blinking Shader is not valid";
            }
        }
    } else {
        m_type = PassiveFeedback;
    }
    if (m_active) {
        stop();
        start(m_startups[m_currentStartup]);
    }
}

void StartupFeedbackEffect::prePaintScreen(ScreenPrePaintData &data, std::chrono::milliseconds presentTime)
{
    int time = 0;
    if (m_lastPresentTime.count()) {
        time = (presentTime - m_lastPresentTime).count();
    }
    m_lastPresentTime = presentTime;

    //if (m_active /*&& effects->isCursorHidden()*/) {
        //stop();
    //}
    if (m_active) {
        // need the unclipped version
        switch (m_type) {
        case BouncingFeedback:
            m_progress = (m_progress + time) % BOUNCE_DURATION;
            m_frame = qRound((qreal)m_progress / (qreal)BOUNCE_FRAME_DURATION) % BOUNCE_FRAMES;
            m_currentGeometry = feedbackRect(); // bounce alters geometry with m_frame
            data.paint = data.paint.united(m_currentGeometry);
            break;
        case BlinkingFeedback:
            m_progress = (m_progress + time) % BLINKING_DURATION;
            m_frame = qRound((qreal)m_progress / (qreal)BLINKING_FRAME_DURATION) % BLINKING_FRAMES;
            break;
        default:
            break; // nothing
        }
    }
    if(m_cursorItem) m_cursorItem->refresh();
    effects->prePaintScreen(data, presentTime);
}

void StartupFeedbackEffect::paintScreen(const RenderTarget &renderTarget, const RenderViewport &viewport, int mask, const QRegion &region, Output *screen)
{
    effects->paintScreen(renderTarget, viewport, mask, region, screen);
    if (m_active) {
        if(m_showBusyCursor) {
           m_cursorItem->refresh();
           effects->addRepaintFull();
        }
        return;
        GLTexture *texture;
        switch (m_type) {
        case BouncingFeedback:
            texture = m_bouncingTextures[FRAME_TO_BOUNCE_TEXTURE[m_frame]].get();
            break;
        case BlinkingFeedback: // fall through
        case PassiveFeedback:
            texture = m_texture.get();
            break;
        default:
            return; // safety
        }
        if (!texture) {
            return;
        }
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        GLShader *shader = nullptr;
        if (m_type == BlinkingFeedback && m_blinkingShader && m_blinkingShader->isValid()) {
            const QColor &blinkingColor = BLINKING_COLORS[FRAME_TO_BLINKING_COLOR[m_frame]];
            ShaderManager::instance()->pushShader(m_blinkingShader.get());
            shader = m_blinkingShader.get();
            m_blinkingShader->setUniform(GLShader::ColorUniform::Color, blinkingColor);
        } else {
            shader = ShaderManager::instance()->pushShader(ShaderTrait::MapTexture | ShaderTrait::TransformColorspace);
        }
        const QRectF pixelGeometry = snapToPixelGridF(scaledRect(m_currentGeometry, viewport.scale()));
        QMatrix4x4 mvp = viewport.projectionMatrix();
        mvp.translate(pixelGeometry.x(), pixelGeometry.y());
        shader->setUniform(GLShader::Mat4Uniform::ModelViewProjectionMatrix, mvp);
        shader->setColorspaceUniforms(ColorDescription::sRGB, renderTarget.colorDescription(), RenderingIntent::Perceptual);
        texture->render(pixelGeometry.size());
        ShaderManager::instance()->popShader();
        glDisable(GL_BLEND);
    }
}

void StartupFeedbackEffect::postPaintScreen()
{
    if (m_active) {
        m_dirtyRect = m_currentGeometry; // ensure the now dirty region is cleaned on the next pass
        if (m_type == BlinkingFeedback || m_type == BouncingFeedback) {
            effects->addRepaint(m_dirtyRect); // we also have to trigger a repaint
        }
    }
    effects->postPaintScreen();
}

void StartupFeedbackEffect::slotMouseChanged(const QPointF &pos, const QPointF &oldpos, Qt::MouseButtons buttons,
                                             Qt::MouseButtons oldbuttons, Qt::KeyboardModifiers modifiers, Qt::KeyboardModifiers oldmodifiers)
{
    if (m_active) {
        m_dirtyRect |= m_currentGeometry;
        m_currentGeometry = feedbackRect();
        m_dirtyRect |= m_currentGeometry;
        effects->addRepaint(m_dirtyRect);
    }
}

void StartupFeedbackEffect::gotNewStartup(const QString &id, const QIcon &icon)
{
    if (Cursors::self()->isCursorHidden()) {
        return;
    }

    const Cursor *mouse = Cursors::self()->mouse();
    if (mouse->source() && mouse->source()->isBlank()) {
        return;
    }

    Startup &startup = m_startups[id];
    startup.icon = icon;

    startup.expiredTimer = std::make_unique<QTimer>();
    // Stop the animation if the startup doesn't finish within reasonable interval.
    connect(startup.expiredTimer.get(), &QTimer::timeout, this, [this, id]() {
        gotRemoveStartup(id);
    });
    startup.expiredTimer->setSingleShot(true);
    startup.expiredTimer->start(m_timeout);

    m_currentStartup = id;
    start(startup);
}

void StartupFeedbackEffect::gotRemoveStartup(const QString &id)
{
    if (!m_startups.remove(id)) {
        return;
    }
    if (m_startups.isEmpty()) {
        m_currentStartup.clear();
        m_cursorItem.reset();
        stop();
        return;
    }
    m_currentStartup = m_startups.begin().key();
    start(m_startups[m_currentStartup]);
}

void StartupFeedbackEffect::gotStartupChange(const QString &id, const QIcon &icon)
{
    if (m_currentStartup == id) {
        Startup &currentStartup = m_startups[m_currentStartup];
        if (!icon.isNull() && icon.name() != currentStartup.icon.name()) {
            currentStartup.icon = icon;
            start(currentStartup);
        }
    }
}

void StartupFeedbackEffect::start(const Startup &startup)
{
    if (m_type == NoFeedback || m_splashVisible || effects->isCursorHidden()) {
        return;
    }

    const Output *output = effects->screenAt(effects->cursorPos().toPoint());
    if (!output) {
        return;
    }
    if (!m_active) {
        connect(effects, &EffectsHandler::mouseChanged, this, &StartupFeedbackEffect::slotMouseChanged);
    }
    m_active = true;

    // read details about the mouse-cursor theme define per default
    KConfigGroup mousecfg(effects->inputConfig(), QStringLiteral("Mouse"));
    m_cursorSize = mousecfg.readEntry("cursorSize", 24);

    int iconSize = m_cursorSize / 1.5;
    if (!iconSize) {
        iconSize = QApplication::style()->pixelMetric(QStyle::PM_SmallIconSize);
    }
    // get ratio for bouncing cursor so we don't need to manually calculate the sizes for each icon size
    if (m_type == BouncingFeedback) {
        m_bounceSizesRatio = iconSize / 16.0;
    }

    const QPixmap iconPixmap = startup.icon.pixmap(iconSize);
    prepareTextures(iconPixmap, output->scale());
    m_dirtyRect = m_currentGeometry = feedbackRect();
    m_cursorTheme = CursorTheme(m_mouseCur->themeName(),
                                m_mouseCur->themeSize(),
                                output->scale());
    m_defaultShape.setTheme(m_cursorTheme);
    m_defaultShape.setShape(Qt::ArrowCursor);

    m_cursorItem = std::make_unique<ShakeCursorItem>(m_cursorTheme, effects->scene()->overlayItem());
    m_cursorItem->setPosition(m_mouseCur->pos());
    connect(m_mouseCur, &Cursor::posChanged, m_cursorItem.get(), [this]() {
        m_cursorItem->setPosition(m_mouseCur->pos());
        //if(effects->isEffectActive("shakecursor"))

        if(m_showBusyCursor) {
            effects->hideCursor();
        }
        else effects->showCursor();
    });
    connect(m_mouseCur, &Cursor::cursorChanged, m_cursorItem.get(), [this]() {
        toggleBusyCursor();
    });
    toggleBusyCursor();
    effects->addRepaint(m_dirtyRect);
}
void StartupFeedbackEffect::toggleBusyCursor()
{
    if(m_active) {
        if(effects->cursorImage().image() == m_defaultShape.image()) { // Cursor is the default, allow cursor animation
            m_showBusyCursor = true;
            while(!effects->isCursorHidden()) {
                effects->hideCursor();
            }
            m_cursorItem->setOpacity(1.0);
        } else {
            m_showBusyCursor = false;
            while(effects->isCursorHidden()) {
                effects->showCursor();
            }
            m_cursorItem->setOpacity(0.0);
        }
    }

}
void StartupFeedbackEffect::stop()
{
    if (!m_active) {
        return;
    }
    m_lastPresentTime = std::chrono::milliseconds::zero();
    disconnect(effects, &EffectsHandler::mouseChanged, this, &StartupFeedbackEffect::slotMouseChanged);
    m_showBusyCursor = false;
    while(effects->isCursorHidden()) {
        effects->showCursor();
    }
    m_active = false;
    effects->makeOpenGLContextCurrent();
    switch (m_type) {
    case BouncingFeedback:
        for (int i = 0; i < 5; ++i) {
            m_bouncingTextures[i].reset();
        }
        break;
    case BlinkingFeedback:
    case PassiveFeedback:
        m_texture.reset();
        break;
    case NoFeedback:
        return; // don't want the full repaint
    default:
        break; // impossible
    }
    effects->addRepaintFull();
}

void StartupFeedbackEffect::prepareTextures(const QPixmap &pix, qreal devicePixelRatio)
{
    effects->makeOpenGLContextCurrent();
    switch (m_type) {
    case BouncingFeedback:
        for (int i = 0; i < 5; ++i) {
            m_bouncingTextures[i] = GLTexture::upload(scalePixmap(pix, BOUNCE_SIZES[i], devicePixelRatio));
            if (!m_bouncingTextures[i]) {
                return;
            }
            m_bouncingTextures[i]->setFilter(GL_LINEAR);
            m_bouncingTextures[i]->setWrapMode(GL_CLAMP_TO_EDGE);
        }
        break;
    case BlinkingFeedback:
    case PassiveFeedback:
        m_texture = GLTexture::upload(pix);
        if (!m_texture) {
            return;
        }
        m_texture->setFilter(GL_LINEAR);
        m_texture->setWrapMode(GL_CLAMP_TO_EDGE);
        break;
    default:
        // for safety
        stop();
        break;
    }
}

QImage StartupFeedbackEffect::scalePixmap(const QPixmap &pm, const QSize &size, qreal devicePixelRatio) const
{
    const QSize &adjustedSize = size * m_bounceSizesRatio;
    QImage scaled = pm.toImage().scaled(adjustedSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    if (scaled.format() != QImage::Format_ARGB32_Premultiplied && scaled.format() != QImage::Format_ARGB32) {
        scaled.convertTo(QImage::Format_ARGB32);
    }

    QImage result(feedbackIconSize() * devicePixelRatio, QImage::Format_ARGB32);
    result.setDevicePixelRatio(devicePixelRatio);

    QPainter p(&result);
    p.setCompositionMode(QPainter::CompositionMode_Source);
    p.fillRect(result.rect(), Qt::transparent);
    p.drawImage(QRectF((20 * m_bounceSizesRatio - adjustedSize.width()) / 2,
                       (20 * m_bounceSizesRatio - adjustedSize.height()) / 2,
                       adjustedSize.width(),
                       adjustedSize.height()),
                scaled);
    return result;
}

QSize StartupFeedbackEffect::feedbackIconSize() const
{
    return QSize(20, 20) * m_bounceSizesRatio;
}

QRect StartupFeedbackEffect::feedbackRect() const
{
    int xDiff;
    if (m_cursorSize <= 16) {
        xDiff = 8 + 7;
    } else if (m_cursorSize <= 32) {
        xDiff = 16 + 7;
    } else if (m_cursorSize <= 48) {
        xDiff = 24 + 7;
    } else {
        xDiff = 32 + 7;
    }
    int yDiff = xDiff;
    GLTexture *texture = nullptr;
    int yOffset = 0;
    switch (m_type) {
    case BouncingFeedback:
        texture = m_bouncingTextures[FRAME_TO_BOUNCE_TEXTURE[m_frame]].get();
        yOffset = FRAME_TO_BOUNCE_YOFFSET[m_frame] * m_bounceSizesRatio;
        break;
    case BlinkingFeedback: // fall through
    case PassiveFeedback:
        texture = m_texture.get();
        break;
    default:
        // nothing
        break;
    }
    const QPoint cursorPos = effects->cursorPos().toPoint() + QPoint(xDiff, yDiff + yOffset);
    QRect rect;
    if (texture) {
        rect = QRect(cursorPos, feedbackIconSize());
    }
    return rect;
}

bool StartupFeedbackEffect::isActive() const
{
    return m_active;
}

ShakeCursorItem::ShakeCursorItem(const CursorTheme &theme, Item *parent)
: Item(parent)
{
    m_source = std::make_unique<ShapeCursorSource>();
    m_source->setTheme(theme);
    m_source->setShape(Qt::BusyCursor);

    refresh();
    connect(m_source.get(), &CursorSource::changed, this, &ShakeCursorItem::refresh);
}

void ShakeCursorItem::refresh()
{
    if (!m_imageItem) {
        m_imageItem = scene()->renderer()->createImageItem(this);
    }
    m_imageItem->setImage(m_source->image());
    m_imageItem->setPosition(-m_source->hotspot());
    m_imageItem->setSize(m_source->image().deviceIndependentSize());
}


} // namespace

#include "moc_startupfeedback.cpp"
