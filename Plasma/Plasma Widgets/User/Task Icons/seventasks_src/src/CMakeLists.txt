# TODO: adapt "org.kde.plasma" here & elsewhere if needed (see README)
add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.plasma.seventasks\")



set(seventasks_SRCS
    seventasks.cpp
)

add_library(plasma_applet_seventasks MODULE ${seventasks_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_seventasks package/metadata.desktop SERVICE_TYPES plasma-applet.desktop)

target_link_libraries(plasma_applet_seventasks
                      Qt5::Gui
                      Qt5::Quick
                      KF5::Plasma
                      KF5::I18n
                      KF5::WindowSystem)
                      
#target_link_libraries(plasma_applet_seventasks KF5::WindowSystem)


install(TARGETS plasma_applet_seventasks DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

plasma_install_package(package org.kde.plasma.seventasks)
