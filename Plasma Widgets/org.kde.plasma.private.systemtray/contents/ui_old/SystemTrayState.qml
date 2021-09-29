/*
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.12
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

//This object contains state of the SystemTray, mainly related to the 'expanded' state
QtObject {
    //true if System Tray is 'expanded'. It may be when:
    // - there is an active applet or
    // - 'Status and Notification' with hidden items is shown
    property bool expanded: false
    //set when there is an applet selected
    property Item activeApplet

    //allow expanded change only when activated at least once
    //this is to suppress expanded state change during Plasma startup
    property bool acceptExpandedChange: false

    // These properties allow us to keep track of where the expanded applet
    // was and is on the panel, allowing PlasmoidPopupContainer.qml to animate
    // depending on their locations.
    property int oldVisualIndex: -1
    property int newVisualIndex: -1

    function setActiveApplet(applet, visualIndex) {
        if (visualIndex === undefined) {
            oldVisualIndex = -1
            newVisualIndex = -1
        } else {
            oldVisualIndex = newVisualIndex
            newVisualIndex = visualIndex
        }

        const oldApplet = activeApplet
        activeApplet = applet
        if (oldApplet && oldApplet !== applet) {
            oldApplet.expanded = false
        }
        expanded = true
    }

    onExpandedChanged: {
        if (expanded) {
            plasmoid.status = PlasmaCore.Types.RequiresAttentionStatus
        } else {
            plasmoid.status = PlasmaCore.Types.PassiveStatus;
            if (activeApplet) {
                // if not expanded we don't have an active applet anymore
                activeApplet.expanded = false
                activeApplet = null
            }
        }
        acceptExpandedChange = false
        plasmoid.expanded = expanded
    }

    //listen on SystemTray AppletInterface signals
    property Connections plasmoidConnections: Connections {
        target: plasmoid
        //emitted when activation is requested, for example by using a global keyboard shortcut
        function onActivated() {
            acceptExpandedChange = true
        }
        function onExpandedChanged() {
            if (acceptExpandedChange) {
                expanded = plasmoid.expanded
            } else {
                plasmoid.expanded = expanded
            }
        }
    }

    property Connections activeAppletConnections: Connections {
        target: activeApplet

        function onExpandedChanged() {
            if (!activeApplet.expanded) {
                expanded = false
            }
        }
    }

}
