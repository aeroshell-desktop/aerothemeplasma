/*
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QObject>
#include <QPointer>
#include <QStringList>

class KConfigLoader;

/**
 * @brief The SystemTraySettings class
 */
class SystemTraySettings : public QObject
{
    Q_OBJECT
public:
    explicit SystemTraySettings(KConfigLoader *config, QObject *parent = nullptr);

    bool isKnownPlugin(const QString &pluginId);
    const QStringList knownPlugins() const;
    void addKnownPlugin(const QString &pluginId);
    void removeKnownPlugin(const QString &pluginId);

    bool isEnabledPlugin(const QString &pluginId) const;
    const QStringList enabledPlugins() const;
    void addEnabledPlugin(const QString &pluginId);
    void removeEnabledPlugin(const QString &pluginId);

    bool isDisabledStatusNotifier(const QString &pluginId);

    bool isShowAllItems() const;
    const QStringList shownItems() const;
    const QStringList hiddenItems() const;

    void cleanupPlugin(const QString &pluginId);

Q_SIGNALS:
    void configurationChanged();
    void enabledPluginsChanged(const QStringList &enabledPlugins, const QStringList &disabledPlugins);

private:
    void loadConfig();
    void writeConfigValue(const QString &key, const QVariant &value);
    void notifyAboutChangedEnabledPlugins(const QStringList &enabledPluginsOld, const QStringList &enabledPluginsNew);

    QPointer<KConfigLoader> config;

    bool updatingConfigValue = false;
    QStringList m_extraItems;
    QStringList m_knownItems;
    QStringList m_disabledStatusNotifiers;
};
