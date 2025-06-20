set(kwin_aeroglassblur_config_SRCS
    blur_config.cpp
    blur_config.h
    mainwindow.h
    mainwindow.cpp
    flowlayout.cpp
    colorwindow.cpp
    colorwindow.h
    colorbutton.h
    colorbutton.cpp
    blur_config.qrc
    )

ki18n_wrap_ui(kwin_aeroglassblur_config_SRCS blur_config.ui mainwindow.ui)
kconfig_add_kcfg_files(kwin_aeroglassblur_config_SRCS ../blurconfig.kcfgc)

qt_add_dbus_interface(kwin_aeroglassblur_config_SRCS ${KWIN_EFFECTS_INTERFACE} kwineffects_interface)

add_library(kwin_aeroglassblur_config MODULE ${kwin_aeroglassblur_config_SRCS})
target_link_libraries(kwin_aeroglassblur_config
    KF6::KCMUtils
    KF6::CoreAddons
    KF6::I18n
    Qt6::DBus
    KF6::WindowSystem
)

if (KWIN_BUILD_WAYLAND)
    install(TARGETS kwin_aeroglassblur_config DESTINATION ${KDE_INSTALL_PLUGINDIR}/kwin/effects/configs)
else()
    install(TARGETS kwin_aeroglassblur_config DESTINATION ${KDE_INSTALL_PLUGINDIR}/kwin-x11/effects/configs)
endif()
