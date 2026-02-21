cmake_minimum_required(VERSION 3.16)
project(aerothemeplasma-desktop)

set(KF6_MIN_VERSION "6.0.0")
find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

set(PROJECT_VERSION "6.5.4")
set(PROJECT_VERSION_MAJOR 6)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)
find_package(KF6Config)
find_package(Plasma)

add_subdirectory(plasma)
add_subdirectory(misc)

install()

