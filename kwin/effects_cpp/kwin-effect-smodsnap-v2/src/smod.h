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

    inline void registerResource(const QString &name)
    {
        QResource::registerResource(QDir::homePath() + QStringLiteral("/.local/share/smod/") + name + SMOD_EXTENSION);
    }

    inline bool resourceExists(const QString &name)
    {
        QFileInfo resource(QDir::homePath() + QStringLiteral("/.local/share/smod/") + name + SMOD_EXTENSION);
        return resource.exists();
    }
}
