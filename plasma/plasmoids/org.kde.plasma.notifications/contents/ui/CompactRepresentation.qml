/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.quickcharts 1.0 as Charts

import "global"

MouseArea {
    id: compactRoot

    Layout.minimumWidth: Plasmoid.formFactor === PlasmaCore.Types.Horizontal ? height : Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? width : Kirigami.Units.iconSizes.small + 2 * Kirigami.Units.iconSizes.small

    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    property int activeCount: 0
    property int unreadCount: 0

    property int jobsCount: 0
    property int jobsPercentage: 0

    property bool inhibited: false

    property bool wasExpanded: false
    onPressed: wasExpanded = root.expanded
    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) {
            Globals.toggleDoNotDisturbMode();
        } else {
            root.expanded = !wasExpanded;
        }
    }

    hoverEnabled: true

    Kirigami.Icon {
        id: notificationIcon
        anchors.centerIn: parent
        // Deliberately rounding the size here rather than letting Kirigami.Icon
        // do it itself so that children can derive sane sizes from it.
        width: Kirigami.Units.iconSizes.roundedIconSize(Math.min(parent.width, parent.height))
        height: width
        //visible: opacity > 0
        //active: compactRoot.containsMouse

        source: {
            let iconName;
            if(compactRoot.jobsCount > 0) {
                iconName = "notification-progress-active"
            } else if (compactRoot.inhibited) {
                iconName = "notification-disabled";
            } else if (compactRoot.unreadCount > 0) {
                iconName = "notification-active";
            } else {
                iconName = "notification-inactive"
            }
            return iconName;
        }

        /*Charts.PieChart {
            id: chart

            anchors.fill: parent

            visible: false

            range { from: 0; to: 100; automatic: false }

            valueSources: Charts.SingleValueSource { value: compactRoot.jobsPercentage }
            colorSource: Charts.SingleValueSource { value: Kirigami.Theme.highlightColor }

            thickness: 5
        }

        PlasmaComponents3.Label {
            id: countLabel
            anchors.centerIn: parent
            width: Math.round(Math.min(parent.width, parent.height) * (text.length > 1 ? 0.67 : 0.75))
            height: width
            fontSizeMode: Text.Fit
            font.pointSize: 1024
            font.pixelSize: -1
            minimumPointSize: 5//Kirigami.Theme.smallFont.pointSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: compactRoot.unreadCount || ""
            renderType: Text.QtRendering
            visible: false
        }

        PlasmaComponents3.BusyIndicator {
            id: busyIndicator
            anchors.fill: parent
            visible: false
            running: visible
        }*/
    }

    /*Kirigami.Icon {
        id: dndIcon
        anchors.fill: parent
        source: "notifications-disabled"
        opacity: 0
        scale: 2
        visible: opacity > 0
        active: compactRoot.containsMouse
    }*/

    /*states: [
        State { // active process
            when: compactRoot.jobsCount > 0
            PropertyChanges {
                target: notificationIcon
                source: "notification-progress-inactive"
            }
            PropertyChanges {
                target: countLabel
                text: compactRoot.jobsCount
                visible: true
            }
            PropertyChanges {
                target: busyIndicator
                visible: compactRoot.jobsPercentage == 0
            }
            PropertyChanges {
                target: chart
                visible: true
            }
        },
        State { // do not disturb
            when: compactRoot.inhibited
            PropertyChanges {
                target: dndIcon
                scale: 1
                opacity: 1
            }
            PropertyChanges {
                target: notificationIcon
                scale: 0
                opacity: 0
            }
        },
        State { // unread notifications
            name: "UNREAD"
            when: compactRoot.unreadCount > 0
            PropertyChanges {
                target: notificationIcon
                source: "notification-active"
            }
        }
    ]

    transitions: [
        Transition {
            to: "*" // any state
            NumberAnimation {
                targets: [notificationIcon, dndIcon]
                properties: "opacity,scale"
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: ""
            to: "UNREAD"
            SequentialAnimation {
                RotationAnimation {
                    target: notificationIcon
                    to: 30
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration
                }
                RotationAnimation {
                    target: notificationIcon
                    to: -30
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration * 2 // twice the swing distance, keep speed uniform
                }
                RotationAnimation {
                    target: notificationIcon
                    to: 0
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration
                }
            }
        }
    ]*/

}
