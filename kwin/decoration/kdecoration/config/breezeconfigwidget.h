//////////////////////////////////////////////////////////////////////////////
// breezeconfigurationui.h
// -------------------
//
// SPDX-FileCopyrightText: 2009 Hugo Pereira Da Costa <hugo.pereira@free.fr>
//
// SPDX-License-Identifier: MIT
//////////////////////////////////////////////////////////////////////////////

#pragma once

#include "breeze.h"
#include "breezeexceptionlistwidget.h"
#include "breezesettings.h"
#include "ui_breezeconfigurationui.h"

#include <KCModule>
#include <KSharedConfig>

#include <QSharedPointer>
#include <QWidget>

#include <QDir>
#include <QListWidget>
#include <QFileInfo>
#include <QFileInfoList>
#include <algorithm>
#include <QObject>
#include <QStringListModel>
#include <QItemSelection>
#include <QList>

namespace Breeze
{

//_____________________________________________
class ConfigWidget : public KCModule
{
    Q_OBJECT

public:
    //* constructor
    explicit ConfigWidget(QObject *parent, const KPluginMetaData &data, const QVariantList &args);

    //* destructor
    virtual ~ConfigWidget() = default;

    //* default
    void defaults() override;

    //* load configuration
    void load() override;

    //* save configuration
    void save() override;

protected Q_SLOTS:

    //* update changed state
    virtual void updateChanged();

    void themeChanged(QModelIndex index, QModelIndex previous);

private:
    //* ui
    Ui_BreezeConfigurationUI m_ui;

    //* kconfiguration object
    KSharedConfig::Ptr m_configuration;

    //* internal exception
    InternalSettingsPtr m_internalSettings;

    //* changed state
    bool m_changed;
    bool m_themeChanged;

};

}
