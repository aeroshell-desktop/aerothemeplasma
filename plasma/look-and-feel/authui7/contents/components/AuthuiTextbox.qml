/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.3
import org.kde.plasma.core 2.0 as PlasmaCore

TextField {
    id: root

    signal clicked
    activeFocusOnTab: true

    Keys.priority: Keys.AfterItem
    Keys.onPressed: (event) => {
        if(event.key == Qt.Key_Return) {
            root.clicked();
        }
    }
    onAccepted: {
        root.clicked();
    }

    color: "black"
    padding: 4
    background: Rectangle {
        color: "#2c628b"
        radius: 3
        implicitWidth: 100
        implicitHeight: 24
        border.color: "#7FFFFFFF"
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: "white"
            radius: 2
            implicitWidth: 100
            implicitHeight: 24
            border.color: "#2c628b"
            border.width: 1
        }
    }
}
