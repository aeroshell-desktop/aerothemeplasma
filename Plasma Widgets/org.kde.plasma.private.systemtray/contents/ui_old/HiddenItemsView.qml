/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // For Highlight
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "items"

MouseArea {
    id: hiddenTasksView

    property alias layout: hiddenTasks

    hoverEnabled: true
    onExited: hiddenTasks.currentIndex = -1

    PlasmaExtras.ScrollArea {
        width: parent.width
        height: parent.height
        frameVisible: false

        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        verticalScrollBarPolicy: systemTrayState.activeApplet ? Qt.ScrollBarAlwaysOff : Qt.ScrollBarAsNeeded

        GridView {
            id: hiddenTasks

            readonly property int rows: 4
            readonly property int columns: 4

            cellWidth: Math.floor(hiddenTasks.width / hiddenTasks.columns)
            cellHeight: Math.floor(hiddenTasks.height / hiddenTasks.rows)

            currentIndex: -1
            highlight: PlasmaComponents.Highlight {}
            highlightMoveDuration: 0

            pixelAligned: true

            readonly property int itemCount: model.count

            model: PlasmaCore.SortFilterModel {
                sourceModel: plasmoid.nativeInterface.systemTrayModel
                filterRole: "effectiveStatus"
                filterCallback: function(source_row, value) {
                    return value === PlasmaCore.Types.PassiveStatus
                }
            }
            delegate: ItemLoader {}
        }
    }
}
