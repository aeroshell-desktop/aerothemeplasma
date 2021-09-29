/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons // kuser
import org.kde.plasma.private.shell 2.0

import org.kde.kwindowsystem 1.0
import QtGraphicalEffects 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.quicklaunch 1.0


import QtQuick.Dialogs 1.2

PlasmaCore.Dialog {
    id: root
    objectName: "popupWindow"
    flags: Qt.WindowStaysOnTopHint
    location: PlasmaCore.Types.BottomEdge
    //clip: true
    hideOnWindowDeactivate: true
    property int iconSize: units.iconSizes.medium
    property int iconSizeSide: units.iconSizes.smallMedium
    property int cellWidth: units.gridUnit * 15
    property int cellWidthSide: units.gridUnit * 9
    property int cellHeight: iconSize +  ( Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                                    highlightItemSvg.margins.left + highlightItemSvg.margins.right))
    property bool searching: (searchField.text != "")
    property bool showingAllPrograms: false

    onVisibleChanged: {
        if (!visible) {
            reset();
        } else {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
            requestActivate();
        }
    }

    onHeightChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }

    onWidthChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }

    onSearchingChanged: {
        if (searching) {
            //pageList.model = runnerModel;

        } else {
            reset();
        }
    }

    function reset() {
        if (!searching) {
            //pageList.model = rootModel.modelForRow(0);
            //pageList.currentIndex = 1;
        }
        searchField.text = "";
        //pageListScrollArea.focus = true;
        //pageList.currentItem.itemGrid.currentIndex = -1;
    }

    function popupPosition(width, height) {
        var screenAvail = plasmoid.availableScreenRect;
        var screenGeom = plasmoid.screenGeometry;
        //QtBug - QTBUG-64115
        var screen = Qt.rect(screenAvail.x + screenGeom.x,
                             screenAvail.y + screenGeom.y,
                             screenAvail.width,
                             screenAvail.height);

        var offset = -5;//units.smallSpacing;

        // Fall back to bottom-left of screen area when the applet is on the desktop or floating.
        var x = offset;
        var y = screen.height - height - offset;
        var horizMidPoint;
        var vertMidPoint;
        var appletTopLeft;
        if (plasmoid.location === PlasmaCore.Types.BottomEdge) {
            horizMidPoint = screen.x + (screen.width / 2);
            appletTopLeft = parent.mapToGlobal(0, 0);
            x = (appletTopLeft.x < horizMidPoint) ? screen.x + offset : (screen.x + screen.width) - width - offset;
            y = screen.height - height - offset;// - panelSvg.margins.top;
        } else if (plasmoid.location === PlasmaCore.Types.TopEdge) {
            horizMidPoint = screen.x + (screen.width / 2);
            var appletBottomLeft = parent.mapToGlobal(0, parent.height);
            x = (appletBottomLeft.x < horizMidPoint) ? screen.x + offset : (screen.x + screen.width) - width - offset;
            y = parent.height;// + panelSvg.margins.bottom + offset;
        } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
            vertMidPoint = screen.y + (screen.height / 2);
            appletTopLeft = parent.mapToGlobal(0, 0);
            x = parent.width;// + panelSvg.margins.right + offset;
            y = (appletTopLeft.y < vertMidPoint) ? screen.y + offset : (screen.y + screen.height) - height - offset;
        } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
            vertMidPoint = screen.y + (screen.height / 2);
            appletTopLeft = parent.mapToGlobal(0, 0);
            x = appletTopLeft.x;// - panelSvg.margins.left - offset - width;
            y = (appletTopLeft.y < vertMidPoint) ? screen.y + offset : (screen.y + screen.height) - height - offset;
        }

        return Qt.point(x, y);
    }
    FocusScope {
        
        //clip: true
        Layout.minimumWidth:  root.cellWidth + root.cellWidthSide// + units.smallSpacing*3
        Layout.maximumWidth:  root.cellWidth + root.cellWidthSide// + units.smallSpacing*3
        Layout.minimumHeight: (cellHeight * plasmoid.configuration.numberRows) + searchField.height +  units.iconSizes.smallMedium
        Layout.maximumHeight: (cellHeight * plasmoid.configuration.numberRows) + searchField.height +  units.iconSizes.smallMedium
        
        focus: true

        KCoreAddons.KUser {   id: kuser  }
        Logic {   id: logic }
        
        Connections {
        target: plasmoid.configuration
            onNumberRowsChanged: {
                recents.model = rootModel.modelForRow(0);
            }
        }

        PlasmaCore.DataSource {
            id: pmEngine
            engine: "powermanagement"
            connectedSources: ["PowerDevil", "Sleep States"]
            function performOperation(what) {
                var service = serviceForSource("PowerDevil")
                var operation = service.operationDescription(what)
                service.startOperationCall(operation)
            }
        }

        PlasmaCore.DataSource {
            id: executable
            engine: "executable"
            connectedSources: []
            onNewData: {
                var exitCode = data["exit code"]
                var exitStatus = data["exit status"]
                var stdout = data["stdout"]
                var stderr = data["stderr"]
                exited(sourceName, exitCode, exitStatus, stdout, stderr)
                disconnectSource(sourceName)
            }
            function exec(cmd) {
                if (cmd) {
                    connectSource(cmd)
                }
            }
            signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
        }

        PlasmaComponents.Highlight {
            id: delegateHighlight
            visible: false
            z: -1 // otherwise it shows ontop of the icon/label and tints them slightly
        }

        PlasmaExtras.Heading {
            id: dummyHeading
            visible: false
            width: 0
            level: 5
        }

        TextMetrics {
            id: headingMetrics
            font: dummyHeading.font
        }

        ActionMenu {
            id: actionMenu
            onActionClicked: visualParent.actionTriggered(actionId, actionArgument)
            onClosed: {
                /*if (pageList.currentItem) {
                    pageList.currentItem.itemGrid.currentIndex = -1;
                }*/
            }
        }


        
        Rectangle {
                id: backgroundRect
                //anchors.fill: pageListScrollArea
                anchors.top: faves.top
                anchors.topMargin: -4
                anchors.left: faves.left
                //anchors.leftMargin: units.smallSpacing
                width:  root.cellWidth
                height: (root.cellHeight * plasmoid.configuration.numberRows)  + searchBackground.height + 4
                color: "white"
                border.color: "#44000000"
                border.width: 1
                radius: 3
                z: 5
                Behavior on width {
                    NumberAnimation { easing.type: Easing.Linear; duration: 150 }
            //NumberAnimation { duration: 1000 }
                }
                 Rectangle {
                     id: backgroundBorderLine
                color: "#cddbea"
                radius: 3
                 anchors { 
                    top: searchBackground.top
                    topMargin: 1
                    //bottomMargin: units.smallSpacing
                    left: parent.left
                    leftMargin: 1
                    
                }
                width: backgroundRect.width-2
                height: 2
                //height: backgroundRect
                z: 5
                
        }
        Rectangle {
                id: searchBackground
                 Behavior on width {
                    NumberAnimation { easing.type: Easing.Linear; duration: 150 }
            //NumberAnimation { duration: 1000 }
                }
                color: "#F3F7FB"
                radius: 3
                anchors { 
                    bottom: parent.bottom 
                    bottomMargin: units.smallSpacing-2
                    left: parent.left
                    leftMargin: 1
                }
                width: root.cellWidth - 2
                height: searchField.height + units.smallSpacing * 4.5
            }
            }
        FavoritesView {
            id: faves
            anchors.left: parent.left
            anchors.top: parent.top
            //anchors.bottom: pageListScrollAreabottom
            //anchors.right: pageListScrollArea.right
            width: root.cellWidth
            height: plasmoid.configuration.showRecentsView ? ((root.cellHeight * (faves.getFavoritesCount() > 9 ? 9 : faves.getFavoritesCount())) - units.smallSpacing * 2) : (root.cellHeight * plasmoid.configuration.numberRows - units.smallSpacing*2 - allProgramsButton.height - allProgramsSeparator.height)
            visible: !showingAllPrograms && !searching
            z: 8
        }
        Rectangle {
        id: tabBarSeparator
        anchors.top: faves.bottom
        anchors.topMargin: units.smallSpacing
        anchors.left: parent.left
        anchors.leftMargin: units.smallSpacing*4
        anchors.right: faves.right
        anchors.rightMargin: units.smallSpacing*4
        
        height: 1
        color: "#d6e5f5"
        opacity: 1
        visible: plasmoid.configuration.showRecentsView && (!showingAllPrograms && !searching)
        z: 6
        
        }
        OftenUsedView {
            id: recents
            anchors.left: parent.left
            anchors.top: faves.bottom
            anchors.topMargin: units.smallSpacing*2
            anchors.bottomMargin: units.smallSpacing
            width: root.cellWidth
            height: (root.cellHeight * plasmoid.configuration.numberRows) - (root.cellHeight * (faves.getFavoritesCount() > 9 ? 9 : faves.getFavoritesCount())) - units.smallSpacing*2 - allProgramsButton.height
            visible: plasmoid.configuration.showRecentsView && (!showingAllPrograms && !searching)
            z: 8
        }
        Rectangle {
        id: allProgramsSeparator
        anchors.top: plasmoid.configuration.showRecentsView ? recents.bottom : faves.bottom
        //anchors.topMargin: units.smallSpacing
        anchors.left: parent.left
        anchors.leftMargin: units.smallSpacing*4
        //anchors.right: faves.right
        anchors.rightMargin: units.smallSpacing*4
        width: root.cellWidth - units.smallSpacing*8
        Behavior on width {
                    NumberAnimation { easing.type: Easing.Linear; duration: 150 }
                }
        height: 1
        color: "#d6e5f5"
        opacity: 1
        //visible: !showingAllPrograms && !searching
        z: 6
        
        }
         MouseArea {
                id: allButtonsArea
                hoverEnabled: true
                anchors.top: plasmoid.configuration.showRecentsView ? recents.bottom : faves.bottom
                anchors.topMargin: units.smallSpacing
                anchors.left: parent.left
                anchors.leftMargin: units.smallSpacing
                anchors.rightMargin: units.smallSpacing
                onClicked: {
                    if(searching)
                    {
                        searchField.text = "";
                        //searching = false;
                        console.log("stopped searching");
                    }
                    else if(showingAllPrograms)
                    {
                        showingAllPrograms = false;
                        appsView.reset();
                        console.log("showing normal view");
                    }
                    else if(!searching && !showingAllPrograms)
                    {
                        showingAllPrograms = true;
                        console.log("showing all apps");
                    }
                }
                height: 25
                width: root.cellWidth - units.smallSpacing*2
                Behavior on width {
                    NumberAnimation { easing.type: Easing.Linear; duration: 150 }
                }
                z: 8
                PlasmaCore.FrameSvgItem {
                        id : allProgramsButton
                        
                
        
        //visible: true
        anchors.fill: parent
        imagePath: "widgets/viewitem"
        
        prefix: "hover"
        visible: allButtonsArea.containsMouse ? true : false
        //z:7
       
        
            
        }
        PlasmaCore.SvgItem {
            id: arrowDirection
            svg: arrowsSvg
            elementId: (searching || showingAllPrograms) ? "left-arrow" : "right-arrow"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: units.smallSpacing
            width: 16
            height: 16
            Colorize {
                    anchors.fill: arrowDirection
                    source: arrowDirection
                    hue: 0.0
                    saturation: 0.0
                    lightness: -0.6
            }
        }
            Text {
                            text: showingAllPrograms || searching ? "Back" : "All programs"
                            font.pixelSize: 12
                            //color: searching ? "#202020" : "white"
                            anchors.left: arrowDirection.right
                            anchors.leftMargin: units.smallSpacing
                            //anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
            }
            
        }
        
        
        SearchView {
            id: searchView
            anchors.top: parent.top
            anchors.topMargin: units.smallSpacing*2 -4
            anchors.left: parent.left
            anchors.right: parent.right
            //anchors.rightMargin: units.smallSpacing -2
            anchors.bottom: allProgramsSeparator.top
            height: root.cellHeight * plasmoid.configuration.numberRows - units.smallSpacing*2 - allProgramsButton.height
            //Layout.fillWidth: true
            opacity: 0
            Behavior on opacity {
                NumberAnimation { easing.type: Easing.OutQuart; duration: 450 }
            }
            z: 7
            //visible: !showingAllPrograms && searching
        }
        ApplicationsView {
            id: appsView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: faves.right
            width: root.cellWidth
            height: (root.cellHeight * plasmoid.configuration.numberRows) - units.smallSpacing*2 - allProgramsButton.height
            opacity: 0
            z: 1
            function resetIndex() {
                appsView.listView.currentIndex = -1;
            }
        }
        
        states: [

            State {
                name: "AllPrograms"; when: !searching && showingAllPrograms
                PropertyChanges {
                    target: faves; opacity: 0;
                }
                PropertyChanges {
                    target: recents; opacity: 0;
                }
                PropertyChanges {
                    target: tabBarSeparator; opacity: 0;
                }
                PropertyChanges {
                    target: appsView; opacity: 1;
                }
                PropertyChanges { 
                    target: appsView; z: 7;
                }
                StateChangeScript {
                    script: appsView.resetIndex();
                    //target: appsView.applicationsView.listView; currentIndex: -1;
                }
                
            },
            State {
                name: "Searching"; when: searching// && !showingAllPrograms
                PropertyChanges {
                    target: searchView; opacity: (backgroundRect.width === searchView.width ? 1 : 0);
                }
                PropertyChanges {
                    target: faves; opacity: 0;
                }
                PropertyChanges {
                    target: recents; opacity: 0;
                }
                PropertyChanges {
                    target: tabBarSeparator; opacity: 0;
                }
                PropertyChanges {
                    target: searchBackground; width: searchView.width - units.smallSpacing;
                }
                PropertyChanges {
                    target: backgroundRect; width: searchView.width;
                }
                PropertyChanges {
                    target: allProgramsButton; width: searchView.width - units.smallSpacing*2;
                }
                PropertyChanges {
                    target: allProgramsSeparator; width: searchView.width - units.smallSpacing*8;
                }
                PropertyChanges {
                    target: allButtonsArea; width: searchView.width - units.smallSpacing*2;
                }
                PropertyChanges {
                    target: sidePanel; opacity: 0;
                }
                /*PropertyChanges {
                    target: appsView; opacity: 0;
                }*/
                PropertyChanges {
                    target: sidePanel; enabled: false
                }
                /*PropertyChanges {
                    target: searchBackground; width: searchView.width
                }*/
            }
        ]
        transitions: [ 
        Transition {
            PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 350 }
        }
        /*Transition {
            NumberAnimation { properties: "width"; easing.type: Easing.OutQuad; duration: 250 }
        }*/
        ]
        
        
        PlasmaComponents.TextField {
            id: searchField
            anchors{
                //top: leaveButtons.top
                bottom: parent.bottom
                bottomMargin: units.smallSpacing * 2.5
                left: parent.left
                right: faves.right// + units.largeSpacing
                rightMargin: units.smallSpacing * 2
                leftMargin:  units.smallSpacing * 2
            }  
            
            style: TextFieldStyle {
                 textColor: "black"
                 placeholderTextColor: "#707070"
                 font.italic: searchField.length == 0 ? true : false
                 
            Rectangle { 
                anchors.fill: parent
                color: "white" } 
            }
            z: 7
            clearButtonShown: true
            width: root.cellWidth - units.smallSpacing * 4
            height: shutdown.height - units.smallSpacing
            placeholderText: i18n("Search programs and files")
            text: ""
            onTextChanged: {
                
                searchView.onQueryChanged();
                //runnerModel.query = text;
            }
            Keys.onPressed: {
                if(searching)
                {
                var currentView = searchView;
              switch(event.key) {
            case Qt.Key_Up: {
                currentView.decrementCurrentIndex();
                event.accepted = true;
                break;
            }
            case Qt.Key_Down: {
                currentView.incrementCurrentIndex();
                event.accepted = true;
                break;
            }
            /*case Qt.Key_Left: {
                if (searchField.focus && header.state == "query") {
                    break;
                }
                if (!currentView.deactivateCurrentIndex()) {
                    if (root.state == "Applications") {
                        mainTabGroup.currentTab = firstButton.tab;
                        tabBar.currentTab = firstButton;
                    }
                    root.state = "Normal"
                }
                event.accepted = true;
                break;
            }
            case Qt.Key_Right: {
                if (header.input.focus && header.state == "query") {
                    break;
                }
                currentView.activateCurrentIndex();
                event.accepted = true;
                break;
            }*/
            /*case Qt.Key_Tab: {
                root.state == "Applications" ? root.state = "Normal" : root.state = "Applications";
                event.accepted = true;
                break;
            }*/
            case Qt.Key_Enter:
            case Qt.Key_Return: {
                currentView.activateCurrentIndex(1);
                event.accepted = true;
                break;
            }
             default:
                if (!searchField.focus) {
                    searchField.forceActiveFocus();
                }
            }
                }
            }

            function backspace() {
                if (!root.visible) {
                    return;
                }

                focus = true;
                text = text.slice(0, -1);
            }

            function appendText(newText) {
                if (!root.visible) {
                    return;
                }

                focus = true;
                text = text + newText;
            }
        }

        Item{
            id: sidePanel
            width: root.cellWidthSide
            height: parent.height
            z: 7
            anchors{
                left: faves.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom 
                bottomMargin: units.largeSpacing
                leftMargin: units.smallSpacing * 2.15
                rightMargin: units.smallSpacing
            }

            FileDialog {
                id: folderDialog
                visible: false
                folder: shortcuts.pictures

                function getPath(val){
                    if(val === 1)
                        return shortcuts.pictures
                    else if (val === 2)
                        return shortcuts.documents
                    else if (val === 3)
                        return shortcuts.music
                    else if (val === 4)
                        return shortcuts.home
                    else if (val === 5)
                        return shortcuts.movies
                    else if (val === 6)
                        return "~/Downloads"
                    else if (val === 7)
                        return "/"
                }
            }

            Rectangle{
                id: iconUser
                height: units.iconSizes.huge
                width: height
                color: "transparent"
                clip: true
                //anchors.left: parent.width
                anchors.leftMargin: units.smallSpacing
                anchors.top: parent.top
                anchors.topMargin: -units.smallSpacing
                anchors.horizontalCenter: parent.horizontalCenter
               // Image {
                  Image {
                    source: "../pics/user.png"
                    smooth: true
                    z: 1
                    //anchors.fill: parent
                    anchors.left: parent.left
                    //anchors.leftMargin: -units.smallSpacing*2.2
                    anchors.right: parent.right
                    //anchors.rightMargin: -units.smallSpacing*2.2
                    anchors.bottom: parent.bottom
                    //anchors.bottomMargin: -units.smallSpacing*1.7
                    anchors.top: parent.top
                    //anchors.topMargin: -units.smallSpacing*2.2
                    //width: parent.width + units.smallSpacing * 2
                    //height: parent.height + units.smallSpacing * 2
                   
                }
                PlasmaCore.IconItem {
                    id: imgAuthor
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 2
                    anchors.leftMargin: 2
                    anchors.rightMargin: 2
                    anchors.bottomMargin: 2
                    source: kuser.faceIconUrl.toString() || "user-identity"
                    smooth: true
                    visible: false
                     usesPlasmaTheme: false
                   
                }
                OpacityMask {
                    anchors.fill: imgAuthor
                    source: imgAuthor
                    maskSource: Rectangle {
                        width: imgAuthor.width
                        height: imgAuthor.height
                        //radius: iconUser.width*0.5
                        visible: false
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onPressed: {
                        root.visible = false;
                        KCMShell.open("kcm_users")
                    }
                }
            }
            ColumnLayout {
                id: columnItems
                spacing: units.smallSpacing
                anchors.top: iconUser.bottom
                anchors.topMargin: units.largeSpacing
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                ListDelegate {
                    text: kuser.loginName
                    //highlight: delegateHighlight
                    icon: "user-home"
                    size: iconSizeSide
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("dolphin --new-window "+folderDialog.getPath(4))
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    //onClicked: executable.exec("dolphin --new-window "+folderDialog.getPath(4))
                    
                }
                ListDelegate {
                    text: "Documents"
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("dolphin --new-window "+folderDialog.getPath(2))
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    icon: "folder-documents"
                    size: iconSizeSide
                    //onClicked: executable.exec("dolphin --new-window "+folderDialog.getPath(2))
                }
                
                ListDelegate {
                    text: "Pictures"
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("dolphin --new-window "+folderDialog.getPath(1))
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    icon: "folder-pictures"
                    size: iconSizeSide
                    //onClicked: executable.exec("dolphin --new-window "+folderDialog.getPath(1))
                }
                ListDelegate {
                    text: "Music"
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("dolphin --new-window "+folderDialog.getPath(3))
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    icon: "folder-music"
                    size: iconSizeSide
                    //onClicked: executable.exec("dolphin --new-window "+folderDialog.getPath(3))
                }
                ListDelegate {
                    text: "Videos"
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("dolphin --new-window "+folderDialog.getPath(5))
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    icon: "folder-music"
                    size: iconSizeSide
                    //onClicked: executable.exec("dolphin --new-window "+folderDialog.getPath(5))
                }
                ListDelegate {
                    text: "Downloads"
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("dolphin --new-window "+folderDialog.getPath(6))
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    icon: "folder-music"
                    size: iconSizeSide
                    //onClicked: executable.exec("dolphin --new-window "+folderDialog.getPath(5))
                }
                ListDelegate {
                    text: "Computer"
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("dolphin --new-window "+folderDialog.getPath(7))
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    icon: "folder-music"
                    size: iconSizeSide
                    //onClicked: executable.exec("dolphin --new-window "+folderDialog.getPath(5))
                }

                ListDelegate {
                    text: "System Settings"
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        fillMode: Image.PreserveAspectFit
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("systemsettings5")
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    icon: "configure"
                    size: iconSizeSide
                    //onClicked: logic.openUrl("file:///usr/share/applications/systemsettings.desktop")
                }
                ListDelegate {
                    text: "Default Programs"
                    Image {
                        property bool hovered: false
                        source: "../pics/menu_select.png"
                        smooth: false
                        opacity: hovered ? 1.0 : 0.0
                        width: parent.width
                        height: parent.height
                        MouseArea {
                            enabled: !root.hoverDisabled
                            acceptedButtons: Qt.LeftButton
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                root.visible = false;
                                executable.exec("systemsettings5 componentchooser")
                            }
                            hoverEnabled: true
                            anchors.fill: parent
                            }
                    }
                    icon: "configure"
                    size: iconSizeSide
                    //onClicked: logic.openUrl("file:///usr/share/applications/systemsettings.desktop")
                }

                Item{
                    Layout.fillHeight: true
                }
                //Clock{}

                Item{
                    height: units.smallSpacing
                }

                
            }
        }
        
        RowLayout{
                    id: leaveButtons
                    width: units.smallSpacing*28
                    height: units.smallSpacing * 7
                    z: 7
                    anchors{
                //top: leaveButtons.top
                //bottom: searchField.bottom
                        top: searchField.top
                        topMargin: -units.smallSpacing/2
                        //bottom: searchField.bottom
                        //bottomMargin: -units.smallSpacing * 3
                        left: searchField.right
                        leftMargin: units.smallSpacing*4-1
                    }
                    //anchors.top: searchField.top
                    //anchors.topMargin: searchField.topMargin 
                    Layout.fillWidth: false
                    ListDelegate {
                        //text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                        id: shutdown
                        width: units.smallSpacing * 20
                        height: units.smallSpacing * 7-2
                        Text {
                            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                            font.pixelSize: 12
                            color: searching ? "#202020" : PlasmaCore.Theme.textColor
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        size: iconSizeSide
                        Image {
                                        id: shutdownButton
                                        MouseArea {
                                                id: ma
                                                enabled: !root.hoverDisabled
                                                acceptedButtons: Qt.LeftButton
                                                onPressed: {
                                                    shutdownButton.source = "../pics/shutdown_pressed.png"
                                                }
                                                onReleased: {
                                                    shutdownButton.source = "../pics/shutdown.png"
                                                }
                                                onEntered: {
                                                    shutdownButton.source = "../pics/shutdown_hover.png"
                                                }
                                                onExited: {
                                                    shutdownButton.source = "../pics/shutdown.png"   
                                                }
                                                onClicked: {
                                                    root.visible = false;
                                                    pmEngine.performOperation("requestShutDown")
                                                }
                                                hoverEnabled: true
                                                anchors.fill: parent
                                        }
                                        //source: ma.containsMouse ? "../pics/shutdown_hover.png" : "../pics/shutdown.png"
                                        source: "../pics/shutdown.png"
                                        //fillMode: Image.PreserveAspectFit
                                        width: parent.width + units.smallSpacing / 2
                                        height: parent.height - units.smallSpacing / 2
                                        anchors.left: parent.left
                                }
                    }
                     ListDelegate {
                         id: lockScreenDelegate
                        //text: i18nc("@action", "Lock Screen")
                        width: units.smallSpacing * 8
                        anchors.left: shutdown.right
                        anchors.leftMargin: -1
                        anchors.top: shutdown.top
                        height: shutdown.height 
                        
                        //icon: "system-lock-screen"
                        Image {
                                        id: lockButton
                                        MouseArea {
                                                id: ma_two
                                                enabled: !root.hoverDisabled
                                                acceptedButtons: Qt.LeftButton
                                                onPressed: {
                                                    lockButton.source = "../pics/shutdown_pressed_small.png"
                                                }
                                                onReleased: {
                                                    lockButton.source = "../pics/shutdown_small.png"
                                                }
                                                onEntered: {
                                                    lockButton.source = "../pics/shutdown_hover_small.png"
                                                }
                                                onExited: {
                                                    lockButton.source = "../pics/shutdown_small.png"   
                                                }
                                                onClicked: {
                                                    root.visible = false;
                                                    pmEngine.performOperation("lockScreen")
                                                }
                                                hoverEnabled: true
                                                anchors.fill: parent
                                        }
                                        //source: ma.containsMouse ? "../pics/shutdown_hover.png" : "../pics/shutdown.png"
                                        source: "../pics/shutdown_small.png"
                                        fillMode: Image.PreserveAspectFit
                                        width: parent.width
                                        height: parent.height - units.smallSpacing / 2
                                        anchors.left: parent.left
                                }
                        Image {
                            id: lockScreenSvg
                            source: "../pics/system-lock-screen.svg"
                            width: parent.height - units.smallSpacing
                            height: parent.height - units.smallSpacing
                            //anchors.horizontalCenter: parent.horizontalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: units.smallSpacing
                            ColorOverlay {
                            anchors.fill: lockScreenSvg
                            source: lockScreenSvg
                            /*hue: 0.0
                            saturation: 0.0
                            lightness: searching ? -0.5 : 1.0*/
                            color: searching ? "#FF202020" : PlasmaCore.Theme.textColor 
                        }
                        }
                        //highlight: delegateHighlight
                        enabled: pmEngine.data["Sleep States"]["LockScreen"]
                        size: iconSizeSide
                        //showIcon: true
                        onClicked: pmEngine.performOperation("lockScreen")
                    }
                }


        Keys.onPressed: {
            if (event.key == Qt.Key_Escape) {
                event.accepted = true;

                if (searching) {
                    reset();
                } else if(showingAllPrograms) {
                    showingAllPrograms = false;
                    appsView.reset();
                } else {
                    root.visible = false;
                }

                return;
            }

            if (searchField.focus) {
                return;
            }

            if (event.key == Qt.Key_Backspace) {
                event.accepted = true;
                searchField.backspace();
            /*} else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab) {
                if (pageListScrollArea.focus == true && pageList.currentItem.itemGrid.currentIndex == -1) {
                    event.accepted = true;
                    pageList.currentItem.itemGrid.tryActivate(0, 0);
                }*/
            } else if (event.text != "") {
                event.accepted = true;
                searchField.appendText(event.text);
            }
        }

    }

    Component.onCompleted: {
        kicker.reset.connect(reset);
        //dragHelper.dropped.connect(pageList.cycle);
        reset();
        faves.listView.currentIndex = -1;
    }
}
