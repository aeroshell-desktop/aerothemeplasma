/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012  Gregor Taetzner <gregor@freenet.de>
    Copyright 2014 Sebastian Kügler <sebas@kde.org>
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

//This is the generic item delegate used by FavoritesView, RecentlyUsedView and SearchView. 

import QtQuick 2.0
import org.kde.plasma.plasmoid
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.draganddrop 2.0

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

import "code/tools.js" as Tools

Item {
    id: listItem

    enabled: !model.disabled && !(model.display === "")
    visible: !(model.display === "")
    width: parentLayout.width
    implicitHeight: model.display === "" ? 0 : ((Kirigami.Units.smallSpacing / (small ? 2 : 1)) + Math.max(elementIcon.height, titleElement.implicitHeight) + (small ? 1 : 0))

    property int pressX: -1
    property int pressY: -1
    signal reset
    signal actionTriggered(string actionId, variant actionArgument)
    signal aboutToShowActionMenu(variant actionMenu)
    signal addBreadcrumb(var model, string title)

    property alias toolTip: toolTip
    property alias toolTipTimer: toolTipTimer
	property bool smallIcon: true
    readonly property int itemIndex: model.index
    readonly property string url: model.url || ""
    readonly property var decoration: model.decoration || ""

    property bool dropEnabled: false
    property bool appView: false
    property bool modelChildren: model.hasChildren || false
    property bool isCurrent: parentLayout.childItem === listItem;
    property bool showAppsByName: Plasmoid.configuration.showAppsByName

    property bool hasActionList: ((model.favoriteId !== null)
        || (("hasActionList" in model) && (model.hasActionList === true)))
    property Item menu: actionMenu

    property bool expanded: listItem.parentLayout.delegateItem.expanded
    property var childModel
    property var listView
    property var parentLayout

    onAboutToShowActionMenu: (actionMenu) => { // Loads context menu items here
        var actionList = hasActionList ? model.actionList : [];
        if(model.favoriteId) { // If we have a launchable application, try allowing the user to pin it
            // Find seventasks instance, if available
            const entry = "applications:" + model.favoriteId; //kicker.convertUrl(model.url);
            var panel = kicker.parent;
            while(panel !== null && typeof panel.sevenTasksReference === "undefined") { // Find seventasks loader reference from the panel
                panel = panel.parent;
            }
            if(panel.sevenTasksReference) { // If found, add the pin/unpin menu item
                const unpin = (panel.sevenTasksReference.applet.findTask(entry) !== -1);
                var pinAction = {   // Add custom action
                                    icon: "pin",
                                    actionId: "pinToTasks",
                                    text: unpin ? i18n("Unpin from taskbar") : i18n("Pin to taskbar"),
                                    action: () => {
                                        if(unpin) {
                                            panel.sevenTasksReference.applet.unpinTask(entry);
                                        } else {
                                            panel.sevenTasksReference.applet.pinTask(entry);
                                        }
                                }};
                actionList = [...actionList, pinAction]; // Use spread operator and pass that to the fillActionMenu function
            }
        }
        Tools.fillActionMenu(i18n, actionMenu, actionList, listItem.listView.model.favoritesModel, model.favoriteId);
    }

    onActionTriggered: (actionId, actionArgument) => {
        kicker.expanded = false;

        if (Tools.triggerAction(listItem.childModel, model.index, actionId, actionArgument) === true) {
            kicker.expanded = false;
        }
    }

    function activate() {
        var view = listView;

        if (model.hasChildren) {
            childModel = view.model.modelForRow(index);
            listItem.expanded = !listItem.expanded;
        } else {
            childModel.trigger(model.index, "", null);
            listItem.reset();
            Plasmoid.expanded = false;
        }
    }

    function openActionMenu(x, y) {
        aboutToShowActionMenu(actionMenu);
        if(actionMenu.actionList.length === 0) return;
        actionMenu.visualParent = listItem;
        actionMenu.open(x, y);
    }

    ActionMenu {
        id: actionMenu

        onActionClicked: (actionId, actionArgument) => {
            actionTriggered(actionId, actionArgument);
        }
    }

    KSvg.FrameSvgItem {
        id: newHighlight

        anchors.fill: background

        imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
        prefix: "new"

        visible: model?.isNewlyInstalled ?? false

        Rectangle {
            anchors.fill: parent

            color: "#ffe599"

            visible: listItem.smallIcon
        }
    }

    KSvg.FrameSvgItem {
        id: background
        imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
        prefix: "hover"
        opacity: {
            if(ma.containsMouse) return 1;
            if(listItem.parentLayout.childIndex === model.index) return 0.5;
            return 0;
        }
        anchors {
            fill: parent
            leftMargin: listItem.smallIcon ? Kirigami.Units.smallSpacing/2+1 : Kirigami.Units.smallSpacing
            rightMargin: listItem.smallIcon ? Kirigami.Units.smallSpacing/2+1 : Kirigami.Units.smallSpacing

        }
    }

    Kirigami.Icon {
        id: elementIcon

        anchors {
            left: parent.left
            leftMargin: Kirigami.Units.largeSpacing*3
            verticalCenter: parent.verticalCenter
        }
		width: smallIcon ? Kirigami.Units.iconSizes.small : Kirigami.Units.iconSizes.medium
        height: width

        animated: false

        source: model.decoration
    }

    PlasmaComponents.Label {
        id: titleElement

        y: Math.round((parent.height - titleElement.height - ( (subTitleElement.text != "") ? subTitleElement.implicitHeight : 0) ) / 2)
        anchors {
            left: elementIcon.right
            right: parent.right
            leftMargin: Kirigami.Units.mediumSpacing-1
            rightMargin: Kirigami.Units.smallSpacing * 2
        }
        height: implicitHeight //undo PC2 height override, remove when porting to PC3
        // TODO: games should always show the by name!
        text: model.display
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        color: "#000000"
    }

    PlasmaComponents.Label {
        id: subTitleElement

        anchors {
            left: titleElement.left
            right: parent.right
            top: titleElement.bottom
        }
        height: implicitHeight
        color: "#000000"
        text: ""//model.description || ""
        opacity: listItem.isCurrent ? 0.8 : 0.6
        font: Kirigami.Theme.smallFont
        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignLeft
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Menu && hasActionList) {
            event.accepted = true;
            openActionMenu();
        } else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
            event.accepted = true;
            listItem.activate();
        }
    }
    PlasmaCore.ToolTipArea {
        id: toolTip

        anchors.fill: parent
        active: titleElement.truncated
        interactive: false
        mainText: model.display
        location: {
            var result = PlasmaCore.Types.Floating
            if(ma.containsMouse) result |= PlasmaCore.Types.Desktop;
            return result;
        }

    }

    onIsCurrentChanged: {
        if(isCurrent && !ma.containsMouse) {
            toolTipTimer.start();
        } else {
            toolTipTimer.stop();
            toolTip.hideImmediately();
        }
    }
    Timer {
        id: toolTipTimer
        interval: Kirigami.Units.longDuration*2
        onTriggered: {
            toolTip.showToolTip();
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            if(listItem.parentLayout.childItem && listItem.parentLayout.childItem === listItem) {
                listItem.parentLayout.childItem.toolTipTimer.stop();
                listItem.parentLayout.childItem.toolTip.hideToolTip();
            }
            listItem.parentLayout.childItem = listItem;
            Qt.callLater(() => toolTipTimer.start());
        }
        onExited: {
            toolTipTimer.stop();
            toolTip.hideToolTip();
            listItem.parentLayout.childItem = null;
            listItem.pressX = -1;
            listItem.pressY = -1;
        }
        onPressed: mouse => {
            if(mouse.button === Qt.LeftButton) {
                listItem.pressX = mouse.x;
                listItem.pressY = mouse.y;
            }

        }
        onPositionChanged: mouse => {
                if(listItem.pressX != -1 && model.url && dragHelper.isDrag(listItem.pressX, listItem.pressY, mouse.x, mouse.y)) {
                    kicker.dragSource = listItem;
                    dragHelper.dragIconSize = Kirigami.Units.iconSizes.small;
                    dragHelper.startDrag(kicker, model.url, model.decoration);
                }
        }
        onReleased: mouse => {
            if(mouse.button === Qt.LeftButton) {
                if (mouse.source == Qt.MouseEventSynthesizedByQt) {
                    positionChanged(mouse);
                }
                listItem.pressX = -1;
                listItem.pressY = -1;
            }
        }
        onClicked: mouse => {
            if(mouse.button === Qt.LeftButton) {
                listItem.activate();
                root.visible = false;
            } else if(mouse.button === Qt.RightButton) {
                if(listItem.hasActionList) {
                    listItem.openActionMenu(mouse.x, mouse.y);
                }
            }
        }

    }
}
