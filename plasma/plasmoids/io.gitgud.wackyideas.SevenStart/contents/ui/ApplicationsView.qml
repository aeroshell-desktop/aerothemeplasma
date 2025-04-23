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
import org.kde.plasma.plasmoid
import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

Item {
    id: appViewContainer

    objectName: "ApplicationsView"

    property ListView listView: applicationsView.listView
    property alias currentIndex: applicationsView.currentIndex
    property alias count: applicationsView.count

    function deactivateCurrentIndex() {
        return false;
    }

    onFocusChanged: {
        if(focus) {
            applicationsView.currentIndex = 0;
            applicationsView.positionView();
        }
        else {
            applicationsView.currentIndex = -1;
            applicationsView.clearChildHighlights();
        }
    }

    function decrementCurrentIndex() {
        applicationsView.decrementCurrentIndex();
    }
    Keys.onPressed: event => {
        if(event.key == Qt.Key_Up) {
            applicationsView.decrementCurrentIndex();
        } else if(event.key == Qt.Key_Down) {
            applicationsView.incrementCurrentIndex();
        } else if(event.key == Qt.Key_Return) {
            applicationsView.activateCurrentIndex();
        } else if(event.key == Qt.Key_Menu) {
            applicationsView.openCurrentContextMenu();
        } else if(event.key == Qt.Key_Tab) {
            applicationsView.clearChildHighlights();
            event.accepted = false;
        }
    }
    KeyNavigation.tab: root.m_showAllButton
    function reset() {
        applicationsView.clearBreadcrumbs();
        applicationsView.decrementCurrentIndex();
    }

    function refreshed() {
        reset();
    }

    Connections {
        target: kicker
        function onExpandedChanged() {
            
            if (!kicker.expanded) {
                reset();
            }
        }
    }
    
    ColumnLayout {
        id: columnContainer
        spacing: 0
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: 2
        }


    KickoffListView {
        id: applicationsView
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing+1
		small: true

        property Item activatedItem: null
        property var newModel: null

        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration } }

        focus: true
        appView: true
        model: rootModel

        function clearBreadcrumbs() {
            applicationsView.listView.currentIndex = -1;
        }

        onReset: appViewContainer.reset()


        Component.onCompleted: {
            clearBreadcrumbs();
        }
    }
}

    Component.onCompleted: {
        rootModel.cleared.connect(refreshed);
    }

} // appViewContainer
