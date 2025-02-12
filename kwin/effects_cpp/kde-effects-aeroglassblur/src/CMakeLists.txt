add_subdirectory(kcm)

set(aeroglassblur_SOURCES
    blur.cpp
    aeroblur.qrc
    main.cpp
)

kconfig_add_kcfg_files(aeroglassblur_SOURCES
    blurconfig.kcfgc
)

add_library(aeroglassblur MODULE ${aeroglassblur_SOURCES})
target_link_libraries(aeroglassblur PRIVATE
    KWin::kwin

    KF6::ConfigGui

    KDecoration3::KDecoration
    KF6::Svg

)

install(TARGETS aeroglassblur DESTINATION ${KDE_INSTALL_PLUGINDIR}/kwin/effects/plugins)
