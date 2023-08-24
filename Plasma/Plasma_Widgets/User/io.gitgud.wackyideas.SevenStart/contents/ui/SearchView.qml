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
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
    id: searchViewContainer

    objectName: "SearchView"

    function decrementCurrentIndex() {
        runnerModel.decrementCurrentIndex();
    }

    function incrementCurrentIndex() {
        runnerModel.incrementCurrentIndex();
    }

    function activateCurrentIndex() {
        runnerModel.currentItem.activate();
    }

    function openContextMenu() {
        runnerModel.currentItem.openActionMenu();
    }

    function setCurrentIndex() {
        runnerModel.currentIndex = 0;
    }
    function resetCurrentIndex() {
        runnerModel.currentIndex = -1;
    }
    function onQueryChanged() {
            runnerModel.query = searchField.text;

            if (!searchField.text) {
                repeaterModelIndex = 0;
                runnerGrid.repeater.currentModelIndex = 0;
                runnerModel.model = null;
            } else {
                if(runnerGrid.count != 0) {
                    runnerGrid.repeater.currentModelIndex = 0;
                }
            }
    }

    property int repeaterModelIndex: 0
    onFocusChanged: {

        if(runnerGrid.count != 0) {
            if(!focus) repeaterModelIndex = runnerGrid.repeater.currentModelIndex;
            else {
                runnerGrid.repeater.currentModelIndex = repeaterModelIndex;
            }
        }
    }
    property Item itemGrid: runnerGrid


    Kicker.RunnerModel {
        id: runnerModel
        appletInterface: plasmoid
        mergeResults: false
        favoritesModel: globalFavorites
    }

    Connections {
        target: runnerModel

        function onCountChanged() {

            if (runnerModel.count && !runnerGrid.model) {
                runnerGrid.model = runnerModel;
            }
        }
    }

    ItemMultiGridView {
    	id: runnerGrid
    	anchors.fill: parent
    	anchors.leftMargin: units.smallSpacing;
    	z: 9999
    	aCellWidth: parent.width - units.smallSpacing*2
    	aCellHeight: iconSize + units.smallSpacing

    	enabled: searchField.text
    	isSquare: false
    	model: runnerModel
    	grabFocus: true
	}

}
