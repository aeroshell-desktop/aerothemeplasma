/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15

import Qt5Compat.GraphicalEffects

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

import "../components"

ColumnLayout {
    id: root
    property alias containsMouse: mouseArea.containsMouse
    spacing: 0

    signal clicked

    Item {
        implicitWidth: 80
        implicitHeight: 80
        Layout.alignment: Qt.AlignHCenter
        id: smolPFP

        Item {
            id: imageSource

            anchors.centerIn: smolPFP
            width: 48
            height: 48

            Image {
                id: face
                source: kscreenlocker_userImage
                fillMode: Image.PreserveAspectCrop
                anchors.fill: parent
            }
            Kirigami.Icon {
                id: faceIcon
                source: "user-symbolic"
                visible: (face.status == Image.Error || face.status == Image.Null)
                anchors.fill: parent
                anchors.margins: Kirigami.Units.gridUnit * 0.5 // because mockup says so...
                //colorGroup: PlasmaCore.ColorScope.colorGroup
            }
        }
        Image {
            id: imageFrame
            anchors.fill: smolPFP
            source: activeFocus ? (containsMouse ? "../images/pfpframesmolhoverfocused.png" : "../images/pfpframesmolfocused.png") : (containsMouse ? "../images/pfpframesmolhover.png" : "../images/pfpframesmol.png")
        }
    }

    Label {
        id: usernameDelegate
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: 9

        width: parent.width
        text: kscreenlocker_userName
        color: "white"
        horizontalAlignment: Text.AlignCenter
        layer.enabled: true
        layer.effect: DropShadow {
            //visible: !softwareRendering
            horizontalOffset: 0
            verticalOffset: 1
            radius: 6
            samples: 14
            spread: 0.0001
            color: "#bf000000"
        }
    }

    Label {
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: 9

        width: implicitWidth
        text: "Locked"
        color: "white"
        horizontalAlignment: Text.AlignCenter
        layer.enabled: true
        layer.effect: DropShadow {
            //visible: !softwareRendering
            horizontalOffset: 0
            verticalOffset: 1
            radius: 6
            samples: 14
            spread: 0.0001
            color: "#bf000000"
        }
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        onClicked: root.clicked()
        Keys.onEnterPressed: clicked()
        Keys.onReturnPressed: clicked()
        anchors.fill: parent
    }
}
