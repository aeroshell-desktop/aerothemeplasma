#######################################
# Effect

set(aeroglide_SOURCES
    glide.cpp
    main.cpp
)

kconfig_add_kcfg_files(aeroglide_SOURCES
    glideconfig.kcfgc
)

add_library(aeroglide MODULE ${aeroglide_SOURCES})

#kwin_add_builtin_effect(glide ${glide_SOURCES})
target_link_libraries(aeroglide PRIVATE
    KF6::CoreAddons
    KF6::ConfigGui
)
if (KWIN_BUILD_WAYLAND)
    target_link_libraries(aeroglide PRIVATE
        KWin::kwin
    )
else()
    target_link_libraries(aeroglide PRIVATE
        KWinX11::kwin
    )
endif()


#######################################
# Config
set(kwin_aeroglide_config_SRCS glide_config.cpp)
ki18n_wrap_ui(kwin_aeroglide_config_SRCS glide_config.ui)
kconfig_add_kcfg_files(kwin_aeroglide_config_SRCS glideconfig.kcfgc)
qt_add_dbus_interface(kwin_aeroglide_config_SRCS ${KWIN_EFFECTS_INTERFACE} kwineffects_interface)

#kwin_add_effect_config(kwin_aeroglide_config ${kwin_aeroglide_config_SRCS})

add_library(kwin_aeroglide_config MODULE ${kwin_aeroglide_config_SRCS})
target_link_libraries(kwin_aeroglide_config
    KF6::KCMUtils
    KF6::CoreAddons
    KF6::I18n
    Qt6::DBus
    KF6::WindowSystem
    #KWinEffectsInterface
)

if (KWIN_BUILD_WAYLAND)
    install(TARGETS aeroglide DESTINATION ${KDE_INSTALL_PLUGINDIR}/kwin/effects/plugins)
    install(TARGETS kwin_aeroglide_config DESTINATION ${KDE_INSTALL_PLUGINDIR}/kwin/effects/configs)
else()
    install(TARGETS aeroglide DESTINATION ${KDE_INSTALL_PLUGINDIR}/kwin-x11/effects/plugins)
    install(TARGETS kwin_aeroglide_config DESTINATION ${KDE_INSTALL_PLUGINDIR}/kwin-x11/effects/configs)
endif()
