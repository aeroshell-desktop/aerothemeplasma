/*
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtMultimedia 5.15

Image {
    id: root
    source: "images/background.jpg"

    property int stage

    onStageChanged: {
        if (stage == 6) {
            splashSound.play();
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 1
        TextMetrics {
            id: units
            text: "M"
            property int gridUnit: boundingRect.height
            property int largeSpacing: units.gridUnit
            property int smallSpacing: Math.max(2, gridUnit/4)
        }

        Text {
            id: logo
            font.pixelSize: 23;
            font.letterSpacing: 0.8;
            text: "Welcome";
            color: "white";
            font.family: "Segoe UI";
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -units.largeSpacing*3;
            layer.enabled: true
            layer.effect: DropShadow {
                verticalOffset: 1
                color: "#CC000000"
                radius: 2
                samples: 3
            }
            renderType: Text.NativeRendering;
            font.hintingPreference: Font.PreferVerticalHinting
        }

        AnimatedImage {
            id: busyIndicator
            anchors.right: logo.left;
            anchors.rightMargin: units.smallSpacing*2;
            anchors.horizontalCenterOffset: -logo.width / 2 -units.smallSpacing * 5;
            anchors.verticalCenterOffset: -units.largeSpacing*3;
            anchors.centerIn: parent
            source: "images/busy.gif"
            smooth: true
        }

        Rectangle {
            id: fadeout
            anchors.fill: parent
            color: "black"
            opacity: 0
        }
        SoundEffect {
            id: splashSound
            source: "logon.wav"
            loops: 0
        }
    }


    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 150
        easing.type: Easing.Linear
    }
}
