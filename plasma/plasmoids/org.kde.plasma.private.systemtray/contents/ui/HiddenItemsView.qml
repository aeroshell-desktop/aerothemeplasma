/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0
import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.kirigami 2.20 as Kirigami
import "items"
import org.kde.plasma.extras 2.0 as PlasmaExtras

ScrollView {
    id: hiddenTasksView

    property alias hiddenItemsCount: hiddenTasks.count
    property alias cellWidth: hiddenTasks.cellWidth
    property alias cellHeight: hiddenTasks.cellHeight
    //property int hiddenTasksWidth: 3 * hiddenTasks.cellWidth + Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing / 2 - 1 + hiddenTasksView.padding*2
    //property int hiddenTasksHeight: Math.ceil(hiddenTasks.count / 3) * (hiddenTasks.cellHeight + Kirigami.Units.smallSpacing) + 40 + Kirigami.Units.largeSpacing*2 + hiddenTasksView.padding*2
    property alias layout: hiddenTasks

    property int flyoutHeight: Math.ceil(hiddenTasks.count / 3) * (hiddenTasks.cellHeight + Kirigami.Units.smallSpacing) + Kirigami.Units.smallSpacing*2

    width: (hiddenTasks.cellWidth+Kirigami.Units.smallSpacing) * 3 - Kirigami.Units.smallSpacing/2 - 1

    //topPadding: 0
    padding: Kirigami.Units.mediumSpacing
    leftPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.mediumSpacing + Kirigami.Units.smallSpacing
    rightPadding: 0
    hoverEnabled: true
    onHoveredChanged: if (!hovered) {

        hiddenTasks.currentIndex = -1;
    }
    background: null

    GridView {
        id: hiddenTasks

        readonly property int maximumColumns: 3
        readonly property int minimumRows: 4
        readonly property int minimumColumns: 4

        cellWidth: Kirigami.Units.iconSizes.medium //Math.floor(Math.min(hiddenTasksView.availableWidth, popup.Layout.minimumWidth) / minimumRows)
        cellHeight: Kirigami.Units.iconSizes.medium //Math.floor(popup.Layout.minimumHeight / minimumColumns)

        currentIndex: -1
        //highlight: PlasmaExtras.Highlight {}
        highlightMoveDuration: 0

        pixelAligned: true

        readonly property int itemCount: model.count

        //! This is used in order to identify the minimum required label height in order for all
        //! labels to be aligned properly at all items. At the same time this approach does not
        //! enforce labels with 3 lines at all cases so translations that require only one or two
        //! lines will always look consistent with no too much padding
        readonly property int minLabelHeight: {
            var minHeight = 0;

            for(let i in contentItem.children){
                var gridItem = contentItem.children[i];
                if (!gridItem || !gridItem.hasOwnProperty("item") || !gridItem.item.hasOwnProperty("labelHeight")) {
                    continue;
                }

                if (gridItem.item.labelHeight > minHeight) {
                    minHeight = gridItem.item.labelHeight;
                }
            }

            return minHeight;
        }

        model: KItemModels.KSortFilterProxyModel {
            sourceModel: Plasmoid.systemTrayModel
            filterRoleName: "effectiveStatus"
            filterRowCallback: (sourceRow, sourceParent) => {
                let value = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole);
                return value === PlasmaCore.Types.PassiveStatus
            }
        }
        delegate: ItemLoader {
            id: itemloader
            GridView.onRemove: SequentialAnimation {
                PropertyAction { target: itemloader; property: "GridView.delayRemove"; value: true }
                NumberAnimation { target: itemloader; property: "opacity"; to: 0; duration: 25; easing.type: Easing.InOutQuad }
                PropertyAction { target: itemloader; property: "GridView.delayRemove"; value: false }
            }
            //GridView.delayRemove: true
            width: hiddenTasks.cellWidth
            height: hiddenTasks.cellHeight
            minLabelHeight: 0//hiddenTasks.minLabelHeight
        }

        keyNavigationEnabled: true
        activeFocusOnTab: true

        KeyNavigation.up: hiddenTasksView.KeyNavigation.up

        onActiveFocusChanged: {
            if (activeFocus && currentIndex === -1) {
                currentIndex = 0
            } else if (!activeFocus && currentIndex >= 0) {
                currentIndex = -1
            }
        }
    }
}
