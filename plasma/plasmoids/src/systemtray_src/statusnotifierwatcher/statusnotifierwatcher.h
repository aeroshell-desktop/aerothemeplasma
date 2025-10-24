/*
    SPDX-FileCopyrightText: 2009 Marco Martin <notmart@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <kdedmodule.h>

#include <QDBusContext>
#include <QObject>
#include <QSet>
#include <QStringList>

class QDBusServiceWatcher;

class StatusNotifierWatcher : public KDEDModule, protected QDBusContext
{
    Q_OBJECT
    Q_PROPERTY(QStringList RegisteredStatusNotifierItems READ RegisteredStatusNotifierItems)
    Q_PROPERTY(bool IsStatusNotifierHostRegistered READ IsStatusNotifierHostRegistered)
    Q_PROPERTY(int ProtocolVersion READ ProtocolVersion)

public:
    explicit StatusNotifierWatcher(QObject *parent, const QList<QVariant> &);
    ~StatusNotifierWatcher() override;

    QStringList RegisteredStatusNotifierItems() const;

    bool IsStatusNotifierHostRegistered() const;

    int ProtocolVersion() const;

public Q_SLOTS:
    void RegisterStatusNotifierItem(const QString &service);

    void RegisterStatusNotifierHost(const QString &service);

protected Q_SLOTS:
    void serviceUnregistered(const QString &name);

Q_SIGNALS:
    void StatusNotifierItemRegistered(const QString &service);
    // TODO: decide if this makes sense, the systray itself could notice the vanishing of items, but looks complete putting it here
    void StatusNotifierItemUnregistered(const QString &service);
    void StatusNotifierHostRegistered();
    void StatusNotifierHostUnregistered();

private:
    QDBusServiceWatcher *m_serviceWatcher = nullptr;
    QStringList m_registeredServices;
};
