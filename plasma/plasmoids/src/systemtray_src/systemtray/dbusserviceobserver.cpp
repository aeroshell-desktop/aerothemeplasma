/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "dbusserviceobserver.h"

#include "systemtraysettings.h"

#include <KPluginMetaData>

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusServiceWatcher>

DBusServiceObserver::DBusServiceObserver(const QPointer<SystemTraySettings> &settings, QObject *parent)
    : QObject(parent)
    , m_settings(settings)
    , m_sessionServiceWatcher(new QDBusServiceWatcher(this))
    , m_systemServiceWatcher(new QDBusServiceWatcher(this))
{
    m_sessionServiceWatcher->setConnection(QDBusConnection::sessionBus());
    m_systemServiceWatcher->setConnection(QDBusConnection::systemBus());

    connect(m_settings, &SystemTraySettings::enabledPluginsChanged, this, &DBusServiceObserver::initDBusActivatables);

    // Watch for new services
    connect(m_sessionServiceWatcher, &QDBusServiceWatcher::serviceRegistered, this, [this](const QString &serviceName) {
        if (!m_dbusSessionServiceNamesFetched) {
            return;
        }
        serviceRegistered(serviceName);
    });
    connect(m_sessionServiceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, [this](const QString &serviceName) {
        if (!m_dbusSessionServiceNamesFetched) {
            return;
        }
        serviceUnregistered(serviceName);
    });
    connect(m_systemServiceWatcher, &QDBusServiceWatcher::serviceRegistered, this, [this](const QString &serviceName) {
        if (!m_dbusSystemServiceNamesFetched) {
            return;
        }
        serviceRegistered(serviceName);
    });
    connect(m_systemServiceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, [this](const QString &serviceName) {
        if (!m_dbusSystemServiceNamesFetched) {
            return;
        }
        serviceUnregistered(serviceName);
    });
}

void DBusServiceObserver::registerPlugin(const KPluginMetaData &pluginMetaData)
{
    const QString dbusactivation = pluginMetaData.value(QStringView(u"X-Plasma-DBusActivationService"));
    if (!dbusactivation.isEmpty()) {
        qDebug() << "Found DBus-able Applet: " << pluginMetaData.pluginId() << dbusactivation;
        QRegularExpression rx = QRegularExpression::fromWildcard(dbusactivation);
        m_dbusActivatableTasks[pluginMetaData.pluginId()] = rx;

        const QString watchedService = QString(dbusactivation).replace(QLatin1String(".*"), QLatin1String("*"));
        m_sessionServiceWatcher->addWatchedService(watchedService);
        m_systemServiceWatcher->addWatchedService(watchedService);
    }
}

void DBusServiceObserver::unregisterPlugin(const QString &pluginId)
{
    if (m_dbusActivatableTasks.contains(pluginId)) {
        auto rx = m_dbusActivatableTasks.take(pluginId);
        const QString watchedService = rx.pattern().replace(QLatin1String(".*"), QLatin1String("*"));
        m_sessionServiceWatcher->removeWatchedService(watchedService);
        m_systemServiceWatcher->removeWatchedService(watchedService);
    }
}

bool DBusServiceObserver::isDBusActivable(const QString &pluginId)
{
    return m_dbusActivatableTasks.contains(pluginId);
}

/* Loading and unloading Plasmoids when dbus services come and go
 *
 * This works as follows:
 * - we collect a list of plugins and related services in m_dbusActivatableTasks
 * - we query DBus for the list of services, async (initDBusActivatables())
 * - we go over that list, adding tasks when a service and plugin match ({session,system}BusNameFetchFinished())
 * - we start watching for new services, and do the same (serviceRegistered())
 * - whenever a service is gone, we check whether to unload a Plasmoid (serviceUnregistered())
 *
 * Order of events has to be:
 * - create a match rule for new service on DBus daemon
 * - start fetching a list of names
 * - ignore all changes that happen in the meantime
 * - handle the list of all names
 */
void DBusServiceObserver::initDBusActivatables()
{
    // fetch list of existing services
    QDBusConnection::sessionBus().interface()->callWithCallback(QStringLiteral("ListNames"),
                                                                QList<QVariant>(),
                                                                this,
                                                                SLOT(sessionBusNameFetchFinished(QStringList)),
                                                                SLOT(sessionBusNameFetchError(QDBusError)));

    QDBusConnection::systemBus().interface()->callWithCallback(QStringLiteral("ListNames"),
                                                               QList<QVariant>(),
                                                               this,
                                                               SLOT(systemBusNameFetchFinished(QStringList)),
                                                               SLOT(systemBusNameFetchError(QDBusError)));
}

void DBusServiceObserver::sessionBusNameFetchFinished(const QStringList &list)
{
    for (const QString &serviceName : list) {
        serviceRegistered(serviceName);
    }

    m_dbusSessionServiceNamesFetched = true;
}

void DBusServiceObserver::sessionBusNameFetchError(const QDBusError &error)
{
    qWarning() << "Could not get list of available D-Bus services on the session bus:" << error.name() << ":" << error.message();
}

void DBusServiceObserver::systemBusNameFetchFinished(const QStringList &list)
{
    for (const QString &serviceName : list) {
        serviceRegistered(serviceName);
    }

    m_dbusSystemServiceNamesFetched = true;
}

void DBusServiceObserver::systemBusNameFetchError(const QDBusError &error)
{
    qWarning() << "Could not get list of available D-Bus services on the system bus:" << error.name() << ":" << error.message();
}

void DBusServiceObserver::serviceRegistered(const QString &service)
{
    if (service.startsWith(QLatin1Char(':'))) {
        return;
    }

    for (auto it = m_dbusActivatableTasks.constBegin(), end = m_dbusActivatableTasks.constEnd(); it != end; ++it) {
        const QString &plugin = it.key();
        if (!m_settings->isEnabledPlugin(plugin)) {
            continue;
        }

        const auto &rx = it.value();
        if (rx.match(service).hasMatch()) {
            qDebug() << "DBus service" << service << "matching" << m_dbusActivatableTasks[plugin] << "appeared. Loading" << plugin;
            Q_EMIT serviceStarted(plugin);
            m_dbusServiceCounts[plugin]++;
        }
    }
}

void DBusServiceObserver::serviceUnregistered(const QString &service)
{
    for (auto it = m_dbusActivatableTasks.constBegin(), end = m_dbusActivatableTasks.constEnd(); it != end; ++it) {
        const QString &plugin = it.key();
        if (!m_settings->isEnabledPlugin(plugin)) {
            continue;
        }

        const auto &rx = it.value();
        if (rx.match(service).hasMatch()) {
            m_dbusServiceCounts[plugin]--;
            Q_ASSERT(m_dbusServiceCounts[plugin] >= 0);
            if (m_dbusServiceCounts[plugin] == 0) {
                qDebug() << "DBus service" << service << "matching" << m_dbusActivatableTasks[plugin] << "disappeared. Unloading" << plugin;
                Q_EMIT serviceStopped(plugin);
            }
        }
    }
}

#include "moc_dbusserviceobserver.cpp"
