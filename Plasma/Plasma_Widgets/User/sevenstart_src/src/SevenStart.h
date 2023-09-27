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
#include <kx11extras.h>


class SevenStart : public Plasma::Applet
{
    Q_OBJECT

public:
    SevenStart( QObject *parent, const QVariantList &args );
    ~SevenStart();


    Q_INVOKABLE void setDashWindow(QQuickWindow* w)
    {
        dashWindow = w;
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

    // In all honesty, I don't know why this works at this point, it just does.
    // I would sincerely love to know more about this and be told that there's a
    // much simpler way.
    Q_INVOKABLE void setWinState(QQuickWindow* w)
    {
        KWindowSystem::setState(w->winId(), NET::SkipTaskbar | NET::SkipPager | NET::SkipSwitcher | NET::KeepAbove | NET::Sticky);
    }
    Q_INVOKABLE void setWinType(QQuickWindow* w)
    {
        KWindowSystem::setType(w->winId(), NET::Dock);
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
        KX11Extras::forceActiveWindow(w->winId());
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
    void onStackingOrderChanged()
    {
        if(orb != nullptr && dashWindow != nullptr)
        {
            orb->raise();

            // It works without any of this.
            /*auto stackingOrder = KX11Extras::stackingOrder();
            int l = stackingOrder.length()-1;
            if(l < 1) return;
            if(stackingOrder.at(l) == dashWindow->winId() && stackingOrder.at(l-1) == orb->winId())*/
        }

    }
protected:
    QBitmap* inputMaskCache = nullptr;
    QQuickWindow* orb = nullptr;
    QQuickWindow* dashWindow = nullptr;
};

#endif
