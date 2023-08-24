/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "blur_config.h"
// KConfigSkeleton
#include "blurconfig.h"
//#include <config-kwin.h>

#include <kwineffects_interface.h>
#include <KAboutData>
#include <KPluginFactory>
#include <QDir>


K_PLUGIN_FACTORY_WITH_JSON(BlurEffectConfigFactory,
                           "blur_config.json",
                           registerPlugin<KWin::BlurEffectConfig>();)

namespace KWin
{

BlurEffectConfig::BlurEffectConfig(QWidget *parent, const QVariantList &args)
    : KCModule(parent, args), m_sharedMemory("kwinreflect")
{
    ui.setupUi(this);

    QString tooltipText = "Add window class values here, separated by semicolons.\n\nThe window class for a specific window can be found by either:\n1. Reading the value of WM_CLASS(STRING) from xprop.\n2. Opening 'Window Rules' -> 'Add New...' -> 'Detect Window Properties'\nand reading the 'Window class (application)' row.";
    ui.kcfg_ExcludedWindows->setToolTip(tooltipText);
    ui.kcfg_ExcludedColorization->setToolTip(tooltipText);

    // These widgets are changed indirectly by the color mixer window.
    ui.kcfg_AccentColor->setVisible(false);
    ui.kcfg_AccentColorName->setVisible(false);
    ui.kcfg_CustomColor->setVisible(false);
    ui.kcfg_EnableTransparency->setVisible(false);

    // Setting up the file dialog.
    m_dialog = new QFileDialog(this);
    m_dialog->setFileMode(QFileDialog::ExistingFile);
    m_dialog->setNameFilter("PNG files (*.png)");
    connect(ui.showAccentColor_label, SIGNAL(linkActivated(QString)), this, SLOT(openColorMixer(QString)));
    connect(ui.browse_pushButton, SIGNAL(clicked()), this, SLOT(setTexturePath()));
    connect(ui.clear_pushButton, SIGNAL(clicked()), this, SLOT(clearTexturePath()));

    // Initializing the KCModule parts.
    BlurConfig::instance("kwinrc");
    addConfig(BlurConfig::self(), this);

    // Initializing color mixer window
    m_window = new MainWindow(ui.kcfg_AccentColorName, ui.kcfg_EnableTransparency, ui.kcfg_AccentColor, ui.kcfg_CustomColor, this);
    m_window->setWindowModality(Qt::WindowModality::WindowModal);
    load();
}


void BlurEffectConfig::openColorMixer(QString str)
{
    m_window->show();
}

/*
 * Writes the following to the shared memory between this and the effect process itself:
 * 1. Currently selected accent color
 * 2. Transparency toggle
 * 3. A boolean which tells the BlurEffect::reconfigure function to end before loading
 *    the rest of the configuration to prevent unnecessary loading.
 */
void BlurEffectConfig::writeToMemory(QColor col, bool transparency, bool skip)
{
    // Examples for QSharedMemory can be found on the Qt website.
    if(m_sharedMemory.isAttached())
    {
        if(!m_sharedMemory.detach())
        {
            printf("Couldn't detach shared memory.\n");
        }
    }

    QBuffer buffer;
    buffer.open(QBuffer::ReadWrite);
    QDataStream out(&buffer);
    //QString result = "Please work this time"; // I'm gonna keep this I think it's funny
    QPair<QColor, QPair<bool, bool>> result;
    result.first = col;
    result.second = QPair(transparency, skip);
    out << result;
    int size = buffer.size();

    if(!m_sharedMemory.create(size))
    {
        printf("Couldn't create or attach shared memory.\n");
        return;
    }
    m_sharedMemory.lock(); // Mutex lock
    char* destination = (char*)m_sharedMemory.data();
    const char* source = buffer.data().data();
    memcpy(destination, source, qMin(m_sharedMemory.size(), size));
    m_sharedMemory.unlock();

    // Calls BlurEffect::reconfigure through qdbus
    OrgKdeKwinEffectsInterface interface(QStringLiteral("org.kde.KWin"),
                                         QStringLiteral("/Effects"),
                                         QDBusConnection::sessionBus());
    interface.reconfigureEffect(QStringLiteral("reflection"));
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
    delete m_window;
    delete m_dialog;
}

// Saves the configuration to disk and calls the reconfigure function through qdbus.
void BlurEffectConfig::save()
{
    writeToMemory(ui.kcfg_AccentColor->toPlainText(), ui.kcfg_EnableTransparency->isChecked(), false);
    KCModule::save();

    OrgKdeKwinEffectsInterface interface(QStringLiteral("org.kde.KWin"),
                                         QStringLiteral("/Effects"),
                                         QDBusConnection::sessionBus());
    interface.reconfigureEffect(QStringLiteral("reflection"));
}

} // namespace KWin

#include "blur_config.moc"
