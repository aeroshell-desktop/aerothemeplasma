/***************************************************************************
 *   Copyright (C) 2015 by Eike Hein <hein@kde.org>                        *
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

import QtQuick 2.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker

/* 
	This is a list of items organized by categories in a stacking order used by 
	the SearchView. As it shows multiple data models at once, they're split up
	into categories, with each category having their own header.
*/
PlasmaExtras.ScrollArea {
    id: itemMultiGrid

    anchors.fill: parent
    anchors.rightMargin: units.smallSpacing
    anchors.bottomMargin: units.smallSpacing

    implicitHeight: itemColumn.implicitHeight

    signal keyNavLeft(int subGridIndex)
    signal keyNavRight(int subGridIndex)
    signal keyNavUp()
    signal keyNavDown()

    property bool grabFocus: false

    property alias model: repeater.model
    property alias count: repeater.count
    property bool isSquare: false
    property int aCellHeight
    property int aCellWidth
    property alias repeater: itemColumn.repeater

    verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

    flickableItem.flickableDirection: Flickable.VerticalFlick

    onFocusChanged: {
        if (!focus) {
            for (var i = 0; i < repeater.count; i++) {
                subGridAt(i).focus = false;
            }
        } else {
            subGridAt(repeater.currentModelIndex).focus = true;
        }
    }

    function subGridAt(index) {
        return repeater.itemAt(index).itemGrid;
    }

    function tryActivate(row, col) { // FIXME TODO: Cleanup messy algo.
        if (flickableItem.contentY > 0) {
            row = 0;
        }

        var target = null;
        var rows = 0;

        for (var i = 0; i < repeater.count; i++) {
            var grid = subGridAt(i);

            if (rows <= row) {
                target = grid;
                rows += grid.lastRow() + 2; // Header counts as one.
            } else {
                break;
            }
        }

        if (target) {
            rows -= (target.lastRow() + 2);
            target.tryActivate(row - rows, col);
        }
    }

    Column {
        id: itemColumn

        width: itemMultiGrid.width - units.gridUnit

        property alias repeater: repeater

        Repeater {
            id: repeater


            property int currentModelIndex: 0
            onCurrentModelIndexChanged: {
                if(currentModelIndex == repeater.count) currentModelIndex = 0;
                else if(currentModelIndex < 0) currentModelIndex = repeater.count - 1;
                repeater.itemAt(currentModelIndex).itemGrid.forceActiveFocus();
                repeater.itemAt(currentModelIndex).itemGrid.focus = true;
            }
            function isRepeaterEmpty() {
                for(var i = 0; i < repeater.count; i++) {
                    if(repeater.itemAt(i).count != 0) return false;
                }
                return true;
            }
            function getCurrentModel() {
                return repeater.itemAt(currentModelIndex);
            }
            delegate: Item {
                width: itemColumn.width
                height:  gridViewLabel.height + gridView.height + (index == repeater.count - 1 ? 0 : units.smallSpacing)
                visible:  repeater.model.modelForRow(index).count > 0

                property alias currentIndex: gridView.currentIndex
                property alias count: gridView.count
                property Item itemGrid: gridView
				
				//Header displaying the name of the result category and the number of items in the category.
                PlasmaExtras.Heading {
                    id: gridViewLabel
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: units.smallSpacing
                    height: dummyHeading.height
                    wrapMode: Text.NoWrap
                    color: "#1d3287";
                    level: 4
                    verticalAlignment: Qt.AlignVCenter
                    text: repeater.model.modelForRow(index).description + " (" + repeater.model.modelForRow(index).count +")"
                }
				
				//Line that extends from the header to the right of the search view. 
                Rectangle {
                    anchors.topMargin: units.smallSpacing
                    anchors.left: gridViewLabel.right
                    anchors.leftMargin: units.smallSpacing
                    anchors.verticalCenter: gridViewLabel.verticalCenter
                    height: 1
                    width: parent.width - gridViewLabel.implicitWidth - units.smallSpacing*4
                    color: "#e5e5e6"
                    opacity: 1
                }

                MouseArea {
                    width: parent.width
                    height: parent.height
                    onClicked: root.toggle();
                }

				//The actual list of search results
                ItemGridViewBack {
                    id: gridView

                    anchors {
                        top: gridViewLabel.bottom
                        topMargin: units.smallSpacing
                    }

                    width: parent.width
                    //height: Math.ceil(count / Math.floor(width / root.tileSide)) * root.tileSide
                    height: gridView.count ? gridView.count * aCellHeight : 0

                    cellWidth:  isSquare ? root.tileSide : aCellWidth
                    cellHeight: isSquare ? root.tileSide : aCellHeight
                    iconSize: root.iconSize
                    square: isSquare
                    //verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                    model: repeater.model.modelForRow(index)

                    onFocusChanged: {
                        if (focus) {
                            itemMultiGrid.focus = true;
                        }
                    }

                    onCountChanged: {
                        if (itemMultiGrid.grabFocus && index == 0 && count > 0) {
                            currentIndex = 0;
                            focus = true;
                        }
                    }

                    onCurrentItemChanged: {
                        if (!currentItem) {
                            return;
                        }

                        if (index == 0 && currentRow() === 0) {
                            itemMultiGrid.flickableItem.contentY = 0;
                            return;
                        }

                        var y = currentItem.y;
                        y = contentItem.mapToItem(itemMultiGrid.flickableItem.contentItem, 0, y).y;

                        if (y < itemMultiGrid.flickableItem.contentY) {
                            itemMultiGrid.flickableItem.contentY = y;
                        } else {
                            y += isSquare ? root.tileSide : aCellHeight;
                            y -= itemMultiGrid.flickableItem.contentY;
                            y -= itemMultiGrid.viewport.height;

                            if (y > 0) {
                                itemMultiGrid.flickableItem.contentY += y;
                            }
                        }
                    }

                    onKeyNavLeft: {
                        itemMultiGrid.keyNavLeft(index);
                    }

                    onKeyNavRight: {
                        itemMultiGrid.keyNavRight(index);
                    }

                    onKeyNavUp: {
                        if (index > 0) {
                            var prevGrid = subGridAt(index - 1);
                            prevGrid.tryActivate(prevGrid.lastRow(), currentCol());
                        } else {
                            itemMultiGrid.keyNavUp();
                        }
                    }

                    onKeyNavDown: {
                        if (index < repeater.count - 1) {
                            subGridAt(index + 1).tryActivate(0, currentCol());
                        } else {
                            itemMultiGrid.keyNavDown();
                        }
                    }
                }

                // HACK: Steal wheel events from the nested grid view and forward them to
                // the ScrollView's internal WheelArea.
                Kicker.WheelInterceptor {
                    anchors.fill: gridView
                    z: 1

                    destination: findWheelArea(itemMultiGrid.flickableItem)
                }
            }
        }
    }
}
