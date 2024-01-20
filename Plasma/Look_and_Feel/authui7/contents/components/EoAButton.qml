/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

GenericButton {
    id: root
    implicitWidth: 38
    implicitHeight: 28
    focusPolicy: Qt.NoFocus

    iconSource: "access"
    /*PlasmaCore.IconItem {
        id: elementIcon

        anchors.centerIn: root
        width: PlasmaCore.Units.iconSizes.smallMedium
        height: width

        animated: false
        usesPlasmaTheme: false

        source: "access"
    }*/
}
