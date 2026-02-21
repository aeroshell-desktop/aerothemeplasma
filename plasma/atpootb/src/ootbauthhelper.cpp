#include "ootbauthhelper.h"

#include <KConfig>
#include <KConfigGroup>
#include <QSharedPointer>
#include <QFileInfo>
#include <QDir>

static QSharedPointer<KConfig> openConfig(const QString &filePath)
{
    QFileInfo fileLocation(filePath);
    QDir dir(fileLocation.absolutePath());
    if (!dir.exists()) {
        QDir().mkpath(dir.path());
    }
    QFile file(filePath);
    if (!file.exists()) {
        // If we are creating the config file, ensure it is world-readable: if
        // we don't do that, KConfig will create a file which is only readable
        // by root
        if(!file.open(QIODevice::WriteOnly)) return nullptr;
        file.close();
        file.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ReadGroup | QFile::ReadOther);
    }
    // in case the file has already been created with wrong permissions
    else if (!(file.permissions() & QFile::ReadOwner & QFile::WriteOwner & QFile::ReadGroup & QFile::ReadOther)) {
        file.setPermissions(QFile::ReadOwner | QFile::WriteOwner | QFile::ReadGroup | QFile::ReadOther);
    }

    return QSharedPointer<KConfig>(new KConfig(file.fileName(), KConfig::SimpleConfig));
}
ActionReply OotbAuthHelper::apply(const QVariantMap &args)
{
    Q_UNUSED(args);
    QString path = QStringLiteral("/usr/share/icons/default/index.theme");
    QString groupName = QStringLiteral("Icon Theme");
    QString cursorTheme = QStringLiteral("aero-drop");
    QSharedPointer<KConfig> cursorConfig = openConfig(path);
    if(!cursorConfig)
    {
        ActionReply reply = ActionReply::HelperErrorReply();
        qDebug() << "Nullptr KConfig";
        reply.setErrorDescription(QStringLiteral("Cursor KConfig nullptr"));
        return reply;
    }
    if(cursorConfig->isImmutable())
    {
        ActionReply reply = ActionReply::HelperErrorReply();
        qDebug() << "Immutable KConfig";
        reply.setErrorDescription(QStringLiteral("Immutable error"));
        return reply;
    }

    int groupIndex = cursorConfig->groupList().indexOf(groupName, 0, Qt::CaseInsensitive);
    if(groupIndex != -1)
    {
        auto groupList = cursorConfig->groupList();
        QString tmpStr = cursorConfig->group(groupList[groupIndex]).readEntry(QStringLiteral("Inherits"), QStringLiteral(""));
        QStringList tmp = tmpStr.split(QStringLiteral(","));
        cursorConfig->group(groupList[groupIndex]).writeEntry(QStringLiteral("Inherits"), cursorTheme);
    }
    else
    {
        qDebug() << "Writing" << cursorTheme << "to" << groupName << "in index.theme";
        cursorConfig->group(groupName).writeEntry(QStringLiteral("Inherits"), cursorTheme);
    }

    if(!cursorConfig->sync())
    {
        ActionReply reply = ActionReply::HelperErrorReply();
        reply.setErrorDescription(QStringLiteral("Failed to sync KConfig"));
        qDebug() << "Failed to sync KConfig";
        return reply;
    }

    return ActionReply::SuccessReply();
}

KAUTH_HELPER_MAIN("io.gitgud.wackyideas.ootb", OotbAuthHelper)

#include "moc_ootbauthhelper.cpp"
