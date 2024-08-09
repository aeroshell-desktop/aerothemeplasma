/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami
import Qt5Compat.GraphicalEffects

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

        LinearGradient {
            id: gradient
            anchors.fill: parent
            z: -1
            start: Qt.point(0,0)
            end: Qt.point(gradient.width, gradient.height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#eeecee" }
                GradientStop { position: 1.0; color: "#a39ea3" }
            }
        }
        Kirigami.Icon {
            id: faceIcon
            source: iconSource
            visible: (face.status == Image.Error || face.status == Image.Null)
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit * 0.5 // because mockup says so...
            //colorGroup: PlasmaCore.ColorScope.colorGroup

        }
    }

    Image {
        id: imageFrame

        anchors.fill: root
        source: "../images/pfpframe.png"
    }
}
