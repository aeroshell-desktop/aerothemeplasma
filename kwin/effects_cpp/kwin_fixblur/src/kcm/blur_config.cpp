/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "blur_config.h"
// KConfigSkeleton
#include "blurconfig.h"
//#include <config-kwin.h>

#include "kwineffects_interface.h"
#include <KAboutData>
#include <KPluginFactory>
#include <QDir>


/*K_PLUGIN_FACTORY_WITH_JSON(BlurEffectConfigFactory,
                           "blur_config.json",
                           registerPlugin<KWin::BlurEffectConfig>();)*/

namespace KWin
{

K_PLUGIN_CLASS(BlurEffectConfig)

BlurEffectConfig::BlurEffectConfig(QObject *parent, const KPluginMetaData &data)
    : KCModule(parent, data)
{
    ui.setupUi(widget());

    QString tooltipText = "Add window class values here, separated by semicolons.\n\nThe window class for a specific window can be found by either:\n1. Reading the value of WM_CLASS(STRING) from xprop.\n2. Opening 'Window Rules' -> 'Add New...' -> 'Detect Window Properties'\nand reading the 'Window class (application)' row.";
    ui.kcfg_IncludedWindows->setToolTip(tooltipText);

    // Setting up the file dialog.
    m_dialog = new QFileDialog();
    m_dialog->setFileMode(QFileDialog::ExistingFile);
    m_dialog->setNameFilter("SVG files (*.svg)");
    connect(ui.browse_pushButton, SIGNAL(clicked()), this, SLOT(setTexturePath()));
    connect(ui.clear_pushButton, SIGNAL(clicked()), this, SLOT(clearTexturePath()));

    // Initializing the KCModule parts.
    BlurConfig::instance("kwinrc");
    addConfig(BlurConfig::self(), widget());

    load();
}

void BlurEffectConfig::clearTexturePath()
{
    ui.kcfg_TextureLocation->setText("");
}
void BlurEffectConfig::setTexturePath()
{
    if(m_dialog->exec())
    {
        ui.kcfg_TextureLocation->setText(m_dialog->selectedFiles()[0]);
    }
}

BlurEffectConfig::~BlurEffectConfig()
{
    delete m_dialog;
}

// Saves the configuration to disk and calls the reconfigure function through qdbus.
void BlurEffectConfig::save()
{
    KCModule::save();

    OrgKdeKwinEffectsInterface interface(QStringLiteral("org.kde.KWin"),
                                         QStringLiteral("/Effects"),
                                         QDBusConnection::sessionBus());
    interface.reconfigureEffect(QStringLiteral("customblur"));
}

} // namespace KWin

#include "blur_config.moc"
#include "moc_blur_config.cpp"
