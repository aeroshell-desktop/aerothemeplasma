add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_io.gitgud.wackyideas.notifications\")

set(notificationapplet_SRCS
    notificationapplet.cpp
    notificationwindow.cpp
    draghelper.cpp
    fileinfo.cpp
    filemenu.cpp
    globalshortcuts.cpp
    jobaggregator.cpp
    thumbnailer.cpp
    notificationapplet.h
    notificationwindow.h
    draghelper.h
    fileinfo.h
    filemenu.h
    globalshortcuts.h
    jobaggregator.h
    thumbnailer.h
)

plasma_add_applet(io.gitgud.wackyideas.notifications QML_ARGS DEPENDENCIES QtCore QtQuick org.kde.plasma.core)

target_sources(io.gitgud.wackyideas.notifications PRIVATE ${notificationapplet_SRCS})

ecm_target_qml_sources(io.gitgud.wackyideas.notifications SOURCES
    components/ActionContainer.qml
    components/Body.qml
    components/DraggableFileArea.qml
    components/EditContextMenu.qml
    components/FooterLoader.qml
    components/HeadingButtons.qml
    components/Icon.qml
    components/JobDetails.qml
    components/JobIconItem.qml
    components/JobItem.qml
    components/ModelInterface.qml
    components/NotificationHeader.qml
    components/NotificationReplyField.qml
    components/Summary.qml
    components/ThumbnailStrip.qml
    components/ToolButton.qml
    PATH components
)

ecm_target_qml_sources(io.gitgud.wackyideas.notifications SOURCES
    delegates/BaseDelegate.qml
    delegates/DelegateHistoryGrouped.qml
    delegates/DelegateHistory.qml
    delegates/DelegatePopup.qml
    PATH delegates
)
ecm_target_qml_sources(io.gitgud.wackyideas.notifications SOURCES
    svgs/icons.svg
    svgs/button.svgz
    PATH svgs
)

set_source_files_properties(global/Globals.qml PROPERTIES QT_QML_SINGLETON_TYPE ON)

ecm_target_qml_sources(io.gitgud.wackyideas.notifications SOURCES
    global/Globals.qml
    global/PulseAudio.qml
    PATH global
)

ecm_target_qml_sources(io.gitgud.wackyideas.notifications SOURCES
    CompactRepresentation.qml
    DraggableDelegate.qml
    FullRepresentation.qml
    main.qml
    NotificationPopup.qml
)

if (Qt6_VERSION VERSION_GREATER_EQUAL "6.8.0")
    set(private_code_option  "PRIVATE_CODE")
endif()
qt_generate_wayland_protocol_client_sources(io.gitgud.wackyideas.notifications
    FILES
        "${PLASMA_WAYLAND_PROTOCOLS_DIR}/plasma-shell.xml"
        "${Wayland_DATADIR}/wayland.xml"
    ${private_code_option}
)

target_link_libraries(io.gitgud.wackyideas.notifications PRIVATE
                      Qt::Gui
                      Qt::Quick # for QQmlParserStatus
                      KF6::ConfigGui # for KStandardActions
                      KF6::I18n
                      Plasma::Plasma
                      Plasma::PlasmaQuick
                      KF6::CoreAddons
                      KF6::GlobalAccel
                      KF6::KIOGui
                      KF6::KIOWidgets # for PreviewJob
                      KF6::Notifications # for KNotificationJobUiDelegate
                      notificationmanager
                      Wayland::Client
                      )

ecm_qt_declare_logging_category(io.gitgud.wackyideas.notifications
    HEADER notifications_debug.h
    IDENTIFIER PLASMA_APPLET_NOTIFICATIONS_DEBUG
    CATEGORY_NAME io.gitgud.wackyideas.notifications
    DESCRIPTION "aerothemeplasma applet notification"
    EXPORT PLASMAWORKSPACE
)
