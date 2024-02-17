kcoreaddons_add_plugin(kcm_smoddecoration SOURCES kcm_breezedecoration.cpp INSTALL_NAMESPACE "plasma/kcms/smod")
target_include_directories(kcm_smoddecoration PRIVATE ${CMAKE_SOURCE_DIR}/kdecoration ${CMAKE_BINARY_DIR}/kdecoration/)
target_link_libraries(kcm_smoddecoration breezecommon5 smoddecoration_STATIC KF5::I18n KF5::CoreAddons KF5::ConfigWidgets Qt::DBus)
kcmutils_generate_desktop_file(kcm_smoddecoration)
