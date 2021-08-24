/*
 *   Copyright 2020 Konrad Materka <materka@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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
        //emitted when the configuration dialog is opened
        function onUserConfiguringChanged() {
            if (plasmoid.userConfiguring) {
                systemTrayState.expanded = false
            }
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
