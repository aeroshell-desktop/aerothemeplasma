/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef BLUR_CONFIG_H
#define BLUR_CONFIG_H

#include <QFileDialog>
#include <KCModule>
#include "ui_blur_config.h"
#include <QSharedMemory>
#include <QBuffer>
#include <QDataStream>
#include <QColor>
#include <QPair>

#include "mainwindow.h"

namespace KWin
{

class BlurEffectConfig : public KCModule
{
    Q_OBJECT

public:
    explicit BlurEffectConfig(QWidget *parent = nullptr, const QVariantList& args = QVariantList());
    ~BlurEffectConfig() override;

    void save() override;
    void writeToMemory(QColor col, bool transparency, bool skip);
public slots:
    void setTexturePath();
    void clearTexturePath();
    void openColorMixer(QString str);
private:
    ::Ui::BlurEffectConfig ui;
    QFileDialog* m_dialog;
    QSharedMemory m_sharedMemory;
    MainWindow *m_window;
};

} // namespace KWin

#endif

