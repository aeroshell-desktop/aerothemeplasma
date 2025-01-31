/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.10
import org.kde.kirigami 2.11 as Kirigami

MouseArea {
    id: delegate

    property Item contentItem
    property bool draggable: false
    signal dismissRequested

    implicitWidth: contentItem ? contentItem.implicitWidth : 0
    implicitHeight: contentItem ? contentItem.implicitHeight : 0
    opacity: 1 - Math.min(1, 1.5 * Math.abs(x) / width)

    drag {
        axis: Drag.XAxis
        target: draggable && Kirigami.Settings.tabletMode ? this : null
    }

    onReleased: {
        if (Math.abs(x) > width / 2) {
            delegate.dismissRequested();
        } else {
            slideAnim.restart();
        }
    }

    NumberAnimation {
        id: slideAnim
        target: delegate
        property:"x"
        to: 0
        duration: Kirigami.Units.longDuration
    }
}
