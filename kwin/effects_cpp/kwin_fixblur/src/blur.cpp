/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2011 Philipp Knechtges <philipp-dev@knechtges.com>
    SPDX-FileCopyrightText: 2018 Alex Nemeth <alex.nemeth329@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "blur.h"
// KConfigSkeleton
#include "blurconfig.h"
#include "effect/effecthandler.h"
#include "effect/effectwindow.h"
#include "opengl/glplatform.h"
#include "internalwindow.h"

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
    BlurConfig::instance(effects->config()); //initConfig<BlurConfig>();
    reconfigure(ReconfigureAll);

    connect(effects, &EffectsHandler::windowAdded, this, &BlurEffect::slotWindowAdded);
    connect(effects, &EffectsHandler::propertyNotify, this, &BlurEffect::slotPropertyNotify);
	//connect(effects, &EffectWindow::windowFrameGeometryChanged, this, &BlurEffect::slotWindowFrameGeometryChanged);
	updateAllWindows();
}
void BlurEffect::updateAllWindows()
{
	const auto stackingOrder = effects->stackingOrder();
    for (EffectWindow *w: stackingOrder) {
		slotWindowAdded(w);
    }
}
bool BlurEffect::isWindowValid(KWin::EffectWindow *w)
{
	// Because Wayland does things differently
	QStringList classes = w->windowClass().split((' '));
	if(w->isWaylandClient())
	{
		return m_includedWindows.contains(classes[0]);
	}
	bool valid = classes[0] == QStringLiteral("navigator") || classes[0] == QStringLiteral("Navigator");
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

   	m_includedWindows = BlurConfig::includedWindows().split(',');
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

QWindow* BlurEffect::getWaylandWindowHandle(KWin::EffectWindow* w)
{
	// Stub, literally how because w->internalWindow() returns nullptr
	return nullptr;
}

void BlurEffect::applyBlurRegion(KWin::EffectWindow *w, bool maximized)
{

	//QWindow* win = w->isWaylandClient() ? getWaylandWindowHandle(w) : QWindow::fromWinId(w->windowId());
	QWindow* win = QWindow::fromWinId(w->windowId());


	if(win == nullptr) return;
	// Getting the offset caused by client-side decoration shadows
	auto geo = w->frameGeometry();
	auto geoExp = w->expandedGeometry();

	if(maximized)
	{
		KWindowEffects::enableBlurBehind(win, true, QRegion(0, 0, w->size().width(), w->size().height()));
	}
	else
	{
		static int cachedDx = 0;
		static int cachedDy = 0;

		int dx = std::abs(geoExp.x() - geo.x());
		int dy = std::abs(geoExp.y() - geo.y());

		if(dx != 0)
		{
			cachedDx = dx;
		}
		if(dy != 0)
		{
			cachedDy = dy;
		}
		defaultSvg.resizeFrame(w->size());
		QRegion mask = defaultSvg.mask();
		if(mask.boundingRect().size() != w->size().toSize())
		{
			mask = getForcedNewRegion();
		}

		mask.translate(cachedDx, cachedDy);
		//win->setMask(mask);
		KWindowEffects::enableBlurBehind(win, true, mask);
	}
}
void BlurEffect::slotWindowAdded(EffectWindow *w)
{
   	if(isWindowValid(w))
	{
		connect(w, &EffectWindow::windowFrameGeometryChanged, this, &BlurEffect::slotWindowFrameGeometryChanged);
		connect(w, &EffectWindow::windowMaximizedStateChanged, this, &BlurEffect::slotWindowMaximizedStateChanged);
		//connect(w, &EffectWindow::windowFinishUserMovedResized, this, &BlurEffect::slotWindowFinishUserMovedResized);
		applyBlurRegion(w);
   	}
}
void BlurEffect::slotWindowMaximizedStateChanged(KWin::EffectWindow *w, bool horizontal, bool vertical)
{
   	if(isWindowValid(w))
	{
		applyBlurRegion(w, horizontal && vertical);
	}
}

void BlurEffect::slotWindowFinishUserMovedResized(KWin::EffectWindow *w)
{
   	if(isWindowValid(w))
	{
		applyBlurRegion(w);
	}

}
void BlurEffect::slotWindowFrameGeometryChanged(KWin::EffectWindow *w, const QRectF &oldGeometry)
{
   	if(isWindowValid(w))
	{
		if(oldGeometry.size() != w->size())
		{
			applyBlurRegion(w);
		}
	}
}

void BlurEffect::slotWindowDeleted(EffectWindow *w)
{

}

void BlurEffect::slotPropertyNotify(KWin::EffectWindow *w, long atom)
{
	if(w)
	{
		if(w->decoration() && isWindowValid(w))
		{
			applyBlurRegion(w);
		}
	}
}

bool BlurEffect::enabledByDefault()
{
	return false;
}

bool BlurEffect::supported()
{
	return effects->openglContext() && effects->openglContext()->supportsBlits();
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
