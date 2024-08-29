/*
    SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
    SPDX-FileCopyrightText: 2016 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2020 George Vogiatzis <gvgeo@protonmail.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.1
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg

/**
 * Ignores the theme's listItem margins, and uses custom highlight(pressed) area.
 * Could break some themes but the majority look fine.
 * Also includes a separator to be used in sections.
 */
MouseArea {
    id: listItem

    property bool checked: false
    property bool separator: false
    property rect highlightRect: Qt.rect(0, 0, width, height)

    width: parent.width

    // Sections have spacing above but not below. Will use 2 of them below.
    height: separator ? separatorLine.height + Kirigami.Units.smallSpacing * 3 : parent.height
    hoverEnabled: true

    KSvg.SvgItem {
        id: separatorLine
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Kirigami.Units.smallSpacing
        }
        imagePath: "widgets/line"
        elementId: "horizontal-line"
        width: parent.width
        visible: separator
    }

    KSvg.FrameSvgItem {
        id: background
        imagePath: "widgets/listitem"
        prefix: "normal"
        anchors.fill: parent
        visible: separator ? false : true
    }

    KSvg.FrameSvgItem {
        id: pressed
        imagePath: "widgets/listitem"
        prefix: "pressed"
        opacity: checked ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration } }

        x: highlightRect.x
        y: highlightRect.y
        height: highlightRect.height
        width: highlightRect.width
    }
}
