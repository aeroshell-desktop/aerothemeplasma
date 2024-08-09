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

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3
import QtQuick.Templates 2.3
import org.kde.plasma.core 2.0 as PlasmaCore
import QtMultimedia
import "../components"

Item {
    id: root
    z: -9

    property int stage

    onStageChanged: {
        if (stage == 5) {
            //lockSuccess.play();

            //fadeOut.running = true;
            transitionAnim.opacity = 1;
        }
    }
    /*MediaPlayer {
        id: lockSuccess
        source: Qt.resolvedUrl("../sounds/lockSuccess.ogg");
        audioOutput: AudioOutput {}
    }*/

    Rectangle {
        color: "#1D5F7A"
        anchors.fill: parent
    }

    Image {
        id: bgtexture
        source: "../images/bgtexture.jpg"
        anchors.fill: parent
    }

    Status {
        id: statusText
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -36
        statusText: i18nd("okular", "Welcome")
        speen: true
    }

    RowLayout {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 96
        Rectangle { Layout.fillWidth: true }
        Image {
            id: watermark
            source: "../images/watermark.png"
        }
        Rectangle { Layout.fillWidth: true }
    }

    Rectangle {
        id: transitionAnim
        opacity: 0
        color: "black"
        anchors.fill: parent
        Behavior on opacity {
            NumberAnimation { duration: 640; }
        }
    }

    /*OpacityAnimator {
        id: fadeOut
        running: false
        target: transitionAnim
        from: 0
        to: 1
        duration: 640
        easing.type: Easing.InOutQuad
    }*/
}
