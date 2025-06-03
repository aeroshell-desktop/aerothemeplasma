/*
    SPDX-FileCopyrightText: 2012-2016 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.taskmanager as TaskManager

import "code/layoutmetrics.js" as LayoutManager
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

Item {
    id: tasksMenuItem

    signal clicked

    property var iconSource: ""
    property var menuText: ""
    property bool selected: false
    property QtObject wrapperItem: tasksMenuItem.parent

    KSvg.FrameSvgItem {
        id: texture
        z: -1
        anchors.fill: parent
        imagePath: Qt.resolvedUrl("svgs/jumplistitem.svg")
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
        enabled: !tasksMenu.sliderAnimation.running
        onClicked: {
            tasksMenu.setCurrentItem(wrapperItem);
            tasksMenuItem.clicked();
            tasksMenu.closeMenu();
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
    Kirigami.Icon {
        id: menuIcon
        z: -1
        anchors {
            left: parent.left
            top: parent.top
            topMargin: Kirigami.Units.smallSpacing/2
            leftMargin: Kirigami.Units.smallSpacing/2
            verticalCenter: parent.verticalCenter
        }
        width: Kirigami.Units.iconSizes.small
        height: width
        opacity: parent.enabled ? 1 : 0.5
        source: iconSource
        active: false
        //enabled: parent.enabled || tasksMenu.sliderAnimation.running
    }
    PlasmaComponents.Label {
        id: menuTitle
        z: -1
        anchors {
            left: menuIcon.right
            right: parent.right
            leftMargin: Kirigami.Units.smallSpacing
            rightMargin: Kirigami.Units.smallSpacing*2
        }
        height: parent.height
        text: menuText
        font.pointSize: 9 //9.3
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        opacity: parent.enabled ? 1 : 0.75
        color: "black"
        style: Text.Sunken
        styleColor: "transparent"
    }
    PlasmaComponents.Label {
        id: menuTitle_highlight
        z: -1
        anchors {
            left: menuIcon.right
            right: parent.right
            leftMargin: Kirigami.Units.smallSpacing
            rightMargin: Kirigami.Units.smallSpacing*2
        }
        height: parent.height
        text: menuText
        font.pointSize: 9 //9.3
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        opacity: 0.66
        color: "transparent"
        style: Text.Sunken
        styleColor: "transparent"
    }
}
