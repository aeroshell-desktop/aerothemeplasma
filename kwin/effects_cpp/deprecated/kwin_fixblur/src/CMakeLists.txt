add_subdirectory(kcm)

set(effect_SRCS
    blur.cpp
    resources.qrc
    main.cpp
)

kconfig_add_kcfg_files(effect_SRCS
    blurconfig.kcfgc
)

add_library(kwin4_effect_customblur MODULE ${effect_SRCS})

target_link_libraries(kwin4_effect_customblur
    Qt6::Core
    Qt6::DBus
    Qt6::Gui
    Qt6::Widgets
    KDecoration2::KDecoration
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::CoreAddons
    KF6::WindowSystem
    Plasma::KWaylandClient
    KWin::kwin
    epoxy::epoxy
    KF6::Svg
)

install(
    TARGETS
        kwin4_effect_customblur

    DESTINATION
        ${KDE_INSTALL_PLUGINDIR}/kwin/effects/plugins/
)

