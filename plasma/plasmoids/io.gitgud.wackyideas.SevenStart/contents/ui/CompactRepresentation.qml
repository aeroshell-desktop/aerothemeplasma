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

import org.kde.kirigami as Kirigami

Item {
    id: root

    Layout.minimumHeight: floatingOrbPanel.buttonIconSizes.height;
    Layout.maximumHeight: floatingOrbPanel.buttonIconSizes.height;
    Layout.minimumWidth: floatingOrbPanel.buttonIconSizes.width;
    Layout.maximumWidth: floatingOrbPanel.buttonIconSizes.width;
    property bool compositing: false

    /*
     * The following code gets the ContainmentInterface instance which is used for keeping track of edit mode's state.
     * This allows us to hide the StartOrb object so the user can actually highlight and select this plasmoid during edit mode.
     */
    //property var containmentInterface: null
    property QtObject contextMenu: null
    property QtObject dashWindow: null
    readonly property bool editMode: Plasmoid.containment.corona.editMode //containmentInterface ? containmentInterface.editMode : false
    readonly property bool inPanel: (Plasmoid.location == PlasmaCore.Types.TopEdge || Plasmoid.location == PlasmaCore.Types.RightEdge || Plasmoid.location == PlasmaCore.Types.BottomEdge || Plasmoid.location == PlasmaCore.Types.LeftEdge)
    property bool menuShown: dashWindow.visible
    property QtObject orb: null
    property alias orbTimer: orbTimer
    readonly property var screenGeometry: Plasmoid.screenGeometry

    // Should the orb be rendered in its own dialog window so that it can stick out of the panel?
    readonly property bool stickOutOrb: Plasmoid.configuration.stickOutOrb && inPanel && !editMode
    readonly property bool useCustomButtonImage: (Plasmoid.configuration.useCustomButtonImage)
    readonly property bool vertical: (Plasmoid.formFactor == PlasmaCore.Types.Vertical)

    //property int opacityDuration: 350

    /*function createContextMenu(pos) {
        contextMenu = Qt.createQmlObject("ContextMenu {}", root);
        contextMenu.fillActions();
        contextMenu.show();
    }*/
    // If the url is empty (default value), then use the fallback url. Otherwise, return the url path relative to
    // the location of the source code.
    function getResolvedUrl(url, fallback) {
        if (url.toString() === "") {
            return Qt.resolvedUrl(fallback);
        }
        return url;
    }
    function positionOrb() {
        var pos = kicker.mapToGlobal(floatingOrbPanel.x, floatingOrbPanel.y);
        pos.y -= 5;
        //if(floatingOrbPanel.buttonIcon.implicitHeight === 54) // Using an orb with extra height around it

        //var pos = kicker.mapToGlobal(kicker.x, kicker.y); // Gets the global position of this plasmoid, in screen coordinates.
        orb.width = floatingOrbPanel.buttonIcon.implicitWidth// + panelSvg.margins.left;
        orb.height = floatingOrbPanel.buttonIcon.implicitHeight;

        orb.x = pos.x;
        orb.y = pos.y;// + panelSvg.margins.bottom;



        // Keep the orb positioned exactly on the bottom if it is rendered out of bounds (beyond the screen geometry)
        /*if (orb.y + orb.height > kicker.screenGeometry.height) {
            orb.y = kicker.screenGeometry.height - orb.height; //orb.y + orb.height - kicker.screenGeometry.height;
        }*/
    }
    function showMenu() {
        dashWindow.visible = !dashWindow.visible;
        dashWindow.showingAllPrograms = false;
        Plasmoid.setActiveWin(dashWindow);
        dashWindow.m_searchField.focus = true;
        orb.raise();
    }
    function updateSizeHints() {
        return;
        if (useCustomButtonImage) {
            if (vertical) {
                var scaledHeight = Math.floor(parent.width * (floatingOrbPanel.buttonIcon.height / floatingOrbPanel.buttonIcon.width));
                root.Layout.minimumHeight = scaledHeight;
                root.Layout.maximumHeight = scaledHeight;
                root.Layout.minimumWidth = Kirigami.Units.iconSizes.small;
                root.Layout.maximumWidth = inPanel ? Kirigami.Units.iconSizes.medium : -1;
            } else {
                var scaledWidth = Math.floor(parent.height * (floatingOrbPanel.buttonIcon.width / floatingOrbPanel.buttonIcon.height));
                root.Layout.minimumWidth = scaledWidth;
                root.Layout.maximumWidth = scaledWidth;
                root.Layout.minimumHeight = Kirigami.Units.iconSizes.small;
                root.Layout.maximumHeight = inPanel ? Kirigami.Units.iconSizes.medium : -1;
            }
        } else {
            root.Layout.minimumWidth = Kirigami.Units.iconSizes.small;
            root.Layout.maximumWidth = inPanel ? Kirigami.Units.iconSizes.medium : -1;
            root.Layout.minimumHeight = Kirigami.Units.iconSizes.small;
            root.Layout.maximumHeight = inPanel ? Kirigami.Units.iconSizes.medium : -1;
        }
        if (stickOutOrb && orb) {
            root.Layout.minimumWidth = orb.width + panelSvg.margins.right * (compositing ? 0 : 1);
            root.Layout.maximumWidth = orb.width + panelSvg.margins.right * (compositing ? 0 : 1);
            root.Layout.minimumHeight = orb.height;
            root.Layout.maximumHeight = orb.height;
        }
    }

    //kicker.status: PlasmaCore.Types.PassiveStatus
    Plasmoid.status: dashWindow && dashWindow.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus
    //clip: true

    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("MenuRepresentation {}", kicker);
        orb = Qt.createQmlObject("StartOrb {}", kicker);
        //Plasmoid.fullRepresentation = dashWindow
        Plasmoid.activated.connect(function () {
            showMenu();
        });
    }
    onCompositingChanged: {
        updateSizeHints();
        positionOrb();
        /*if (compositing) {
            orb.x += panelSvg.margins.left;
        }*/
        compositingFix.start();
    }
    onHeightChanged: updateSizeHints()
    onParentChanged: {
        /*if (parent) {
            for (var obj = root, depth = 0; !!obj; obj = obj.parent, depth++) {
                if (obj.toString().startsWith('ContainmentInterface')) {
                    // desktop containment / plasmoidviewer
                    // Note: This doesn't always work. FolderViewDropArea may not yet have
                    //       ContainmentInterface as a parent when this loop runs.
                    if (typeof obj['editMode'] === 'boolean') {
                        root.containmentInterface = obj;
                        break;
                    }
                } else if (obj.toString().startsWith('DeclarativeDropArea')) {
                    // panel containment
                    if (typeof obj['Plasmoid'] !== 'undefined' && obj['Plasmoid'].toString().startsWith('ContainmentInterface')) {
                        if (typeof obj['Plasmoid']['editMode'] === 'boolean') {
                            root.containmentInterface = obj.Plasmoid;
                            break;
                        }
                    }
                }
            }
        }*/
    }
    onStickOutOrbChanged: {
        updateSizeHints();
        positionOrb();
    }
    onWidthChanged: updateSizeHints()

    /*Connections {
        target: Kirigami.Units.iconSizeHints

        function onPanelChanged() { updateSizeHints(); }
    }*/

    Connections {
        target: Plasmoid.configuration
        function onCustomButtonImageChanged() {
            positionOrb();
            console.log("AAAA")
        }
    }
    Connections {
        function onScreenChanged() {
            positionOrb();
        }
        function onScreenGeometryChanged() {
            positionOrb();
        }

        target: kicker
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
        anchors.left: parent.left
        //anchors.leftMargin: -Kirigami.Units.mediumSpacing
        anchors.verticalCenter: parent.verticalCenter
        //anchors.verticalCenterOffset: Kirigami.Units.smallSpacing-1
        //anchors.fill: parent
        objectName: "innerorb"
        opacity: (!stickOutOrb)

    }

    // Handles all mouse events for the popup orb
    MouseArea {
        id: mouseAreaCompositingOff

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        hoverEnabled: true
        //visible: !stickOutOrb
        propagateComposedEvents: true

        onPressed: mouse => {
            if(mouse.button === Qt.LeftButton)
                showMenu();
            else
                mouse.accepted = false;
        }
    }

    // I hate this

    // So the only way I could reasonably think of to make this work is running the function
    // with a delay.
    Timer {
        id: compositingFix

        interval: 150

        onTriggered: {
            if (!compositing) {
                Plasmoid.setTransparentWindow();
            }
        }
    }

    // Even worse, this just makes things even more unsophisticated. If someone has a better
    // way of solving this, I would love to know.
    Timer {
        id: orbTimer

        interval: 15

        onTriggered: {
            Plasmoid.setOrb(orb);
            // Currently hardcoded, will make it configurable soon, when it's been properly tested and hopefully slightly refactored.
            Plasmoid.setMask(Qt.resolvedUrl("./orbs/mask.png"), false);
            Plasmoid.setWinState(orb);
            Plasmoid.setWinType(orb);
            Plasmoid.setDashWindow(dashWindow);
            updateSizeHints();
            positionOrb();
        }
    }
}
