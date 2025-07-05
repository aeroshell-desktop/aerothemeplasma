/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include "ui_blur_config.h"
#include <KCModule>
#include <QDir>
#include <QSharedMemory>
#include <QBuffer>
#include <QDataStream>
#include <QFileDialog>

#include "mainwindow.h"

namespace KWin
{

class BlurEffectConfig : public KCModule
{
    Q_OBJECT

public:
    explicit BlurEffectConfig(QObject *parent, const KPluginMetaData &data);
    ~BlurEffectConfig() override;

    void save() override;
	void writeToMemory(int h, int s, int v, int i, bool transparency, bool skip);
private slots:
	void setTexturePath();
	void clearTexturePath();
	void openColorMixer(QString str);
    void on_kcfg_AeroIntensity_valueChanged(int value);
    void on_kcfg_AeroHue_valueChanged(int value);
    void on_kcfg_AeroSaturation_valueChanged(int value);
    void on_kcfg_AeroBrightness_valueChanged(int value);
    void on_kcfg_ReflectionIntensity_valueChanged(int value);
    void on_kcfg_FirefoxHollowRegion_checkStateChanged(Qt::CheckState state);

private:
    ::Ui::BlurEffectConfig ui;

	QFileDialog* m_dialog;
	QSharedMemory m_sharedMemory;
	MainWindow *m_window;

    void calculateDebugPrint();
    void loadColor(int r, int g, int b, int a);
};

} // namespace KWin
