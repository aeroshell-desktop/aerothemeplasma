/*
    SPDX-FileCopyrightText: 2024 Fushan Wen <qydwhotmail@gmail.com>

    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Controls as QQC
import org.kde.plasma.private.systemtray as ST

Column {
    Repeater {
        model: ST.StatusNotifierModel { }
        delegate: QQC.Label {
            text: model.Title
        }
    }
}