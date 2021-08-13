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
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.ToolTipArea {
    id: tooltip

    property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
    implicitWidth: PlasmaCore.Units.iconSizes.smallMedium
    implicitHeight: implicitWidth

    subText: systemTrayState.expanded ? i18n("Close popup") : i18n("Show hidden icons")

    MouseArea {
        id: arrowMouseArea
        anchors.fill: parent
        onClicked: systemTrayState.expanded = !systemTrayState.expanded

        readonly property int arrowAnimationDuration: PlasmaCore.Units.shortDuration

        PlasmaCore.Svg {
            id: arrowSvg
            imagePath: "widgets/arrows"
        }

        PlasmaCore.SvgItem {
            id: arrow

            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width

            rotation: systemTrayState.expanded ? 180 : 0
            Behavior on rotation {
                RotationAnimation {
                    duration: arrowMouseArea.arrowAnimationDuration
                }
            }
            opacity: systemTrayState.expanded ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: arrowMouseArea.arrowAnimationDuration
                }
            }

            svg: arrowSvg
            elementId: {
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

        PlasmaCore.SvgItem {
            anchors.centerIn: parent
            width: arrow.width
            height: arrow.height

            rotation: systemTrayState.expanded ? 0 : -180
            Behavior on rotation {
                RotationAnimation {
                    duration: arrowMouseArea.arrowAnimationDuration
                }
            }
            opacity: systemTrayState.expanded ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: arrowMouseArea.arrowAnimationDuration
                }
            }

            svg: arrowSvg
            elementId: {
                if (plasmoid.location === PlasmaCore.Types.TopEdge) {
                    return "up-arrow";
                } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
                    return "left-arrow";
                } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
                    return "right-arrow";
                } else {
                    return "down-arrow";
                }
            }
        }
    }
}
