include_directories (
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/engines
)
find_package(KF5WindowSystem)
# Allow // comments in .c files
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")

set (emerald_engines_SOURCES
    engines/legacy.c
    engines/line.c
    engines/oxygen.c
    engines/pixmap.c
    engines/truglass.c
    engines/vrunner.c
    engines/zootreeves.c
)

set (smaragd_SOURCES
    kwin_smaragd.cpp
    emerald.c
    main.c
    shadowengine.cpp
)

set (smaragd_config_SOURCES
#    config/kwin_smaragd_config.cpp
)

ki18n_wrap_ui (smaragd_config_SOURCES config/kwin_smaragd_dialog.ui)

add_library  (kwin_smaragd MODULE
    ${smaragd_SOURCES}
    ${smaragd_config_SOURCES}
    ${emerald_engines_SOURCES}
)
target_link_libraries (kwin_smaragd
    Qt5::Core
    Qt5::Gui
    Qt5::Widgets
    KF5::ConfigCore
    KF5::CoreAddons
    KF5::I18n
    KF5::WidgetsAddons
    KF5::WindowSystem
    KDecoration2::KDecoration
    ${CAIRO_LIBRARIES}
    ${GLIB2_LIBRARIES}
)

install (TARGETS kwin_smaragd DESTINATION ${PLUGIN_INSTALL_DIR}/org.kde.kdecoration2)
install (FILES smaragd.knsrc DESTINATION ${CONFIG_INSTALL_DIR})

