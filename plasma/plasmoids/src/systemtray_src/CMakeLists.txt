cmake_minimum_required(VERSION 3.16)

project(io.gitgud.wackyideas.systemtray)
 
find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
set(CMAKE_AUTOMOC ON)
set(QT_MAJOR_VERSION 6)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_MIN_VERSION "6.9.0")
set(KF6_MIN_VERSION "6.18.0")
set(BUILD_TESTING ON)
include(GNUInstallDirs)

option(WITH_X11 "Build with X11 support. Building without is experimental" ON)
add_definitions(-DHAVE_X11=1)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
if (BUILD_TESTING)
    include(ECMAddTests)
    find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Test QuickTest)
    find_package(Qt6 REQUIRED CONFIG COMPONENTS WaylandCompositor)
endif()
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
include(CMakePackageConfigHelpers)
include(WriteBasicConfigVersionFile)
include(CheckIncludeFiles)
include(FeatureSummary)
find_package(PkgConfig REQUIRED)
find_package(KF6WindowSystem)
find_package(KF6Svg)
find_package(KF6Config)
find_package(Plasma)
find_package(PlasmaQuick)
find_package(Plasma5Support)

find_package(Qt6WaylandClient COMPONENTS Private)
find_package(PlasmaWaylandProtocols)
find_package(Wayland REQUIRED COMPONENTS Client)



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
if (Qt6Gui_VERSION VERSION_GREATER_EQUAL "6.10.0")
    find_package(Qt6GuiPrivate ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE)
    find_package(Qt6WaylandClientPrivate ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE)
endif()

find_package(KF6 REQUIRED COMPONENTS
    I18n
    Notifications
    NotifyConfig
    GlobalAccel
    KIO
    IconThemes
    ItemModels
    StatusNotifierItem
    XmlGui
)

find_package(KF6CoreAddons)
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

add_subdirectory(libdbusmenuqt)
add_subdirectory(systemtray)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
