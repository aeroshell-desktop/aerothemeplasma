// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 WackyIdeas <wackyideas@disroot.org>

#pragma once

#include <QObject>
#include <QWindow>
#include <QQmlEngine>

#define SDDM_CONFIG_DIR "/etc/sddm.conf.d"
#define SDDM_CONFIG_FILE "/etc/sddm.conf"
#define AEROTHEMEPLASMA_INSTALL_DIR "/usr/share/aerothemeplasma"

class QQuickWindow;

class App : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool firstTime READ firstTime NOTIFY firstTimeChanged)
public:
    App();
    Q_INVOKABLE void applyLookAndFeel();
    Q_INVOKABLE void syncPlasmaWithSDDM();
    Q_INVOKABLE void setCursorThemeSDDM();
    Q_INVOKABLE void setWindowProps(QWindow *handle);
    Q_INVOKABLE void saveOotbConfig(bool reset = false);
protected:
    bool firstTime() const;

Q_SIGNALS:
    void firstTimeChanged();

private:
    bool m_firstTime = false;
};
