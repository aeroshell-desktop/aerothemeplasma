#pragma once

/*
 * Generic reusable code for SMOD
 */

#include <QDir>
#include <QResource>
#include <QString>

namespace SMOD
{
    const QString SMOD_EXTENSION = ".smod.rcc";

    inline void registerResource(const QString &name)
    {
        QResource::registerResource(QDir::homePath() + "/.local/share/smod/" + name + SMOD_EXTENSION);
    }
}
