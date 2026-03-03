/*
    SPDX-FileCopyrightText: 2017 Martin Gräßlin <mgraesslin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.VirtualKeyboard

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

InputPanel {
    id: inputPanel
    property bool activated: false
    active: activated && Qt.inputMethod.visible
    width: parent.width

    states: [
        State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: inputPanel.parent.height - inputPanel.height
                opacity: 1
                visible: true
            }
        },
        State {
            name: "hidden"
            when: !inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: inputPanel.parent.height
                opacity: 0
                visible:false
            }
        }
    ]

}
