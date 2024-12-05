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

Item {
    id: tasksMenuItemSeparator

    objectName: "menuseparator"
    property var menuText: ""
    implicitHeight: Kirigami.Units.smallSpacing*5
    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight

    PlasmaComponents.Label {
        id: menuTitle
        z: -1
        anchors {
            left: parent.left
            top: parent.top
            //leftMargin: PlasmaCore.Units.smallSpacing
            rightMargin: Kirigami.Units.smallSpacing*2
        }
        height: parent.height
        text: menuText
        font.pointSize: 9 //9.3
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignTop
        color: "#002e89"
        style: Text.Sunken
        styleColor: "transparent"
    }
    PlasmaComponents.Label {
        id: menuTitle_highlight
        z: -1
        anchors {
            left: parent.left
            top: parent.top
            //leftMargin: PlasmaCore.Units.smallSpacing
            rightMargin: Kirigami.Units.smallSpacing*2
        }
        height: parent.height
        text: menuText
        font.pointSize: 9 //9.3
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignTop
        opacity: 0.66
        color: "transparent"
        style: Text.Sunken
        styleColor: "transparent"
    }

    Rectangle {
        id: separatorLine
        color: "#afbedf"
        height: 1
        //width: parent.width
        anchors {
            left: menuTitle.right
            right: parent.right
            leftMargin: Kirigami.Units.smallSpacing
            //rightMargin: PlasmaCore.Units.smallSpacing
            verticalCenter: parent.verticalCenter
        }

    }


}
