/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012 Marco Martin <mart@kde.org>
    Copyright (C) 2015  Eike Hein <hein@kde.org>
    Copyright (C) 2017  Ivan Cukic <ivan.cukic@kde.org>

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
import org.kde.plasma.components as PlasmaComponents
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.plasmoid

import org.kde.plasma.private.kicker 0.1 as Kicker

import org.kde.draganddrop 2.0


Item {
    property alias model: baseView.model
    property alias delegate: baseView.delegate
    property alias currentIndex: baseView.currentIndex;
    property alias count: baseView.count;
    height: baseView.contentHeight

    objectName: "OftenUsedView"
    property ListView listView: baseView.listView

    function decrementCurrentIndex() {
        var tempIndex = baseView.currentIndex-1;
        if(tempIndex < 0) {
            baseView.currentIndex = -1;
            root.m_faves.focus = true;
            root.m_faves.listView.currentIndex = root.m_faves.listView.count-1;
            return;
        }
        baseView.decrementCurrentIndex();
    }
    KeyNavigation.tab: root.m_showAllButton

    function incrementCurrentIndex() {
        var tempIndex = baseView.currentIndex+1;
        if(tempIndex >= baseView.count) {
            baseView.currentIndex = -1;
            root.m_showAllButton.focus = true;
            return;
        }
        baseView.incrementCurrentIndex();

    }

    function activateCurrentIndex() {

        baseView.currentItem.delegateItem.activate();
    }

    function openContextMenu() {
        baseView.currentItem.delegateItem.openActionMenu();
    }

    function setCurrentIndex() {
        baseView.currentIndex = 0;
    }
    function resetCurrentIndex() {
        baseView.currentIndex = -1;
    }
    Connections {
        target: Plasmoid

        function onExpandedChanged() {
            if (!Plasmoid.expanded) {
                baseView.currentIndex = -1;
            }
        }
    }
    /*
     * The KSortFilterProxyModel has a nasty behavior (with this particular
     * source model) where only the first row will be updated (twice instantly),
     * which invalidates the index list. In that case, we want a full update
     * instead of a partial update, so the filtering can update the index map.
     */
    Timer {
        id: refreshTimer
        interval: 50
        onTriggered: {
            Qt.callLater(() => { recentUsageModel.refresh()});
        }
    }

    KickoffListView {
        id: baseView

        anchors.fill: parent

        recentsView: true
        currentIndex: -1
        interactive: contentHeight > height
        //model: recentUsageModel //rootModel.modelForRow(0)
        model: KItemModels.KSortFilterProxyModel {
            id: sortModel
            sourceModel: recentUsageModel
            property var favoritesModel: globalFavorites
            property int favoritesCount: sourceModel.favoritesModel.count
            property int favoritesFound: 0
            /*
             * Because the trigger function relies on the original model's
             * index values, we need a way to map the index values from the filtered
             * model to the values from the source model.
             */
            property list<int> originalIndexList
            onFavoritesCountChanged: Qt.callLater(() => { sourceModel.refresh()});
            onCountChanged: Qt.callLater(() => {
                if(count > Plasmoid.configuration.numberRows) sourceModel.refresh();
            })
            function trigger(index, str, ptr) {
                if(typeof originalIndexList[index] !== "undefined") {
                    sourceModel.trigger(originalIndexList[index], str, ptr);
                }
            }
            filterRowCallback: function(source_row, source_parent) {
                if(source_row == 0) {
                    refreshTimer.start();
                    originalIndexList.length = 0;
                    favoritesFound = 0;
                } else {
                    refreshTimer.stop();
                }
				const FavoriteIdRole = sourceModel.KItemModels.KRoleNames.role("favoriteId");
				const favoriteId = sourceModel.data(sourceModel.index(source_row, 0, source_parent), FavoriteIdRole);
                var hasFavorite = favoritesIds.idList.indexOf(favoriteId) === -1
                if(!hasFavorite) favoritesFound++;
                var shouldAccept = hasFavorite && source_row < (Plasmoid.configuration.numberRows+favoritesFound);
                if(shouldAccept) {
                    originalIndexList.push(source_row);
                }
                return shouldAccept;// - sourceModel.favoritesModel.count;
            };

        }
    }


    onFocusChanged: {
        if(focus) setCurrentIndex();
        else resetCurrentIndex();
    }
    Keys.onPressed: event => {
        if(event.key == Qt.Key_Up) {
            decrementCurrentIndex();
        } else if(event.key == Qt.Key_Down) {
            incrementCurrentIndex();
        } else if(event.key == Qt.Key_Return) {
            activateCurrentIndex();
        } else if(event.key == Qt.Key_Menu) {
            openContextMenu();
        }
    }
}
