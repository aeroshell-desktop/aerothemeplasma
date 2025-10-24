add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_io.gitgud.wackyideas.systemtray\")

plasma_install_package(package io.gitgud.wackyideas.systemtray)

include_directories(../statusnotifierwatcher)

set(systemtray_SRCS
    dbusserviceobserver.cpp dbusserviceobserver.h
    plasmoidregistry.cpp plasmoidregistry.h
    statusnotifieritemjob.cpp statusnotifieritemjob.h
    statusnotifieritemhost.cpp statusnotifieritemhost.h
    statusnotifieritemservice.cpp statusnotifieritemservice.h
    statusnotifieritemsource.cpp statusnotifieritemsource.h
    systemtraysettings.cpp systemtraysettings.h
    systemtraytypes.cpp
)

qt_add_dbus_interface(systemtray_SRCS ../dbus/kf6_org.kde.StatusNotifierWatcher.xml statusnotifierwatcher_interface)
qt_add_dbus_interface(systemtray_SRCS ../dbus/org.freedesktop.DBus.Properties.xml dbusproperties)

set(statusnotifieritem_xml ../dbus/kf6_org.kde.StatusNotifierItem.xml)
set_source_files_properties(${statusnotifieritem_xml} PROPERTIES
   NO_NAMESPACE false
   INCLUDE "systemtraytypes.h"
   CLASSNAME OrgKdeStatusNotifierItem
)
qt_add_dbus_interface(systemtray_SRCS ${statusnotifieritem_xml} statusnotifieritem_interface)

ecm_qt_declare_logging_category(systemtray_SRCS HEADER debug.h
                                            IDENTIFIER SYSTEM_TRAY
                                            CATEGORY_NAME atp.systemtray
                                            DEFAULT_SEVERITY Info
                                            DESCRIPTION "aerothemeplasma applet systemtray"
                                            EXPORT PLASMAWORKSPACE
                                        )
add_library(systemtray_static STATIC ${systemtray_SRCS})
target_link_libraries(systemtray_static
    PUBLIC
        Qt::DBus
        Qt::Gui
        Qt::GuiPrivate
        Qt::Quick
        KF6::ConfigCore
        KF6::IconThemes
        KF6::I18n
        KF6::ItemModels
        KF6::WindowSystem
        KF6::XmlGui
        Plasma::Plasma
        Plasma::Plasma5Support
        Plasma::PlasmaQuick
        dbusmenuqt
)

set_property(TARGET systemtray_static PROPERTY POSITION_INDEPENDENT_CODE ON)

add_library(systemtraymodel_static STATIC systemtraymodel.cpp sortedsystemtraymodel.cpp sortedsystemtraymodel.h)
target_link_libraries(systemtraymodel_static PUBLIC systemtray_static)
set_property(TARGET systemtraymodel_static PROPERTY POSITION_INDEPENDENT_CODE ON)

set(systemtray_SRCS
    systemtray.cpp
)
add_library(io.gitgud.wackyideas.systemtray MODULE ${systemtray_SRCS})

install(TARGETS io.gitgud.wackyideas.systemtray DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

target_link_libraries(io.gitgud.wackyideas.systemtray systemtraymodel_static)

ecm_add_qml_module(systemtrayplugin URI io.gitgud.wackyideas.private.systemtray GENERATE_PLUGIN_SOURCE)
target_sources(systemtrayplugin PRIVATE systemtraymodel.cpp)
target_link_libraries(systemtrayplugin PRIVATE systemtray_static)
ecm_finalize_qml_module(systemtrayplugin)

#install(FILES statusnotifieritem.operations DESTINATION ${PLASMA5SUPPORT_DATA_INSTALL_DIR}/services)

if(BUILD_TESTING)
  add_subdirectory(autotests)
  add_subdirectory(tests)
endif()
