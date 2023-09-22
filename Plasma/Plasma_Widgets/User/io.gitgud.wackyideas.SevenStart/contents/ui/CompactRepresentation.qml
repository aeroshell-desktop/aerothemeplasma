/***************************************************************************
 *   Copyright (C) 2013-2014 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kwindowsystem 1.0

Item {
    id: root
    readonly property var screenGeometry: plasmoid.screenGeometry
    readonly property bool inPanel: (plasmoid.location == PlasmaCore.Types.TopEdge
								  || plasmoid.location == PlasmaCore.Types.RightEdge
								  || plasmoid.location == PlasmaCore.Types.BottomEdge
								  || plasmoid.location == PlasmaCore.Types.LeftEdge)
    readonly property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    readonly property bool useCustomButtonImage: (plasmoid.configuration.useCustomButtonImage)

    // Should the orb be rendered in its own dialog window so that it can stick out of the panel?
    readonly property bool stickOutOrb: plasmoid.configuration.stickOutOrb && inPanel && !editMode
    property QtObject dashWindow: null
    property QtObject orb: null
    property QtObject contextMenu: null

    Plasmoid.status: dashWindow && dashWindow.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    onWidthChanged: updateSizeHints()
    onHeightChanged: updateSizeHints()
    clip: true
    function updateSizeHints() {
        if (useCustomButtonImage) {
            if (vertical) {
                var scaledHeight = Math.floor(parent.width * (floatingOrbPanel.buttonIcon.implicitHeight / floatingOrbPanel.buttonIcon.implicitWidth));
                root.Layout.minimumHeight = scaledHeight;
                root.Layout.maximumHeight = scaledHeight;
                root.Layout.minimumWidth = units.iconSizes.small;
                root.Layout.maximumWidth = inPanel ? units.iconSizeHints.panel : -1;
            } else {
                var scaledWidth = Math.floor(parent.height * (floatingOrbPanel.buttonIcon.implicitWidth / floatingOrbPanel.buttonIcon.implicitHeight));
                root.Layout.minimumWidth = scaledWidth;
                root.Layout.maximumWidth = scaledWidth;
                root.Layout.minimumHeight = units.iconSizes.small;
                root.Layout.maximumHeight = inPanel ? units.iconSizeHints.panel : -1;
            }
        } else {
            root.Layout.minimumWidth = units.iconSizes.small;
            root.Layout.maximumWidth = inPanel ? units.iconSizeHints.panel : -1;
            root.Layout.minimumHeight = units.iconSizes.small
            root.Layout.maximumHeight = inPanel ? units.iconSizeHints.panel : -1;
        }
        if(stickOutOrb && orb) {
            root.Layout.minimumWidth =  orb.width + panelSvg.margins.right*(compositing ? 0 : 1);
            root.Layout.maximumWidth =  orb.width + panelSvg.margins.right*(compositing ? 0 : 1);
            root.Layout.minimumHeight = orb.height;
            root.Layout.maximumHeight = orb.height;
        }
    }

    onStickOutOrbChanged: {
        updateSizeHints();
        positionOrb();
    }


    /* The following code gets the ContainmentInterface instance which is used for two things:
     * 1. Getting context menu actions for entering edit mode and adding plasmoids
     * 2. Keeping track on when edit mode is enabled. This allows us to hide the StartOrb
     *    object so the user can actually highlight and select this plasmoid during edit mode.
     */
    property var containmentInterface: null
	readonly property bool editMode: containmentInterface ? containmentInterface.editMode : false
	onParentChanged: {
		if (parent) {
			for (var obj = root, depth = 0; !!obj; obj = obj.parent, depth++) {
				if (obj.toString().startsWith('ContainmentInterface')) {
					// desktop containment / plasmoidviewer
					// Note: This doesn't always work. FolderViewDropArea may not yet have
					//       ContainmentInterface as a parent when this loop runs.
					if (typeof obj['editMode'] === 'boolean') {
						root.containmentInterface = obj
						break
					}
				} else if (obj.toString().startsWith('DeclarativeDropArea')) {
					// panel containment
					if (typeof obj['Plasmoid'] !== 'undefined' && obj['Plasmoid'].toString().startsWith('ContainmentInterface')) {
						if (typeof obj['Plasmoid']['editMode'] === 'boolean') {
							root.containmentInterface = obj.Plasmoid
							break
						}
					}
				}
			}
		}
	}
    Connections {
        target: units.iconSizeHints

        function onPanelChanged() { updateSizeHints(); }
    }
    property bool compositing: kwindowsystem.compositingActive

    /* We want to change the background hint for the orb dialog window depending
     * on the compositing state. In this case, 0 refers to NoBackground, while
     * 2 refers to SolidBackground.
     */
    onCompositingChanged: {
        if(compositing) {
            orb.backgroundHints = 0;
        } else {
            orb.backgroundHints = 2;
        }
        updateSizeHints();
        positionOrb();

        // Add a little padding to the orb.
        if(compositing)
            orb.x += panelSvg.margins.left;
    }

    function positionOrb() {
        var pos = plasmoid.mapToGlobal(kicker.x, kicker.y); // Gets the global position of this plasmoid, in screen coordinates.
        orb.width = floatingOrbPanel.buttonIcon.implicitWidth + panelSvg.margins.left;
        orb.height = floatingOrbPanel.buttonIcon.implicitHeight;
        orb.x = pos.x;
        orb.y = pos.y + panelSvg.margins.bottom;

        // Keep the orb positioned exactly on the bottom if it is rendered out of bounds (beyond the screen geometry)
        if(orb.y + orb.height > plasmoid.screenGeometry.height) {
            orb.y -= orb.y + orb.height - plasmoid.screenGeometry.height;
        }
    }
    // If the url is empty (default value), then use the fallback url. Otherwise, return the url path relative to
    // the location of the source code.
    function getResolvedUrl(url, fallback) {
        if(url.toString() === "") {
            return Qt.resolvedUrl(fallback);
        }
        return url;
    }
    property int opacityDuration: 250

    function createContextMenu(pos) {
        contextMenu = Qt.createQmlObject("ContextMenu {}", root);
        contextMenu.fillActions();
        contextMenu.show();
    }

    /*
     * Three IconItems are used in order to achieve the same look and feel as Windows 7's
     * orbs. When the menu is closed, hovering over the orb results in the hovered icon
     * gradually appearing into view, and clicking on the orb causes an instant change in
     * visibility, where the normal and hovered icons are invisible, and the pressed icon
     * is visible.
     *
     * When they're bounded by the panel, these icons will by default try to fill up as
     * much space as they can in the compact representation while preserving their aspect
     * ratio.
     */

    FloatingOrb {
        id: floatingOrbPanel
        visible: (!stickOutOrb)
        anchors.fill: parent
        objectName: "innerorb"
    }

    // Covers the entire compact representation just in case the orb dialog doesn't cover
    // the entire area by itself.
    MouseArea
    {
        id: mouseAreaCompositingOff
        anchors.fill: parent
        hoverEnabled: true
        visible: stickOutOrb
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if(mouse.button == Qt.RightButton) {
                var pos = plasmoid.mapToGlobal(mouse.x, mouse.y);
                createContextMenu(pos);


            } else {
                dashWindow.visible = !dashWindow.visible;
                dashWindow.showingAllPrograms = false;
            }
        }
    }


    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("MenuRepresentation {}", root);
        orb = Qt.createQmlObject("StartOrb {}", root);
        plasmoid.activated.connect(function() {
            dashWindow.visible = !dashWindow.visible;
            dashWindow.showingAllPrograms = false;
        });
        positionOrb();
    }
}
