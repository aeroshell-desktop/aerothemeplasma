/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012 Marco Martin <mart@kde.org>
    Copyright 2014 Sebastian Kügler <sebas@kde.org>
    Copyright (C) 2015-2018  Eike Hein <hein@kde.org>
    Copyright (C) 2016 Jonathan Liu <net147@gmail.com>
    Copyright (C) 2016 Kai Uwe Broulik <kde@privat.broulik.de>

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
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

import org.kde.plasma.plasmoid
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import org.kde.draganddrop

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kirigami as Kirigami

Item {
    property ListView listView: favoritesView.listView
    height: favoritesView.contentHeight

    property int count: favoritesView.count
    /*onFavoritesCountChanged: {
        console.log("AAAHHH " + height + " " + favoritesView.contentHeight);
    }*/
    function activateCurrentIndex() {
        favoritesView.currentItem.delegateItem.activate();
    }
    function decrementCurrentIndex() {
        if (favoritesView.currentIndex == 0)
            return;
        favoritesView.decrementCurrentIndex();
    }
    function getFavoritesCount() {
        return favoritesView.count;
    }
    function incrementCurrentIndex() {
        var tempIndex = favoritesView.currentIndex + 1;
        if (tempIndex >= favoritesView.count) {
            favoritesView.currentIndex = -1;
            if (Plasmoid.configuration.numberRows) {
                root.m_recents.focus = true;
                root.m_recents.currentIndex = 0;
            } else {
                root.m_showAllButton.focus = true;
            }
            return;
        }
        favoritesView.incrementCurrentIndex();
    }

    // QQuickItem::isAncestorOf is not invokable...
    function isChildOf(item, parent) {
        if (!item || !parent) {
            return false;
        }
        if (item.parent === parent) {
            return true;
        }
        return isChildOf(item, item.parent);
    }
    function openContextMenu() {
        favoritesView.currentItem.delegateItem.openActionMenu();
    }
    function resetCurrentIndex() {
        favoritesView.currentIndex = -1;
    }
    function setCurrentIndex() {
        favoritesView.currentIndex = 0;
    }

    KeyNavigation.tab: Plasmoid.configuration.numberRows ? root.m_recents : root.m_showAllButton
    //anchors.fill: parent
    anchors.topMargin: Kirigami.Units.smallSpacing
    objectName: "FavoritesView"

    Keys.onPressed: event => {
        if (event.key == Qt.Key_Up) {
            decrementCurrentIndex();
        } else if (event.key == Qt.Key_Down) {
            incrementCurrentIndex();
        } else if (event.key == Qt.Key_Return) {
            activateCurrentIndex();
        } else if (event.key == Qt.Key_Menu) {
            openContextMenu();
        }
    }
    onFocusChanged: {
        if (focus)
            setCurrentIndex();
        else
            resetCurrentIndex();
    }

    Rectangle {
        id: dragIndicator
        height: 1
        color: "#ababab"
        width: parent.width - Kirigami.Units.largeSpacing*2
        visible: dropArea.containsDrag
    }
    DropArea {
        id: dropArea
        function syncTarget(event) {
            if (favoritesView.animating) {
                return;
            }
            var pos = mapToItem(listView.contentItem, event.x, event.y);
            var above = listView.itemAt(pos.x, pos.y);
            var source = kicker.dragSource;
            if (above && above !== source && isChildOf(source, favoritesView)) {
                favoritesView.model.moveRow(source.itemIndex, above.index);
                // itemIndex changes directly after moving,
                // we can just set the currentIndex to it then.
                favoritesView.currentIndex = source.itemIndex;
            }
        }

        anchors.fill: parent
        enabled: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable

        onDrop: event => {
            syncTarget(event);
        }
        onDragMove: event => {
            var pos = mapToItem(listView.contentItem, event.x, event.y);
            var above = listView.itemAt(pos.x, pos.y);
            if (above) {
                dragIndicator.x = above.x + Kirigami.Units.largeSpacing
                dragIndicator.y = above.y + (kicker.dragSource.itemIndex >= above.index ? 0 : above.height)
            }
        }
    }
    Transition {
        id: moveTransition

        SequentialAnimation {
            PropertyAction {
                property: "animating"
                target: favoritesView
                value: true
            }
            NumberAnimation {
                duration: favoritesView.animationDuration
                easing.type: Easing.OutQuad
                properties: "x, y"
            }
            PropertyAction {
                property: "animating"
                target: favoritesView
                value: false
            }
        }
    }
    Connections {
        function onExpandedChanged() {
            if (!kicker.expanded) {
                favoritesView.currentIndex = -1;
            }
        }

        target: kicker
    }
    KickoffListView {
        id: favoritesView

        property bool animating: false
        property int animationDuration: resetAnimationDurationTimer.interval

        anchors.fill: parent
        interactive: contentHeight > height
        model: globalFavorites
        //move: moveTransition
        //moveDisplaced: moveTransition

        onCountChanged: {
            animationDuration = 0;
            resetAnimationDurationTimer.start();
        }
    }
    Timer {
        id: resetAnimationDurationTimer

        interval: 150

        onTriggered: favoritesView.animationDuration = interval - 20
    }
}
