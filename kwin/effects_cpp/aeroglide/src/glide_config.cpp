/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2010 Alexandre Pereira <pereira.alex@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
#include "glide_config.h"

//#include "config-kwin.h"

// KConfigSkeleton
#include "glideconfig.h"

#include <KPluginFactory>
#include "kwineffects_interface.h"
#define KWIN_CONFIG "kwinrc"

namespace KWin
{

K_PLUGIN_CLASS(GlideEffectConfig)

GlideEffectConfig::GlideEffectConfig(QObject *parent, const KPluginMetaData &data)
    : KCModule(parent, data)
{
    ui.setupUi(widget());
    GlideConfig::instance(KWIN_CONFIG);
    addConfig(GlideConfig::self(), widget());
}

GlideEffectConfig::~GlideEffectConfig()
{
}

void GlideEffectConfig::save()
{
    KCModule::save();
    OrgKdeKwinEffectsInterface interface(QStringLiteral("org.kde.KWin"),
                                         QStringLiteral("/Effects"),
                                         QDBusConnection::sessionBus());
    interface.reconfigureEffect(QStringLiteral("aeroglide"));
}

} // namespace KWin

#include "glide_config.moc"

#include "moc_glide_config.cpp"
