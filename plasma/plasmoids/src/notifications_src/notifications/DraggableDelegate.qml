/*
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami

T.SwipeDelegate {
    id: swipeDelegate

    property bool draggable
    signal dismissRequested

    function close() {
        swipe.open(T.SwipeDelegate.Left)
    }

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight
    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing

    swipe.enabled: draggable && Kirigami.Settings.tabletMode
    swipe.onCompleted: dismissRequested()
    swipe.transition: Transition {
        NumberAnimation {
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.Linear
        }
    }
    opacity: 1 - Math.abs(swipe.position)
    swipe.right: Item {
        anchors.fill:parent
    }
    swipe.left: Item {
        anchors.fill:parent
    }
}
