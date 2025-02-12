cmake_minimum_required(VERSION 3.16)
project(breeze)
set(PROJECT_VERSION "6.3.80")
set(PROJECT_VERSION_MAJOR 6)

set(KF5_MIN_VERSION "5.102.0")
set(KF6_MIN_VERSION "6.10.0")
set(KDE_COMPILERSETTINGS_LEVEL "5.82")
set(QT5_MIN_VERSION "5.15.2")
set(QT_MIN_VERSION "6.7.0")

include(GenerateExportHeader)
include(WriteBasicConfigVersionFile)
include(FeatureSummary)
include(GNUInstallDirs)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH}  ${CMAKE_SOURCE_DIR}/cmake)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# We need this because we can't include KDECMakeSettings here, because that
# would need KDEInstallDirs, which we can only include in the qt{5,6} builds
# to get the correct installation dirs for each Qt version.
option(BUILD_TESTING "Build the testing tree." ON)
if(BUILD_TESTING)
    enable_testing()
endif()

include(CMakePackageConfigHelpers)
include(ECMInstallIcons)
include(ECMGenerateHeaders)
include(ECMGeneratePkgConfigFile)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(KDEGitCommitHooks)
include(GtkUpdateIconCache)

option(BUILD_QT5 "Build Qt5 style" OFF)
option(BUILD_QT6 "Build with Qt6" ON)

set(QT_NO_CREATE_VERSIONLESS_TARGETS ON)
set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS ON)

# For KDE CI only. As the current infrastructure doesn't allow us to set CMAKE options per build variant
if($ENV{CI_JOB_NAME_SLUG} MATCHES "qt5")
    set(BUILD_QT5 ON)
    set(BUILD_QT6 OFF)
elseif($ENV{CI_JOB_NAME_SLUG} MATCHES "qt6")
    set(BUILD_QT5 OFF)
    set(BUILD_QT6 ON)
endif()

if(WIN32 OR APPLE)
    set(WITH_DECORATIONS OFF)
endif()

function(build_Qt5)
    set(QT_MAJOR_VERSION 5)
    include(KDEInstallDirs5)
    include(KDECMakeSettings)

    find_package(Qt5 ${QT5_MIN_VERSION} REQUIRED CONFIG COMPONENTS Widgets DBus)
    find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
        CoreAddons
        Config
        ConfigWidgets
        GuiAddons
        IconThemes
        WindowSystem)

    find_package(Qt5 ${QT5_MIN_VERSION} OPTIONAL_COMPONENTS Quick)
    if(${Qt5Quick_FOUND})
        find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Kirigami2)
    endif()

    find_package(KF5FrameworkIntegration ${KF5_MIN_VERSION} CONFIG )
    set_package_properties(KF${QT_MAJOR_VERSION}FrameworkIntegration PROPERTIES
        DESCRIPTION "KF${QT_MAJOR_VERSION} Framework Integration"
        URL "https://projects.kde.org/projects/frameworks/frameworkintegration"
        TYPE OPTIONAL
        PURPOSE "Required to use KStyle convenience functionalities in style")

    find_package(Qt5 ${QT5_MIN_VERSION} OPTIONAL_COMPONENTS X11Extras)
    set_package_properties(KF${QT_MAJOR_VERSION}FrameworkIntegration PROPERTIES
        DESCRIPTION "KF${QT_MAJOR_VERSION} Framework Integration"
        URL "https://projects.kde.org/projects/frameworks/frameworkintegration"
        TYPE OPTIONAL
        PURPOSE "Required to use KStyle convenience functionalities in style")

    set(BREEZE_HAVE_KSTYLE ${KF5FrameworkIntegration_FOUND})
    set(BREEZE_HAVE_QTQUICK ${Qt5Quick_FOUND})

    add_subdirectory(kstyle kstyle5)
    add_subdirectory(libbreezecommon libbreezecommon5)

    unset(QUERY_EXECUTABLE CACHE)
endfunction()
if(BUILD_QT5)
    build_Qt5()
endif()

function(build_Qt6)
    set(QT_MAJOR_VERSION 6)
    include(KDEInstallDirs6)
    include(KDECMakeSettings)

    option(WITH_DECORATIONS "Build Breeze window decorations for KWin" ON)
    option(WITH_WALLPAPERS "Install Breeze default wallpapers" OFF)

    find_package(Qt6 ${QT_MIN_VERSION} REQUIRED CONFIG COMPONENTS Widgets DBus)
    find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
        CoreAddons
        ColorScheme
        Config
        GuiAddons
        I18n
        IconThemes
        WindowSystem)
    if(NOT WIN32 AND NOT APPLE)
        find_package(KF6KCMUtils ${KF6_MIN_VERSION})
        set_package_properties(KF6KCMUtils PROPERTIES
            TYPE REQUIRED
            DESCRIPTION "Helps create configuration modules"
            PURPOSE "KCMUtils used for the configuration modules or the decoration and Qt Style"
        )
    endif()

    find_package(Qt6 ${QT_MIN_VERSION} OPTIONAL_COMPONENTS Quick)
    if(${Qt6Quick_FOUND})
        find_package(KF6KirigamiPlatform ${KF6_MIN_VERSION} REQUIRED)
    endif()

    find_package(KF6FrameworkIntegration ${KF6_MIN_VERSION} CONFIG )
    set_package_properties(KF${QT_MAJOR_VERSION}FrameworkIntegration PROPERTIES
        DESCRIPTION "KF6 Framework Integration"
        URL "https://projects.kde.org/projects/frameworks/frameworkintegration"
        TYPE OPTIONAL
        PURPOSE "Required to use KStyle convenience functionalities in style")

    set(BREEZE_HAVE_QTQUICK ${Qt6Quick_FOUND})

    # https://bugreports.qt.io/browse/QTBUG-114706
    add_library(Qt::Core ALIAS Qt6::Core)
    add_library(Qt::Gui ALIAS Qt6::Gui)
    add_library(Qt::OpenGL ALIAS Qt6::OpenGL)
    add_library(Qt::Network ALIAS Qt6::Network)
    if(Qt6_VERSION_MINOR GREATER 6)
        add_library(Qt::PlatformModuleInternal ALIAS Qt6::PlatformModuleInternal)
    endif()

    add_subdirectory(libbreezecommon libbreezecommon6)

    if(WITH_DECORATIONS)
        find_package(KDecoration3 REQUIRED)
        add_subdirectory(kdecoration)
    endif()

    ki18n_install(po)

    unset(QUERY_EXECUTABLE CACHE)
endfunction()
if(BUILD_QT6)
    build_Qt6()
endif()

# add clang-format target for all our real source files
file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
