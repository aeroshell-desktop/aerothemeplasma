/*
    SPDX-FileCopyrightText: 2016, 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick

import org.kde.kirigami as Kirigami

import plasma.applet.io.gitgud.wackyideas.notifications as NotificationsApplet

Item {
    id: area

    signal activated
    signal contextMenuRequested(var pos)

    required property Item dragParent
    property int dragPixmapSize: Kirigami.Units.iconSizes.large
    property url dragUrl
    property var dragPixmap

    readonly property bool dragging: NotificationsApplet.DragHelper.dragActive
    readonly property alias hovered: hoverHandler.hovered

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        id: tapHandler
        acceptedButtons: Qt.LeftButton

        onTapped: {
            area.activated();
        }
    }

    TapHandler {
        id: menuTapHandler
        acceptedButtons: Qt.LeftButton
        acceptedDevices: PointerDevice.TouchScreen | PointerDevice.Stylus
        onLongPressed: area.contextMenuRequested(point.position)
    }

    MouseArea {
        acceptedButtons: Qt.RightButton
        cursorShape: tapHandler.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        anchors.fill: parent
        onPressed: (mouse) => {
            area.contextMenuRequested(Qt.point(mouse.x, mouse.y))
        }
    }

    DragHandler {
        id: dragHandler

        onActiveChanged: {
            if (active) {
                NotificationsApplet.DragHelper.dragPixmapSize = area.dragPixmapSize;
                NotificationsApplet.DragHelper.startDrag(area.dragParent, area.dragUrl, area.dragPixmap);
            }
        }
    }
}
