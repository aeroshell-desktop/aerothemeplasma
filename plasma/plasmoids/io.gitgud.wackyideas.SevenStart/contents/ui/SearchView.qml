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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.private.kicker as Kicker

import org.kde.kirigami as Kirigami

Item {
    id: searchViewContainer

    property Item itemGrid: runnerGrid
    property bool queryFinished: false
    property int repeaterModelIndex: 0

    function inhibitMouse() {
        runnerGrid.inhibitMouseEvents = 2;
    }
    function activateCurrentIndex() {
        runnerGrid.tryActivate();
    }
    function decrementCurrentIndex() {
        inhibitMouse();
        var listView = runnerGrid.flickableItem;
        if(listView.currentIndex-1 < 0) {
            listView.currentIndex = listView.count - 1;
        } else {
            listView.currentIndex--;
        }
    }
    function incrementCurrentIndex() {
        inhibitMouse();
        var listView = runnerGrid.flickableItem;
        if(listView.currentIndex+1 >= listView.count) {
            listView.currentIndex = 0;
        } else {
            listView.currentIndex++;
        }
    }
    function onQueryChanged() {
        queryFinished = false;
        runnerModel.query = searchField.text;
        if (!searchField.text) {
            if (runnerModel.model)
                runnerModel.model = null;
        }
    }
    function openContextMenu() {
        runnerModel.currentItem.openActionMenu();
    }

    objectName: "SearchView"

    Connections {
        function onCountChanged() {
            if (runnerModel.count && !runnerGrid.model) {
                runnerGrid.model = runnerModel.modelForRow(0);
            }
        }
        function onQueryFinished() {
            if (runnerModel.count) {
                runnerGrid.model = null;
                runnerGrid.model = runnerModel.modelForRow(0);
                queryFinished = true;
                var listView = runnerGrid.flickableItem;
                if(listView.count > 0) listView.currentIndex = 0;
                //console.log(runnerModel.modelForRow(0).modelForRow(0))
            }
        }

        target: runnerModel
    }

    NavGrid {
        id: runnerGrid
        anchors.fill: parent
        property alias model: runnerGrid.triggerModel
        triggerModel: kicker.runnerModel.count ? kicker.runnerModel.modelForRow(0) : null
        MouseArea {
            id: mouseInhibitor
            anchors.fill: parent
            z: 99
            hoverEnabled: true
            visible: runnerGrid.inhibitMouseEvents > 0
            onPositionChanged: {
                if(runnerGrid.inhibitMouseEvents > 0)
                    runnerGrid.inhibitMouseEvents--;
            }
        }

    }


}
