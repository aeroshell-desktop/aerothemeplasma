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

PlasmaComponents3.ItemDelegate {
    id: root

    //property alias slider: slider

    property bool profilesInstalled
    property bool profilesAvailable

    property string activeProfile

    property string inhibitionReason
    readonly property bool inhibited: inhibitionReason !== ""

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
        }, {
            label: i18n("Balanced"),
            profile: "balanced",
            canBeInhibited: false,
        }, {
            label: i18n("Performance"),
            profile: "performance",
            canBeInhibited: true,
        }
    ]

    readonly property int activeProfileIndex: profileData.findIndex(data => data.profile === activeProfile)
    // type: typeof(profileData[])?
    readonly property var activeProfileData: activeProfileIndex !== -1 ? profileData[activeProfileIndex] : undefined
    // type: typeof(profileHolds)
    readonly property var activeHolds: profileHolds.filter(hold => hold.Profile === activeProfile)

    signal activateProfileRequested(string profile)

    highlighted: false
    down: false
    //background.visible: highlighted
    //highlighted: activeFocus
    //hoverEnabled: false
    //text: i18n("Power Profile")

    Accessible.description: !root.profilesAvailable ? i18nc("Power profile", "Not available") : activeProfileData ? activeProfileData.label : ""
    Accessible.role: Accessible.Slider
    //Keys.forwardTo: [slider]

    contentItem: RowLayout {
        spacing: Kirigami.Units.gridUnit

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 0

            /*RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: root.text
                }

                PlasmaComponents3.Label {
                    id: activeProfileLabel
                    Layout.alignment: Qt.AlignRight
                    text: !root.profilesAvailable ? i18nc("Power profile", "Not available") : activeProfileData ? activeProfileData.label : ""
                    enabled: root.profilesAvailable
                }
            }*/

            ColumnLayout {
                id: profileConfiguration


                visible: root.profilesAvailable
                PlasmaComponents3.Label {
                    text: "Select a power plan:"
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
                    QtControls.RadioButton {
                        id: balancedRadio
                        property string profileId: "balanced"
                        property int value: 1
                        text: root.profileData.find(profile => profile.profile === profileId).label
                        checked: activeProfileData.profile == profileId
                    }
                    QtControls.RadioButton {
                        id: powerSaverRadio
                        property string profileId: "power-saver"
                        property int value: 0
                        text: root.profileData.find(profile => profile.profile === profileId).label
                        checked: activeProfileData.profile == profileId
                    }
                    QtControls.RadioButton {
                        id: performanceRadio
                        property string profileId: "performance"
                        property int value: 2
                        text: root.profileData.find(profile => profile.profile === profileId).label
                        checked: activeProfileData.profile == profileId
                    }
                }

            }

            /*PlasmaComponents3.Slider {
                id: slider
                visible: root.profilesAvailable
                Layout.fillWidth: true

                activeFocusOnTab: false
                from: 0
                to: 2
                stepSize: 1
                value: root.activeProfileIndex
                snapMode: PlasmaComponents3.Slider.SnapAlways
                onMoved: {

                }

                // fake having a disabled second half
                Rectangle {
                    z: -1
                    visible: root.inhibited
                    color: Kirigami.Theme.backgroundColor
                    anchors {
                        top: parent.background.top
                        left: parent.horizontalCenter
                        leftMargin: 1
                        right: parent.right
                        bottom: parent.background.bottom
                    }
                    opacity: 0.4
                }
            }*/

            /*RowLayout {
                spacing: 0
                visible: root.profilesAvailable
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                Kirigami.Icon {
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    source: "battery-profile-powersave-symbolic"

                    HoverHandler {
                        id: powersaveIconHover
                    }

                    PlasmaComponents3.ToolTip {
                        text: root.profileData.find(profile => profile.profile === "power-saver").label
                        visible: powersaveIconHover.hovered
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Kirigami.Icon {
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    source: "battery-profile-performance-symbolic"

                    HoverHandler {
                        id: performanceIconHover
                    }

                    PlasmaComponents3.ToolTip {
                        text: root.profileData.find(profile => profile.profile === "performance").label
                        visible: performanceIconHover.hovered
                    }
                }
            }*/

            // NOTE Only one of these will be visible at a time since the daemon will only set one depending
            // on its version
            InhibitionHint {
                id: inhibitionReasonHint

                Layout.fillWidth: true

                visible: root.inhibited
                iconSource: "dialog-information"
                text: switch(root.inhibitionReason) {
                    case "lap-detected":
                        return i18n("Performance mode has been disabled to reduce heat generation because the computer has detected that it may be sitting on your lap.")
                    case "high-operating-temperature":
                        return i18n("Performance mode is unavailable because the computer is running too hot.")
                    default:
                        return i18n("Performance mode is unavailable.")
                }
            }

            InhibitionHint {
                id: inhibitionPerformanceHint

                Layout.fillWidth: true

                visible: root.activeProfile === "performance" && root.degradationReason !== ""
                iconSource: "dialog-information"
                text: switch(root.degradationReason) {
                    case "lap-detected":
                        return i18n("Performance may be lowered to reduce heat generation because the computer has detected that it may be sitting on your lap.")
                    case "high-operating-temperature":
                        return i18n("Performance may be reduced because the computer is running too hot.")
                    default:
                        return i18n("Performance may be reduced.")
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
                            i18n(root.activeProfileData.label))
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

            RowLayout {
                visible: !root.profilesInstalled
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    text: xi18n("Power profiles may be supported on your device.<nl/>Try installing the <command>power-profiles-daemon</command> package using your distribution's package manager and restarting the system.")
                    enabled: false
                    font: Kirigami.Theme.smallFont
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }

        }
    }
}
