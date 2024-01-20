/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3

GenericButton {
    id: root
    implicitWidth: 45
    implicitHeight: 28
    focusPolicy: Qt.TabFocus
    Accessible.description: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")

    //iconSource: "../images/osk.png"
    Image {
        anchors.centerIn: root
        source: "../images/osk.png"
    }
}
