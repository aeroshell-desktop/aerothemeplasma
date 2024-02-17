cmake_minimum_required(VERSION 3.16)
project(breeze)
set(PROJECT_VERSION "5.27.10")
set(PROJECT_VERSION_MAJOR 5)

set(KF5_MIN_VERSION "5.102.0")
set(KDE_COMPILERSETTINGS_LEVEL "5.82")
set(QT_MIN_VERSION "5.15.2")

include(GenerateExportHeader)
include(WriteBasicConfigVersionFile)
include(FeatureSummary)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH}  ${CMAKE_SOURCE_DIR}/cmake)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(CMakePackageConfigHelpers)
include(ECMInstallIcons)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(KDEGitCommitHooks)
include(ECMGenerateHeaders)
include(ECMGeneratePkgConfigFile)

include(GtkUpdateIconCache)

find_package(KF5KCMUtils ${KF5_MIN_VERSION} REQUIRED)

find_package(KDecoration2 REQUIRED)
add_subdirectory(kdecoration)

add_subdirectory(libbreezecommon)

find_package(KF5I18n ${KF5_MIN_VERSION} CONFIG REQUIRED)
#ki18n_install(po)

include(ECMSetupVersion)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
