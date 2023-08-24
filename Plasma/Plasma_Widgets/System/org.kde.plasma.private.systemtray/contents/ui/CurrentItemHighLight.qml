/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
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
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.FrameSvgItem {
    id: currentItemHighLight

    property int location

    // As this highlight texture is no longer animated except for opacity changes, this property is scheduled for removal.
    property bool animationEnabled: true
    property var highlightedItem: null

    z: -1 // always draw behind icons
    /*
     * The highlight isn't at 100% opacity, however when the highlighted tray icon is hovered,
     * a second highlight will appear underneath that makes it 100% opaque.
     */
    opacity: systemTrayState.expanded ? 0.8 : 0
    
    MouseArea
    {
        id: trayItemHighlight

        anchors.fill: parent
        hoverEnabled: true
        property int highlightOpacity: 0
        onEntered: highlightOpacity = 1
        onExited: highlightOpacity = 0
    }

    imagePath: "widgets/tabbar"
    prefix: {
        var prefix = ""
        switch (location) {
            case PlasmaCore.Types.LeftEdge:
                prefix = "west-active-tab";
                break;
            case PlasmaCore.Types.TopEdge:
                prefix = "north-active-tab";
                break;
            case PlasmaCore.Types.RightEdge:
                prefix = "east-active-tab";
                break;
            default:
                prefix = "south-active-tab";
            }
            if (!hasElementPrefix(prefix)) {
                prefix = "active-tab";
            }
            return prefix;
    }

    // update when System Tray is expanded - applet activated or hidden icons shown
    Connections {
        target: systemTrayState

        function onActiveAppletChanged() {
            Qt.callLater(updateHighlightedItem);
        }

        function onExpandedChanged() {
            Qt.callLater(updateHighlightedItem);
        }
    }

    // update when applet changes parent (e.g. moves from active to hidden icons)
    Connections {
        target: systemTrayState.activeApplet

        function onParentChanged() {
            Qt.callLater(updateHighlightedItem);
        }
    }

    // update when System Tray size changes
    Connections {
        target: parent

        function onWidthChanged() {
            Qt.callLater(updateHighlightedItem);
        }

        function onHeightChanged() {
            Qt.callLater(updateHighlightedItem);
        }
    }

    // update when scale of newly added tray item changes (check 'add' animation in GridView in main.qml)
    Connections {
        target: !!highlightedItem && highlightedItem.parent ? highlightedItem.parent : null

        function onScaleChanged() {
            Qt.callLater(updateHighlightedItem);
        }
    }

    function updateHighlightedItem() {
        if (systemTrayState.expanded) {
            if (systemTrayState.activeApplet && systemTrayState.activeApplet.parent && systemTrayState.activeApplet.parent.inVisibleLayout) {
                changeHighlightedItem(systemTrayState.activeApplet.parent.container);
            } else { // 'Show hiden items' popup
                highlightedItem = null;
                width = 0;
                height = 0;
            }
        } else {
            highlightedItem = null;
        }
    }

    function changeHighlightedItem(nextItem) {
        // do not animate the first appearance
        // or when the property value of a highlighted item changes
        if (!highlightedItem || (highlightedItem === nextItem)) {
            animationEnabled = false;
        }

        highlightedItem = nextItem;

        const p = parent.mapFromItem(highlightedItem, 0, 0)
        x = p.x;
        y = p.y;
        width = highlightedItem.width
        height = highlightedItem.height

        animationEnabled = true;
    }

    // Fade in/out the highlight texture when it's shown/hidden.
    Behavior on opacity {
        NumberAnimation {
            duration: PlasmaCore.Units.longDuration
            easing.type: systemTrayState.expanded ? Easing.OutCubic : Easing.InCubic
        }
    }
}
