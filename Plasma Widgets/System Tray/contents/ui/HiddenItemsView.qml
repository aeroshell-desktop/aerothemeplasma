/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
 *   Copyright 2020 Konrad Materka <materka@gmail.com>
 *   Copyright 2020 Nate Graham <nate@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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

            cellWidth: hiddenTasks.width / hiddenTasks.columns
            cellHeight: hiddenTasks.height / hiddenTasks.rows

            currentIndex: -1
            highlight: PlasmaComponents.Highlight {}
            highlightMoveDuration: 0

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
