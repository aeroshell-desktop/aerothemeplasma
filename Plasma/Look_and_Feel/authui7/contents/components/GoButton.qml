/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import org.kde.plasma.components 3.0 as PlasmaComponents3

Image {
    id: root
    property alias containsMouse: mouseArea.containsMouse

    signal clicked
    activeFocusOnTab: true

    source: mouseArea.containsPress ? "../images/gopressed.png" : (activeFocus || containsMouse ? "../images/gohover.png" : "../images/go.png")

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        onClicked: root.clicked()
        anchors.fill: parent
    }
}
