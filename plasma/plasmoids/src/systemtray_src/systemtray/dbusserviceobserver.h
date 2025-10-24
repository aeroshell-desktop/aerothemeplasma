/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QDBusError>
#include <QHash>
#include <QObject>
#include <QPointer>
#include <QRegularExpression>

class KPluginMetaData;
class SystemTraySettings;
class QDBusServiceWatcher;

/**
 * @brief Loading and unloading Plasmoids when DBus services come and go.
 */
class DBusServiceObserver : public QObject
{
    Q_OBJECT
public:
    explicit DBusServiceObserver(const QPointer<SystemTraySettings> &settings, QObject *parent = nullptr);

    void registerPlugin(const KPluginMetaData &pluginMetaData);
    void unregisterPlugin(const QString &pluginId);
    bool isDBusActivable(const QString &pluginId);

Q_SIGNALS:
    void serviceStarted(const QString &pluginId);
    void serviceStopped(const QString &pluginId);

public Q_SLOTS:
    void initDBusActivatables();

private Q_SLOTS:
    void sessionBusNameFetchFinished(const QStringList &list);
    void systemBusNameFetchFinished(const QStringList &list);
    void sessionBusNameFetchError(const QDBusError &error);
    void systemBusNameFetchError(const QDBusError &error);

private:
    void serviceRegistered(const QString &service);
    void serviceUnregistered(const QString &service);

    QPointer<SystemTraySettings> m_settings;

    QDBusServiceWatcher *m_sessionServiceWatcher;
    QDBusServiceWatcher *m_systemServiceWatcher;

    QHash<QString /*plugin id*/, QRegularExpression /*DBus Service*/> m_dbusActivatableTasks;
    QHash<QString, int> m_dbusServiceCounts;
    bool m_dbusSessionServiceNamesFetched = false;
    bool m_dbusSystemServiceNamesFetched = false;
};
