cmake_minimum_required(VERSION 3.16)

project(io.gitgud.wackyideas.notifications)
 
find_package(ECM 1.4.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
set(CMAKE_AUTOMOC ON)
set(QT_MAJOR_VERSION 6)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMMarkNonGuiExecutable)
include(ECMOptionalAddSubdirectory)
include(ECMQtDeclareLoggingCategory)
include(ECMQueryQt)
include(ECMInstallIcons)
include(ECMConfiguredInstall)
include(ECMGenerateDBusServiceFile)
include(ECMFindQmlModule)
include(ECMGenerateExportHeader)
include(ECMGenerateQmlTypes)
include(ECMDeprecationSettings)
include(ECMQmlModule)
include(FeatureSummary)
find_package(KF6WindowSystem)
find_package(KF6Svg)
find_package(KF6Config)
find_package(Plasma)
find_package(PlasmaQuick)
find_package(LibNotificationManager REQUIRED)

find_package(Qt6WaylandClient COMPONENTS Private)
find_package(PlasmaWaylandProtocols)
find_package(Wayland REQUIRED COMPONENTS Client)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/build)

find_package(KF6 REQUIRED COMPONENTS
    I18n
    Notifications
    NotifyConfig
    GlobalAccel
    KIO
)

find_package(Qt6 CONFIG REQUIRED COMPONENTS
    Quick
    Core
)

find_package(KF6CoreAddons)

add_subdirectory(notifications)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
