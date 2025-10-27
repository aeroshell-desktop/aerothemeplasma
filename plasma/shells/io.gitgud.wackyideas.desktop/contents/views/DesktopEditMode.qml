/*
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.kcmutils as KCM

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC

import "../components"

Item {
    id: root_item

    property real centerX: Math.round(editModeUi.x + editModeUi.width/2)
    property real centerY: Math.round(editModeUi.y + editModeUi.height/2)
    property real roundedRootWidth: Math.round(root.width)
    property real roundedRootHeight: Math.round(root.height)

    property bool open: false

    Rectangle {
        color: "#1D5F7A"
        anchors.fill: parent
    }

    Image {
        id: bg
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: "/usr/share/sddm/themes/sddm-theme-mod/bgtexture.jpg"
    }

    Rectangle {
        anchors.fill: parent

        height: editModeUi.height + Kirigami.Units.smallSpacing + (Kirigami.Units.largeSpacing * 4)

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { color: Qt.rgba(0, 0, 0, 0.1); position: 0.0 }
            GradientStop { color: Qt.rgba(0, 0, 0, 0.3); position: 0.1 }
            GradientStop { color: Qt.rgba(0, 0, 0, 0.5); position: 0.5 }
            GradientStop { color: Qt.rgba(0, 0, 0, 0.3); position: 0.9 }
            GradientStop { color: Qt.rgba(0, 0, 0, 0.1); position: 1.0 }
        }
    }

    RowLayout {
        id: toolBar

        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        anchors {
            left: editModeUi.left
            bottom: editModeUi.top
            right: editModeUi.right
            bottomMargin: Kirigami.Units.smallSpacing
        }

        Flow {
            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight

            spacing: Kirigami.Units.smallSpacing

            GenericButton {
                id: addWidgetButton
                property QtObject qAction: containment?.plasmoid.internalAction("add widgets") || null
                text: qAction?.text
                onClicked: qAction.trigger()
            }

            GenericButton {
                id: addPanelButton
                height: addWidgetButton.height
                property QtObject qAction: containment?.plasmoid.corona.action("add panel") || null
                text: qAction?.text
                Accessible.role: Accessible.ButtonMenu
                onClicked: containment.plasmoid.corona.showAddPanelContextMenu(mapToGlobal(0, height))
            }

            GenericButton {
                id: configureButton
                property QtObject qAction: containment?.plasmoid.internalAction("configure") || null
                text: i18n("Personalize")
                onClicked: qAction.trigger()
            }

            GenericButton {
                id: themeButton
                text: i18nd("plasma_shell_org.kde.plasma.desktop", "Global Themes")
                onClicked: KCM.KCMLauncher.openSystemSettings("kcm_lookandfeel")
            }

            GenericButton {
                id: displaySettingsButton
                text: i18nd("plasma_shell_org.kde.plasma.desktop", "Display Configuration")
                onClicked: KCM.KCMLauncher.openSystemSettings("kcm_kscreen")
            }

            GenericButton {
                id: manageContainmentsButton
                property QtObject qAction: containment?.plasmoid.corona.action("manage-containments") || null
                text: qAction?.text
                visible: qAction?.visible || false
                onClicked: qAction.trigger()
            }
        }

        GenericButton {
            Layout.alignment: Qt.AlignTop

            visible: Kirigami.Settings.hasTransientTouchInput || Kirigami.Settings.tabletMode

            text: i18ndc("plasma_shell_org.kde.plasma.desktop", "@action:button", "More")

            onClicked: {
                containment.openContextMenu(mapToGlobal(0, height));
            }
        }
        GenericButton {
            Layout.alignment: Qt.AlignTop
            text: i18nd("plasma_shell_org.kde.plasma.desktop", "Exit Edit Mode")
            onClicked: containment.plasmoid.corona.editMode = false
        }
    }

    Item {
        id: editModeUi
        visible: open || xAnim.running
        x: Math.round(open ? editModeRect.x + editModeRect.width/2 - zoomedWidth/2 : 0)
        y: Math.round(open ? editModeRect.y + editModeRect.height/2 - zoomedHeight/2 + toolBar.height : 0)
        width: open ? zoomedWidth : roundedRootWidth
        height: open ? zoomedHeight : roundedRootHeight
        property real zoomedWidth: Math.round(root.width * containmentParent.scaleFactor)
        property real zoomedHeight: Math.round(root.height * containmentParent.scaleFactor)

        Behavior on x {
            NumberAnimation {
                id: xAnim
                duration: Kirigami.Units.longDuration
                easing.type: Easing.Linear
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.Linear
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.Linear
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.Linear
            }
        }

        MultiEffect {
            anchors.fill: parent
            source: containment
            layer.enabled: true
            layer.smooth: true
        }
    }

    Component.onCompleted: {
        open = Qt.binding(() => {return containment.plasmoid.corona.editMode});
        executable.exec("kreadconfig6 --file \"/usr/share/sddm/themes/sddm-theme-mod/theme.conf.user\" --group \"General\" --key \"background\"");
    }
}
