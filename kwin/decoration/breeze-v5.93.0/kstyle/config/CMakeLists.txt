### configuration plugin
add_definitions(-DTRANSLATION_DOMAIN=\"breeze_style_config\")
set(kstyle_breeze_config_PART_SRCS breezestyleconfig.cpp)

set(kstyle_breeze_config_PART_SRCS ${kstyle_breeze_config_PART_SRCS} breezestyleconfigmodule.cpp)

kconfig_add_kcfg_files(kstyle_breeze_config_PART_SRCS ../breezestyleconfigdata.kcfgc)
set(kstyle_breeze_config_PART_FORMS ui/breezestyleconfig.ui)
ki18n_wrap_ui(kstyle_breeze_config_PART_FORMS_HEADERS ${kstyle_breeze_config_PART_FORMS})

kcoreaddons_add_plugin(breezestyleconfig SOURCES
    ${kstyle_breeze_config_PART_SRCS}
    ${kstyle_breeze_config_PART_FORMS_HEADERS}
    INSTALL_NAMESPACE "kstyle_config"
)

target_link_libraries(breezestyleconfig Qt6::Core Qt6::Gui Qt6::Widgets Qt6::DBus)
target_link_libraries(breezestyleconfig KF6::CoreAddons KF6::ConfigCore KF6::ConfigWidgets KF6::I18n)
if(QT_MAJOR_VERSION STREQUAL "6")
    target_link_libraries(breezestyleconfig KF6::KCMUtils)
endif()
kcmutils_generate_desktop_file(breezestyleconfig)

set(breeze_settings_SOURCES main.cpp)
add_executable(breeze-settings ${breeze_settings_SOURCES} )
target_link_libraries(breeze-settings Qt6::Core Qt6::Gui Qt6::Widgets )
target_link_libraries(breeze-settings KF6::I18n KF6::KCMUtils KF6::CoreAddons)

set_target_properties(breeze-settings PROPERTIES OUTPUT_NAME breeze-settings6)

install(TARGETS breeze-settings ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

# icon
ecm_install_icons(ICONS sc-apps-breeze-settings.svgz
    DESTINATION ${KDE_INSTALL_ICONDIR}
    THEME hicolor )
