/*
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QMap>
#include <QObject>
#include <QPointer>

class DBusServiceObserver;
class KPluginMetaData;
class SystemTraySettings;

class PlasmoidRegistry : public QObject
{
    Q_OBJECT
public:
    explicit PlasmoidRegistry(QPointer<SystemTraySettings> settings, QObject *parent = nullptr);

    void init();

    virtual QMap<QString, KPluginMetaData> systemTrayApplets();
    bool isSystemTrayApplet(const QString &pluginId);

Q_SIGNALS:
    /**
     * @brief Emitted when new plasmoid configuration is registered.
     * Emitted on initial run or when new plasmoid is installed in the system.
     *
     * @param pluginMetaData @see KPluginMetaData
     */
    void pluginRegistered(const KPluginMetaData &pluginMetaData);
    /**
     * @brief Emitten when new plasmoid configuration is unregistered.
     * As of now, the only case is when plasmoid is uninstalled for the system.
     *
     * @param pluginId also known as applet Id
     */
    void pluginUnregistered(const QString &pluginId);

    /**
     * @brief Emittend when plasmoid id enabled.
     * Note: this signal can be emitted for already enabled plasmoid.
     *
     * @param pluginId also known as applet Id
     */
    void plasmoidEnabled(const QString &pluginId);
    /**
     * @brief Emitted when plasmoid should be stopped, for example when DBus service is no longer available.
     * Note: this signal can be emitted for already stopped plasmoid.
     *
     * @param pluginId also known as applet Id
     */
    void plasmoidStopped(const QString &pluginId);
    /**
     * @brief Emitted when plasmoid is disabled entirely by user.
     *
     * @param pluginId also known as applet Id
     */
    void plasmoidDisabled(const QString &pluginId);

private Q_SLOTS:
    void onEnabledPluginsChanged(const QStringList &enabledPlugins, const QStringList &disabledPlugins);
    void packageInstalled(const QString &pluginId);
    void packageUninstalled(const QString &pluginId);

private:
    void registerPlugin(const KPluginMetaData &pluginMetaData);
    void unregisterPlugin(const QString &pluginId);
    void sanitizeSettings();

    QPointer<SystemTraySettings> m_settings;
    QPointer<DBusServiceObserver> m_dbusObserver;

    QMap<QString /*plugin id*/, KPluginMetaData> m_systrayApplets;
};
