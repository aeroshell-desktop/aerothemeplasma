/*
    SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2011 Viranch Mehta <viranch.mehta@gmail.com>
    SPDX-FileCopyrightText: 2013 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2023 Natalie Clarius <natalie.clarius@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.workspace.components as WorkspaceComponents
import org.kde.kirigami as Kirigami

import org.kde.plasma.private.battery

MouseArea {
    id: root

    readonly property bool isConstrained: [PlasmaCore.Types.Vertical, PlasmaCore.Types.Horizontal].includes(Plasmoid.formFactor)
        || Plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentForcesSquarePlasmoids
    property int batteryPercent: 0
    property bool batteryPluggedIn: false
    property bool hasBatteries: false
    property bool hasInternalBatteries: false
    property bool hasCumulative: false
    property bool isBrokenBattery: false

    required property bool isSomehowFullyCharged
    required property bool isDischarging

    required property bool isManuallyInhibited
    required property bool isInDefaultPowerProfile
    required property bool isInPowersaveProfile
    required property bool isInBalancedProfile
    required property bool isInPerformanceProfile

    property alias model: view.model

    activeFocusOnTab: true
    hoverEnabled: true

    Accessible.name: Plasmoid.title
    Accessible.description: `${toolTipMainText}; ${toolTipSubText}`
    Accessible.role: Accessible.Button

    property string activeProfileIconSrc: isInPowersaveProfile   ? "battery-profile-powersave-symbolic"
                                        : isInBalancedProfile    ? "speedometer"
                                        : isInPerformanceProfile ? "battery-profile-performance-symbolic"
                                        : Plasmoid.icon

    readonly property string powerModeIconSrc: Plasmoid.icon

    // Shown for no batteries or manual inhibition while not discharging
    Kirigami.Icon {
        id: powerModeIcon

        anchors.fill: parent

        visible: root.isConstrained && (!root.hasInternalBatteries)
        source: root.powerModeIconSrc
        active: root.containsMouse
    }
    // Shown for no batteries or manual inhibition while not discharging
    Kirigami.Icon {
        id: brokenBattery

        anchors.fill: parent

        visible: root.isConstrained && root.isBrokenBattery
        source: "battery-missing"
        active: root.containsMouse
    }

    Item {
        id: overallBatteryInfo

        anchors.fill: parent

        visible: root.isConstrained && !powerModeIcon.visible && root.hasInternalBatteries

        // Show normal battery icon
        WorkspaceComponents.BatteryIcon {
            id: overallBatteryIcon

            anchors.fill: parent

            active: root.containsMouse
            hasBattery: root.hasCumulative
            percent: root.batteryPercent
            pluggedIn: root.batteryPluggedIn
            powerProfileIconName: root.isInDefaultPowerProfile ? ""
                                : root.isInPowersaveProfile    ? "powersave"
                                : root.isInBalancedProfile     ? "balanced"
                                : root.isInPerformanceProfile  ? "performance"
                                : ""
        }

    }

    //Show all batteries
    GridView {
        id: view

        visible: !root.isConstrained

        anchors.fill: parent

        contentHeight: height
        contentWidth: width

        cellWidth: Math.min(height, width)
        cellHeight: cellWidth

        // Don't block events from MouseArea, and don't let users drag the batteries around
        interactive: false

        clip: true

        // We have any batteries; show their status
        delegate: Item {
            id: batteryContainer

            width: view.cellWidth
            height: view.cellHeight

            // Show normal battery icon
            WorkspaceComponents.BatteryIcon {
                id: batteryIcon

                anchors.fill: parent

                active: root.containsMouse
                hasBattery: PluggedIn
                percent: Percent
                pluggedIn: ChargeState === BatteryControlModel.Charging
            }

            WorkspaceComponents.BadgeOverlay {
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                visible: Plasmoid.configuration.showPercentage && !root.isSomehowFullyCharged

                text: i18nc("battery percentage below battery icon", "%1%", Percent)
                icon: batteryIcon
            }
        }
    }
}
