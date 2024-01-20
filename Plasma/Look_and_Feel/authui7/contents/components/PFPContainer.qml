/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3


Item {
    id: root

    property string avatarPath
    property string iconSource: "user-symbolic"

    implicitWidth: 190
    implicitHeight: 190

    Item {
        id: imageSource

        anchors.centerIn: root
        width: 126
        height: 126

        Image {
            id: face
            source: avatarPath
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
        }

        PlasmaCore.IconItem {
            id: faceIcon
            source: iconSource
            visible: (face.status == Image.Error || face.status == Image.Null)
            anchors.fill: parent
            anchors.margins: PlasmaCore.Units.gridUnit * 0.5 // because mockup says so...
            colorGroup: PlasmaCore.ColorScope.colorGroup
        }
    }

    Image {
        id: imageFrame

        anchors.fill: root
        source: "../images/pfpframe.png"
    }
}
