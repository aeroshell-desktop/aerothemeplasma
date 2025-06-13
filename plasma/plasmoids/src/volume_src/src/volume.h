/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef VOLUME_H
#define VOLUME_H

#include <QGuiApplication>
#include <Plasma/Applet>
#include <QVariant>
#include <QWindow>
#include <kwindowsystem.h>
#include <kx11extras.h>
#include <kwindoweffects.h>
#include <KSharedConfig>

#include <PlasmaQuick/PlasmaShellWaylandIntegration>

class Volume : public Plasma::Applet
{
    Q_OBJECT

public:
    Volume(QObject *parentObject, const KPluginMetaData &data, const QVariantList &args);
    ~Volume();
    Q_INVOKABLE void setPopupPosition(QWindow* w, int x, int y)
    {
        PlasmaShellWaylandIntegration::get(w)->setPosition(QPoint(x, y));
    }

    Q_INVOKABLE QString getDecorationPluginName()
    {
        return m_config->group(QStringLiteral("org.kde.kdecoration2")).readEntry(QStringLiteral("library"), QStringLiteral("org.smod.smod"));
    }
    Q_INVOKABLE QString getDecorationThemeName()
    {
        return m_config->group(QStringLiteral("org.kde.kdecoration2")).readEntry(QStringLiteral("theme"), QStringLiteral("SMOD"));
    }
private:
    KSharedConfig::Ptr m_config;
};

#endif // VOLUME_H
