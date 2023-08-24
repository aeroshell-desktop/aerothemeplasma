/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2011 Philipp Knechtges <philipp-dev@knechtges.com>
    SPDX-FileCopyrightText: 2018 Alex Nemeth <alex.nemeth329@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "blur.h"
#include "blurshader.h"
// KConfigSkeleton
#include "blurconfig.h"


#include <QGuiApplication>
#include <QMatrix4x4>
#include <QScreen>
#include <QTime>
#include <QTimer>
#include <QWindow>
#include <cmath> // for ceil()
#include <cstdlib>
#include <QFile>
#include <QBuffer>
#include <QDataStream>
#include <QColor>
#include <QPair>

#include <KConfigGroup>
#include <KSharedConfig>

#include <KDecoration2/Decoration>

namespace KWin
{

static const QByteArray s_blurAtomName = QByteArrayLiteral("_KDE_NET_WM_BLUR_BEHIND_REGION");

BlurEffect::BlurEffect() : m_sharedMemory("kwinreflect")
{
    initConfig<BlurConfig>();
    m_shader = new BlurShader(this);

    m_reflectionTexture = nullptr;
    reconfigure(ReconfigureAll);

    // ### Hackish way to announce support.
    //     Should be included in _NET_SUPPORTED instead.
    if (m_shader && m_shader->isValid()) {
        if (effects->xcbConnection()) {
            net_wm_blur_region = effects->announceSupportProperty(s_blurAtomName, this);
        }
    }

    connect(effects, &EffectsHandler::windowAdded, this, &BlurEffect::slotWindowAdded);
    connect(effects, &EffectsHandler::windowDeleted, this, &BlurEffect::slotWindowDeleted);
    connect(effects, &EffectsHandler::windowDecorationChanged, this, &BlurEffect::setupDecorationConnections);
    connect(effects, &EffectsHandler::propertyNotify, this, &BlurEffect::slotPropertyNotify);
    connect(effects, &EffectsHandler::virtualScreenGeometryChanged, this, &BlurEffect::slotScreenGeometryChanged);
    connect(effects, &EffectsHandler::xcbConnectionChanged, this, [this]() {
        if (m_shader && m_shader->isValid()) {
            net_wm_blur_region = effects->announceSupportProperty(s_blurAtomName, this);
        }
    });

    // Fetch the blur regions for all windows
    const auto stackingOrder = effects->stackingOrder();
    for (EffectWindow *window : stackingOrder) {
        slotWindowAdded(window);
    }

}
void BlurEffect::updateTexture()
{
    if(m_texturePath == "" || !QFile::exists(m_texturePath))
    {
        m_texturePath = QStringLiteral(":/effects/blur/reflection.png");
    }
    if(m_reflectionTexture != nullptr)
    {
        delete m_reflectionTexture;
    }
    m_reflectionTexture = new GLTexture(m_texturePath);
    m_reflectionTexture->setFilter(GL_LINEAR);
    m_reflectionTexture->setWrapMode(GL_REPEAT);

    if(m_reflectionTexture != nullptr)
    {
        printf("Texture successfully loaded.\n");
    }
}
bool BlurEffect::isWindowValid(KWin::EffectWindow *w)
{
    QString windowclass = w->windowClass().split(' ')[0];
	return !(w->isDesktop() || w->isToolbar() || w->isMenu() ||
			 w->isSplash() || w->isDropdownMenu() || w->isPopupMenu() ||
			 w->isTooltip() || w->isNotification() || w->isCriticalNotification() ||
			 w->isOnScreenDisplay() || w->isComboBox() || w->isDNDIcon() || w->isHidden() || /*(w->isDialog() && !w->isAppletPopup()) ||*/
			 w->isMinimized() || m_excludedWindows.contains(windowclass) /*|| (w->isSpecialWindow() && !w->isDock())*/);
}
bool BlurEffect::shouldColorize(KWin::EffectWindow *w)
{
    QString windowclass = w->windowClass().split(' ')[0];
    return !(w->isDesktop() || w->isSplash() || /*w->isHidden() || w->isMinimized() ||*/ m_excludedWindowsColorization.contains(windowclass));
}
BlurEffect::~BlurEffect()
{
    if(m_reflectionTexture) delete m_reflectionTexture;
}

void BlurEffect::slotScreenGeometryChanged()
{
    effects->makeOpenGLContextCurrent();

    // Fetch the blur regions for all windows
    const auto stackingOrder = effects->stackingOrder();
    for (EffectWindow *window : stackingOrder) {
        updateBlurRegion(window);
    }
    effects->doneOpenGLContextCurrent();
}

bool BlurEffect::readMemory(bool* skipFunc)
{

    if(!m_sharedMemory.attach())
    {
        printf("Couldn't access shared memory! %s %d\n", m_sharedMemory.nativeKey().toStdString().c_str(), m_sharedMemory.error());
        if(m_sharedMemory.error())
            return false;
    }
    QBuffer buffer;
    QDataStream in(&buffer);
    QPair<QColor, QPair<bool,bool>> result;
    //QString result;

    m_sharedMemory.lock();
    buffer.setData((char*)m_sharedMemory.constData(), m_sharedMemory.size());
    buffer.open(QBuffer::ReadOnly);
    in >> result;
    m_sharedMemory.unlock();
    m_sharedMemory.detach();

    m_accentColor = result.first;
    m_transparencyEnabled = result.second.first;
    *skipFunc = result.second.second;

    m_accentColorInactive = m_accentColor;
    int saturation = m_accentColorInactive.hslSaturation() / 2;
    m_accentColorInactive.setHsl(m_accentColorInactive.hslHue(), saturation, m_accentColorInactive.lightness());
    return true;
}
void BlurEffect::reconfigure(ReconfigureFlags flags)
{
    bool skip = false;
    bool readColor = readMemory(&skip) && m_firstTimeReconfigure;
    if(skip && m_firstTimeReconfigure)
        return;
    BlurConfig::self()->read();

    if(!readColor)
    {
        m_accentColor = BlurConfig::accentColor();
        m_accentColorInactive = m_accentColor;
        int saturation = m_accentColorInactive.hslSaturation() / 2;
        m_accentColorInactive.setHsl(m_accentColorInactive.hslHue(), saturation, m_accentColorInactive.lightness());
        m_transparencyEnabled = BlurConfig::enableTransparency();
    }

    int blurStrength = BlurConfig::blurStrength() - 1;
    m_offset = blurStrengthValues[blurStrength].offset;
    m_expandSize = blurOffsets[m_downSampleIterations - 1].expandSize;

    m_scalingFactor = std::max(1.0, QGuiApplication::primaryScreen()->logicalDotsPerInch() / 96.0);
    m_translateTexture = BlurConfig::translateTexture();
    m_enableColorization = BlurConfig::enableColorization();

    m_texturePath = BlurConfig::textureLocation();
    updateTexture();

    m_excludedWindows = BlurConfig::excludedWindows().split(';');
    m_excludedWindowsColorization = BlurConfig::excludedColorization().split(';');

    m_firstTimeReconfigure = true;
    // Update all windows for the blur to take effect
    effects->addRepaintFull();
}

void BlurEffect::updateBlurRegion(EffectWindow *w)
{
    QRegion region;
    bool valid = false;

    if (net_wm_blur_region != XCB_ATOM_NONE) {
        const QByteArray value = w->readProperty(net_wm_blur_region, XCB_ATOM_CARDINAL, 32);
        if (value.size() > 0 && !(value.size() % (4 * sizeof(uint32_t)))) {
            const uint32_t *cardinals = reinterpret_cast<const uint32_t *>(value.constData());
            for (unsigned int i = 0; i < value.size() / sizeof(uint32_t);) {
                int x = cardinals[i++];
                int y = cardinals[i++];
                int w = cardinals[i++];
                int h = cardinals[i++];
                region += QRect(x,y,w,h);//fromXNative(QRect(x, y, w, h)).toRect();
            }
        }
        valid = !value.isNull();
    }

    if (auto internal = w->internalWindow()) {
        const auto property = internal->property("kwin_blur");
        if (property.isValid()) {
            region = property.value<QRegion>();
            valid = true;
        }
    }

    if (valid) {
        blurRegions[w] = region;
    } else {
        blurRegions.remove(w);
    }
}

void BlurEffect::slotWindowAdded(EffectWindow *w)
{
    if (auto internal = w->internalWindow()) {
        internal->installEventFilter(this);
    }

    setupDecorationConnections(w);
    updateBlurRegion(w);
}

void BlurEffect::slotWindowDeleted(EffectWindow *w)
{
    blurRegions.remove(w);
    auto it = windowBlurChangedConnections.find(w);
    if (it == windowBlurChangedConnections.end()) {
        return;
    }
    disconnect(*it);
    windowBlurChangedConnections.erase(it);
}

void BlurEffect::slotPropertyNotify(EffectWindow *w, long atom)
{
    if (w && atom == net_wm_blur_region && net_wm_blur_region != XCB_ATOM_NONE) {
        updateBlurRegion(w);
    }
}

void BlurEffect::setupDecorationConnections(EffectWindow *w)
{
    if (!w->decoration()) {
        return;
    }

    connect(w->decoration(), &KDecoration2::Decoration::blurRegionChanged, this, [this, w]() {
        updateBlurRegion(w);
    });
}

bool BlurEffect::eventFilter(QObject *watched, QEvent *event)
{
    auto internal = qobject_cast<QWindow *>(watched);
    if (internal && event->type() == QEvent::DynamicPropertyChange) {
        QDynamicPropertyChangeEvent *pe = static_cast<QDynamicPropertyChangeEvent *>(event);
        if (pe->propertyName() == "kwin_blur") {
            if (auto w = effects->findWindow(internal)) {
                updateBlurRegion(w);
            }
        }
    }
    return false;
}

bool BlurEffect::enabledByDefault()
{
    GLPlatform *gl = GLPlatform::instance();

    if (gl->isIntel() && gl->chipClass() < SandyBridge) {
        return false;
    }
    if (gl->isPanfrost() && gl->chipClass() <= MaliT8XX) {
        return false;
    }
    // The blur effect works, but is painfully slow (FPS < 5) on Mali and VideoCore
    if (gl->isLima() || gl->isVideoCore4() || gl->isVideoCore3D()) {
        return false;
    }
    if (gl->isSoftwareEmulation()) {
        return false;
    }

    return true;
}

bool BlurEffect::supported()
{
    bool supported = effects->isOpenGLCompositing() && GLFramebuffer::supported() && GLFramebuffer::blitSupported();

    if (supported) {
        int maxTexSize;
        glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTexSize);

        const QSize screenSize = effects->virtualScreenSize();
        if (screenSize.width() > maxTexSize || screenSize.height() > maxTexSize) {
            supported = false;
        }
    }
    return supported;
}

bool BlurEffect::decorationSupportsBlurBehind(const EffectWindow *w) const
{
    return w->decoration() && !w->decoration()->blurRegion().isNull();
}

QRegion BlurEffect::decorationBlurRegion(const EffectWindow *w) const
{
    if (!decorationSupportsBlurBehind(w)) {
        return QRegion();
    }

    QRegion decorationRegion = QRegion(w->decoration()->rect()) - w->decorationInnerRect().toRect();
    //! we return only blurred regions that belong to decoration region
    return decorationRegion.intersected(w->decoration()->blurRegion());
}

QRect BlurEffect::expand(const QRect &rect) const
{
    return rect.adjusted(-m_expandSize, -m_expandSize, m_expandSize, m_expandSize);
}

QRegion BlurEffect::expand(const QRegion &region) const
{
    QRegion expanded;

    for (const QRect &rect : region) {
        expanded += expand(rect);
    }

    return expanded;
}

QRegion BlurEffect::blurRegion(const EffectWindow *w, bool internal) const
{
    QRegion region;

    if (auto it = blurRegions.find(w); it != blurRegions.end() && internal) {
        const QRegion &appRegion = *it;
        if (!appRegion.isEmpty()) {
            QRegion temp = appRegion.translated(w->contentsRect().topLeft().toPoint());
            if (w->decorationHasAlpha() && decorationSupportsBlurBehind(w)) {
                region = decorationBlurRegion(w);
            }
            region |= temp & w->decorationInnerRect().toRect();
        } else {
            // An empty region means that the blur effect should be enabled
            // for the whole window.

            region = w->rect().toRect();
            if (w->decorationHasAlpha() && decorationSupportsBlurBehind(w)) {
                region &= w->decorationInnerRect().toRect();
            }

        }
    }
    if (w->decorationHasAlpha() && decorationSupportsBlurBehind(w)) {
        // If the client hasn't specified a blur region, we'll only enable
        // the effect behind the decoration.
        region |= decorationBlurRegion(w);
    }

    return region;
}

void BlurEffect::uploadRegion(QVector2D *&map, const QRegion &region, const int downSampleIterations)
{
    Q_ASSERT(map);
    for (int i = 0; i <= downSampleIterations; i++) {
        const int divisionRatio = (1 << i);

        for (const QRect &r : region) {
            const QVector2D topLeft(r.x() / divisionRatio, r.y() / divisionRatio);
            const QVector2D topRight((r.x() + r.width()) / divisionRatio, r.y() / divisionRatio);
            const QVector2D bottomLeft(r.x() / divisionRatio, (r.y() + r.height()) / divisionRatio);
            const QVector2D bottomRight((r.x() + r.width()) / divisionRatio, (r.y() + r.height()) / divisionRatio);

            // First triangle
            *(map++) = topRight;
            *(map++) = topLeft;
            *(map++) = bottomLeft;

            // Second triangle
            *(map++) = bottomLeft;
            *(map++) = bottomRight;
            *(map++) = topRight;
        }
    }
}

bool BlurEffect::uploadGeometry(GLVertexBuffer *vbo, const QRegion &blurRegion, const QRegion &windowRegion)
{
    const int vertexCount = ((blurRegion.rectCount() * (m_downSampleIterations + 1)) + windowRegion.rectCount()) * 6;
    if (!vertexCount) {
        return false;
    }

    QVector2D *map = (QVector2D *)vbo->map(vertexCount * sizeof(QVector2D));
    if (!map) {
        return false;
    }

    uploadRegion(map, blurRegion, m_downSampleIterations);
    uploadRegion(map, windowRegion, 0);

    vbo->unmap();

    const GLVertexAttrib layout[] = {
        {VA_Position, 2, GL_FLOAT, 0},
        {VA_TexCoord, 2, GL_FLOAT, 0}};

    vbo->setAttribLayout(layout, 2, sizeof(QVector2D));
    return true;
}

void BlurEffect::prePaintScreen(ScreenPrePaintData &data, std::chrono::milliseconds presentTime)
{
    m_paintedArea = QRegion();
    m_currentBlur = QRegion();

    effects->prePaintScreen(data, presentTime);
}

void BlurEffect::prePaintWindow(EffectWindow *w, WindowPrePaintData &data, std::chrono::milliseconds presentTime)
{
    // this effect relies on prePaintWindow being called in the bottom to top order

    effects->prePaintWindow(w, data, presentTime);

    if (!m_shader || !m_shader->isValid()) {
        return;
    }

    const QRegion oldOpaque = data.opaque;
    if (data.opaque.intersects(m_currentBlur)) {
        // to blur an area partially we have to shrink the opaque area of a window
        QRegion newOpaque;
        for (const QRect &rect : data.opaque) {
            newOpaque |= rect.adjusted(m_expandSize, m_expandSize, -m_expandSize, -m_expandSize);
        }
        data.opaque = newOpaque;

        // we don't have to blur a region we don't see
        m_currentBlur -= newOpaque;
    }

    // if we have to paint a non-opaque part of this window that intersects with the
    // currently blurred region we have to redraw the whole region
    if ((data.paint - oldOpaque).intersects(m_currentBlur)) {
        data.paint |= m_currentBlur;
    }

    // in case this window has regions to be blurred
    const QRect screen = effects->virtualScreenGeometry();
    const QRegion blurArea = blurRegion(w).translated(w->pos().toPoint()) & screen;
    const QRegion expandedBlur = (w->isDock() ? blurArea : expand(blurArea)) & screen;

    // if this window or a window underneath the blurred area is painted again we have to
    // blur everything
    if (m_paintedArea.intersects(expandedBlur) || data.paint.intersects(blurArea)) {
        data.paint |= expandedBlur;
        // we have to check again whether we do not damage a blurred area
        // of a window
        if (expandedBlur.intersects(m_currentBlur)) {
            data.paint |= m_currentBlur;
        }
    }

    m_currentBlur |= expandedBlur;

    m_paintedArea -= data.opaque;
    m_paintedArea |= data.paint;
}

bool BlurEffect::shouldBlur(const EffectWindow *w, int mask, const WindowPaintData &data) const
{
    if(m_reflectionTexture == nullptr) return false;
    if (!m_shader || !m_shader->isValid()) {
        return false;
    }

    if (effects->activeFullScreenEffect() && !w->data(WindowForceBlurRole).toBool()) {
        return false;
    }

    if (w->isDesktop()) {
        return false;
    }

    bool scaled = !qFuzzyCompare(data.xScale(), 1.0) && !qFuzzyCompare(data.yScale(), 1.0);
    bool translated = data.xTranslation() || data.yTranslation();

    if ((scaled || (translated || (mask & PAINT_WINDOW_TRANSFORMED))) && !w->data(WindowForceBlurRole).toBool()) {
        return false;
    }

    return true;
}

void BlurEffect::drawWindow(EffectWindow *w, int mask, const QRegion &region, WindowPaintData &data)
{
    /*if(!isWindowValid(w)) {

        effects->drawWindow(w, mask, region, data);
        return;
    }*/
    if(shouldBlur(w, mask, data)) {
        const QRect screen = effects->renderTargetRect();
        QRegion shape = blurRegion(w, isWindowValid(w)).translated(w->pos().toPoint());
        QRegion colorizationShape = blurRegion(w, shouldColorize(w)).translated(w->pos().toPoint());
        auto handleShape = [&](QRegion shape) {
            // let's do the evil parts - someone wants to blur behind a transformed window
            const bool translated = data.xTranslation() || data.yTranslation();
            const bool scaled = data.xScale() != 1 || data.yScale() != 1;
            if (scaled) {
                QPoint pt = shape.boundingRect().topLeft();
                QRegion scaledShape;
                for (QRect r : shape) {
                    r.moveTo(pt.x() + (r.x() - pt.x()) * data.xScale() + data.xTranslation(),
                             pt.y() + (r.y() - pt.y()) * data.yScale() + data.yTranslation());
                    r.setWidth(std::ceil(r.width() * data.xScale()));
                    r.setHeight(std::ceil(r.height() * data.yScale()));
                    scaledShape |= r;
                }
                shape = scaledShape;

                // Only translated, not scaled
            } else if (translated) {
                shape = shape.translated(data.xTranslation(), data.yTranslation());
            }

            shape &= region;
            return shape;
        };
        shape = handleShape(shape);
        colorizationShape = handleShape(colorizationShape);
        EffectWindow *modal = w->transientFor();
        const bool transientForIsDock = (modal ? modal->isDock() : false);


        // Note that we render blurring in logical coordinates since the
        // textures used are of all screens. This means we need to ensure all
        // rendering takes care of that, starting with the projection matrix
        // here that we reset to a simple unscaled orthographic projection.
        QMatrix4x4 projectionMatrix;
        projectionMatrix.ortho(screen);

        if(!colorizationShape.isEmpty() && m_enableColorization) {
            doBlur(colorizationShape, screen, data.opacity(), projectionMatrix, w->isDock() || transientForIsDock, w->frameGeometry().toRect(), w->isFullScreen() || !w->isNormalWindow() || w == effects->activeWindow(), false);
        }
        if (!shape.isEmpty()) {
            doBlur(shape, screen, data.opacity(), projectionMatrix, w->isDock() || transientForIsDock, w->frameGeometry().toRect());
        }
    }
    // Draw the window over the blurred area
    effects->drawWindow(w, mask, region, data);
}

void BlurEffect::doBlur(const QRegion &shape, const QRect &screen, const float opacity, const QMatrix4x4 &screenProjection, bool isDock, QRect windowRect, bool active, bool reflect)
{
    // Blur would not render correctly on a secondary monitor because of wrong coordinates
    // BUG: 393723

    const int xTranslate = -screen.x();
    const int yTranslate = effects->virtualScreenSize().height() - screen.height() - screen.y();

    const QRegion expandedBlurRegion = expand(shape) & expand(screen);

    // Upload geometry for the down and upsample iterations
    GLVertexBuffer *vbo = GLVertexBuffer::streamingBuffer();
    vbo->reset();

    if (!uploadGeometry(vbo, expandedBlurRegion.translated(xTranslate, yTranslate), shape)) {
        return;
    }
    vbo->bindArrays();

    const QRect logicalSourceRect = (expandedBlurRegion.boundingRect() & screen).translated(xTranslate, -screen.y());
    const QRect deviceSourceRect = scaledRect(logicalSourceRect, effects->renderTargetScale()).toRect();
    const QRect destRect = logicalSourceRect.translated(0, yTranslate + screen.y());
    int blurRectCount = expandedBlurRegion.rectCount() * 6;

    glEnable(GL_BLEND);
    if(reflect)
    {
        if(opacity < 1.0) {
            glBlendFunc(GL_CONSTANT_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        } else {
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        }
        renderReflection(vbo, blurRectCount * (m_downSampleIterations + 1), shape.rectCount() * 6, screenProjection, windowRect.topLeft(), windowRect.size(), opacity);
    }
    else
    {
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        renderColorization(vbo, blurRectCount * (m_downSampleIterations + 1), shape.rectCount() * 6, screenProjection, opacity, active);

    }
    glDisable(GL_BLEND);

    vbo->unbindArrays();
}

void BlurEffect::renderColorization(GLVertexBuffer *vbo, int vboStart, int blurRectCount, const QMatrix4x4 &screenProjection, float opacity, bool active)
{
    m_shader->bind(true);

    if(active || m_transparencyEnabled)
        m_shader->setColor(m_accentColor);
    else
        m_shader->setColor(m_accentColorInactive);

    if(!active && m_transparencyEnabled)
        m_shader->setOpacity(opacity * 0.5f, true);
    else
        m_shader->setOpacity(opacity, true);

    m_shader->setModelViewProjectionMatrix(screenProjection, true);
    vbo->draw(GL_TRIANGLES, vboStart, blurRectCount);
    m_shader->unbind();
}

void BlurEffect::renderReflection(GLVertexBuffer *vbo, int vboStart, int blurRectCount, const QMatrix4x4 &screenProjection, QPoint windowPosition, QSize windowSize, float opacity)
{
    m_shader->bind();
    m_shader->setScreenResolution(KWin::effects->virtualScreenSize()); //Screen resolution
    m_shader->setWindowPosition(windowPosition);                       //Window position
    m_shader->setWindowSize(windowSize);                           //Window size
    m_shader->setTranslateTexture(m_translateTexture);
    m_reflectionTexture->bind();

    m_shader->setOpacity(opacity);                                      //Window opacity
    m_shader->setModelViewProjectionMatrix(screenProjection);

    vbo->draw(GL_TRIANGLES, vboStart, blurRectCount);
    m_shader->unbind();
}

bool BlurEffect::isActive() const
{
    return !effects->isScreenLocked();
}

bool BlurEffect::blocksDirectScanout() const
{
    return false;
}

} // namespace KWin
