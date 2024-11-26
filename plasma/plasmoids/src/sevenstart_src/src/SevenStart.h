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
//#include <dialog.h>

class SevenStart : public Plasma::Applet
{
    Q_OBJECT

public:
    SevenStart(QObject *parentObject, const KPluginMetaData &data, const QVariantList &args);
    ~SevenStart();

    Q_INVOKABLE void setDashWindow(QQuickWindow* w, QRegion mask)
    {
        dashWindow = w;
        setDialogAppearance(w, mask);
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

    // In all honesty, I don't know why this works at this point, it just does.
    // I would sincerely love to know more about this and be told that there's a
    // much simpler way.
    /*Q_INVOKABLE void setWinState(QQuickWindow* w)
    {
        if (KWindowSystem::isPlatformX11())
            KX11Extras::setState(w->winId(), NET::SkipTaskbar | NET::SkipPager | NET::SkipSwitcher | NET::KeepAbove | NET::Sticky);
    }
    Q_INVOKABLE void setWinType(QQuickWindow* w)
    {
        if (KWindowSystem::isPlatformX11())
            KX11Extras::setType(w->winId(), NET::Dock);
    }*/

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
    Q_INVOKABLE void setDialogAppearance(QQuickWindow* w, QRegion mask)
    {
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
};

#endif
