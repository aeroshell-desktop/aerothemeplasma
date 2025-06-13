/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "volume.h"
#include <kwindowsystem.h>
#include <kwindowinfo.h>
#include <kx11extras.h>

Volume::Volume(QObject *parentObject, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Applet(parentObject, data, args)
{
    m_config = KSharedConfig::openConfig("kwinrc", KConfig::NoGlobals);
}

Volume::~Volume()
{
}

K_PLUGIN_CLASS(Volume)

#include "volume.moc"
