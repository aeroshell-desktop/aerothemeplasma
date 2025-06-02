# TODO: adapt "org.kde.plasma" here & elsewhere if needed (see README)
add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_io.gitgud.wackyideas.seventasks\")



set(seventasks_SRCS
    seventasks.cpp
)

add_library(io.gitgud.wackyideas.seventasks MODULE ${seventasks_SRCS})

target_link_libraries(io.gitgud.wackyideas.seventasks
                      Qt6::Gui
                      Qt6::Quick
                      KF6::I18n
                      KF6::WindowSystem
                      Plasma
                      PlasmaQuick
                      KF6::Svg
                      KF6::ConfigCore
                      KF6::ConfigGui
                      KF6::CoreAddons)


#target_link_libraries(plasma_applet_seventasks KF5::WindowSystem)
include_directories(/usr/include/Plasma /usr/include/KF6/KConfigCore/ /usr/include/KF6/KConfig/ /usr/include/KF6/KCoreAddons/)

install(TARGETS io.gitgud.wackyideas.seventasks DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)


#plasma_install_package(package io.gitgud.wackyideas.seventasks)
