/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "plasmoidregistry.h"

#include "dbusserviceobserver.h"
#include "systemtraysettings.h"

#include <KPluginMetaData>
#include <Plasma/PluginLoader>

#include <QDBusConnection>

PlasmoidRegistry::PlasmoidRegistry(QPointer<SystemTraySettings> settings, QObject *parent)
    : QObject(parent)
    , m_settings(settings)
    , m_dbusObserver(new DBusServiceObserver(settings, this))
{
    connect(m_dbusObserver, &DBusServiceObserver::serviceStarted, this, &PlasmoidRegistry::plasmoidEnabled);
    connect(m_dbusObserver, &DBusServiceObserver::serviceStopped, this, &PlasmoidRegistry::plasmoidStopped);
}

void PlasmoidRegistry::init()
{
    QDBusConnection::sessionBus().connect(QString(),
                                          QStringLiteral("/KPackage/Plasma/Applet"),
                                          QStringLiteral("org.kde.plasma.kpackage"),
                                          QStringLiteral("packageInstalled"),
                                          this,
                                          SLOT(packageInstalled(QString)));
    QDBusConnection::sessionBus().connect(QString(),
                                          QStringLiteral("/KPackage/Plasma/Applet"),
                                          QStringLiteral("org.kde.plasma.kpackage"),
                                          QStringLiteral("packageUpdated"),
                                          this,
                                          SLOT(packageInstalled(QString)));
    QDBusConnection::sessionBus().connect(QString(),
                                          QStringLiteral("/KPackage/Plasma/Applet"),
                                          QStringLiteral("org.kde.plasma.kpackage"),
                                          QStringLiteral("packageUninstalled"),
                                          this,
                                          SLOT(packageUninstalled(QString)));

    connect(m_settings, &SystemTraySettings::enabledPluginsChanged, this, &PlasmoidRegistry::onEnabledPluginsChanged);

    for (const auto &info : Plasma::PluginLoader::self()->listAppletMetaData(QString())) {
        registerPlugin(info);
    }

    m_dbusObserver->initDBusActivatables();

    sanitizeSettings();
}

QMap<QString, KPluginMetaData> PlasmoidRegistry::systemTrayApplets()
{
    return m_systrayApplets;
}

bool PlasmoidRegistry::isSystemTrayApplet(const QString &pluginId)
{
    return m_systrayApplets.contains(pluginId);
}

void PlasmoidRegistry::onEnabledPluginsChanged(const QStringList &enabledPlugins, const QStringList &disabledPlugins)
{
    for (const QString &pluginId : enabledPlugins) {
        if (m_systrayApplets.contains(pluginId) && !m_dbusObserver->isDBusActivable(pluginId)) {
            Q_EMIT plasmoidEnabled(pluginId);
        }
    }
    for (const QString &pluginId : disabledPlugins) {
        if (m_systrayApplets.contains(pluginId)) {
            Q_EMIT plasmoidDisabled(pluginId);
        }
    }
}

void PlasmoidRegistry::packageInstalled(const QString &pluginId)
{
    qDebug() << "New package installed" << pluginId;

    if (m_systrayApplets.contains(pluginId)) {
        if (m_settings->isEnabledPlugin(pluginId) && !m_dbusObserver->isDBusActivable(pluginId)) {
            // restart plasmoid
            Q_EMIT plasmoidStopped(pluginId);
            Q_EMIT plasmoidEnabled(pluginId);
        }
        return;
    }

    for (const auto &info : Plasma::PluginLoader::self()->listAppletMetaData(QString())) {
        if (info.pluginId() == pluginId) {
            registerPlugin(info);
        }
    }
}

void PlasmoidRegistry::packageUninstalled(const QString &pluginId)
{
    qDebug() << "Package uninstalled" << pluginId;
    if (m_systrayApplets.contains(pluginId)) {
        unregisterPlugin(pluginId);
    }
}

void PlasmoidRegistry::registerPlugin(const KPluginMetaData &pluginMetaData)
{
    if (!pluginMetaData.isValid() || pluginMetaData.value(u"X-Plasma-NotificationAreaCategory").isEmpty()) {
        return;
    }

    const QString &pluginId = pluginMetaData.pluginId();

    m_systrayApplets[pluginId] = pluginMetaData;
    m_dbusObserver->registerPlugin(pluginMetaData);

    Q_EMIT pluginRegistered(pluginMetaData);

    // add plasmoid if is both not enabled explicitly and not already known
    if (pluginMetaData.isEnabledByDefault()) {
        const QString &candidate = pluginMetaData.pluginId();
        if (!m_settings->isKnownPlugin(candidate)) {
            m_settings->addKnownPlugin(candidate);
            if (!m_settings->isEnabledPlugin(candidate)) {
                m_settings->addEnabledPlugin(candidate);
            }
        }
    }

    if (m_settings->isEnabledPlugin(pluginId) && !m_dbusObserver->isDBusActivable(pluginId)) {
        Q_EMIT plasmoidEnabled(pluginId);
    }
}

void PlasmoidRegistry::unregisterPlugin(const QString &pluginId)
{
    Q_EMIT pluginUnregistered(pluginId);

    m_dbusObserver->unregisterPlugin(pluginId);
    m_systrayApplets.remove(pluginId);

    m_settings->cleanupPlugin(pluginId);
}

void PlasmoidRegistry::sanitizeSettings()
{
    // remove all no longer available in the system (e.g. uninstalled)
    const QStringList knownPlugins = m_settings->knownPlugins();
    for (const QString &pluginId : knownPlugins) {
        if (!m_systrayApplets.contains(pluginId)) {
            m_settings->removeKnownPlugin(pluginId);
        }
    }

    const QStringList enabledPlugins = m_settings->enabledPlugins();
    for (const QString &pluginId : enabledPlugins) {
        if (!m_systrayApplets.contains(pluginId)) {
            m_settings->removeEnabledPlugin(pluginId);
        }
    }
}

#include "moc_plasmoidregistry.cpp"
