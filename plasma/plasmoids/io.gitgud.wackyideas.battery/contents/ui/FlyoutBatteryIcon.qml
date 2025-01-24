/*
 *    SPDX-FileCopyrightText: 2011 Viranch Mehta <viranch.mehta@gmail.com>
 *    SPDX-FileCopyrightText: 2013 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *    SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0

import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    property bool hasBattery
    property int percent
    property bool pluggedIn
    property string batteryType
    property bool active: false
    property string powerProfileIconName: ""
    property int health
    property bool broken

    // Icon for current charge level, charging status, and optionally power
    // profile indication (for batteries that support it by setting
    // "powerProfileIconName" to something other than an empty string).
    Kirigami.Icon {
        id: mainBattery
        anchors.fill: parent
        source: root.hasBattery ? fillElement(root.percent, root.health, root.broken) : "flyout-battery-missing"
        visible: !otherBatteriesIcon.visible
        active: root.active

        function fillElement(p: int, h: int, b: bool): string {
            let name = "flyout-"

            if(b && typeof h !== "undefined") {
                return "flyout-battery-missing"
            }

            if (p >= 95) {
                name += "battery-100";
            } else if (p >= 85) {
                name += "battery-090";
            } else if (p >= 75) {
                name += "battery-080";
            } else if (p >= 65) {
                name += "battery-070";
            } else if (p >= 55) {
                name += "battery-060";
            } else if (p >= 45) {
                name += "battery-050";
            } else if (p >= 35) {
                name += "battery-040";
            } else if (p >= 25) {
                name += "battery-030";
            } else if (p >= 15) {
                name += "battery-020";
            } else if (p > 5) {
                name += "battery-010";
            } else {
                name += "battery-000";
            }

            return name;
        }
    }
    Kirigami.Icon {
        anchors.fill: parent
        visible: !otherBatteriesIcon.visible && source != ""
        active: root.active
        source: {

            if(batterymonitor.isPluggedIn) {
                return "flyout-battery-charging"
            } else if(mainBattery.source === "flyout-battery-000") {
                return "flyout-battery-critical";
            } else if(mainBattery.source === "flyout-battery-010") {
                return "flyout-battery-caution";
            }

            return "";
        }
    }

    // Generic icon for other types of batteries
    Kirigami.Icon {
        id: otherBatteriesIcon
        anchors.fill: parent
        source: elementForType(root.batteryType)
        visible: source !== ""
        active: root.active

        function elementForType(t: string): string {
            switch(t) {
                case "Mouse":
                    return "input-mouse-battery";
                case "Keyboard":
                    return "input-keyboard-battery";
                case "Pda":
                    return "phone-battery";
                case "Phone":
                    return "phone-battery";
                case "Ups":
                    return "battery-ups";
                case "GamingInput":
                    return "input-gaming-battery";
                case "Bluetooth":
                    return "preferences-system-bluetooth-battery";
                case "Headset":
                    return "audio-headset-battery";
                default:
                    return "";
            }
        }
    }
}
