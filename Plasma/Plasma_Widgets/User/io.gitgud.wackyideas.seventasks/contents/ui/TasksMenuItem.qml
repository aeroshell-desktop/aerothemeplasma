/*
    SPDX-FileCopyrightText: 2012-2016 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.taskmanager 0.1 as TaskManager

import "code/layout.js" as LayoutManager
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.5 as Kirigami

Item {
    id: tasksMenuItem

    signal clicked

    property var iconSource: ""
    property var menuText: ""
    property bool selected: false
    property QtObject wrapperItem: tasksMenuItem.parent

    PlasmaCore.FrameSvgItem {
        id: texture
        z: -1
        anchors.fill: parent
        imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
        //imagePath: "widgets/menuitem"
        prefix: "hover"
        visible: (tasksMA.containsMouse || selected) && parent.enabled
        opacity: selected ? 1.0 : 0.6
    }
    MouseArea {
        id: tasksMA
        z: 1
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            tasksMenu.setCurrentItem(wrapperItem);
            tasksMenuItem.clicked();
        }
        onPositionChanged: {
            tasksMenu.setCurrentItem(wrapperItem);
        }
        onEntered: {
            tasksMenu.setCurrentItem(wrapperItem);
            //tasksMenu.clearIndices();
        }
        onExited: {
            tasksMenu.clearIndices();
        }
    }
    PlasmaCore.IconItem {
        id: menuIcon
        z: -1
        anchors {
            left: parent.left
            top: parent.top
            topMargin: PlasmaCore.Units.smallSpacing/2
            leftMargin: PlasmaCore.Units.smallSpacing/2
            verticalCenter: parent.verticalCenter
        }
        width: PlasmaCore.Units.iconSizes.small
        height: width
        animated: false
        usesPlasmaTheme: false
        opacity: parent.enabled ? 1 : 0.5
        source: iconSource
    }
    PlasmaComponents.Label {
        id: menuTitle
        z: -1
        anchors {
            left: menuIcon.right
            right: parent.right
            leftMargin: PlasmaCore.Units.smallSpacing
            rightMargin: PlasmaCore.Units.smallSpacing*2
        }
        height: parent.height
        text: menuText
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        opacity: parent.enabled ? 1 : 0.75
        color: "black"
    }

}
