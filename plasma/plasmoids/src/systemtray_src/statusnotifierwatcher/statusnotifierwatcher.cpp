/*
    SPDX-FileCopyrightText: 2009 Marco Martin <notmart@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "statusnotifierwatcher.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QDebug>

#include <kpluginfactory.h>

#include "statusnotifieritem_interface.h"
#include "statusnotifierwatcheradaptor.h"

K_PLUGIN_CLASS_WITH_JSON(StatusNotifierWatcher, "statusnotifierwatcher.json")

StatusNotifierWatcher::StatusNotifierWatcher(QObject *parent, const QList<QVariant> &)
    : KDEDModule(parent)
{
    setModuleName(QStringLiteral("StatusNotifierWatcher"));
    new StatusNotifierWatcherAdaptor(this);
    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.registerObject(QStringLiteral("/StatusNotifierWatcher"), this);

    m_serviceWatcher = new QDBusServiceWatcher(this);
    m_serviceWatcher->setConnection(dbus);
    m_serviceWatcher->setWatchMode(QDBusServiceWatcher::WatchForUnregistration);

    connect(m_serviceWatcher, &QDBusServiceWatcher::serviceUnregistered, this, &StatusNotifierWatcher::serviceUnregistered);
}

StatusNotifierWatcher::~StatusNotifierWatcher()
{
}

void StatusNotifierWatcher::RegisterStatusNotifierItem(const QString &serviceOrPath)
{
    QString service;
    QString path;
    if (serviceOrPath.startsWith(QLatin1Char('/'))) {
        service = message().service();
        path = serviceOrPath;
    } else {
        service = serviceOrPath;
        path = QStringLiteral("/StatusNotifierItem");
    }
    QString notifierItemId = service + path;
    if (m_registeredServices.contains(notifierItemId)) {
        return;
    }
    m_serviceWatcher->addWatchedService(service);
    if (QDBusConnection::sessionBus().interface()->isServiceRegistered(service).value()) {
        // check if the service has registered a SystemTray object
        org::kde::StatusNotifierItem trayclient(service, path, QDBusConnection::sessionBus());
        if (trayclient.isValid()) {
            qDebug() << "Registering" << notifierItemId << "to system tray";
            m_registeredServices.append(notifierItemId);
            Q_EMIT StatusNotifierItemRegistered(notifierItemId);
        } else {
            m_serviceWatcher->removeWatchedService(service);
        }
    } else {
        m_serviceWatcher->removeWatchedService(service);
    }
}

QStringList StatusNotifierWatcher::RegisteredStatusNotifierItems() const
{
    return m_registeredServices;
}

void StatusNotifierWatcher::serviceUnregistered(const QString &name)
{
    qDebug() << "Service " << name << "unregistered";
    m_serviceWatcher->removeWatchedService(name);

    const QString match = name + QLatin1Char('/');
    QStringList::Iterator it = m_registeredServices.begin();
    while (it != m_registeredServices.end()) {
        if (it->startsWith(match)) {
            QString name = *it;
            it = m_registeredServices.erase(it);
            Q_EMIT StatusNotifierItemUnregistered(name);
        } else {
            ++it;
        }
    }
}

void StatusNotifierWatcher::RegisterStatusNotifierHost(const QString &service)
{
    Q_UNUSED(service)
}

bool StatusNotifierWatcher::IsStatusNotifierHostRegistered() const
{
    return true;
}

int StatusNotifierWatcher::ProtocolVersion() const
{
    return 0;
}

#include "statusnotifierwatcher.moc"

#include "moc_statusnotifierwatcher.cpp"
