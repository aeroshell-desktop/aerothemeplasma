/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "SevenStart.h"
#include <kwindowsystem.h>

SevenStart::SevenStart(QObject *parent, const QVariantList &args)
    : Plasma::Applet(parent, args)
{
    connect(KX11Extras::self(), SIGNAL(compositingChanged(bool)), this, SLOT(onCompositingChanged(bool)));
    connect(KWindowSystem::self(), SIGNAL(showingDesktopChanged(bool)), this, SLOT(onShowingDesktopChanged(bool)));
    connect(KX11Extras::self(), SIGNAL(stackingOrderChanged()), this, SLOT(onStackingOrderChanged()));
}

SevenStart::~SevenStart()
{
    if(inputMaskCache) delete inputMaskCache;
}

K_PLUGIN_CLASS_WITH_JSON(SevenStart, "metadata.json")

#include "SevenStart.moc"
