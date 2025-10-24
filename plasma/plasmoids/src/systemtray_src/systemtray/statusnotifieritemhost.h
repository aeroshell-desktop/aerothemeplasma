/*
    SPDX-FileCopyrightText: 2009 Marco Martin <notmart@gmail.com>
    SPDX-FileCopyrightText: 2009 Matthieu Gallien <matthieu_gallien@yahoo.fr>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include "statusnotifierwatcher_interface.h"
#include <QDBusConnection>

class StatusNotifierItemSource;

// Define our plasma Runner
class StatusNotifierItemHost : public QObject
{
    Q_OBJECT

public:
    StatusNotifierItemHost();
    virtual ~StatusNotifierItemHost();

    static StatusNotifierItemHost *self();

    const QList<QString> services() const;
    StatusNotifierItemSource *itemForService(const QString service);

Q_SIGNALS:
    void itemAdded(const QString &service);
    void itemRemoved(const QString &service);

private Q_SLOTS:
    void serviceChange(const QString &name, const QString &oldOwner, const QString &newOwner);
    void registerWatcher(const QString &service);
    void unregisterWatcher(const QString &service);
    void serviceRegistered(const QString &service);
    void serviceUnregistered(const QString &service);

private:
    void init();
    void removeAllSNIServices();
    void addSNIService(const QString &service);
    void removeSNIService(const QString &service);
    int indexOfItem(const QString &service) const;

    org::kde::StatusNotifierWatcher *m_statusNotifierWatcher;
    QString m_serviceName;
    static const int s_protocolVersion = 0;
    QHash<QString, StatusNotifierItemSource *> m_sniServices;
};
