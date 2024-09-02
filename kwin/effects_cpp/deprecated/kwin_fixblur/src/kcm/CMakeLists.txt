set(kcm_SRCS
    blur_config.cpp
)

kconfig_add_kcfg_files(kcm_SRCS
    ../blurconfig.kcfgc
)

qt_wrap_ui(kcm_SRCS blur_config.ui mainwindow.ui)

qt_add_dbus_interface(kcm_SRCS ${KWIN_EFFECTS_INTERFACE} kwineffects_interface)

add_library(kwin4_effect_customblur_config MODULE ${kcm_SRCS})

target_link_libraries(kwin4_effect_customblur_config

    KF6::KCMUtils
    KF6::CoreAddons
    KF6::I18n
    Qt6::DBus
    KF6::WindowSystem

)

#kcoreaddons_desktop_to_json(kwin4_effect_customblur_config blur_config.desktop SERVICE_TYPES kcmodule.desktop)

install(
    TARGETS
        kwin4_effect_customblur_config

    DESTINATION
        ${KDE_INSTALL_PLUGINDIR}/kwin/effects/configs
)
