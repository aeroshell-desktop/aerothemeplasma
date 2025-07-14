#include <QCoreApplication>
#include <QApplication>

#include <KCMultiDialog>
#include <KConfigGroup>
#include <QString>
#include <QJsonObject>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    a.setApplicationName("aerothemeplasma-kcmloader");
    a.setApplicationDisplayName("Personalize");
    QString modulePath;
    if(argc > 2) {
        modulePath = QString(argv[1]);
        if(modulePath.startsWith("kwin")) {
            if(a.platformName() == "xcb") {
                modulePath = QStringLiteral("kwin-x11") + modulePath.slice(4);
            }
        }
        QString iconName(argv[2]);
        a.setWindowIcon(QIcon::fromTheme(iconName));
    } else {
        return 1;
    }
    KCMultiDialog dialog;
    QJsonObject obj;
    obj.insert("standalone", QJsonValue(true));
    dialog.addModule(KPluginMetaData(obj, modulePath), QVariantList{QStringLiteral("KWin/Effect")});
    dialog.winId();
    dialog.open();
    return a.exec();
}
