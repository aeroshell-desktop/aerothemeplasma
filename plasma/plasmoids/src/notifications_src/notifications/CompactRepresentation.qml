/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.quickcharts 1.0 as Charts

import plasma.applet.io.gitgud.wackyideas.notifications as Notifications

MouseArea {
    id: compactRoot

    Layout.minimumWidth: Plasmoid.formFactor === PlasmaCore.Types.Horizontal ? height : Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? width : Kirigami.Units.iconSizes.small + 2 * Kirigami.Units.gridUnit

    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    property int activeCount: 0
    property int unreadCount: 0

    property int jobsCount: 0
    property int jobsPercentage: 0

    property bool inhibited: false

    property bool wasExpanded: false
    onPressed: wasExpanded = root.expanded
    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) {
            Notifications.Globals.toggleDoNotDisturbMode();
        } else {
            root.expanded = !wasExpanded;
        }
    }

    hoverEnabled: true

    Kirigami.Icon {
        id: notificationIcon
        anchors.centerIn: parent
        // Deliberately rounding the size here rather than letting Kirigami.Icon
        // do it itself so that children can derive sane sizes from it.
        width: Kirigami.Units.iconSizes.roundedIconSize(Math.min(parent.width, parent.height))
        height: width
        visible: opacity > 0
        active: compactRoot.containsMouse

        source: {
            let iconName;
            if(compactRoot.jobsCount > 0) {
                iconName = "notification-progress-active"
            } else if (compactRoot.inhibited) {
                iconName = "notification-disabled";
            } else if (compactRoot.unreadCount > 0) {
                iconName = "notification-active";
            } else {
                iconName = "notification-inactive"
            }
            return iconName;
        }
    }
}
