/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "SevenStart.h"

SevenStart::SevenStart(QObject *parentObject, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Applet(parentObject, data, args)
{
    if(KWindowSystem::isPlatformX11()) {
        connect(KX11Extras::self(), SIGNAL(compositingChanged(bool)), this, SLOT(onCompositingChanged(bool)));
    }

    connect(KWindowSystem::self(), SIGNAL(showingDesktopChanged(bool)), this, SLOT(onShowingDesktopChanged(bool)));
}

SevenStart::~SevenStart()
{
    if(inputMaskCache) delete inputMaskCache;
}


bool SevenStart::fileExists(QUrl path)
{
    if(!path.isLocalFile()) return false;

    QFileInfo file(path.toLocalFile());
    return file.exists() && file.isFile();
}

void SevenStart::setOrb(QQuickWindow* w)
{
    orb = w;
}

void SevenStart::setMask(QString mask, bool overrideMask)
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


void SevenStart::setTransparentWindow()
{
    if(orb == nullptr || inputMaskCache == nullptr) return;

    bool compositingActive{true};
    if(KWindowSystem::isPlatformX11()) compositingActive = KX11Extras::compositingActive();

    if(!compositingActive) {
        orb->setMask(*inputMaskCache);
    } else {
        orb->setMask(QRegion());
    }
}

void SevenStart::setActiveWin(QQuickWindow* w)
{
    if(w == nullptr || KWindowSystem::isPlatformWayland()) return;
    KX11Extras::forceActiveWindow(w->winId());
}


void SevenStart::onCompositingChanged(bool enabled)
{
    setTransparentWindow();
}

void SevenStart::onShowingDesktopChanged(bool enabled)
{
    if(enabled && orb != nullptr)
        orb->raise();
}

K_PLUGIN_CLASS(SevenStart)

#include "SevenStart.moc"
