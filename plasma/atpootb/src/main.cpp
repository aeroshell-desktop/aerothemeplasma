/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2025 WackyIdeas <wackyideas@disroot.org>
*/

#include <QtGlobal>
#include <QApplication>

#include <QString>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QUrl>

#include "app.h"
#include "version-atpootb.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include <thread>
#include <chrono>
#include <cstdlib>

#include "atpootbconfig.h"

using namespace Qt::Literals::StringLiterals;

#define SHELLNAME "io.gitgud.wackyideas.desktop"

int main(int argc, char *argv[])
{

    if(const char* env_p = std::getenv("PLASMA_DEFAULT_SHELL"))
    {
        if(strcmp(env_p, SHELLNAME) != 0)
        {
            return -1;
        }
    }
    KConfig ootbConfig(QStringLiteral("aerothemeplasmarc"));
    bool firstTime = ootbConfig.group(QStringLiteral("OOTB")).readEntry(QStringLiteral("wizardRun"), false);

    if(firstTime)
    {
        return 0;
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(3000));

    QApplication app(argc, argv);

    // Default to org.kde.desktop style unless the user forces another style
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(u"org.kde.desktop"_s);
    }

    KLocalizedString::setApplicationDomain("atpootb");
    QCoreApplication::setOrganizationName(u"WackyIdeas"_s);

    KAboutData aboutData(
        // The program name used internally.
        u"atpootb"_s,
        // A displayable program name string.
        i18nc("@title", "atpootb"),
        // The program version string.
        QStringLiteral(ATPOOTB_VERSION_STRING),
        // Short description of what the app does.
        i18n("Application Description"),
        // The license this code is released under.
        KAboutLicense::GPL,
        // Copyright Statement.
        i18n("(c) 2025"));
    aboutData.addAuthor(i18nc("@info:credit", "WackyIdeas"),
                        i18nc("@info:credit", "Maintainer"),
                        u"wackyideas@disroot.org"_s,
                        u"https://gitgud.io/wackyideas/aerothemeplasma"_s);
    //aboutData.setTranslator(i18nc("NAME OF TRANSLATORS", "Your names"), i18nc("EMAIL OF TRANSLATORS", "Your emails"));
    KAboutData::setApplicationData(aboutData);
    QGuiApplication::setWindowIcon(QIcon::fromTheme(u"io.gitgud.wackyideas.atpootb"_s));
    QCoreApplication::setApplicationName(QStringLiteral("__ATPOOTB"));

    QQmlApplicationEngine engine;

    auto config = atpootbConfig::self();

    qmlRegisterSingletonInstance("io.gitgud.wackyideas.atpootb.private", 1, 0, "Config", config);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule("io.gitgud.wackyideas.atpootb", u"Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
