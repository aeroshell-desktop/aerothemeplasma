/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012  Gregor Taetzner <gregor@freenet.de>
    Copyright (C) 2015-2018  Eike Hein <hein@kde.org>

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
import QtQuick.Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

FocusScope {
    id: view

    property bool recentsView: false
    property bool appView: false
    property alias contentHeight: listView.contentHeight
    property alias count: listView.count
    property alias currentIndex: listView.currentIndex
    property alias currentItem: listView.currentItem
    property alias delegate: listView.delegate
    property alias interactive: listView.interactive
    readonly property Item listView: listView
    property alias model: listView.model
    property alias move: listView.move
    property alias moveDisplaced: listView.moveDisplaced
    readonly property Item scrollView: scrollView
    property bool showAppsByName: true
    property bool small: false

    signal addBreadcrumb(var model, string title)
    signal reset

    function decrementCurrentIndex() {
        listView.decrementCurrentIndex();
    }
    function incrementCurrentIndex() {
        listView.incrementCurrentIndex();
    }

    Connections {
        function onExpandedChanged() {
            if (!kicker.expanded) {
                listView.positionViewAtBeginning();
            }
        }

        target: kicker
    }
    Timer {
        id: toolTipTimer
        interval: Kirigami.Units.longDuration*4
        onTriggered: {
            if(listView.currentItem) listView.currentItem.toolTip.showToolTip();
        }
    }
    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.rightMargin: scrollView.ScrollBar.vertical.visible ? 3 : 0

        ListView {
            id: listView

            move: Transition {}
            moveDisplaced: Transition {}
            displaced: Transition {}
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            focus: true
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            keyNavigationWraps: true
            spacing: small ? 0 : Kirigami.Units.smallSpacing / 2

            delegate: KickoffItem {
                id: delegateItem

                required property var model
                required property int index
                appView: view.appView
                showAppsByName: view.showAppsByName
                smallIcon: small

                onAddBreadcrumb: (model, title) => view.addBreadcrumb(model, title)
                onReset: view.reset()
            }
            highlight: KickoffHighlight {
            }

            section.property: "group"

            MouseArea {
                id: mouseArea

                property Item selectedItem: null
                property int pressX: -1
                property int pressY: -1
                property bool tapAndHold: false

                acceptedButtons: Qt.LeftButton | Qt.RightButton
                anchors.left: parent.left
                height: parent.height
                hoverEnabled: true
                width: scrollView.width

                onContainsMouseChanged: {
                    if (!containsMouse) {
                        //pressed = null;
                        toolTipTimer.stop();
                        if(listView.currentItem) listView.currentItem.toolTip.hideToolTip();
                        pressX = -1;
                        pressY = -1;
                        tapAndHold = false;
                        listView.currentIndex = -1;
                    }
                }
                onPositionChanged: mouse => {
                    if (mouse.source != Qt.MouseEventSynthesizedByQt) {
                        if (selectedItem && pressX != -1 && selectedItem.model.url && dragHelper.isDrag(pressX, pressY, mouse.x, mouse.y)) {
                            kicker.dragSource = selectedItem;
                            dragHelper.dragIconSize = Kirigami.Units.iconSizes.medium;
                            dragHelper.startDrag(kicker, selectedItem.model.url, selectedItem.model.icon);
                            pressX = -1;
                            pressY = -1;
                            tapAndHold = false;
                        }
                    }
                    var mapped = listView.mapToItem(listView.contentItem, mouse.x, mouse.y);
                    var item = listView.itemAt(mapped.x, mapped.y);
                    if (item) {
                        toolTipTimer.stop();
                        if(listView.currentItem) listView.currentItem.toolTip.hideToolTip();
                        listView.currentIndex = item.itemIndex;
                        toolTipTimer.start();
                    } else {
                        listView.currentIndex = -1;
                    }
                }
                onPressed: function(mouse) {
                    var mapped = listView.mapToItem(listView.contentItem, mouse.x, mouse.y);
                    var item = listView.itemAt(mapped.x, mapped.y);
                    if (!item) {
                        return;
                    }
                    if (mouse.buttons & Qt.RightButton) {
                        if (item.hasActionList) {
                            mapped = listView.contentItem.mapToItem(item, mapped.x, mapped.y);
                            listView.currentItem.openActionMenu(mapped.x, mapped.y);
                        }
                    } else {
                        selectedItem = item;
                        pressX = mouse.x;
                        pressY = mouse.y;
                    }
                }
                onReleased: function(mouse) {
                    var mapped = listView.mapToItem(listView.contentItem, mouse.x, mouse.y);
                    var item = listView.itemAt(mapped.x, mapped.y);
                    if (item && !tapAndHold) {
                        if (item.appView) {
                            if (mouse.source == Qt.MouseEventSynthesizedByQt) {
                                positionChanged(mouse);
                            }
                            view.state = "OutgoingLeft";
                        } else {
                            item.activate();
                            root.visible = false;
                        }
                        listView.currentIndex = -1;
                    }
                    if (tapAndHold && mouse.source == Qt.MouseEventSynthesizedByQt) {
                        if (item.hasActionList) {
                            mapped = listView.contentItem.mapToItem(item, mapped.x, mapped.y);
                            listView.currentItem.openActionMenu(mapped.x, mapped.y);
                        }
                    }
                    selectedItem = null;
                    pressX = -1;
                    pressY = -1;
                    tapAndHold = false;
                }
            }
        }
    }
}
