/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQml
import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import org.kde.notificationmanager as NotificationManager

import plasma.applet.io.gitgud.wackyideas.notifications as Notifications

ColumnLayout {
    id: jobItem

    property ModelInterface modelInterface

    readonly property int totalFiles: modelInterface.jobDetails && modelInterface.jobDetails.totalFiles || 0

    readonly property alias menuOpen: otherFileActionsMenu.visible

    spacing: Kirigami.Units.smallSpacing

    Notifications.FileInfo {
        id: fileInfo
        url: jobItem.totalFiles === 1 ? jobItem.modelInterface.jobDetails.effectiveDestUrl : ""
    }

    RowLayout {
        id: jobActionsRow
        Layout.fillWidth: true

        spacing: 1 //Kirigami.Units.smallSpacing

        Item { Layout.fillWidth: true }


        PlasmaComponents3.ProgressBar {
            id: progressBar

            Layout.fillWidth: true

            from: 0
            to: 100
            value: jobItem.modelInterface.percentage
            // TODO do we actually need the window visible check? perhaps I do because it can be in popup or expanded plasmoid
            indeterminate: visible && Window.window && Window.window.visible && jobItem.modelInterface.percentage < 1
                           && jobItem.modelInterface.jobState === NotificationManager.Notifications.JobStateRunning
                           // is this too annoying?
                           && (jobItem.modelInterface.jobDetails.processedBytes === 0 || jobItem.modelInterface.jobDetails.totalBytes === 0)
                           && jobItem.modelInterface.jobDetails.processedFiles === 0
                           //&& modelInterface.jobDetails.processedDirectories === 0
        }

        PlasmaComponents3.Label {
            id: progressText
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing

            visible: !progressBar.indeterminate
            // the || "0" is a workaround for the fact that 0 as number is falsey, and is wrongly considered a missing argument
            // BUG: 451807
            text: i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Percentage of a job", "%1%", jobItem.modelInterface.percentage || "0")
            textFormat: Text.PlainText
        }


        ToolButton {
            id: suspendButton

            readonly property bool paused: jobItem.modelInterface.jobState === NotificationManager.Notifications.JobStateSuspended
            checkable: true
            largeSize: true
            checked: paused
            buttonIcon: "pause"
            visible: jobItem.modelInterface.suspendable
            onClicked: paused ? jobItem.modelInterface.resumeJobClicked()
                              : jobItem.modelInterface.suspendJobClicked()
            property string text: paused ? i18ndc("plasma_applet_org.kde.plasma.notifications", "Resume paused job", "Resume")
                                         : i18ndc("plasma_applet_org.kde.plasma.notifications", "Pause running job", "Pause")

            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: parent.text
                location: PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop
            }
        }

        ToolButton {
            id: killButton

            buttonIcon: "stop"
            largeSize: true
            visible: jobItem.modelInterface.killable
            onClicked: jobItem.modelInterface.killJobClicked()

            property string text: i18ndc("plasma_applet_org.kde.plasma.notifications", "Cancel running job", "Cancel")
            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: parent.text
                location: PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop
            }

        }
        ToolButton {
            id: expandButton
            buttonIcon: checked ? "collapse" : "expand"
            checkable: jobItem.modelInterface.jobDetails && jobItem.modelInterface.jobDetails.hasDetails
            visible: checkable
            largeSize: true
            Accessible.onPressAction: if (checkable) clicked();
            onClicked: checked = !checked;
            property string text: i18ndc("plasma_applet_org.kde.plasma.notifications", "Hides/expands item details", "Details")
            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: parent.text
                location: PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop
            }
        }
    }

    Loader {
        Layout.fillWidth: true
        Layout.preferredWidth: Notifications.Globals.popupWidth
        Layout.preferredHeight: item ? item.implicitHeight : 0
        active: expandButton.checked
        // Loader doesn't reset its height when unloaded, just hide it altogether
        visible: active
        sourceComponent: JobDetails {
            modelInterface: jobItem.modelInterface
        }
    }

    Row {
        id: fileActionsRow
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        // We want the actions to be right-aligned but Row also reverses
        // the order of items, so we put them in reverse order
        layoutDirection: Qt.RightToLeft
        visible: jobItem.modelInterface.jobDetails.effectiveDestUrl.toString() !== "" && !fileInfo.error

        PlasmaComponents3.Button {
            id: otherFileActionsButton
            height: Math.max(implicitHeight, openButton.implicitHeight)
            icon.name: "application-menu-symbolic"
            checkable: true
            text: openButton.visible ? "" : Accessible.name
            Accessible.name: i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "More Options…")
            onPressedChanged: {
                if (pressed) {
                    checked = Qt.binding(function() {
                        return otherFileActionsMenu.visible;
                    });
                    otherFileActionsMenu.visualParent = this;
                    // -1 tells it to "align bottom left of visualParent (this)"
                    otherFileActionsMenu.open(-1, -1);
                }
            }

            PlasmaComponents3.ToolTip {
                text: parent.Accessible.name
                enabled: parent.text === ""
            }

            Notifications.FileMenu {
                id: otherFileActionsMenu
                url: jobItem.modelInterface.jobDetails.effectiveDestUrl
                onActionTriggered: action => jobItem.modelInterface.fileActionInvoked(action)
            }
        }

        PlasmaComponents3.Button {
            id: openButton
            width: Math.min(implicitWidth, jobItem.width - otherFileActionsButton.width - fileActionsRow.spacing)
            height: Math.max(implicitHeight, otherFileActionsButton.implicitHeight)
            text: i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Open")
            onClicked: jobItem.modelInterface.openUrl(jobItem.modelInterface.jobDetails.effectiveDestUrl)

            states: [
                State {
                    when: jobItem.modelInterface.jobDetails && jobItem.modelInterface.jobDetails.totalFiles !== 1
                    PropertyChanges {
                        target: openButton
                        text: i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Open Containing Folder")
                        icon.name: "folder-open-symbolic"
                    }
                },
                State {
                    when: fileInfo.openAction !== null
                    PropertyChanges {
                        target: openButton
                        text: fileInfo.openAction.text
                        icon.name: fileInfo.openActionIconName
                        visible: fileInfo.openAction.enabled
                        onClicked: {
                            fileInfo.openAction.trigger();
                            modelInterface.fileActionInvoked(fileInfo.openAction);
                        }
                    }
                }
            ]
        }
    }


    states: [
        State {
            when: jobItem.modelInterface.jobState === NotificationManager.Notifications.JobStateRunning
            PropertyChanges {
                target: suspendButton
                // Explicitly set it to false so it unchecks when pausing from applet
                // and then the job unpauses programmatically elsewhere.
                checked: false
            }
        },
        State {
            when: jobItem.modelInterface.jobState === NotificationManager.Notifications.JobStateSuspended
            PropertyChanges {
                target: suspendButton
                checked: true
            }
            PropertyChanges {
                target: progressBar
                enabled: false
            }
        },
        State {
            when: jobItem.modelInterface.jobState === NotificationManager.Notifications.JobStateStopped
            PropertyChanges {
                target: jobActionsRow
                visible: false
            }
            PropertyChanges {
                target: expandButton
                checked: false
            }
        }
    ]
}
