add_definitions(-DTRANSLATION_DOMAIN="smod_deco")

################# includes #################
include_directories(${CMAKE_SOURCE_DIR}/libbreezecommon)
include_directories(${CMAKE_BINARY_DIR}/libbreezecommon)

################# newt target #################
### plugin classes
set(breezedecoration_SRCS
    breezebutton.cpp
    breezedecoration.cpp
    breezesettingsprovider.cpp
    breezeexceptionlist.cpp
    frametexture.cpp
    sizingmargins.cpp
    smod/smodbutton.cpp
    smod/smoddecoration.cpp
)

### build library
kconfig_add_kcfg_files(breezedecoration_SRCS breezesettings.kcfgc)
add_library(smoddecoration SHARED
    ${breezedecoration_SRCS}
    ${breezedecoration_config_PART_FORMS_HEADERS})

set_target_properties(smoddecoration PROPERTIES
    OUTPUT_NAME org.smod.smod
    PREFIX ""
)

target_compile_definitions(smoddecoration PRIVATE MYSHAREDLIB_LIBRARY)

#set_property(TARGET kwin4_effect_smodwindowbuttons PROPERTY POSITION_INDEPENDENT_CODE ON)

set_target_properties(smoddecoration PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
set_target_properties(smoddecoration PROPERTIES ENABLE_EXPORTS TRUE)

add_compile_options(-fPIC)

target_link_libraries(smoddecoration
    PRIVATE
        breezecommon6
        Qt6::Widgets
        Qt6::DBus
        KF6::CoreAddons
        KF6::ConfigGui
        KF6::GuiAddons
        KF6::I18n
        KF6::IconThemes
        KDecoration3::KDecoration
)

install(TARGETS smoddecoration DESTINATION ${KDE_INSTALL_PLUGINDIR}/${KDECORATION_PLUGIN_DIR})

add_subdirectory(config)

set(smod_HEADERS
  breeze.h
  breezebutton.h
  breezedecoration.h
  breezeexceptionlist.h
  breezesettingsprovider.h
  sizingmargins.h
)

kconfig_add_kcfg_files(smod_HEADERS breezesettings.kcfgc)

ecm_generate_headers(smod_CamelCase_HEADERS
    HEADER_NAMES
        Breeze
        BreezeButton
        BreezeDecoration
        BreezeExceptionList
        BreezeSettingsProvider
        SizingMargins

    REQUIRED_HEADERS
        smod_HEADERS
)

ecm_generate_pkgconfig_file(
    BASE_NAME "smoddecoration"
    LIB_NAME ":org.smod.smod.so"
    INCLUDE_INSTALL_DIR ${KDE_INSTALL_INCLUDEDIR}
    LIB_INSTALL_DIR ${KDE_INSTALL_PLUGINDIR}/org.kde.kdecoration3
    FILENAME_VAR pkgconfig_filename
)

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
