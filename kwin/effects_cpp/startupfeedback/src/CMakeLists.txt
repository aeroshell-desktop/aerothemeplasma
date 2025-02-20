#######################################
# Effect

# Source files
set(startupfeedback_SOURCES
    main.cpp
    startupfeedback.cpp
    startupfeedback.qrc
)

add_library(launchfeedback MODULE ${startupfeedback_SOURCES})
#kwin_add_builtin_effect(startupfeedback ${startupfeedback_SOURCES})
target_link_libraries(launchfeedback PRIVATE
    KWin::kwin

    KF6::ConfigCore
    KF6::ConfigGui
    Qt::DBus
    Qt::Widgets
    KF6::WindowSystem
)
install(TARGETS launchfeedback DESTINATION ${KDE_INSTALL_PLUGINDIR}/kwin/effects/plugins)
