#pragma once

#include <QDir>
#include <QFileInfo>
#include <QResource>
#include <QString>
#include <KConfig>
#include <KConfigGroup>

namespace SMOD
{
    const QString SMOD_RCC_LOCATION = QDir::homePath() + QStringLiteral("/.local/share/smod/");
    const QString SMOD_EXTENSION = QStringLiteral(".smod.rcc");

    inline bool registerResource(const QString &name, const QString &previous)
    {
        if(previous != QStringLiteral(""))
        {
            if(QFileInfo::exists(previous))
            {
                printf("smodglow: Unregistering resource!\n");
                QResource::unregisterResource(previous);
            }
        }
        QFileInfo resource(name);

        if (!resource.exists())
        {
            return false;
        }

        return QResource::registerResource(name);
    }
}

