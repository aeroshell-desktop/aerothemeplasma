cmake_minimum_required(VERSION 3.16)

project(desktopcontainment-aero)

set(QT_MIN_VERSION "6.7.0")
set(KF6_MIN_VERSION "6.0.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMFindQmlModule)
include(ECMQmlModule)
include(FeatureSummary)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    Core
    Gui
    QuickControls2
    Widgets
    QuickWidgets
    DBus
    Svg
    Concurrent
    Core5Compat
    Sql # kcms/activities
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    Kirigami
    CoreAddons
    QQC2DesktopStyle
    IconThemes
    Auth
    Crash
    Config
    KCMUtils
    NewStuff
    KIO
    Notifications
    NotifyConfig
    Attica
    Runner
    GlobalAccel
    GuiAddons # KImageCache
    DBusAddons
    WidgetsAddons
    Codecs
    Sonnet
    Package
    IconThemes
    XmlGui
    Svg

)

ecm_find_qmlmodule(org.kde.kirigami REQUIRED)

find_package(Plasma REQUIRED)
find_package(Plasma5Support ${PROJECT_DEP_VERSION} REQUIRED)
find_package(Plasma ${PROJECT_DEP_VERSION} REQUIRED)
find_package(PlasmaQuick ${PROJECT_DEP_VERSION} REQUIRED)
find_package(PlasmaActivities ${PROJECT_DEP_VERSION} REQUIRED)
find_package(PlasmaActivitiesStats ${PROJECT_DEP_VERSION} REQUIRED)

add_subdirectory(src)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
