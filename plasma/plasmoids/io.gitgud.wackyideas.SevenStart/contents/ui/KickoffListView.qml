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
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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

    function clearChildHighlights() {
        for(var i = 0; i < view.count; i++) {
            var it = listView.itemAtIndex(i);
            if(it.expanded) {
                it.childIndex = -1;
            }
        }
    }
    function positionView(toChild) {
        listView.inhibitMouseEvents = true;
        listView.positionViewAtIndex(listView.currentIndex, toChild ? ListView.Visible : ListView.Contain);
        if(toChild) {
            listView.contentY += listView.mapFromItem(listView.currentItem.childItem, 0, 0).y;
            listView.contentY -= listView.verticalOvershoot;
        }
    }
    function activateCurrentIndex() {
        if(listView.currentItem) {
            if(listView.currentItem.expanded && listView.currentItem.childIndex !== -1) {
                listView.currentItem.childItem.activate();
                return;
            }
            listView.currentItem.delegateItem.activate();
        }
    }
    function openCurrentContextMenu() {
        if(listView.currentItem) {
            if(listView.currentItem.expanded && listView.currentItem.childIndex !== -1) {
                listView.currentItem.childItem.openActionMenu();
                return;
            }
            listView.currentItem.delegateItem.openActionMenu();
        }

    }
    function decrementCurrentIndex() {
        var temp;
        if(listView.currentItem) {
            if(listView.currentItem.expanded && listView.currentItem.childIndex !== -1) {
                    temp = listView.currentItem.childIndex - 1;
                    listView.inhibitMouseEvents = true;
                    if(temp <= -1) {
                        listView.currentItem.childItem = null;
                        positionView(false);
                        return;
                    } else {
                        listView.currentItem.childIndex = temp;
                        listView.currentItem.childItem = listView.currentItem.delegateRepeater.itemAt(temp);
                        positionView(true);
                        return;
                    }
            }
        }
        var itemAbove = listView.itemAtIndex(listView.currentIndex-1);
        if(itemAbove) {
            if(itemAbove.expanded) {
                listView.inhibitMouseEvents = true;
                itemAbove.childItem = itemAbove.delegateRepeater.itemAt(itemAbove.childCount-1);
                listView.decrementCurrentIndex();
                positionView(true);
                return;
            }
        }
        temp = listView.currentIndex-1;
        if(temp < 0) {
            return;
        }
        listView.inhibitMouseEvents = true;
        listView.decrementCurrentIndex();
        positionView(false);

    }
    function incrementCurrentIndex() {

        if(listView.currentItem) {
            if(listView.currentItem.expanded/* && listView.currentItem.childIndex !== listView.currentItem.childCount*/) {
                    var temp = listView.currentItem.childIndex + 1;
                    if(temp >= listView.currentItem.childCount) {
                        listView.inhibitMouseEvents = true;
                        listView.currentItem.childIndex = -1;
                    } else {
                        listView.inhibitMouseEvents = true;
                        listView.currentItem.childIndex = temp;
                        listView.currentItem.childItem = listView.currentItem.delegateRepeater.itemAt(temp);
                        listView.inhibitMouseEvents = true;
                        positionView(true);
                        return;
                    }
            }
        }
        var tempIndex = listView.currentIndex+1;
        if(tempIndex >= listView.count) {
            listView.currentIndex = -1;
            root.m_showAllButton.focus = true;
            return;
        }
        listView.inhibitMouseEvents = true;
        listView.incrementCurrentIndex();
        positionView(false);
    }

    Connections {
        function onExpandedChanged() {
            if (!kicker.expanded) {
                listView.positionViewAtContain();
            }
        }

        target: kicker
    }
    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.rightMargin: scrollView.ScrollBar.vertical.visible ? 3 : 0

        ListView {
            id: listView
            property bool inhibitMouseEvents: false
            cacheBuffer: 2500
            move: Transition {}
            moveDisplaced: Transition {}
            displaced: Transition {}
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            focus: true
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            highlightFollowsCurrentItem: false;
            keyNavigationWraps: true
            spacing: view.small ? 0 : Kirigami.Units.smallSpacing / 2
            MouseArea {
                id: mouseInhibitor
                hoverEnabled: true
                anchors.fill: parent
                visible: listView.inhibitMouseEvents
                onPositionChanged: {
                    listView.inhibitMouseEvents = false;
                }
            }
            delegate:
            ColumnLayout {
                id: delegateLayout
                width: listView.width
                required property var model
                required property int index
                property alias delegateItem: delegateItem
                property alias delegateRepeater: colRepeater
                readonly property bool expanded: delegateItem.expanded
                readonly property int childCount: colRepeater.count
                property alias isNew: delegateItem.isNew
                spacing: 0

                property int childIndex: -1
                property var childItem: null
                onChildItemChanged: {
                    if(childItem) childIndex = childItem.itemIndex;
                    else childIndex = -1;
                }

                KickoffItem {
                    id: delegateItem

                    Layout.preferredHeight: implicitHeight
                    Layout.fillWidth: true
                    Layout.rightMargin: scrollView.ScrollBar.vertical.visible ? -3 : 0
                    property var model: delegateLayout.model
                    property int index: delegateLayout.index
                    appView: view.appView
                    showAppsByName: view.showAppsByName
                    smallIcon: view.small
                    listView: listView

                    onReset: view.reset()
                }
                Column {
                    id: expandedColumn
                    Layout.fillWidth: true
                    Layout.rightMargin: scrollView.ScrollBar.vertical.visible ? -3 : 0
                    Layout.preferredHeight: {
                        if(!delegateItem.modelChildren) return 0;
                        return delegateItem.expanded ? colRepeater.count * delegateItem.implicitHeight : 0
                    }
                    visible: delegateItem.expanded
                    Repeater {
                        id: colRepeater
                        model: delegateItem.childModel
                        delegate: KickoffItemChild {
                            required property var model
                            required property int index
                            appView: view.appView
                            showAppsByName: view.showAppsByName
                            smallIcon: view.small
                            onReset: view.reset()
                            listView: listView
                            childModel: delegateItem.childModel
                            parentLayout: delegateLayout
                            width: expandedColumn.width
                        }
                    }
                }
            }

            //section.property: "group"
        }
    }
}
