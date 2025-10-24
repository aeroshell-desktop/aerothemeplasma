/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg

PlasmaCore.ToolTipArea {
    id: abstractItem

    property var model: itemModel

    property alias mouseArea: mouseArea
    property string itemId
    property alias text: label.text
    property alias labelHeight: label.implicitHeight
    property alias iconContainer: iconContainer
    property int /*PlasmaCore.Types.ItemStatus*/ status: model.status || PlasmaCore.Types.UnknownStatus
    property int /*PlasmaCore.Types.ItemStatus*/ effectiveStatus: model.effectiveStatus || PlasmaCore.Types.UnknownStatus
    property bool effectivePressed: false
    property real minLabelHeight: 0
    readonly property bool inHiddenLayout: effectiveStatus === PlasmaCore.Types.PassiveStatus
    readonly property bool inVisibleLayout: effectiveStatus === PlasmaCore.Types.ActiveStatus
    property alias held: mouseArea.held

    // input agnostic way to trigger the main action
    signal activated(var pos)

    // proxy signals for MouseArea
    signal clicked(var mouse)
    signal pressed(var mouse)
    signal wheel(var wheel)
    signal contextMenu(var mouse)

    /* subclasses need to assign to this tooltip properties
    mainText:
    subText:
    */



    location: {
        if (inHiddenLayout) {
            return PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop;
            /*if (LayoutMirroring.enabled && Plasmoid.location !== PlasmaCore.Types.RightEdge) {
                return PlasmaCore.Types.LeftEdge;
            } else if (Plasmoid.location !== PlasmaCore.Types.LeftEdge) {
                return PlasmaCore.Types.RightEdge;
            }*/
        }

        return Plasmoid.location;
    }

    /*PulseAnimation {
        targetItem: iconContainer
        running: (abstractItem.status === PlasmaCore.Types.NeedsAttentionStatus
                || abstractItem.status === PlasmaCore.Types.RequiresAttentionStatus)
            && Kirigami.Units.longDuration > 0
    }*/

    KSvg.FrameSvgItem {
        id: itemHighLight
        anchors.fill: parent
        anchors.bottomMargin: ((Plasmoid.location === PlasmaCore.Types.BottomEdge || Plasmoid.location === PlasmaCore.Types.TopEdge) && !inHiddenLayout) ? -2 : 0
        //property int location

        property bool animationEnabled: true
        property var highlightedItem: null

        z: -1 // always draw behind icons
        opacity: (mouseArea.containsMouse && !dropArea.containsDrag) ? 1 : 0

        imagePath: Qt.resolvedUrl("../svgs/tabbar.svgz")
        //imagePath: "widgets/tabbar"
        prefix: "active-tab"
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Rectangle {
            id: pressRect
            property alias activatedPress: pressRect.opacity
            anchors.fill: parent
            anchors.leftMargin: Kirigami.Units.smallSpacing / 2; // We don't want the rectangle to draw over the highlight texture itself.
            anchors.rightMargin: Kirigami.Units.smallSpacing / 2;
            gradient: Gradient {
                // The first and last gradient stops are offset by +/-0.1 to avoid a sudden gradient "cutoff".
                GradientStop { position: 0.1; color: "transparent"; }
                GradientStop { position: 0.5; color: "#8c000000"; }
                GradientStop { position: 0.9; color: "transparent"; }
            }
            opacity: mouseArea.containsPress ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150;
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
    MouseArea {
        id: mouseArea
        propagateComposedEvents: true
        property bool held: false

        function setRequestedInhibitDnd(value) {
            // This is modifying the value in the panel containment that
            // inhibits accepting drag and drop, so that we don't accidentally
            // drop the task on this panel.
            let item = this;
            while (item.parent) {
                item = item.parent;
                if (item.appletRequestsInhibitDnD !== undefined) {
                    item.appletRequestsInhibitDnD = value
                }
            }
        }
        onHeldChanged: {
            setRequestedInhibitDnd(held);
        }
        // This needs to be above applets when it's in the grid hidden area
        // so that it can receive hover events while the mouse is over an applet,
        // but below them on regular systray, so collapsing works
        //z: inHiddenLayout ? 1 : 0
        z: 1
        anchors.fill: abstractItem
        hoverEnabled: true
        drag.filterChildren: true
        drag.target: held && !abstractItem.inHiddenLayout ? icon : null
        // Necessary to make the whole delegate area forward all mouse events
        acceptedButtons: Qt.AllButtons
        // Using onPositionChanged instead of onEntered because changing the
        // index in a scrollable view also changes the view position.
        // onEntered will change the index while the items are scrolling,
        // making it harder to scroll.

        onContainsMouseChanged: {
            if(abstractItem.inHiddenLayout && !mouseArea.containsMouse) {
                root.hiddenLayout.currentIndex = -1;
            }
        }
        onPositionChanged: {
            if (abstractItem.inHiddenLayout) {
                root.hiddenLayout.currentIndex = index
            } else {
                if(mouseArea.containsPress) {
                    held = true;
                }
            }

        }
        onClicked: mouse => { abstractItem.clicked(mouse) }
        onReleased: {
            icon.Drag.drop();
            held = false;
        }
        onPressed: mouse => {
            if (inHiddenLayout) {
                root.hiddenLayout.currentIndex = index
            }
            abstractItem.hideImmediately()
            abstractItem.pressed(mouse)
        }
        onPressAndHold: mouse => {
            //held = true;

            if (mouse.button === Qt.LeftButton) {
                abstractItem.contextMenu(mouse)
            }
        }
        onWheel: wheel => {
            abstractItem.wheel(wheel);
            //Don't accept the event in order to make the scrolling by mouse wheel working
            //for the parent scrollview this icon is in.
            wheel.accepted = false;
        }
    }

    ColumnLayout {
        id: icon
        anchors.fill: abstractItem
        anchors.topMargin: abstractItem.inHiddenLayout ? 0 : 1
        spacing: 0

        Drag.active: mouseArea.drag.active// && abstractItem.inHiddenLayout
        Drag.source: abstractItem.parent
        Drag.hotSpot: Qt.point(width/2, height/2)

        states: [
            State {
                when: icon.Drag.active

                ParentChange {
                    target: icon
                    parent: root.tasksGrid
                }

                PropertyChanges {
                    target: icon
                    x: mouseArea.mapToItem(root.tasksGrid, mouseArea.mouseX, mouseArea.mouseY).x - iconContainer.width * 0.75
                    y: mouseArea.mapToItem(root.tasksGrid, mouseArea.mouseX, mouseArea.mouseY).y - iconContainer.height / 2
                }
                /*AnchorChanges {
                    target: icon
                    anchors.horizontalCenter: undefined
                    anchors.verticalCenter: undefined
                }*/
            }
        ]

        FocusScope {
            id: iconContainer
            Kirigami.Theme.colorSet: abstractItem.inHiddenLayout ? Kirigami.Theme.Tooltip : Kirigami.Theme.Window
            Kirigami.Theme.inherit: false
            activeFocusOnTab: true
            focus: true // Required in HiddenItemsView so keyboard events can be forwarded to this item
            Accessible.name: abstractItem.text
            Accessible.description: abstractItem.subText
            Accessible.role: Accessible.Button
            Accessible.onPressAction: abstractItem.activated(Plasmoid.popupPosition(iconContainer, iconContainer.width/2, iconContainer.height/2));
            opacity: icon.Drag.active ? 0.5 : 1
            Keys.onPressed: event => {
                switch (event.key) {
                    case Qt.Key_Space:
                    case Qt.Key_Enter:
                    case Qt.Key_Return:
                    case Qt.Key_Select:
                        abstractItem.activated(Qt.point(width/2, height/2));
                        break;
                    case Qt.Key_Menu:
                        abstractItem.contextMenu(null);
                        event.accepted = true;
                        break;
                }
            }

            property alias container: abstractItem
            property alias inVisibleLayout: abstractItem.inVisibleLayout
            readonly property int size: abstractItem.inVisibleLayout ? root.itemSize : Kirigami.Units.iconSizes.small

            Layout.alignment: Qt.Bottom | Qt.AlignHCenter
            Layout.fillHeight: abstractItem.inHiddenLayout ? true : false
            implicitWidth: root.vertical && abstractItem.inVisibleLayout ? abstractItem.width : size
            implicitHeight: !root.vertical && abstractItem.inVisibleLayout ? abstractItem.height : size
            //Layout.topMargin: abstractItem.inHiddenLayout ? Kirigami.Units.mediumSpacing : 0
        }
        PlasmaComponents3.Label {
            id: label
            Layout.fillWidth: true
            Layout.fillHeight: abstractItem.inHiddenLayout ? true : false
            //! Minimum required height for all labels is used in order for all
            //! labels to be aligned properly at all items. At the same time this approach does not
            //! enforce labels with 3 lines at all cases so translations that require only one or two
            //! lines will always look consistent with no too much padding
            Layout.minimumHeight: abstractItem.inHiddenLayout ? abstractItem.minLabelHeight : 0
            Layout.leftMargin: abstractItem.inHiddenLayout ? Kirigami.Units.smallSpacing : 0
            Layout.rightMargin: abstractItem.inHiddenLayout ? Kirigami.Units.smallSpacing : 0
            Layout.bottomMargin: abstractItem.inHiddenLayout ? Kirigami.Units.smallSpacing : 0

            visible: false //abstractItem.inHiddenLayout

            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 3

            opacity: visible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
    DropArea {
        id: dropArea
        anchors.fill: parent
        anchors.margins: 0
        property bool hasDrag: false
        Rectangle {
            id: leftBar
            color: "#70ffffff"
            width: 1
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: Kirigami.Units.smallSpacing/2
            anchors.bottomMargin: Kirigami.Units.smallSpacing/2
            visible: false
            z: -1
        }
        Rectangle {
            id: rightBar
            color: "#70ffffff"
            width: 1
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: Kirigami.Units.smallSpacing/2
            anchors.bottomMargin: Kirigami.Units.smallSpacing/2
            visible: false
            z: -1
        }
        onEntered: drag => {

            if(drag.source.visualIndex < abstractItem.parent.visualIndex) {
                rightBar.visible = true;
                leftBar.visible = false;
            } else {
                rightBar.visible = false;
                leftBar.visible = true;
            }
            hasDrag = true;
        }
        onExited: drag => {
            hasDrag = false;
            rightBar.visible = false;
            leftBar.visible = false;
        }
        onDropped: drag => {
            root.activeModel.items.move(drag.source.visualIndex, abstractItem.parent.visualIndex);
            //orderingManager.setItemOrder(itemId, abstractItem.parent.visualIndex);
            //orderingManager.setItemOrder(drag.source.itemId, drag.source.visualIndex);
            hasDrag = false;
            rightBar.visible = false;
            leftBar.visible = false;
            orderingManager.saveConfiguration();
        }
    }
}

