add_definitions(-DTRANSLATION_DOMAIN="smod_deco")

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS CoreAddons GuiAddons ConfigWidgets I18n IconThemes)
find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS DBus)

################# includes #################
include_directories(${CMAKE_SOURCE_DIR}/libbreezecommon)
include_directories(${CMAKE_BINARY_DIR}/libbreezecommon)

################# newt target #################
### plugin classes
set(breezedecoration_SRCS
    breezebutton.cpp
    breezedecoration.cpp
    breezesettingsprovider.cpp
    smod/qgraphicsgloweffect.cpp
)

### config classes
set(breezedecoration_config_SRCS
    breezeexceptionlist.cpp
    config/breezeconfigwidget.cpp
    config/breezedetectwidget.cpp
    config/breezeexceptiondialog.cpp
    config/breezeexceptionlistwidget.cpp
    config/breezeexceptionmodel.cpp
    config/breezeitemmodel.cpp
)
ki18n_wrap_ui(breezedecoration_config_SRCS
   config/ui/breezeconfigurationui.ui
   config/ui/breezeexceptiondialog.ui
   config/ui/breezeexceptionlistwidget.ui
)
add_library(smoddecoration_STATIC STATIC ${breezedecoration_config_SRCS})
# Needed to link this static lib to shared libs
set_property(TARGET smoddecoration_STATIC PROPERTY POSITION_INDEPENDENT_CODE ON)
kconfig_add_kcfg_files(smoddecoration_STATIC breezesettings.kcfgc)
target_link_libraries(smoddecoration_STATIC
    PUBLIC
        Qt::Core
        Qt::Gui
        Qt::DBus
        KDecoration2::KDecoration
    PRIVATE
        KF5::ConfigCore
        KF5::CoreAddons
        KF5::ConfigWidgets
        KF5::GuiAddons
        KF5::I18n
        KF5::IconThemes
)

### build library
add_library(smoddecoration MODULE
    ${breezedecoration_SRCS}
    ${breezedecoration_config_PART_FORMS_HEADERS})

target_link_libraries(smoddecoration
    PRIVATE
        breezecommon5
        smoddecoration_STATIC
        KF5::CoreAddons
        KF5::ConfigWidgets
        KF5::GuiAddons
        KF5::I18n
        KF5::IconThemes
)

install(TARGETS smoddecoration DESTINATION ${KDE_INSTALL_PLUGINDIR}/org.kde.kdecoration2)

add_subdirectory(config)

set(smod_HEADERS
  breeze.h
  breezebutton.h
  breezedecoration.h
  breezeexceptionlist.h
  breezesettingsprovider.h
)

kconfig_add_kcfg_files(smod_HEADERS breezesettings.kcfgc)

ecm_generate_headers(smod_CamelCase_HEADERS
    HEADER_NAMES
        Breeze
        BreezeButton
        BreezeDecoration
        BreezeExceptionList
        BreezeSettingsProvider

    REQUIRED_HEADERS
        smod_HEADERS
)


ecm_generate_pkgconfig_file(
    BASE_NAME "smoddecoration"
    LIB_NAME ":smoddecoration.so"
    INCLUDE_INSTALL_DIR ${KDE_INSTALL_INCLUDEDIR}
    LIB_INSTALL_DIR ${KDE_INSTALL_PLUGINDIR}/org.kde.kdecoration2
    FILENAME_VAR pkgconfig_filename
)

set(ECM_PKGCONFIG_INSTALL_DIR "${KDE_INSTALL_LIBDIR}/pkgconfig")

install(
    FILES
        ${smod_HEADERS}
        ${breezedecoration_config_PART_FORMS_HEADERS}
        ${smod_CamelCase_HEADERS}

    DESTINATION
        ${CMAKE_INSTALL_INCLUDEDIR}/SMOD/Decoration

    COMPONENT
        Devel
)

install(
    FILES
        ${pkgconfig_filename}

    DESTINATION
        ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
