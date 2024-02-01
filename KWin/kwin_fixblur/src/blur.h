/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2018 Alex Nemeth <alex.nemeth329@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <kwineffects.h>
#include <kwinglplatform.h>
#include <kwinglutils.h>

#include <KF5/KWayland/Server/blur_interface.h>
#include <KF5/KWayland/Server/display.h>
#include <KF5/KWayland/Server/surface_interface.h>
#include <QStack>
#include <QVector2D>
#include <QVector>
#include <QDir>
#include <QSharedMemory>
#include <Plasma/FrameSvg>

namespace KWin
{

static const int borderSize = 5;

class BlurShader;

class BlurEffect : public KWin::Effect
{
    Q_OBJECT

public:
    BlurEffect();
    ~BlurEffect() override;

    static bool supported();
    static bool enabledByDefault();

    void reconfigure(ReconfigureFlags flags) override;
    //void prePaintScreen(ScreenPrePaintData &data, std::chrono::milliseconds presentTime) override;
    void prePaintWindow(EffectWindow *w, WindowPrePaintData &data, std::chrono::milliseconds presentTime) override;
    //void drawWindow(EffectWindow *w, int mask, const QRegion &region, WindowPaintData &data) override;

    bool provides(Feature feature) override;
    bool isActive() const override;

    int requestedEffectChainPosition() const override
    {
        return 19;
    }

    bool blocksDirectScanout() const override;
    bool isWindowValid(KWin::EffectWindow *w);
	void applyBlurRegion(KWin::EffectWindow *w);
	void updateTexture();
	QRegion getForcedNewRegion();
	void updateAllWindows();
public Q_SLOTS:
    void slotWindowAdded(KWin::EffectWindow *w);
    void slotWindowDeleted(KWin::EffectWindow *w);
    void slotPropertyNotify(KWin::EffectWindow *w, long atom);
	void slotWindowFrameGeometryChanged(KWin::EffectWindow *w, const QRectF &oldGeometry);
	void slotWindowFinishUserMovedResized(KWin::EffectWindow *w);
    //void slotScreenGeometryChanged();

private:
	QString svgPath = QDir::homePath() + "/.emerald/ffBlurRegion.svg";
    Plasma::FrameSvg defaultSvg;
	QStringList m_includedWindows;
	QString m_texturePath;
};

inline bool BlurEffect::provides(Effect::Feature feature)
{
    if (feature == Blur) {
        return true;
    }
    return KWin::Effect::provides(feature);
}

} // namespace KWin
