/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.ksvg as KSvg

import org.kde.kirigami as Kirigami
//import QtQuick.Controls.Styles.Plasma as Styles

Item {
    id: crumbRoot

    height: crumb.implicitHeight + Kirigami.Units.smallSpacing * 2
    width: crumb.implicitWidth + arrowSvg.width

    property string text
    property bool root: false
    property int depth: model.depth

    function clickCrumb() {
        heading_ma.clicked(null);
    }

    PlasmaExtras.Heading {
			id: crumb
			anchors {
				left: arrowSvg.right
				top: parent.top
				bottom: parent.bottom
				topMargin: Kirigami.Units.smallSpacing
				leftMargin: Kirigami.Units.smallSpacing
				bottomMargin: Kirigami.Units.smallSpacing
			}
			horizontalAlignment: Text.AlignHCenter
			text: crumbRoot.text + " "
			color: "#404040"
			font.underline: heading_ma.enabled && heading_ma.containsMouse
			level: 5

			MouseArea {
				id: heading_ma
				anchors.fill: parent
				hoverEnabled: crumbRoot.depth < crumbModel.count
				enabled: crumbRoot.depth < crumbModel.count
                onClicked: {
                    // Remove all the breadcrumbs in front of the clicked one
                    while (crumbModel.count > 0 && crumbRoot.depth < crumbModel.get(crumbModel.count-1).depth) {
                        crumbModel.remove(crumbModel.count-1)
                        crumbModel.models.pop()
                    }

                    if (crumbRoot.root) {
                        applicationsView.newModel = rootModel;
                    } else {
                        applicationsView.newModel = crumbModel.models[index];
                    }
                    applicationsView.state = "OutgoingRight";
                }
				cursorShape: Qt.PointingHandCursor
				z: 99
			}
		}
        KSvg.SvgItem{
                id: arrowSvg

                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.smallSpacing*2
                anchors.verticalCenter: parent.verticalCenter
                height: crumbRoot.height / 2
                width: visible ? height : 0

                svg: arrowsSvg
                elementId: LayoutMirroring.enabled ? "right-arrow" : "left-arrow"
        }



} // crumbRoot
