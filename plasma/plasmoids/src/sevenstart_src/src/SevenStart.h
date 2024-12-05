/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef SEVENSTART_H
#define SEVENSTART_H
#include <Plasma/Applet>
#include <QColor>
#include <QPixmap>
#include <QImage>
#include <QRgb>
#include <QIcon>
#include <QVariant>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickItemGrabResult>
#include <QtQuick/QQuickWindow>
#include <QBitmap>
#include <QWindow>
#include <QCursor>
#include <QKeySequence>
#include <QVariantList>
#include <kwindoweffects.h>
#include <kwindowsystem.h>
#include <kwindowinfo.h>
#include <kx11extras.h>
#include <QFileInfo>
#include <QUrl>
#include "dialogshadows_p.h"
#include <plasmaquick/dialog.h>

class SevenStart : public Plasma::Applet
{
    Q_OBJECT

public:
    SevenStart(QObject *parentObject, const KPluginMetaData &data, const QVariantList &args);
    ~SevenStart();

    QRect availableScreenGeometryForPosition(const QPoint &pos) const
    {
        // FIXME: QWindow::screen() never ever changes if the window is moved across
        //        virtual screens (normal two screens with X), this seems to be intentional
        //        as it's explicitly mentioned in the docs. Until that's changed or some
        //        more proper way of howto get the current QScreen for given QWindow is found,
        //        we simply iterate over the virtual screens and pick the one our QWindow
        //        says it's at.
        QRect avail;
        const auto screens = QGuiApplication::screens();
        for (QScreen *screen : screens) {
            // we check geometry() but then take availableGeometry()
            // to reliably check in which screen a position is, we need the full
            // geometry, including areas for panels
            if (screen->geometry().contains(pos)) {
                avail = screen->availableGeometry();
                break;
            }
        }

        /*
         * if the heuristic fails (because the topleft of the dialog is offscreen)
         * use at least our screen()
         * the screen should be correctly updated now on Qt 5.3+ so should be
         * more reliable anyways (could be tried to remove the whole for loop
         * above at this point)
         *
         * important: screen can be a nullptr... see bug 345173
         */
        if (avail.isEmpty() && dashWindow && dashWindow->screen()) {
            avail = dashWindow->screen()->availableGeometry();
        }

        return avail;
    }
    void setShadowBorders(KSvg::FrameSvg::EnabledBorders enabledBorders)
    {
        if(dashWindow == nullptr || shadow == nullptr) return;
        shadow->setEnabledBorders(dashWindow, enabledBorders);
    }

    Q_INVOKABLE void syncBorders(const QRect &geom, Plasma::Types::Location location)
    {
        if(!shadowEnabled) return;
        QRect avail = availableScreenGeometryForPosition(geom.topLeft());
        int borders = KSvg::FrameSvg::AllBorders;

        if (geom.x() <= avail.x() || location == Plasma::Types::LeftEdge) {
            borders = borders & ~KSvg::FrameSvg::LeftBorder;
        }
        if (geom.y() <= avail.y() || location == Plasma::Types::TopEdge) {
            borders = borders & ~KSvg::FrameSvg::TopBorder;
        }
        if (avail.right() <= geom.x() + geom.width() || location == Plasma::Types::RightEdge) {
            borders = borders & ~KSvg::FrameSvg::RightBorder;
        }
        if (avail.bottom() <= geom.y() + geom.height() || location == Plasma::Types::BottomEdge) {
            borders = borders & ~KSvg::FrameSvg::BottomBorder;
        }

        setShadowBorders((KSvg::FrameSvg::EnabledBorders)borders);
    }
    Q_INVOKABLE void setDashWindow(QQuickWindow* w, QRegion mask, QUrl svg)
    {
        dashWindow = w;
        if(!shadow)
        {
            shadow = new DialogShadows(this, svg.toString());
        }
        if(!w) return;
        setDialogAppearance(w, mask);
    }
    Q_INVOKABLE void enableShadow(bool enable)
    {
        QWindow *window = static_cast<QWindow *>(dashWindow);
        if(!shadow || !dashWindow) return;
        if(enable && !shadowEnabled) shadow->addWindow(window);
        else if(!enable && shadowEnabled) shadow->removeWindow(window);
        shadowEnabled = enable;
    }
    Q_INVOKABLE bool fileExists(QUrl path)
    {
        if(!path.isLocalFile()) return false;

        QFileInfo file(path.toLocalFile());
        return file.exists() && file.isFile();
    }
    Q_INVOKABLE void setOrb(QQuickWindow* w)
    {
        orb = w;
    }
    Q_INVOKABLE void setMask(QString mask, bool overrideMask)
    {
        QString m = mask.mid(7).toStdString().c_str();
        if(overrideMask)
        {
            if(inputMaskCache != nullptr) delete inputMaskCache;
            inputMaskCache = new QBitmap(m);
        }
        else
        {
            if(!inputMaskCache)
            {
                inputMaskCache = new QBitmap(m);
            }
        }
    }

    // Uses QWindow::setMask(QRegion) to set a X11 input mask which also defines an arbitrary window shape.
    Q_INVOKABLE void setTransparentWindow()
    {
        if(orb == nullptr || inputMaskCache == nullptr) return;
        if(!KX11Extras::compositingActive())
        {
            orb->setMask(*inputMaskCache);
            printf("Set input mask correctly\n");
        }
        else if(KX11Extras::compositingActive())
        {
            orb->setMask(QRegion());
            printf("Reset input mask\n");
        }
    }
    Q_INVOKABLE void setActiveWin(QQuickWindow* w)
    {
        if(w == nullptr) return;
        KX11Extras::forceActiveWindow(w->winId());
    }
    Q_INVOKABLE void setDialogAppearance(QQuickWindow* w, QRegion mask)
    {
        if(w == nullptr) return;
        KWindowEffects::enableBlurBehind(w, true, mask);
    }
public Q_SLOTS:
    void onCompositingChanged(bool enabled)
    {
        setTransparentWindow();
    }
    void onShowingDesktopChanged(bool enabled)
    {
        if(enabled && orb != nullptr)
            orb->raise();
    }
protected:
    QBitmap* inputMaskCache = nullptr;
    QQuickWindow* orb = nullptr;
    QQuickWindow* dashWindow = nullptr;
    DialogShadows* shadow = nullptr;
    bool shadowEnabled = false;
};

#endif
