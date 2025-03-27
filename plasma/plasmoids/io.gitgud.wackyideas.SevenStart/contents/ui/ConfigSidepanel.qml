/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
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
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kcmutils as KCM

import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.3 as Kirigami

KCM.SimpleKCM {
    id: configSidepanel

    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_sidePanelVisibility: sidePanelVisibility.text

	TextField {
		id: sidePanelVisibility
		visible: false
	}

	Item {
		id: visibilityManager
		property var sidePanelVisibilityObject: {}
		function addItem(n) {
			if(typeof sidePanelVisibilityObject === "undefined")
				sidePanelVisibilityObject = {};

			sidePanelVisibilityObject[n] = 1;
			sidePanelVisibility.text = JSON.stringify(sidePanelVisibilityObject);
		}
		function removeItem(n) {
			delete sidePanelVisibilityObject[n];
			if(typeof sidePanelVisibilityObject === "undefined")
				sidePanelVisibilityObject = {};
			sidePanelVisibility.text = JSON.stringify(sidePanelVisibilityObject);
		}
		function getItem(n) {
			return sidePanelVisibilityObject[n];
		}
	}

    SidePanelModels { id: sidePanelModels }
    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.gridUnit*4
        anchors.rightMargin: Kirigami.Units.gridUnit*4
        GroupBox {
			id: gbox
            Layout.fillWidth: true

            background: Rectangle {
				color: "white"
				border.color: "#bababe"
				y: gbox.topPadding - gbox.bottomPadding
				height: parent.height - gbox.topPadding + gbox.bottomPadding

			}
			label: Label {
				x: gbox.leftPadding
				width: gbox.availableWidth
				text: gbox.title
				elide: Text.ElideRight
			}

            title: i18n("Customize how links, icons, and menus look and behave.")

			ColumnLayout {

				Repeater {
					model: sidePanelModels.firstCategory.length
					delegate: CheckBox {
						required property int index
						text: sidePanelModels.firstCategory[index].name
						icon.name: sidePanelModels.firstCategory[index].itemIcon
						icon.source: sidePanelModels.firstCategory[index].itemIconFallback
						icon.width: Kirigami.Units.iconSizes.small
						icon.height: Kirigami.Units.iconSizes.small
						checked: typeof visibilityManager.getItem(text) !== "undefined"
						onCheckStateChanged: {
							if(checkState === Qt.Checked) {
								visibilityManager.addItem(text);
							} else {
								visibilityManager.removeItem(text);
							}
						}
					}
				}
				Repeater {
					model: sidePanelModels.secondCategory.length
					delegate: CheckBox {
						required property int index
						text: sidePanelModels.secondCategory[index].name
						icon.name: sidePanelModels.secondCategory[index].itemIcon
						icon.source: sidePanelModels.secondCategory[index].itemIconFallback
						icon.width: Kirigami.Units.iconSizes.small
						icon.height: Kirigami.Units.iconSizes.small
						checked: typeof visibilityManager.getItem(text) !== "undefined"
						onCheckStateChanged: {
							if(checkState === Qt.Checked) {
								visibilityManager.addItem(text);
							} else {
								visibilityManager.removeItem(text);
							}
						}
					}
				}
				Repeater {
					model: sidePanelModels.thirdCategory.length
					delegate: CheckBox {
						required property int index
						text: sidePanelModels.thirdCategory[index].name
						icon.name: sidePanelModels.thirdCategory[index].itemIcon
						icon.source: sidePanelModels.thirdCategory[index].itemIconFallback
						icon.width: Kirigami.Units.iconSizes.small
						icon.height: Kirigami.Units.iconSizes.small
						checked: typeof visibilityManager.getItem(text) !== "undefined"
						onCheckStateChanged: {
							if(checkState === Qt.Checked) {
								visibilityManager.addItem(text);
							} else {
								visibilityManager.removeItem(text);
							}
						}
					}
				}
			}
        }
    }
    Component.onCompleted: {
		if(Plasmoid.configuration.stickOutOrb) Plasmoid.setTransparentWindow();
		var list = Plasmoid.configuration.sidePanelVisibility;
		if(list !== "")
			visibilityManager.sidePanelVisibilityObject = JSON.parse(list);

		if(typeof visibilityManager.sidePanelVisibilityObject === "undefined")
			visibilityManager.sidePanelVisibilityObject = {};
    }
	Component.onDestruction: {
		if(Plasmoid.configuration.stickOutOrb) Plasmoid.setTransparentWindow();
    }
}
