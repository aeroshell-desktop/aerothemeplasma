/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.5
import QtQml.Models 2.10
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasmoid 2.0
import org.kde.draganddrop 2.0 as DnD
import org.kde.kirigami 2.5 as Kirigami // For Settings.tabletMode
import org.kde.kitemmodels 1.0 as KItemModels

import "items"

ContainmentItem {
    id: root

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    Layout.minimumWidth: vertical ? Kirigami.Units.iconSizes.small : mainLayout.implicitWidth + Kirigami.Units.largeSpacing+1
    Layout.minimumHeight: vertical ? mainLayout.implicitHeight + Kirigami.Units.smallSpacing : Kirigami.Units.iconSizes.small

    LayoutMirroring.enabled: !vertical && Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    readonly property alias tasksGrid: tasksGrid
    readonly property alias activeModel: activeModel
    readonly property alias systemTrayState: systemTrayState
    readonly property alias itemSize: tasksGrid.itemSize
    readonly property alias visibleLayout: tasksGrid
    readonly property alias hiddenLayout: expandedRepresentation.hiddenLayout
    readonly property bool oneRowOrColumn: tasksGrid.rowsOrColumns === 1

    KSvg.Svg {
        id: buttonIcons
        imagePath: Qt.resolvedUrl("svgs/icons.svg");
    }
    KSvg.FrameSvgItem {
        id : dialogSvg
        visible: false
        imagePath: "solid/dialogs/background"
    }
    MouseArea {
        anchors.fill: parent

        onWheel: {
            // Don't propagate unhandled wheel events
            wheel.accepted = true;
        }

        SystemTrayState {
            id: systemTrayState
        }

        //being there forces the items to fully load, and they will be reparented in the popup one by one, this item is *never* visible
        Item {
            id: preloadedStorage
            visible: false
        }

        CurrentItemHighLight {
            id: currentHighlight
            location: Plasmoid.location
            parent: root

            onHighlightedItemChanged: {
                if(dialog.visible) dialog.setDialogPosition();
            }
        }

        DnD.DropArea {
            anchors.fill: parent

            preventStealing: true

            /** Extracts the name of the system tray applet in the drag data if present
            * otherwise returns null*/
            function systemTrayAppletName(event) {
                if (event.mimeData.formats.indexOf("text/x-plasmoidservicename") < 0) {
                    return null;
                }
                const plasmoidId = event.mimeData.getDataAsByteArray("text/x-plasmoidservicename");

                if (!Plasmoid.isSystemTrayApplet(plasmoidId)) {
                    return null;
                }
                return plasmoidId;
            }

            onDragEnter: event => {
                if (!systemTrayAppletName(event)) {
                    event.ignore();
                }
            }

            onDrop: {
                const plasmoidId = systemTrayAppletName(event);
                if (!plasmoidId) {
                    event.ignore();
                    return;
                }

                if (Plasmoid.configuration.extraItems.indexOf(plasmoidId) < 0) {
                    const extraItems = Plasmoid.configuration.extraItems;
                    extraItems.push(plasmoidId);
                    Plasmoid.configuration.extraItems = extraItems;
                }
            }
        }

        Item {
            id: orderingManager
            property var orderObject: {}

            function saveConfiguration() {
                for(var i = 0; i < activeModel.items.count; i++) {
                    var item = activeModel.items.get(i);
                    if(item.model.itemId !== "")
                        setItemOrder(item.model.itemId, item.itemsIndex, false);
                }
                writeToConfig();
            }
            function setItemOrder(id, index, write = true) {
                if(typeof orderObject === "undefined")
                    orderObject = {};
                orderObject[id] = index;
                if(write) writeToConfig();
            }
            function getItemOrder(id) {
                if(typeof orderObject[id] === "undefined") return -1;
                return orderObject[id];
            }
            function writeToConfig() {
                Plasmoid.configuration.itemOrdering = JSON.stringify(orderObject);
                Plasmoid.configuration.writeConfig();
            }

            Component.onCompleted: {
                var list = Plasmoid.configuration.itemOrdering;
                if(list !== "")
                    orderObject = JSON.parse(list);

                if(typeof orderObject === "undefined")
                    orderObject = {};
            }
            /*Component.onDestruction: {
                saveConfiguration();
            }*/
        }
        Timer {
            id: updateTimer
            interval: 100
            onTriggered: {
                root.hiddenLayout.model.invalidateFilter()
                shownItemsModel.invalidateFilter();
            }
        }

        DelegateModel {
            id: activeModel
            model: KItemModels.KSortFilterProxyModel {
                id: shownItemsModel
                sourceModel: Plasmoid.systemTrayModel
                filterRoleName: "effectiveStatus"

                filterRowCallback: (sourceRow, sourceParent) => {
                    let value = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), filterRole);
                    return value === PlasmaCore.Types.ActiveStatus;
                }
            }
            property int unsortedCount: unsortedItems.count;
            property int sortedCount: items.count;
            function determinePosition(item) {
                let lower = 0;
                let upper = items.count
                while(lower < upper) {
                    const middle = Math.floor(lower + (upper - lower) / 2)
                    var middleItem = items.get(middle);

                    var first = orderingManager.getItemOrder(item.model.itemId);
                    var second = orderingManager.getItemOrder(middleItem.model.itemId);

                    const result = first < second;
                    if(result) {
                        upper = middle;
                    } else {
                        lower = middle + 1;
                    }
                }
                return lower;
            }
            function sort() {
                while(unsortedItems.count > 0) {
                    const item = unsortedItems.get(0);
                    //var shouldInsert = item.model.itemId !== "" || (typeof item.model.hasApplet !== "undefined");
                    var i = determinePosition(item); //orderingManager.getItemOrder(item.model.itemId);
                    item.groups =  "items";
                    items.move(item.itemsIndex, i);
                }
            }
            items.includeByDefault: false
            groups: DelegateModelGroup {
                id: unsortedItems
                name: "unsorted"

                includeByDefault: true
                onChanged: (removed, inserted) => {
                    /*if(inserted.length > 0) {
                        root.hiddenLayout.model.invalidateFilter()
                        shownItemsModel.invalidateFilter();
                    }*/
                    activeModel.sort();
                    if(activeModel.count != shownItemsModel.count) {
                        root.hiddenLayout.model.invalidateFilter()
                        shownItemsModel.invalidateFilter();
                    }
                }
            }
            delegate: ItemLoader {
                id: delegate
                width: tasksGrid.cellWidth
                height: tasksGrid.cellHeight
                property int visualIndex: DelegateModel.itemsIndex
                visible: !DelegateModel.isUnresolved
                minLabelHeight: 0
                // We need to recalculate the stacking order of the z values due to how keyboard navigation works
                // the tab order depends exclusively from this, so we redo it as the position in the list
                // ensuring tab navigation focuses the expected items
                Component.onCompleted: {
                    let item = tasksGrid.itemAtIndex(index - 1);
                    if (item) {
                        Plasmoid.stackItemBefore(delegate, item)
                    } else {
                        item = tasksGrid.itemAtIndex(index + 1);
                    }
                    if (item) {
                        Plasmoid.stackItemAfter(delegate, item)
                    }
                }
            }
        }
        //Main Layout
        GridLayout {
            id: mainLayout

            rowSpacing: 0
            columnSpacing: 0
            anchors.fill: parent

            flow: vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
            ExpanderArrow {
                id: expander
                Layout.fillWidth: vertical
                Layout.fillHeight: !vertical
                Layout.alignment: vertical ? Qt.AlignVCenter : Qt.AlignHCenter
                Layout.topMargin: !vertical ? 1 : 0
                iconSize: tasksGrid.itemSize
                visible: root.hiddenLayout.itemCount > 0
            }
            GridView {
                id: tasksGrid

                Layout.alignment: Qt.AlignCenter

                interactive: false //disable features we don't need
                flow: vertical ? GridView.LeftToRight : GridView.TopToBottom

                // The icon size to display when not using the auto-scaling setting
                readonly property int smallIconSize: Kirigami.Units.iconSizes.small

                // Automatically use autoSize setting when in tablet mode, if it's
                // not already being used
                readonly property bool autoSize: Plasmoid.configuration.scaleIconsToFit || Kirigami.Settings.tabletMode

                readonly property int gridThickness: root.vertical ? root.width : root.height
                // Should change to 2 rows/columns on a 56px panel (in standard DPI)
                readonly property int rowsOrColumns: autoSize ? 1 : Math.max(1, Math.min(count, Math.floor(gridThickness / (smallIconSize + Kirigami.Units.smallSpacing))))

                // Add margins only if the panel is larger than a small icon (to avoid large gaps between tiny icons)
                readonly property int cellSpacing: Kirigami.Units.smallSpacing * (Kirigami.Settings.tabletMode ? 6 : Plasmoid.configuration.iconSpacing)
                readonly property int smallSizeCellLength: gridThickness < smallIconSize ? smallIconSize : smallIconSize + cellSpacing

                cellHeight: {
                    if (root.vertical) {
                        return autoSize ? itemSize + (gridThickness < itemSize ? 0 : cellSpacing) : smallSizeCellLength
                    } else {
                        return autoSize ? root.height : Math.floor(root.height / rowsOrColumns)
                    }
                }
                cellWidth: {
                    if (root.vertical) {
                        return autoSize ? root.width : Math.floor(root.width / rowsOrColumns)
                    } else {
                        return autoSize ? itemSize + (gridThickness < itemSize ? 0 : cellSpacing) : smallSizeCellLength
                    }
                }

                //depending on the form factor, we are calculating only one dimension, second is always the same as root/parent
                implicitHeight: {
                    return root.vertical ? cellHeight * Math.ceil(count / rowsOrColumns) : root.height
                }
                implicitWidth: {
                    return !root.vertical ? cellWidth * Math.ceil(count / rowsOrColumns) : root.width
                }

                readonly property int itemSize: {
                    if (autoSize) {
                        return Kirigami.Units.iconSizes.roundedIconSize(Math.min(Math.min(root.width, root.height) / rowsOrColumns, Kirigami.Units.iconSizes.enormous))
                    } else {
                        return smallIconSize
                    }
                }

                model: activeModel
            }
        }

        Timer {
            id: expandedSync
            interval: 100
            onTriggered: systemTrayState.expanded = dialog.visible;
        }

        //Main popup
        PlasmaCore.Dialog {
            id: dialog
            objectName: "popupWindow"
            flags: Qt.WindowStaysOnTopHint
            location: "Floating"
            x: 0
            y: 0
            property int flyoutMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing/2
            property bool firstTimePopup: false

            hideOnWindowDeactivate: !Plasmoid.configuration.pin
            visible: systemTrayState.expanded
            appletInterface: root

            backgroundHints: expandedRepresentation.useTransparentFlyout ? PlasmaCore.Dialog.StandardBackground : PlasmaCore.Dialog.SolidBackground

            onWidthChanged: setDialogPosition();
            onHeightChanged: setDialogPosition();

            function setDialogPosition() {
                var rootPos = root.mapToGlobal(root.x, root.y);
                var pos = root.mapToGlobal(currentHighlight.x, currentHighlight.y);
                var availScreen = Plasmoid.containment.availableScreenRect;
                var screen = root.screenGeometry;
                var availableScreenGeometry = Qt.rect(availScreen.x + screen.x, availScreen.y + screen.y, availScreen.width, availScreen.height);

                if(Plasmoid.location === PlasmaCore.Types.BottomEdge) {
                    x = pos.x - width / 2 + (expandedRepresentation.hiddenLayout.visible ? flyoutMargin + Kirigami.Units.smallSpacing/2 : currentHighlight.width / 2);
                    y = pos.y - height - flyoutMargin;

                } else if(Plasmoid.location === PlasmaCore.Types.LeftEdge) {
                    y = pos.y - height / 2 + flyoutMargin;
                    x = rootPos.x + root.width + flyoutMargin;

                } else if(Plasmoid.location === PlasmaCore.Types.RightEdge) {
                    y = pos.y - height / 2 + flyoutMargin;
                    x = rootPos.x - flyoutMargin - width;

                } else if(Plasmoid.location === PlasmaCore.Types.TopEdge) {
                    x = pos.x - width / 2 + (expandedRepresentation.hiddenLayout.visible ? flyoutMargin + Kirigami.Units.smallSpacing/2 : currentHighlight.width / 2);
                    y = rootPos.y + root.height + flyoutMargin;
                }

                if(x < availableScreenGeometry.x) x = availableScreenGeometry.x + flyoutMargin;
                if(x + dialog.width >= availableScreenGeometry.x + availScreen.width) {
                    x = availableScreenGeometry.x + availScreen.width - dialog.width - flyoutMargin;
                }
                if(y < availableScreenGeometry.y) y = availableScreenGeometry.y + flyoutMargin;
                if(y + dialog.height >= availableScreenGeometry.y + availScreen.height) {
                    y = availableScreenGeometry.y + availScreen.height - dialog.height - flyoutMargin;
                }
                /*if(root.vertical) {
                    if(pos.x > dialog.x) dialog.x -= flyoutMargin;
                    else dialog.x += flyoutMargin;
                } else {
                    if(pos.y > dialog.y) dialog.y -= flyoutMargin;
                    else dialog.y += flyoutMargin;
                }*/
            }
            onYChanged: {
                if(!firstTimePopup) { setDialogPosition(); }
                firstTimePopup = true;
            }
            onVisibleChanged: {
                if(visible) {
                    setDialogPosition();
                }
                if (!visible) {
                    expandedSync.restart();
                } else {
                    if (expandedRepresentation.plasmoidContainer.visible) {
                        expandedRepresentation.plasmoidContainer.forceActiveFocus();
                    } else if (expandedRepresentation.hiddenLayout.visible) {
                        expandedRepresentation.hiddenLayout.forceActiveFocus();
                    }
                }
            }
            mainItem: ExpandedRepresentation {
                id: expandedRepresentation

                Keys.onEscapePressed: {
                    systemTrayState.expanded = false
                }

                LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
                LayoutMirroring.childrenInherit: true
            }
        }
    }
}
