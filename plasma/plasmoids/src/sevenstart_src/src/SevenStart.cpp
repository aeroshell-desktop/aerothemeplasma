/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "SevenStart.h"
#include <kwindowsystem.h>

SevenStart::SevenStart(QObject *parentObject, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Applet(parentObject, data, args)
{
    connect(KX11Extras::self(), SIGNAL(compositingChanged(bool)), this, SLOT(onCompositingChanged(bool)));
    connect(KWindowSystem::self(), SIGNAL(showingDesktopChanged(bool)), this, SLOT(onShowingDesktopChanged(bool)));
}

SevenStart::~SevenStart()
{
    if(inputMaskCache) delete inputMaskCache;
}

K_PLUGIN_CLASS(SevenStart)
//K_PLUGIN_CLASS_WITH_JSON(SevenStart, "package/metadata.json")

#include "SevenStart.moc"
