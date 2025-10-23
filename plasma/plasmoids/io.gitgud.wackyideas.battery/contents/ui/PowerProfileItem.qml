/*
 *   SPDX-FileCopyrightText: 2021 Kai Uwe Broulik <kde@broulik.de>
 *   SPDX-FileCopyrightText: 2021 David Redondo <kde@david-redondo.de>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.notification
import org.kde.plasma.workspace.dbus as DBus

QtControls.ItemDelegate {
    id: root


    property bool isTlpInstalled

    property bool profilesInstalled
    property bool profilesAvailable

    property string activeProfile
    property string activeProfileError

    property string inhibitionReason
    readonly property bool inhibited: inhibitionReason !== ""
    property var inhibitionControllerRef
    property alias powerSaverRadio: powerSaverRadio
    property alias performanceRadio: performanceRadio

    property string degradationReason

    // type: [{ Name: string, Icon: string, Profile: string, Reason: string }]
    required property var profileHolds

    // The canBeInhibited property mean that this profile's availability
    // depends on root.inhibited value (and thus on the
    // inhibitionReason string).
    readonly property var profileData: [
        {
            label: i18n("Power Save"),
            profile: "power-saver",
            canBeInhibited: false,
            radioButton: powerSaverRadio,
            icon: "battery-profile-powersave"
        }, {
            label: i18n("Balanced"),
            profile: "balanced",
            canBeInhibited: false,
            radioButton: balancedRadio,
            icon: "battery-profile-balanced"
        }, {
            label: i18n("Performance"),
            profile: "performance",
            canBeInhibited: true,
            radioButton: performanceRadio,
            icon: "battery-profile-performance"
        }
    ]

    readonly property int activeProfileIndex: profileData.findIndex(data => data.profile === root.activeProfile)
    // type: typeof(profileData[])?
    readonly property var activeProfileData: activeProfileIndex !== -1 ? profileData[activeProfileIndex] : undefined
    // type: typeof(profileHolds)
    readonly property var activeHolds: profileHolds.filter(hold => hold.Profile === activeProfile)

    signal activateProfileRequested(string profile)

    background.visible: false//highlighted
    //highlighted: activeFocus
    hoverEnabled: false
    text: i18n("Power Profile")

    Keys.forwardTo: [radioButtons]

    onFocusChanged: {
        powerSaverRadio.focus = true;
    }

    Notification {
        id: powerProfileError
        componentName: "plasma_workspace"
        eventId: "warning"
        iconName: "speedometer"
        title: i18n("Power Management")
    }

    contentItem: ColumnLayout {
        id: grid
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.Label {
            visible: root.profilesAvailable && !root.isTlpInstalled
            text: i18n("Select a power plan:")
            opacity: 0.75
        }
        QtControls.ButtonGroup {
            buttons: radioButtons.children
            onClicked: (button) => {
                const { canBeInhibited, profile } = root.profileData[button.value];
                if (!(canBeInhibited && root.inhibited)) {
                    activateProfileRequested(profile);
                }/* else {
                    value = Qt.binding(() => root.activeProfileIndex);
                }*/
            }
        }
        ColumnLayout {
            id: radioButtons
            Layout.leftMargin: Kirigami.Units.smallSpacing+1
            spacing: 0
            visible: root.profilesAvailable && !root.isTlpInstalled

            QtControls.RadioButton {
                id: powerSaverRadio
                property string profileId: "power-saver"
                property int value: 0
                text: root.profileData.find(profile => profile.profile === profileId).label
                checked: activeProfileData.profile == profileId
                KeyNavigation.tab: balancedRadio
                KeyNavigation.down: balancedRadio
                KeyNavigation.backtab: root.inhibitionControllerRef
                KeyNavigation.up: root.inhibitionControllerRef
            }
            QtControls.RadioButton {
                id: balancedRadio
                property string profileId: "balanced"
                property int value: 1
                text: root.profileData.find(profile => profile.profile === profileId).label
                checked: activeProfileData.profile == profileId
                KeyNavigation.tab: performanceRadio
                KeyNavigation.down: performanceRadio
                KeyNavigation.backtab: powerSaverRadio
                KeyNavigation.up: powerSaverRadio
            }
            QtControls.RadioButton {
                id: performanceRadio
                property string profileId: "performance"
                property int value: 2
                text: root.profileData.find(profile => profile.profile === profileId).label
                checked: activeProfileData.profile == profileId
                KeyNavigation.backtab: balancedRadio
                KeyNavigation.up: balancedRadio
                KeyNavigation.tab: root.inhibitionControllerRef
                KeyNavigation.down: root.inhibitionControllerRef
            }


            Connections {
                target: root
                function onActiveProfileChanged() {
                    DBus.SessionBus.asyncCall({service: "org.kde.plasmashell", path: "/org/kde/osdService", iface: "org.kde.osdService", member: "showText",
                        arguments: [new DBus.string(root.profileData[root.activeProfileIndex].icon), new DBus.string(i18n("Power profile set to: ") + root.profileData[root.activeProfileIndex].label)], signature: "(ss)"});
                }
            }
            Connections {
                target: root
                function onActiveProfileErrorChanged() {
                    if (root.activeProfileError !== "") {
                        powerProfileError.text = i18n("Failed to activate %1 mode", root.activeProfileError);
                        powerProfileError.sendEvent();
                        root.activeProfileError = "";
                    }
                }
            }
        }
        // NOTE Only one of these will be visible at a time since the daemon will only set one depending
        // on its version
        InhibitionHint {
            id: inhibitionReasonHint

            Layout.fillWidth: true

            visible: root.inhibited
            iconSource: "dialog-information"
            text: {
                switch (root.inhibitionReason) {
                case "lap-detected":
                    return i18n("Performance mode has been disabled to reduce heat generation because the computer has detected that it may be sitting on your lap.")
                case "high-operating-temperature":
                    return i18n("Performance mode is unavailable because the computer is running too hot.")
                default:
                    return i18n("Performance mode is unavailable.")
                }
            }
        }

        InhibitionHint {
            id: inhibitionPerformanceHint

            Layout.fillWidth: true

            visible: root.activeProfile === "performance" && root.degradationReason !== ""
            iconSource: "dialog-information"
            text: {
                switch (root.degradationReason) {
                case "lap-detected":
                    return i18n("Performance may be lowered to reduce heat generation because the computer has detected that it may be sitting on your lap.")
                case "high-operating-temperature":
                    return i18n("Performance may be reduced because the computer is running too hot.")
                default:
                    return i18n("Performance may be reduced.")
                }
            }
        }

        InhibitionHint {
            id: inhibitionHoldersHint

            Layout.fillWidth: true

            visible: root.activeHolds.length > 0 && root.activeProfileData !== undefined
            text: root.activeProfileData !== undefined
                ? i18np("One application has requested activating %2:",
                        "%1 applications have requested activating %2:",
                        root.activeHolds.length,
                        root.activeProfileData.label)
                : ""
        }

        Repeater {
            id: repeater

            model: root.activeHolds

            InhibitionHint {
                Layout.fillWidth: true

                x: Kirigami.Units.smallSpacing
                iconSource: modelData.Icon
                text: i18nc("%1 is the name of the application, %2 is the reason provided by it for activating performance mode",
                            "%1: %2", modelData.Name, modelData.Reason)
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.smallSpacing

            visible: repeater.visibleChildren > 0
                || inhibitionReasonHint.visible
                || inhibitionPerformanceHint.visible
                || inhibitionHoldersHint.visible
        }

        InhibitionHint {
            iconSource: "info"
            visible: !root.profilesAvailable
            text: root.isTlpInstalled
                ? i18n("The TLP service automatically controls power profiles")
                : root.profilesInstalled
                ? i18n("Power profiles are not supported on your device.")
                : xi18n("Power profiles may be supported on your device.<nl/>Try installing the <command>power-profiles-daemon</command> package using your distribution's package manager and restarting the system.")
            Layout.fillWidth: true
        }
    }

}
