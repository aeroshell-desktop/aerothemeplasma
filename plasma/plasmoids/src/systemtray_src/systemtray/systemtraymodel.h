/*
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QAbstractListModel>
#include <QConcatenateTablesProxyModel>
#include <QList>
#include <QPointer>
#include <qqmlregistration.h>

#include <KPluginMetaData>
#include <Plasma/Plasma>
#include <Plasma5Support/Service>

namespace Plasma
{
class Applet;
}

class PlasmoidRegistry;
class SystemTraySettings;
class StatusNotifierItemHost;

/**
 * @brief Base class for models used in System Tray.
 *
 */
class BaseModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum class BaseRole {
        ItemType = Qt::UserRole + 1,
        ItemId,
        CanRender,
        Category,
        Status,
        EffectiveStatus,
        LastBaseRole,
    };

    explicit BaseModel(QPointer<SystemTraySettings> settings, QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;

private Q_SLOTS:
    void onConfigurationChanged();

protected:
    Plasma::Types::ItemStatus calculateEffectiveStatus(bool canRender, Plasma::Types::ItemStatus status, QString itemId) const;

private:
    QPointer<SystemTraySettings> m_settings;

    bool m_showAllItems;
    QStringList m_shownItems;
    QStringList m_hiddenItems;
};

/**
 * @brief Data model for plasmoids/applets.
 */
class PlasmoidModel : public BaseModel
{
    Q_OBJECT
public:
    enum class Role {
        Applet = static_cast<int>(BaseModel::BaseRole::LastBaseRole) + 1,
        HasApplet,
    };

    explicit PlasmoidModel(const QPointer<SystemTraySettings> &settings, const QPointer<PlasmoidRegistry> &plasmoidRegistry, QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

public Q_SLOTS:
    void addApplet(Plasma::Applet *applet);
    void removeApplet(Plasma::Applet *applet);

private Q_SLOTS:
    void appendRow(const KPluginMetaData &pluginMetaData);
    void removeRow(const QString &pluginId);

private:
    struct Item {
        KPluginMetaData pluginMetaData;
        Plasma::Applet *applet = nullptr;
    };

    int indexOfPluginId(const QString &pluginId) const;

    QPointer<PlasmoidRegistry> m_plasmoidRegistry;

    QList<Item> m_items;
};

/**
 * @brief Data model for Status Notifier Items (SNI).
 * @note This model is exported to QML for plasma-mobile
 */
class StatusNotifierModel : public BaseModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum class Role {
        DataEngineSource = static_cast<int>(BaseModel::BaseRole::LastBaseRole) + 100,
        Service,
        AttentionIcon,
        AttentionIconName,
        AttentionMovieName,
        Category,
        Icon,
        IconName,
        IconThemePath,
        Id,
        ItemIsMenu,
        OverlayIconName,
        Status,
        Title,
        ToolTipSubTitle,
        ToolTipTitle,
        WindowId,
    };

    explicit StatusNotifierModel(QObject *parent = nullptr);
    explicit StatusNotifierModel(QPointer<SystemTraySettings> settings, QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    struct Item {
        QString source;
        Plasma5Support::Service *service = nullptr;
    };

public Q_SLOTS:
    void addSource(const QString &source);
    void removeSource(const QString &source);
    void dataUpdated(const QString &sourceName);

private:
    int indexOfSource(const QString &source) const;
    void init();

    StatusNotifierItemHost *m_sniHost = nullptr;
    QList<Item> m_items;
};
Q_DECLARE_TYPEINFO(StatusNotifierModel::Item, Q_RELOCATABLE_TYPE);

/**
 * @brief Cantenating model for system tray, that can expose multiple data models as one.
 */
class SystemTrayModel : public QConcatenateTablesProxyModel
{
    Q_OBJECT
public:
    explicit SystemTrayModel(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;

    void addSourceModel(QAbstractItemModel *sourceModel);

private:
    QHash<int, QByteArray> m_roleNames;
};
