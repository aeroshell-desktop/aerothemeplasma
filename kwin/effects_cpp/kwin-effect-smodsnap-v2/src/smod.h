/*
 * SPDX-FileCopyrightText: 2024 Souris
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

/*
 * Generic reusable code for SMOD
 */

#include <QDir>
#include <QFileInfo>
#include <QResource>
#include <QString>

namespace SMOD
{
    const QString SMOD_EXTENSION = QStringLiteral(".smod.rcc");
    const QString SYSTEM_PATH = QStringLiteral("/usr/share/smod/");
    const QString LOCAL_PATH = QDir::homePath() + QStringLiteral("/.local/share/smod/");

    inline void registerResource(const QString &name)
    {
        QString path = LOCAL_PATH + name + SMOD_EXTENSION;
        if(!QFileInfo::exists(path))
        {
            path = SYSTEM_PATH + name + SMOD_EXTENSION;
        }

        QResource::registerResource(path);
    }

    inline bool resourceExists(const QString &name)
    {
        QString path = LOCAL_PATH + name + SMOD_EXTENSION;
        if(!QFileInfo::exists(path))
        {
            path = SYSTEM_PATH + name + SMOD_EXTENSION;
            if(!QFileInfo::exists(path)) return false;
        }
        return true;
        /*QFileInfo resource(QDir::homePath() + QStringLiteral("/.local/share/smod/") + name + SMOD_EXTENSION);
        return resource.exists();*/
    }
}
