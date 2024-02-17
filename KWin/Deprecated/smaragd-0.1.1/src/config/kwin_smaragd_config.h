/*
 * kwin_smaragd_config.h - Emerald window decoration for KDE
 *
 * Copyright (c) 2010 Christoph Feck <christoph@maxiom.de>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#ifndef KWIN_SMARAGD_CONFIG_H
#define KWIN_SMARAGD_CONFIG_H 1

#include "ui_kwin_smaragd_dialog.h"
#include "configmanager.h"

namespace Smaragd
{

class ConfigUi : public QWidget, public Ui::KWinSmaragdDialog
{
Q_OBJECT

public:
    explicit ConfigUi(QWidget *parent = 0)
        : QWidget(parent)
    {
        setupUi(this);
        verticalLayout->setMargin(0);
    }
};

class Config : public QObject
{
Q_OBJECT

public:
    explicit Config(KConfig *config, QWidget *parent = 0);
    virtual ~Config();

public Q_SLOTS:
    void load(const KConfigGroup &configGroup);
    void save(KConfigGroup &configGroup);
    void defaults();
    void setShadowTabDisabled(bool disabled) { ui->tabWidget->setTabEnabled(1, !disabled); }

Q_SIGNALS:
    void changed();

protected Q_SLOTS:
    void slotSelectionChanged();

private:
    ConfigManager configManager;
    KConfig *smaragdConfig;
    ConfigUi *ui;
};

}; // namespace Smaragd

#endif

