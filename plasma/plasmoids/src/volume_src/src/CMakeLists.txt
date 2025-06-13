# TODO: adapt "org.kde.plasma" here & elsewhere if needed (see README)
add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_io.gitgud.wackyideas.volume\")



set(volume_SRCS
    volume.cpp
)
if (Qt6_VERSION VERSION_GREATER_EQUAL "6.8.0")
    set(private_code_option  "PRIVATE_CODE")
endif()
add_library(io.gitgud.wackyideas.volume MODULE ${volume_SRCS})
qt_generate_wayland_protocol_client_sources(io.gitgud.wackyideas.volume
    FILES
        "${PLASMA_WAYLAND_PROTOCOLS_DIR}/plasma-shell.xml"
        "${Wayland_DATADIR}/wayland.xml"
    ${private_code_option}
)

target_link_libraries(io.gitgud.wackyideas.volume
                      Qt6::Gui
                      Qt6::Quick
                      KF6::I18n
                      KF6::WindowSystem
                      Plasma::Plasma
                      Plasma::PlasmaQuick
                      Wayland::Client
                      KF6::Svg
                      KF6::ConfigCore
                      KF6::ConfigGui
                      KF6::CoreAddons)


include_directories(/usr/include/Plasma /usr/include/PlasmaQuick /usr/include/KF6/KConfigCore/ /usr/include/KF6/KConfig/ /usr/include/KF6/KCoreAddons/)

install(TARGETS io.gitgud.wackyideas.volume DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

