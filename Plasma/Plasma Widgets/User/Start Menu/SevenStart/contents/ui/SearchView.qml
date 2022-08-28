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

    //anchors.fill: parent

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
    function onQueryChanged() {
            runnerModel.query = searchField.text;
            //searchView.currentIndex = 0;

            if (!searchField.text) {
                runnerModel.model = null;
            }
    }

    Kicker.RunnerModel {
        id: runnerModel
        appletInterface: plasmoid
        mergeResults: false
        favoritesModel: globalFavorites
    }

    /*Connections {
        target: searchField

        
    }*/

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

                    //enabled: (opacity == 1.0) ? 1 : 0
                    enabled: searchField.text
                    isSquare: false
                    model: runnerModel
                    grabFocus: true
                    //opacity: searching ? 1.0 : 0.0
                    /*onOpacityChanged: {
                        if (opacity == 1.0) {
                            mainColumn.visibleGrid = runnerGrid;
                        }
                    }*/
                    //onKeyNavRight: globalFavoritesGrid.tryActivate(0,0)
                }

    /*KickoffSearchView {
        id: searchView

        anchors.fill: parent

        showAppsByName: false //krunner results have the most relevant field in the "display" column, which is showAppsByName = false
    }*/
}
