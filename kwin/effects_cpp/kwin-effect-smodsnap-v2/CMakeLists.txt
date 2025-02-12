cmake_minimum_required(VERSION 3.16.0)

project(effect_smodsnap)

option(BUILD_KF6 "Build for KDE Plasma 6" OFF)

if (BUILD_KF6)
set(QT_MAJOR_VERSION "6")
set(TARGET_NAME "kwin_effect_smodsnap")
else ()
set(QT_MAJOR_VERSION "5")
set(TARGET_NAME "kwin4_effect_smodsnap")
endif ()

if (QT_MAJOR_VERSION STREQUAL "5")
set(QT_MIN_VERSION "5.15.2")
set(KF5_MIN_VERSION "5.78")
else ()
set(QT_MIN_VERSION "6.5.0")
set(KF5_MIN_VERSION "5.240.0")
endif ()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs6)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)

find_package(Qt${QT_MAJOR_VERSION} REQUIRED
    COMPONENTS
        Core
)

find_package(KF${QT_MAJOR_VERSION} REQUIRED
    COMPONENTS
        ConfigWidgets
)

find_package(KDecoration3 REQUIRED)

if (QT_MAJOR_VERSION STREQUAL "5")
find_package(KWinEffects REQUIRED
    COMPONENTS
        kwineffects
        kwinglutils
)
find_package(XCB REQUIRED XCB)
find_package(epoxy REQUIRED)
else ()
find_package(KWin REQUIRED kwineffects)
endif ()

pkg_check_modules(smoddecoration REQUIRED IMPORTED_TARGET smoddecoration)

feature_summary(WHAT ALL)

set(kwin4_effect_smodsnap_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/smodsnap.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/smodsnap.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/plugin.cpp
)

if (QT_MAJOR_VERSION STREQUAL "5")
list(APPEND kwin4_effect_smodsnap_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/smodsnap-kf5.cpp
)
else ()
list(APPEND kwin4_effect_smodsnap_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/smodsnap-kf6.cpp
)
endif ()

add_library(${TARGET_NAME} SHARED ${kwin4_effect_smodsnap_SOURCES})

target_link_directories(${TARGET_NAME}
    PRIVATE
        ${smoddecoration_LIBRARY_DIRS})

target_link_libraries(${TARGET_NAME}
    PRIVATE
        Qt${QT_MAJOR_VERSION}::Core
        KF${QT_MAJOR_VERSION}::ConfigGui
        KDecoration3::KDecoration
        PkgConfig::smoddecoration
)

if (QT_MAJOR_VERSION STREQUAL "5")
target_link_libraries(${TARGET_NAME}
    PRIVATE
        KWinEffects::kwineffects
        KWinEffects::kwinglutils
)
else ()
target_link_libraries(${TARGET_NAME}
    PRIVATE
        KWin::kwin
)
endif ()

install(
    TARGETS
        ${TARGET_NAME}
    DESTINATION
        ${KDE_INSTALL_PLUGINDIR}/kwin/effects/plugins
)

