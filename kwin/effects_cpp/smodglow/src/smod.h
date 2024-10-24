#pragma once

#include <QDir>
#include <QFileInfo>
#include <QResource>
#include <QString>

namespace SMOD
{
    const QString SMOD_RCC_LOCATION = QDir::homePath() + QStringLiteral("/.local/share/smod/");
    const QString SMOD_EXTENSION = QStringLiteral(".smod.rcc");

    inline bool registerResource(const QString &name)
    {
        QFileInfo resource(SMOD_RCC_LOCATION + name + SMOD_EXTENSION);

        if (!resource.exists())
        {
            return false;
        }

        return QResource::registerResource(SMOD_RCC_LOCATION + name + SMOD_EXTENSION);
    }
}
