/*
    SPDX-FileCopyrightText: 2014 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Window 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: wrapper

    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    property bool isCurrent: true

    property string name
    property string userName
    property string avatarPath
    property string iconSource
    property bool needsPassword
    property var vtNumber
    property bool constrainText: true
    property alias nameFontSize: usernameDelegate.font.pointSize
    property int fontSize: PlasmaCore.Theme.defaultFont.pointSize + 2
    signal clicked()

    property real faceSize: PlasmaCore.Units.gridUnit * 7

    opacity: isCurrent ? 1.0 : 0.5

    Behavior on opacity {
        OpacityAnimator {
            duration: PlasmaCore.Units.longDuration
        }
    }

    // Draw a translucent background circle under the user picture
    Rectangle {
        anchors.centerIn: imageSource
        width: imageSource.width - 2 // Subtract to prevent fringing
        height: width
        radius: width / 2

        color: PlasmaCore.ColorScope.backgroundColor
        opacity: 0.6
    }

    Item {
        id: imageSource
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on width {
            PropertyAnimation {
                from: faceSize
                duration: PlasmaCore.Units.longDuration;
            }
        }
        width: isCurrent ? faceSize : faceSize - PlasmaCore.Units.largeSpacing
        height: width

        //Image takes priority, taking a full path to a file, if that doesn't exist we show an icon
        Image {
            id: face
            source: wrapper.avatarPath
            sourceSize: Qt.size(faceSize * Screen.devicePixelRatio, faceSize * Screen.devicePixelRatio)
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

    PlasmaComponents3.Label {
        id: usernameDelegate

        anchors.top: imageSource.bottom
        anchors.topMargin: PlasmaCore.Units.gridUnit
        anchors.horizontalCenter: parent.horizontalCenter

        // Make it bigger than other fonts to match the scale of the avatar better
        font.pointSize: wrapper.fontSize + 4

        width: constrainText ? parent.width : implicitWidth
        text: wrapper.name
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? PlasmaCore.ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        wrapMode: Text.WordWrap
        maximumLineCount: wrapper.constrainText ? 3 : 1
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        //make an indication that this has active focus, this only happens when reached with keyboard navigation
        font.underline: wrapper.activeFocus
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: wrapper.clicked()
    }

    Keys.onSpacePressed: wrapper.clicked()

    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { wrapper.clicked() }
}
