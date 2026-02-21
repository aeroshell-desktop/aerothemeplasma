// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 WackyIdeas <wackyideas@disroot.org>

#include "app.h"
#include <KSharedConfig>
#include <KWindowConfig>
#include <QQuickWindow>
#include <KWindowEffects>
#include <KAuth/ExecuteJob>
#include <KUser>
#include <QApplication>
#include <QFont>
#include <QProcess>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDir>
#include <QFile>
#include <QFileInfo>

#include "effectsmodel.h"


App::App()
{
    KConfig ootbConfig(QStringLiteral("aerothemeplasmarc"));
    m_firstTime = ootbConfig.group(QStringLiteral("OOTB")).readEntry(QStringLiteral("wizardRun"), false);
    Q_EMIT firstTimeChanged();
}
bool App::firstTime() const
{
    return m_firstTime;
}
void App::setWindowProps(QWindow *handle)
{
    KWindowEffects::enableBlurBehind(handle, true, QRegion(0,0,0,0));
}

void App::syncPlasmaWithSDDM()
{
    // initial check for sddm user; abort if user not present
    // we have to check with QString and isEmpty() instead of QDir and exists() because
    // QDir returns "." and true for exists() in the case of a non-existent user;
    QString sddmHomeDirPath = KUser("sddm").homeDir();
    if (sddmHomeDirPath.isEmpty()) {
        qWarning() << "SDDM user not found";
        return;
    }

    // read Plasma values
    KConfig cursorConfig(QStringLiteral("kcminputrc"));
    KConfigGroup cursorConfigGroup(&cursorConfig, QStringLiteral("Mouse"));
    QString cursorTheme = cursorConfigGroup.readEntry("cursorTheme", QString());
    QString cursorSize = cursorConfigGroup.readEntry("cursorSize", QString());

    KConfig dpiConfig(QStringLiteral("kcmfonts"));
    KConfigGroup dpiConfigGroup(&dpiConfig, QStringLiteral("General"));
    QString dpiValue = dpiConfigGroup.readEntry("forceFontDPI");
    QString dpiArgument = QStringLiteral("-dpi ") + dpiValue;

    KConfig numLockConfig(QStringLiteral("kcminputrc"));
    KConfigGroup numLockConfigGroup(&numLockConfig, QStringLiteral("Keyboard"));
    QString numLock = numLockConfigGroup.readEntry("NumLock");

    // Syncing the font only works with SDDM >= 0.19, but will not have a negative effect with older versions
    KConfig plasmaFontConfig(QStringLiteral("kdeglobals"));
    KConfigGroup plasmaFontGroup(&plasmaFontConfig, QStringLiteral("General"));
    QString plasmaFont = plasmaFontGroup.readEntry("font", QApplication::font().toString());

    // define paths
    const QString fontconfigPath = QStandardPaths::locate(QStandardPaths::GenericConfigLocation, QStringLiteral("fontconfig"), QStandardPaths::LocateDirectory);
    const QString kdeglobalsPath = QStandardPaths::locate(QStandardPaths::GenericConfigLocation, QStringLiteral("kdeglobals"));
    const QString plasmarcPath = QStandardPaths::locate(QStandardPaths::GenericConfigLocation, QStringLiteral("plasmarc"));
    const QString kcminputrcPath = QStandardPaths::locate(QStandardPaths::GenericConfigLocation, QStringLiteral("kcminputrc"));
    const QString kwinoutputconfigPath = QStandardPaths::locate(QStandardPaths::GenericConfigLocation, QStringLiteral("kwinoutputconfig.json"));

    // send values and paths to helper, debug if it fails
    QVariantMap args;

    args[QStringLiteral("kde_settings.conf")] = QString{QLatin1String(SDDM_CONFIG_DIR "/") + QStringLiteral("kde_settings.conf")};

    args[QStringLiteral("sddm.conf")] = QLatin1String(SDDM_CONFIG_FILE);

    args[QStringLiteral("kde_settings.conf/General/GreeterEnvironment")] = QStringLiteral("QML_DISABLE_DISTANCEFIELD=1");
    args[QStringLiteral("kde_settings.conf/Theme/Current")] = QStringLiteral("sddm-theme-mod");
    args[QStringLiteral("kde_settings.conf/Theme/CursorTheme")] = QStringLiteral("aero-drop");

    if (!cursorSize.isNull()) {
        args[QStringLiteral("kde_settings.conf/Theme/CursorSize")] = cursorSize;
    } else {
        qDebug() << "Cannot find cursor size value; unsetting it";
        args[QStringLiteral("kde_settings.conf/Theme/CursorSize")] = QVariant();
    }

    if (!dpiValue.isEmpty()) {
        args[QStringLiteral("kde_settings.conf/X11/ServerArguments")] = dpiArgument;
    } else {
        qDebug() << "Cannot find scaling DPI value.";
    }

    if (!numLock.isEmpty()) {
        if (numLock == QStringLiteral("0")) {
            args[QStringLiteral("kde_settings.conf/General/Numlock")] = QStringLiteral("on");
        } else if (numLock == QStringLiteral("1")) {
            args[QStringLiteral("kde_settings.conf/General/Numlock")] = QStringLiteral("off");
        } else if (numLock == QStringLiteral("2")) {
            args[QStringLiteral("kde_settings.conf/General/Numlock")] = QStringLiteral("none");
        }
    } else {
        qDebug() << "Cannot find NumLock value.";
    }

    if (!plasmaFont.isEmpty()) {
        args[QStringLiteral("kde_settings.conf/Theme/Font")] = plasmaFont;
    } else {
        qDebug() << "Cannot find Plasma font value.";
    }

    if (!fontconfigPath.isEmpty()) {
        args[QStringLiteral("fontconfig")] = fontconfigPath;
    } else {
        qDebug() << "Cannot find fontconfig folder.";
    }

    if (!kdeglobalsPath.isEmpty()) {
        args[QStringLiteral("kdeglobals")] = kdeglobalsPath;
    } else {
        qDebug() << "Cannot find kdeglobals file.";
    }

    if (!plasmarcPath.isEmpty()) {
        args[QStringLiteral("plasmarc")] = plasmarcPath;
    } else {
        qDebug() << "Cannot find plasmarc file.";
    }

    if (!kcminputrcPath.isEmpty()) {
        args[QStringLiteral("kcminputrc")] = kcminputrcPath;
    } else {
        qDebug() << "Cannot find kcminputrc file.";
    }

    if (!kwinoutputconfigPath.isEmpty()) {
        args[QStringLiteral("kwinoutputconfig")] = kwinoutputconfigPath;
    } else {
        qDebug() << "Cannot find kwinoutputconfiguration.json file";
    }

    auto path = QStandardPaths::locate(QStandardPaths::GenericDataLocation, QStringLiteral("kscreen/"), QStandardPaths::LocateDirectory);
    if (!path.isEmpty()) {
        args[QStringLiteral("kscreen-config")] = path;
    }
    KAuth::Action syncAction(QStringLiteral("org.kde.kcontrol.kcmsddm.sync"));
    syncAction.setHelperId(QStringLiteral("org.kde.kcontrol.kcmsddm"));
    syncAction.setArguments(args);

    auto job = syncAction.execute();
    if (!job->exec()) {
        qDebug() << "KAuth returned an error code:" << job->error();
        if (!job->errorText().isEmpty()) {
            qWarning() << job->errorString() << job->errorText();
        }
    } else {
        qDebug() << "KAuth succeeded.";
        if (!job->errorText().isEmpty()) {
            qWarning() << job->errorString() << job->errorText();
        }
    }
}

void App::setCursorThemeSDDM()
{
    QVariantMap args;
    KAuth::Action syncAction(QStringLiteral("io.gitgud.wackyideas.ootb.apply"));
    syncAction.setHelperId(QStringLiteral("io.gitgud.wackyideas.ootb"));
    syncAction.setArguments(args);

    auto job = syncAction.execute();
    if (!job->exec()) {
        qDebug() << "KAuth returned an error code:" << job->error();
        if (!job->errorText().isEmpty()) {
            qWarning() << job->errorString() << job->errorText();
        }
    } else {
        qDebug() << "KAuth succeeded.";
        if (!job->errorText().isEmpty()) {
            qWarning() << job->errorString() << job->errorText();
        }
        QString contents = job->data()["contents"].toString();
        qDebug() << "KAuth succeeded. Contents: " << contents;

    }

}

void App::applyLookAndFeel()
{
    // Font config
    KConfig kdeglobalsConfig(QStringLiteral("kdeglobals"));
    QFont font = QFont(QStringLiteral("Segoe UI"), 9);
    font.setStyleName(QStringLiteral("Regular"));
    QFont fontSmall = QFont(QStringLiteral("Segoe UI"), 8);
    font.setStyleName(QStringLiteral("Regular"));
    KConfigGroup generalGroup = kdeglobalsConfig.group(QStringLiteral("General"));
    generalGroup.writeEntry(QStringLiteral("font"), font);
    generalGroup.writeEntry(QStringLiteral("smallestReadableFont"), fontSmall);
    generalGroup.writeEntry(QStringLiteral("toolBarFont"), font);
    generalGroup.writeEntry(QStringLiteral("menuFont"), font);
    kdeglobalsConfig.group(QStringLiteral("WM")).writeEntry(QStringLiteral("activeFont"), font);
    kdeglobalsConfig.sync();

    EffectsModel model;
    model.setData(model.findByPluginId("aeroglassblur"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("aeroglide"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("smodglow"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("smodpeekeffect"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("libkwin_effect_smodsnap"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("launchfeedback"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("fadingpopupsaero"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("squashaero"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("dimscreenaero"), Qt::Checked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("aeroshell-thumbnails"), Qt::Checked, EffectsModel::StatusRole);

    model.setData(model.findByPluginId("blur"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("contrast"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("login"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("logout"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("maximize"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("scale"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("squash"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("slide"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("fade"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("slidingpopups"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("dialogparent"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("fadingpopups"), Qt::Unchecked, EffectsModel::StatusRole);
    model.setData(model.findByPluginId("windowaperture"), Qt::Unchecked, EffectsModel::StatusRole);
    model.save();

    QDBusMessage kwinDbus = QDBusMessage::createMethodCall(QStringLiteral("org.kde.KWin"), QStringLiteral("/KWin"),
                                                           QStringLiteral(""), QStringLiteral("reconfigure"));
    if(!QDBusConnection::sessionBus().send(kwinDbus))
    {
        qWarning() << "DBus kwin failed!";
        return;
    }

    // Apply Global Theme
    qInfo() << QProcess::startDetached("plasma-apply-lookandfeel", { "-a", "authui7" });
    // Apply Kvantum theme (Windows7Aero)
    qInfo() << QProcess::execute("kvantummanager", { "--set", "Windows7Aero" });
    qInfo() << QProcess::execute("plasma-apply-cursortheme", { "aero-drop", "--size", "32" });

}
void App::saveOotbConfig(bool reset)
{
    qInfo() << QProcess::execute("plasma-apply-cursortheme", { "breeze_cursors" }); // Prevent breeze cursor theme from showing up momentarily on splash screen
    KConfig ootbConfig(QStringLiteral("aerothemeplasmarc"));
    ootbConfig.group(QStringLiteral("OOTB")).writeEntry(QStringLiteral("wizardRun"), reset);
    ootbConfig.sync();
    qInfo() << QProcess::execute("plasma-apply-cursortheme", { "aero-drop", "--size", "32" });
}

#include "moc_app.cpp"
