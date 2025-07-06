/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
#include "blur_config.h"

//#include <config-kwin.h>

// KConfigSkeleton
#include "blurconfig.h"

#include <KPluginFactory>
#include "kwineffects_interface.h"

#include "../hsvrgb.h"
#include "../wackyfunc.h"

namespace KWin
{

K_PLUGIN_CLASS(BlurEffectConfig)

BlurEffectConfig::BlurEffectConfig(QObject *parent, const KPluginMetaData &data)
    : KCModule(parent, data), m_sharedMemory("kwinaero")
{
    ui.setupUi(widget());
    BlurConfig::instance("kwinrc");
    addConfig(BlurConfig::self(), widget());
    calculateDebugPrint();

	ui.invisibleWidgets->setVisible(false);
	ui.debugValues->setVisible(false);
	ui.debugValues->setVisible(false);
    ui.kcfg_BlurMatching->setVisible(false);
	
	m_dialog = new QFileDialog();
	m_dialog->setFileMode(QFileDialog::ExistingFile);
	m_dialog->setNameFilter("PNG files (*.png)");

	connect(ui.browse_pushButton, SIGNAL(clicked()), this, SLOT(setTexturePath()));
    connect(ui.clear_pushButton, SIGNAL(clicked()), this, SLOT(clearTexturePath()));
	connect(ui.showAccentColor_label, SIGNAL(linkActivated(QString)), this, SLOT(openColorMixer(QString)));
    connect(ui.kcfg_ReflectionIntensity, SIGNAL(valueChanged(int)), this, SLOT(on_kcfg_ReflectionIntensity_valueChanged(int)));
    connect(ui.kcfg_FirefoxHollowRegion, SIGNAL(checkStateChanged(Qt::CheckState)), this, SLOT(on_kcfg_FirefoxHollowRegion_checkStateChanged(Qt::CheckState)));

	m_window = new MainWindow(ui.kcfg_AccentColorName, ui.kcfg_AccentColorGroup, ui.kcfg_EnableTransparency,
							  ui.kcfg_AeroHue, ui.kcfg_AeroSaturation, ui.kcfg_AeroBrightness,
							  ui.kcfg_AeroIntensity, ui.kcfg_CustomColor, this, nullptr);
	m_window->setWindowModality(Qt::WindowModality::WindowModal);

    ui.reflectionLabel->setText(QString::number(ui.kcfg_ReflectionIntensity->value()) + " %" );
    on_kcfg_FirefoxHollowRegion_checkStateChanged(ui.kcfg_FirefoxHollowRegion->checkState());

}
void BlurEffectConfig::openColorMixer(QString str)
{
	m_window->show();
}

BlurEffectConfig::~BlurEffectConfig()
{
	delete m_dialog;
}

void BlurEffectConfig::on_kcfg_FirefoxHollowRegion_checkStateChanged(Qt::CheckState state)
{
    ui.kcfg_FirefoxBlurTopMargin->setEnabled(state != Qt::Unchecked);
}
void BlurEffectConfig::on_kcfg_ReflectionIntensity_valueChanged(int value)
{
    ui.reflectionLabel->setText(QString::number(ui.kcfg_ReflectionIntensity->value()) + " %" );
    //writeToMemory(ui.kcfg_AeroHue->value(), )
}

void BlurEffectConfig::writeToMemory(int h, int s, int v, int i, bool transparency, bool skip)
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
	
    out << h;
	out << s;
	out << v;
	out << i;
	out << transparency;
	out << skip;
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

    OrgKdeKwinEffectsInterface interface(QStringLiteral("org.kde.KWin"),
                                         QStringLiteral("/Effects"),
                                         QDBusConnection::sessionBus());
    interface.reconfigureEffect(QStringLiteral("aeroglassblur"));
}
void BlurEffectConfig::save()
{
    int intensity  = ui.kcfg_AeroIntensity->value();
    int hue        = ui.kcfg_AeroHue->value();
    int saturation = ui.kcfg_AeroSaturation->value();
    int brightness = ui.kcfg_AeroBrightness->value();
	writeToMemory(hue, saturation, brightness, intensity, ui.kcfg_EnableTransparency->isChecked(), false);
    KCModule::save();
    OrgKdeKwinEffectsInterface interface(QStringLiteral("org.kde.KWin"),
                                         QStringLiteral("/Effects"),
                                         QDBusConnection::sessionBus());
    interface.reconfigureEffect(QStringLiteral("aeroglassblur"));
}

void BlurEffectConfig::on_kcfg_AeroIntensity_valueChanged(int value)
{
    Q_UNUSED(value)
    //calculateDebugPrint();
    //save();
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
void BlurEffectConfig::on_kcfg_AeroHue_valueChanged(int value)
{
    Q_UNUSED(value)
    //calculateDebugPrint();
    //save();
}

void BlurEffectConfig::on_kcfg_AeroSaturation_valueChanged(int value)
{
    Q_UNUSED(value)
    //calculateDebugPrint();
    //save();
}

void BlurEffectConfig::on_kcfg_AeroBrightness_valueChanged(int value)
{
    Q_UNUSED(value)
    //calculateDebugPrint();
    //save();
}

void BlurEffectConfig::calculateDebugPrint()
{
    int intensity  = ui.kcfg_AeroIntensity->value();
    int hue        = ui.kcfg_AeroHue->value();
    int saturation = ui.kcfg_AeroSaturation->value();
    int brightness = ui.kcfg_AeroBrightness->value();

    float fR = 0, fG = 0, fB = 0, fH = 0, fS = 0, fV = 0;

    fH = (float)hue;
    fS = ((float)saturation) / 100.0f;
    fV = ((float)brightness) / 100.0f;

    HSVtoRGB(fR, fG, fB, fH, fS, fV);

    int primaryBalance, secondaryBalance, blurBalance;
    getColorBalances(intensity, primaryBalance, secondaryBalance, blurBalance);

    //primaryBalance   *= 100.0f;
    //secondaryBalance *= 100.0f;
    //blurBalance      *= 100.0f;

    ui.printIntensity->setText(QString::number(intensity));

    ui.printHue->setText(QString::number(hue));
    ui.printSaturation->setText(QString::number(saturation));
    ui.printBrightness->setText(QString::number(brightness));

    ui.printRed->setText(QString::number(qRound(fR * 255)));
    ui.printGreen->setText(QString::number(qRound(fG * 255)));
    ui.printBlue->setText(QString::number(qRound(fB * 255)));

    ui.printColorBalance->setText(QString::number((primaryBalance)));
    ui.printAfterglowBalance->setText(QString::number((secondaryBalance)));
    ui.printBlurBalance->setText(QString::number((blurBalance)));
}

void BlurEffectConfig::loadColor(int r, int g, int b, int a)
{
    float fR = 0, fG = 0, fB = 0, fH = 0, fS = 0, fV = 0;
    float i = a;

    fR = r;
    fG = g;
    fB = b;

    fR /= 255;
    fG /= 255;
    fB /= 255;
    //i /= 2.55;

    RGBtoHSV(fR, fG, fB, fH, fS, fV);

    fS *= 100;
    fV *= 100;

    ui.kcfg_AeroIntensity->setValue(a);
    ui.kcfg_AeroHue->setValue(qRound(fH));
    ui.kcfg_AeroSaturation->setValue(qRound(fS));
    ui.kcfg_AeroBrightness->setValue(qRound(fV));
}

} // namespace KWin

#include "blur_config.moc"

#include "moc_blur_config.cpp"
