/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15

import Qt5Compat.GraphicalEffects

RowLayout {
    id: root

    property string statusText
    property int spinnum: 0
    property bool speen

    spacing: 8
    Image {
        id: loadingspinner
        source: "../images/100/spin"+spinnum+".png"
    }
    Label {
        id: welcomeLbl
        z: 1
        text: statusText
        color: "#FFFFFF"
        font.pointSize: 18
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferFullHinting
        font.kerning: false
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

    SequentialAnimation {
        id: spinner
        running: speen
        loops: Animation.Infinite
        NumberAnimation { target: root; property: "spinnum"; to: 17; duration: 900 }
        NumberAnimation { target: root; property: "spinnum"; to: 0; duration: 0 }
    }
}
