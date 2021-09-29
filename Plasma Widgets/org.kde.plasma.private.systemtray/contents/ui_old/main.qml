/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.draganddrop 2.0 as DnD
import org.kde.kirigami 2.5 as Kirigami

import "items"

MouseArea {
    id: root

    readonly property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

    Layout.minimumWidth: vertical ? PlasmaCore.Units.iconSizes.small : mainLayout.implicitWidth + PlasmaCore.Units.smallSpacing
    Layout.minimumHeight: vertical ? mainLayout.implicitHeight + PlasmaCore.Units.smallSpacing : PlasmaCore.Units.iconSizes.small

    LayoutMirroring.enabled: !vertical && Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    readonly property alias systemTrayState: systemTrayState
    readonly property alias itemSize: tasksGrid.itemSize
    readonly property alias visibleLayout: tasksGrid
    readonly property alias hiddenLayout: expandedRepresentation.hiddenLayout
    readonly property bool oneRowOrColumn: tasksGrid.rowsOrColumns == 1

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
        location: plasmoid.location
        parent: root
    }

    DnD.DropArea {
        anchors.fill: parent

        preventStealing: true;

        /** Extracts the name of the system tray applet in the drag data if present
         * otherwise returns null*/
        function systemTrayAppletName(event) {
            if (event.mimeData.formats.indexOf("text/x-plasmoidservicename") < 0) {
                return null;
            }
            var plasmoidId = event.mimeData.getDataAsByteArray("text/x-plasmoidservicename");

            if (!plasmoid.nativeInterface.isSystemTrayApplet(plasmoidId)) {
                return null;
            }
            return plasmoidId;
        }

        onDragEnter: {
            if (!systemTrayAppletName(event)) {
                event.ignore();
            }
        }

        onDrop: {
            var plasmoidId = systemTrayAppletName(event);
            if (!plasmoidId) {
                event.ignore();
                return;
            }

            if (plasmoid.configuration.extraItems.indexOf(plasmoidId) < 0) {
                var extraItems = plasmoid.configuration.extraItems;
                extraItems.push(plasmoidId);
                plasmoid.configuration.extraItems = extraItems;
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

        GridView {
            id: tasksGrid

            Layout.alignment: Qt.AlignCenter

            interactive: false //disable features we don't need
            flow: vertical ? GridView.LeftToRight : GridView.TopToBottom

            // The icon size to display when not using the auto-scaling setting
            readonly property int smallIconSize: PlasmaCore.Units.iconSizes.smallMedium

            // Automatically use autoSize setting when in tablet mode, if it's
            // not already being used
            readonly property bool autoSize: plasmoid.configuration.scaleIconsToFit || Kirigami.Settings.tabletMode

            readonly property int gridThickness: root.vertical ? root.width : root.height
            // Should change to 2 rows/columns on a 56px panel (in standard DPI)
            readonly property int rowsOrColumns: autoSize ? 1 : Math.max(1, Math.min(count, Math.floor(gridThickness / (smallIconSize + PlasmaCore.Units.smallSpacing))))

            // Add margins only if the panel is larger than a small icon (to avoid large gaps between tiny icons)
            readonly property int smallSizeCellLength: gridThickness < smallIconSize ? smallIconSize : smallIconSize + PlasmaCore.Units.smallSpacing * 2
            cellHeight: {
                if (root.vertical) {
                    return autoSize ? root.width + PlasmaCore.Units.smallSpacing : smallSizeCellLength
                } else {
                    return autoSize ? root.height : Math.floor(root.height / rowsOrColumns)
                }
            }
            cellWidth: {
                if (root.vertical) {
                    return autoSize ? root.width : Math.floor(root.width / rowsOrColumns)
                } else {
                    return autoSize ? root.height + PlasmaCore.Units.smallSpacing : smallSizeCellLength
                }
            }

            //depending on the form factor, we are calculating only one dimention, second is always the same as root/parent
            implicitHeight: root.vertical ? cellHeight * Math.ceil(count / rowsOrColumns) : root.height
            implicitWidth: !root.vertical ? cellWidth * Math.ceil(count / rowsOrColumns) : root.width

            readonly property int itemSize: {
                if (autoSize) {
                    const size = Math.min(implicitWidth / rowsOrColumns, implicitHeight / rowsOrColumns)
                    return PlasmaCore.Units.roundToIconSize(Math.min(size, PlasmaCore.Units.iconSizes.enormous))
                } else {
                    return smallIconSize
                }
            }

            model: PlasmaCore.SortFilterModel {
                sourceModel: plasmoid.nativeInterface.systemTrayModel
                filterRole: "effectiveStatus"
                filterCallback: function(source_row, value) {
                    return value === PlasmaCore.Types.ActiveStatus
                }
            }

            delegate: ItemLoader {}

            add: Transition {
                enabled: itemSize > 0

                NumberAnimation {
                    property: "scale"
                    from: 0
                    to: 1
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.longDuration
                }
            }

            displaced: Transition {
                //ensure scale value returns to 1.0
                //https://doc.qt.io/qt-5/qml-qtquick-viewtransition.html#handling-interrupted-animations
                NumberAnimation {
                    property: "scale"
                    to: 1
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.longDuration
                }
            }

            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.longDuration
                }
            }
        }

        ExpanderArrow {
            id: expander
            Layout.fillWidth: vertical
            Layout.fillHeight: !vertical
            Layout.alignment: vertical ? Qt.AlignVCenter : Qt.AlignHCenter
            iconSize: tasksGrid.itemSize
            visible: root.hiddenLayout.itemCount > 0
        }
    }

    //Main popup
    PlasmaCore.Dialog {
        id: dialog
        visualParent: root
        flags: Qt.WindowStaysOnTopHint
        location: plasmoid.location
        hideOnWindowDeactivate: !plasmoid.configuration.pin
        visible: systemTrayState.expanded

        onVisibleChanged: {
            systemTrayState.expanded = visible
        }
        mainItem: ExpandedRepresentation {
            id: expandedRepresentation

            Keys.onEscapePressed: {
                systemTrayState.expanded = false
            }

            // Draws a line between the applet dialog and the panel
            PlasmaCore.SvgItem {
                anchors {
                    top: plasmoid.location == PlasmaCore.Types.BottomEdge ? undefined : parent.top
                    left: plasmoid.location == PlasmaCore.Types.RightEdge ? undefined : parent.left
                    right: plasmoid.location == PlasmaCore.Types.LeftEdge ? undefined : parent.right
                    bottom: plasmoid.location == PlasmaCore.Types.TopEdge ? undefined : parent.bottom
                    topMargin: plasmoid.location == PlasmaCore.Types.BottomEdge ? undefined : -dialog.margins.top
                    leftMargin: plasmoid.location == PlasmaCore.Types.RightEdge ? undefined : -dialog.margins.left
                    rightMargin: plasmoid.location == PlasmaCore.Types.LeftEdge ? undefined : -dialog.margins.right
                    bottomMargin: plasmoid.location == PlasmaCore.Types.TopEdge ? undefined : -dialog.margins.bottom
                }
                height: (plasmoid.location == PlasmaCore.Types.TopEdge || plasmoid.location == PlasmaCore.Types.BottomEdge) ? 1 : undefined
                width: (plasmoid.location == PlasmaCore.Types.LeftEdge || plasmoid.location == PlasmaCore.Types.RightEdge) ? 1 : undefined
                z: 999 /* Draw the line on top of the applet */
                elementId: (plasmoid.location == PlasmaCore.Types.TopEdge || plasmoid.location == PlasmaCore.Types.BottomEdge) ? "horizontal-line" : "vertical-line"
                svg: PlasmaCore.Svg {
                    imagePath: "widgets/line"
                }
            }

            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
            LayoutMirroring.childrenInherit: true
        }
    }
}
