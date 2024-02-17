cmake_minimum_required(VERSION 3.16.0)

project(kwin_effect_smodwindowbuttons)

set(KF_MIN_VERSION "5.78")
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH}
    ${ECM_MODULE_PATH}
    ${ECM_KDE_MODULE_DIR}
)

include(FeatureSummary)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt5 REQUIRED
    COMPONENTS
        Core
)

find_package(KWinEffects REQUIRED
    COMPONENTS
        kwineffects
        kwinglutils
)

find_package(KDecoration2 REQUIRED)
find_package(XCB REQUIRED XCB)
find_package(epoxy REQUIRED)
find_package(PkgConfig REQUIRED)

pkg_check_modules(smoddecoration REQUIRED IMPORTED_TARGET smoddecoration)

feature_summary(WHAT ALL)

set(buttonglow_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/smodwindowbuttons.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/smodwindowbuttons.qrc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/plugin.cpp
)

add_library(kwin4_effect_smodwindowbuttons SHARED ${buttonglow_SOURCES})

target_link_directories(kwin4_effect_smodwindowbuttons
    PRIVATE
        ${smoddecoration_LIBRARY_DIRS})

target_link_libraries(kwin4_effect_smodwindowbuttons
    PRIVATE
        KWinEffects::kwineffects
        KWinEffects::kwinglutils
        KDecoration2::KDecoration
        PkgConfig::smoddecoration
        Qt5::Core
        KF5::ConfigGui
)

install(
    TARGETS
        kwin4_effect_smodwindowbuttons

    DESTINATION
        ${PLUGIN_INSTALL_DIR}/kwin/effects/plugins
)
