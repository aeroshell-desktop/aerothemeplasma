# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2025 WackyIdeas <wackyideas@disroot.org>

# Target: static library
qt_add_qml_module(atpootb_static
    STATIC
    URI io.gitgud.wackyideas.atpootb
    VERSION 1.0
    QML_FILES
        contents/ui/Main.qml

)

set(atpootb_SRCS
    app.cpp
    effectsmodel.cpp
)
qt_add_dbus_interface(atpootb_SRCS
    ${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces/org.kde.kwin.Effects.xml kwin_effects_interface
)

target_sources(atpootb_static PUBLIC
    ${atpootb_SRCS}
)

target_link_libraries(atpootb_static PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    KF6::AuthCore
    KF6::I18n
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::KCMUtils
    KF6::Package
    KWin::kwin
)
target_include_directories(atpootb_static PUBLIC ${CMAKE_BINARY_DIR})

target_link_libraries(atpootb_static PUBLIC Qt::Widgets)

kconfig_add_kcfg_files(atpootb_static GENERATE_MOC atpootbconfig.kcfgc)

# Target: main executable
qt_add_executable(atpootb main.cpp contents/ui/assets.qrc)
target_link_libraries(atpootb PUBLIC atpootb_static atpootb_staticplugin)
install(TARGETS atpootb ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
