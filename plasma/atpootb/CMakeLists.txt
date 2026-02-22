# SPDX-FileCopyrightText: 2025 WackyIdeas <wackyideas@disroot.org>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)

project(atpootb VERSION 0.1)

include(FeatureSummary)

set(QT6_MIN_VERSION 6.5.0)
set(KF6_MIN_VERSION 6.12.0)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(FeatureSummary)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMFindQmlModule)
include(KDEGitCommitHooks)
include(KDEClangFormat)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX ATPOOTB
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/src/version-atpootb.h"
)

remove_definitions(-DQT_NO_CAST_FROM_ASCII)
set(QT_EXTRA_COMPONENTS)
list(APPEND QT_EXTRA_COMPONENTS Widgets)

find_package(Qt6 ${QT6_MIN_VERSION} REQUIRED COMPONENTS Core Gui Qml QuickControls2 Svg ${QT_EXTRA_COMPONENTS})
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS Kirigami KCMUtils Package CoreAddons Config I18n Auth)

find_package(KWin REQUIRED COMPONENTS
    kwin
)

set(KAUTH_ACTIONS_QML true CACHE BOOL "Build with KAuth prompts")

if(KAUTH_ACTIONS_QML)
    message("Enabled KAuth")
else()
    message("Disabled KAuth")
endif()
configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

qt_policy(SET QTP0001 NEW)

ecm_find_qmlmodule(org.kde.kirigamiaddons.formcard 1.0)

kauth_install_actions(io.gitgud.wackyideas.ootb kauth.actions)

add_executable(ootbcursor_authhelper src/ootbauthhelper.cpp src/ootbauthhelper.h)
target_link_libraries(ootbcursor_authhelper KF6::AuthCore KF6::ConfigCore KF6::I18n Qt6::DBus Qt6::Core)

install(TARGETS ootbcursor_authhelper DESTINATION ${KAUTH_HELPER_INSTALL_DIR})
kauth_install_helper_files(ootbcursor_authhelper io.gitgud.wackyideas.ootb root)

add_subdirectory(src)

ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES src/*.cpp src/*.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
