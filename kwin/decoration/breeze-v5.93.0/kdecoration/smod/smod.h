#pragma once

/*
 * Generic reusable code for SMOD
 */

#include <QDir>
#include <QResource>
#include <QString>
#include <QFileInfo>

namespace SMOD
{
    const QString SMOD_EXTENSION = ".smod.rcc";
    const QString SYSTEM_PATH = "/usr/share/smod/decorations/";
    const QString LOCAL_PATH = QDir::homePath() + "/.local/share/smod/decorations/";

    static QString currentlyRegisteredResource = "";
    static QString currentlyRegisteredPath = SYSTEM_PATH + QStringLiteral("Aero") + SMOD_EXTENSION;

    inline void registerResource(const QString &name)
    {
        if(currentlyRegisteredResource != "")
        {
            QString path = LOCAL_PATH + currentlyRegisteredResource + SMOD_EXTENSION;
            if(!QFileInfo::exists(path))
            {
                path = SYSTEM_PATH + currentlyRegisteredResource + SMOD_EXTENSION;
            }
            if(QFileInfo::exists(path))
            {
                printf("smod: Unregistering resource %s\n", path.toStdString().c_str());
                QResource::unregisterResource(path);
            }
        }
        QString path = LOCAL_PATH + name + SMOD_EXTENSION;
        printf("smod: Trying to register resource %s\n", path.toStdString().c_str());
        if(!QFileInfo::exists(path))
        {
            path = SYSTEM_PATH + name + SMOD_EXTENSION;
            printf("smod: File not found in local directory, fallback to system directory %s\n", path.toStdString().c_str());
            if(!QFileInfo::exists(path))
            {
                path = SYSTEM_PATH + QStringLiteral("Aero") + SMOD_EXTENSION;
                printf("smod: File not found in system directory, fallback to default theme %s\n", path.toStdString().c_str());
            }
        }
        printf("smod: Registering resource %s\n", path.toStdString().c_str());
        QResource::registerResource(path);
        currentlyRegisteredResource = name;
        currentlyRegisteredPath = path;
    }
}
