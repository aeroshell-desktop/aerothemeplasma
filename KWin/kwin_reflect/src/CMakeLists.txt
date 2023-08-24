add_subdirectory(kcm)

set(effect_SRCS
    blur.cpp
    blurshader.cpp
    main.cpp
    blur.qrc
)

kconfig_add_kcfg_files(effect_SRCS
    blurconfig.kcfgc
)

add_library(kwin4_effect_reflect SHARED ${effect_SRCS})

target_link_libraries(kwin4_effect_reflect
    KDecoration2::KDecoration
    Qt5::Core
    Qt5::Gui
    KF5::ConfigCore
    KF5::ConfigGui
    KF5::CoreAddons
    KF5::WindowSystem
    kwineffects::kwineffects
    kwineffects::kwinglutils
    epoxy::epoxy
)

install(
    TARGETS
        kwin4_effect_reflect

    DESTINATION
        ${PLUGIN_INSTALL_DIR}/kwin/effects/plugins/
)

