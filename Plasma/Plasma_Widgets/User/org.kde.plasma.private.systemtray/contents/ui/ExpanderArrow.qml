/***************************************************************************
 *   Copyright 2013 Sebastian Kügler <sebas@kde.org>                       *
 *   Copyright 2015 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                  *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.ToolTipArea {
    id: tooltip

    property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
    implicitWidth: PlasmaCore.Units.iconSizes.smallMedium
    implicitHeight: implicitWidth

    mainText: systemTrayState.expanded ? i18n("Hide") : i18n("Show hidden icons")

    MouseArea {
        id: arrowMouseArea
        anchors.fill: parent
        anchors.leftMargin: 2

        // When clicking on the arrow, toggle the system tray's expanded state. '
        onClicked: systemTrayState.expanded = !systemTrayState.expanded
        hoverEnabled: true
        
        // Loading in the arrows SVG file from the Plasma theme.
        PlasmaCore.Svg {
            id: arrowSvg
            imagePath: "widgets/arrows"
        }

        // The SvgItem actually does the rendering of the SVG file.
        PlasmaCore.SvgItem {
            id: arrow

            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)+1
            height: width-1

            // This is the Aero styled button texture used for the system tray expander.
            PlasmaCore.FrameSvgItem {
                id: hoverButton
                z: -1 // To prevent layout issues with the MouseArea.
                anchors.fill: parent
                imagePath: Qt.resolvedUrl("svgs/systray.svg")
                prefix: {
                    if(arrowMouseArea.containsPress || systemTrayState.expanded) return "pressed";
                    if(arrowMouseArea.containsMouse) return "hover";
                    return "normal"; // The normal state actually just makes the button invisible.
                }
            }
            svg: arrowSvg
            elementId: {
                // Depending on the taskbar orientation, choose different arrow orientation from the SVG.
                if (plasmoid.location === PlasmaCore.Types.TopEdge) {
                    return "down-arrow";
                } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
                    return "right-arrow";
                } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
                    return "left-arrow";
                } else {
                    return "up-arrow";
                }
            }
        }
    }
}
