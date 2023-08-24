set(kcm_SRCS
    blur_config.cpp
    mainwindow.cpp
    flowlayout.cpp
    colorwindow.cpp
)

kconfig_add_kcfg_files(kcm_SRCS
    ../blurconfig.kcfgc
)

qt5_wrap_ui(kcm_SRCS blur_config.ui mainwindow.ui)

qt5_add_dbus_interface(kcm_SRCS ${KWIN_EFFECTS_INTERFACE} kwineffects_interface)

add_library(kwin4_effect_reflect_config MODULE ${kcm_SRCS})

target_link_libraries(kwin4_effect_reflect_config
    Qt5::Core
    Qt5::DBus
    Qt5::Gui
    KF5::ConfigCore
    KF5::ConfigGui
    KF5::ConfigWidgets

    KF5::CoreAddons
    KF5::WindowSystem
    KF5::WaylandClient
    KF5::WaylandServer
    kwineffects::kwineffects
    kwineffects::kwinglutils
    epoxy::epoxy
    KDecoration2::KDecoration
)

kcoreaddons_desktop_to_json(kwin4_effect_reflect_config blur_config.desktop SERVICE_TYPES kcmodule.desktop)

install(
    TARGETS
        kwin4_effect_reflect_config

    DESTINATION
        ${PLUGIN_INSTALL_DIR}/kwin/effects/configs
)
