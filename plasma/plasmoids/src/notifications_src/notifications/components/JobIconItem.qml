/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQml

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import plasma.applet.io.gitgud.wackyideas.notifications as Notifications

// This item is parented to the NotificationItem iconContainer
Item {
    id: jobDragIconItem

    property ModelInterface modelInterface

    readonly property bool shown: jobDragIcon.valid
    readonly property alias dragging: jobDragArea.dragging

    Notifications.FileInfo {
        id: fileInfo
        url: jobDragIconItem.modelInterface.jobDetails?.totalFiles === 1 ? jobDragIconItem.modelInterface.jobDetails?.effectiveDestUrl : ""
    }

    Notifications.FileMenu {
        id: otherFileActionsMenu
        url: jobDragIconItem.modelInterface.jobDetails?.effectiveDestUrl
        onActionTriggered: action => jobDragIconItem.modelInterface.fileActionInvoked(action)
    }

    Kirigami.Icon {
        id: jobDragIcon
        anchors.fill: parent

        active: jobDragArea.hovered
        opacity: busyIndicator.running ? 0.6 : 1
        source: !fileInfo.error ? fileInfo.iconName : ""

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        DraggableFileArea {
            id: jobDragArea
            anchors.fill: parent

            dragParent: jobDragIcon
            dragUrl: jobDragIconItem.modelInterface.jobDetails?.effectiveDestUrl
            dragPixmap: jobDragIcon.source

            onActivated: jobDragIconItem.modelInterface.openUrl(jobDragIconItem.modelInterface.jobDetails?.effectiveDestUrl)
            onContextMenuRequested: (pos) => {
                otherFileActionsMenu.visualParent = this;
                otherFileActionsMenu.open(pos.x, pos.y);
            }
        }
    }

    PlasmaComponents3.BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: fileInfo.busy && !delayBusyTimer.running
        visible: running

        // Avoid briefly flashing the busy indicator
        Timer {
            id: delayBusyTimer
            interval: 500
            repeat: false
            running: fileInfo.busy
        }
    }
}
