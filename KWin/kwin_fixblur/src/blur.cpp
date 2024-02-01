/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2011 Philipp Knechtges <philipp-dev@knechtges.com>
    SPDX-FileCopyrightText: 2018 Alex Nemeth <alex.nemeth329@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "blur.h"
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
#include <QPainterPath>
#include <QStringLiteral>
#include <QBitmap>

#include <KConfigGroup>
#include <KSharedConfig>
#include <KWindowEffects>

#include <KDecoration2/Decoration>

namespace KWin
{

BlurEffect::BlurEffect()
{
	defaultSvg.setImagePath(svgPath);
	defaultSvg.setUsingRenderingCache(false);
    initConfig<BlurConfig>();
    reconfigure(ReconfigureAll);

    connect(effects, &EffectsHandler::windowAdded, this, &BlurEffect::slotWindowAdded);
    connect(effects, &EffectsHandler::propertyNotify, this, &BlurEffect::slotPropertyNotify);
	connect(effects, &EffectsHandler::windowFrameGeometryChanged, this, &BlurEffect::slotWindowFrameGeometryChanged);
	updateAllWindows();
}
void BlurEffect::updateAllWindows()
{
	const auto stackingOrder = effects->stackingOrder();
    for (EffectWindow *w: stackingOrder) {
   		if(isWindowValid(w)) {
   			applyBlurRegion(w);
   		}
    }
}
bool BlurEffect::isWindowValid(KWin::EffectWindow *w)
{
	QStringList classes = w->windowClass().split(' ');
	bool valid = classes[0] == "navigator";
	if(classes.size() > 1) 
	{
		valid = valid && m_includedWindows.contains(classes[1]);
	}
	return valid;
}

BlurEffect::~BlurEffect()
{

}

void BlurEffect::updateTexture()
{
	if(m_texturePath == "" || !QFile::exists(m_texturePath))
	{
		m_texturePath = svgPath;
	}
	defaultSvg.setImagePath(m_texturePath);
}
void BlurEffect::reconfigure(ReconfigureFlags flags)
{
    BlurConfig::self()->read();

   	m_includedWindows = BlurConfig::includedWindows().split(';');
   	m_texturePath = BlurConfig::textureLocation();
	updateTexture();
	updateAllWindows();
   	effects->addRepaintFull();
}
QRegion BlurEffect::getForcedNewRegion()
{
	defaultSvg.clearCache();
	QPixmap alphaMask = defaultSvg.alphaMask();
	const qreal dpr = alphaMask.devicePixelRatio();
	// region should always be in logical pixels, resize pixmap to be in the logical sizes
    if (alphaMask.devicePixelRatio() != 1.0) {
        alphaMask = alphaMask.scaled(alphaMask.width() / dpr, alphaMask.height() / dpr);
    }
	return QRegion(QBitmap(alphaMask.mask()));
}

void BlurEffect::applyBlurRegion(KWin::EffectWindow *w)
{
	QWindow* win = w->isWaylandClient() ? w->internalWindow() : QWindow::fromWinId(w->windowId());
	defaultSvg.resizeFrame(w->size());
	QRegion mask = defaultSvg.mask();
	if(mask.boundingRect().size() != w->size().toSize())
	{
		mask = getForcedNewRegion();
	}
	//win->setMask(mask);
	KWindowEffects::enableBlurBehind(win, true, mask);//QRegion(0, 0, w->size().width(), w->size().height()));
}
void BlurEffect::slotWindowAdded(EffectWindow *w)
{
   	if(isWindowValid(w)) {
		applyBlurRegion(w);
   	}
}

void BlurEffect::slotWindowFinishUserMovedResized(KWin::EffectWindow *w)
{

}
void BlurEffect::slotWindowFrameGeometryChanged(KWin::EffectWindow *w, const QRectF &oldGeometry)
{
   	if(isWindowValid(w)) {
		if(oldGeometry.size() != w->size())
		{
			applyBlurRegion(w);
		}
	}
}

void BlurEffect::slotWindowDeleted(EffectWindow *w)
{

}

void BlurEffect::slotPropertyNotify(EffectWindow *w, long atom)
{
	if(w) {
		if(w->decoration() && isWindowValid(w)) {
			applyBlurRegion(w);
		}
	}
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

void BlurEffect::prePaintWindow(EffectWindow *w, WindowPrePaintData &data, std::chrono::milliseconds presentTime)
{
	// We perform a bit of tomfoolery :)
	// massive if factual
	if(isWindowValid(w))
	{
   		data.setTranslucent();
	}
   	effects->prePaintWindow(w, data, presentTime);
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
