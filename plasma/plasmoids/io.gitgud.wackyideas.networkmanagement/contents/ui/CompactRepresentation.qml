/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasmoid 2.0

MouseArea {
    id: root

    required property bool airplaneModeAvailable
    required property string iconName

    hoverEnabled: true

    acceptedButtons: airplaneModeAvailable ? Qt.LeftButton | Qt.MiddleButton : Qt.LeftButton

    property bool wasExpanded

    onPressed: wasExpanded = mainWindow.expanded
    onClicked: mouse => {
        if (airplaneModeAvailable && mouse.button === Qt.MiddleButton) {
            mainWindow.planeModeSwitchAction.trigger();
        } else {
            mainWindow.expanded = !wasExpanded;
        }
    }

    Kirigami.Icon {
        id: connectionIcon

        anchors.fill: parent
        source: root.iconName
        active: parent.containsMouse
    }
}
