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

Item {
    id: root

    readonly property var screenGeometry: plasmoid.screenGeometry
    readonly property bool inPanel: (plasmoid.location == PlasmaCore.Types.TopEdge
								  || plasmoid.location == PlasmaCore.Types.RightEdge
								  || plasmoid.location == PlasmaCore.Types.BottomEdge
								  || plasmoid.location == PlasmaCore.Types.LeftEdge)
    readonly property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    readonly property bool useCustomButtonImage: (plasmoid.configuration.useCustomButtonImage)
    property QtObject dashWindow: null

    Plasmoid.status: dashWindow && dashWindow.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    onWidthChanged: updateSizeHints()
    onHeightChanged: updateSizeHints()

    function updateSizeHints() {
        if (useCustomButtonImage) {
            if (vertical) {
                var scaledHeight = Math.floor(parent.width * (buttonIcon.implicitHeight / buttonIcon.implicitWidth));
                root.Layout.minimumHeight = scaledHeight;
                root.Layout.maximumHeight = scaledHeight;
                root.Layout.minimumWidth = units.iconSizes.small;
                root.Layout.maximumWidth = inPanel ? units.iconSizeHints.panel : -1;
            } else {
                var scaledWidth = Math.floor(parent.height * (buttonIcon.implicitWidth / buttonIcon.implicitHeight));
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
    }

    Connections {
        target: units.iconSizeHints

        function onPanelChanged() { updateSizeHints(); }
    }

    // If the url is empty (default value), then use the fallback url.
    function getResolvedUrl(url, fallback) {
        if(url.toString() === "") {
            return Qt.resolvedUrl(fallback);
        }
        return url;
    }
    property int opacityDuration: 250

    /*
     * Three IconItems are used in order to achieve the same look and feel as Windows 7's
     * orbs. When the menu is closed, hovering over the orb results in the hovered icon
     * gradually appearing into view, and clicking on the orb causes an instant change in
     * visibility, where the normal and hovered icons are invisible, and the pressed icon
     * is visible.
     *
     * These icons will by default try to fill up as much space as they can in the compact
     * representation.
     */
    PlasmaCore.IconItem {
        id: buttonIcon
        anchors.fill: parent
        opacity: 1
        readonly property double aspectRatio: (vertical ? implicitHeight / implicitWidth
            : implicitWidth / implicitHeight)
        
        source: getResolvedUrl(plasmoid.configuration.customButtonImage, "orbs/normal.png")
        
        smooth: true
        roundToIconSize: !useCustomButtonImage || aspectRatio === 1
        onSourceChanged: updateSizeHints()
    }
    PlasmaCore.IconItem {
        id: buttonIconPressed
        anchors.fill: parent
        opacity: 1
        visible: dashWindow.visible
        readonly property double aspectRatio: (vertical ? implicitHeight / implicitWidth
            : implicitWidth / implicitHeight)

        source: getResolvedUrl(plasmoid.configuration.customButtonImageActive, "orbs/selected.png") //

        smooth: true
        roundToIconSize: !useCustomButtonImage || aspectRatio === 1
        onSourceChanged: updateSizeHints()
    }
    PlasmaCore.IconItem {
        id: buttonIconHovered
        z: 1
        source: getResolvedUrl(plasmoid.configuration.customButtonImageHover, "orbs/hovered.png");
        opacity: mouseArea.containsMouse
        visible:  !dashWindow.visible
        anchors.fill: parent
        readonly property double aspectRatio: (vertical ? implicitHeight / implicitWidth
            : implicitWidth / implicitHeight)
        smooth: true
        Behavior on opacity {
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: opacityDuration  }
        }
        // A custom icon could also be rectangular. However, if a square, custom, icon is given, assume it
        // to be an icon and round it to the nearest icon size again to avoid scaling artifacts.
        roundToIconSize: !useCustomButtonImage || aspectRatio === 1

        onSourceChanged: updateSizeHints()
    }

    // Clicking on the plasmoid or activating it in any way causes the Full representation
    // to show/hide.
    MouseArea
    {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            dashWindow.visible = !dashWindow.visible;
            dashWindow.showingAllPrograms = false;
        }
    }

    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("MenuRepresentation {}", root);
        plasmoid.activated.connect(function() {
            dashWindow.visible = !dashWindow.visible;
        });
    }
}
