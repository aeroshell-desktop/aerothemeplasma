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

    enabled: !model.disabled && !(model.display === "" || model.display === "Recent Applications")
    visible: !(model.display === "" || model.display === "Recent Applications")
    width: ListView.view.width
    height: model.display === "" || model.display === "Recent Applications" ? 0 : (Kirigami.Units.smallSpacing / (small ? 2 : 1)) + Math.max(elementIcon.height, titleElement.implicitHeight /*+ subTitleElement.implicitHeight*/)

    signal reset
    signal actionTriggered(string actionId, variant actionArgument)
    signal aboutToShowActionMenu(variant actionMenu)
    signal addBreadcrumb(var model, string title)

    property alias toolTip: toolTip
	property bool smallIcon: false
    readonly property int itemIndex: model.index
    readonly property string url: model.url || ""
    readonly property var decoration: model.decoration || ""

    property bool dropEnabled: false
    property bool appView: false
    property bool modelChildren: model.hasChildren || false
    property bool isCurrent: listItem.ListView.view.currentIndex === index;
    property bool showAppsByName: Plasmoid.configuration.showAppsByName

    property bool hasActionList: ((model.favoriteId !== null)
        || (("hasActionList" in model) && (model.hasActionList === true)))
    property Item menu: actionMenu
    //property alias usePlasmaIcon: elementIcon.usesPlasmaTheme

    onAboutToShowActionMenu: (actionMenu) => {
        var actionList = hasActionList ? model.actionList : [];

        Tools.fillActionMenu(i18n, actionMenu, actionList, ListView.view.model.favoritesModel, model.favoriteId);
    }

    onActionTriggered: (actionId, actionArgument) => {
        kicker.expanded = false;

        if (Tools.triggerAction(ListView.view.model, model.index, actionId, actionArgument) === true) {
            kicker.expanded = false;
        }

        /*if (actionId.indexOf("_kicker_favorite_") === 0) {
            switchToInitial();
        }*/
    }

    function activate() {
        var view = listItem.ListView.view;

        if (model.hasChildren) {
            var childModel = view.model.modelForRow(index);

            listItem.addBreadcrumb(childModel, model.display);
            view.model = childModel;
        } else {
            view.model.trigger(model.index, "", null);
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

    Kirigami.Icon {
        id: elementIcon

        anchors {
            left: parent.left
            leftMargin: Kirigami.Units.smallSpacing*2-1
            verticalCenter: parent.verticalCenter
        }
		width: smallIcon ? Kirigami.Units.iconSizes.small : Kirigami.Units.iconSizes.medium
        height: width

        animated: false
        //usesPlasmaTheme: false

        source: model.decoration
    }

    PlasmaComponents.Label {
        id: titleElement

        y: Math.round((parent.height - titleElement.height - ( (subTitleElement.text != "") ? subTitleElement.implicitHeight : 0) ) / 2)
        anchors {
            left: elementIcon.right
            right: arrow.left
            leftMargin: Kirigami.Units.smallSpacing * 2
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
            right: arrow.right
            top: titleElement.bottom
        }
        height: implicitHeight
        color: "#000000"
        text: ""//model.description || ""
        opacity: isCurrent ? 0.8 : 0.6
        font: Kirigami.Theme.smallFont
        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignLeft
    }

    KSvg.SvgItem {
        id: arrow

        anchors {
            right: parent.right
            rightMargin: Kirigami.Units.smallSpacing
            verticalCenter: parent.verticalCenter
        }

        width: visible ? Kirigami.Units.iconSizes.small : 0
        height: width

        visible: (model.hasChildren === true)
        opacity: (listItem.ListView.view.currentIndex === index) ? 1.0 : 0.8

        svg: arrowsSvg
        elementId: (Qt.application.layoutDirection == Qt.RightToLeft) ? "left-arrow-black" : "right-arrow-black"
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Menu && hasActionList) {
            event.accepted = true;
            openActionMenu();
        } else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && !modelChildren) {
            if (!modelChildren) {
                event.accepted = true;
                listItem.activate();
            }
        }
    }
    PlasmaCore.ToolTipArea {
        id: toolTip

        anchors {
            fill: parent
        }

        active: titleElement.truncated
        interactive: false
        /*location: (((Plasmoid.location === PlasmaCore.Types.RightEdge)
        || (Qt.application.layoutDirection === Qt.RightToLeft))
        ? PlasmaCore.Types.RightEdge : PlasmaCore.Types.LeftEdge)*/

        mainText: model.display
    }

}
