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
    id: tasksMenuItemSeparator

    objectName: "menuseparator"
    property var menuText: ""

    PlasmaComponents.Label {
        id: menuTitle
        z: -1
        anchors {
            left: parent.left
            top: parent.top
            //leftMargin: PlasmaCore.Units.smallSpacing
            rightMargin: PlasmaCore.Units.smallSpacing*2
        }
        height: parent.height
        text: menuText
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignTop
        color: "#002e89"
    }

    Rectangle {
        id: separatorLine
        color: "#afbedf"
        height: 1
        //width: parent.width
        anchors {
            left: menuTitle.right
            right: parent.right
            leftMargin: PlasmaCore.Units.smallSpacing
            //rightMargin: PlasmaCore.Units.smallSpacing
            verticalCenter: parent.verticalCenter
        }

    }


}
