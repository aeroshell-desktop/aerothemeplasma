/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts 1.12
import QtQuick.Window 2.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: popup

    property int flyoutWidth: hiddenItemsView.visible ? hiddenItemsView.width + Kirigami.Units.smallSpacing*2 : (intendedWidth != -1 ? intendedWidth : Math.max(Kirigami.Units.iconSizes.small * 19, container.flyoutImplicitWidth + dialog.margins.right + Kirigami.Units.smallSpacing*2))
    property int flyoutHeight: hiddenItemsView.visible ?
    hiddenItemsView.implicitHeight + trayHeading.height + Kirigami.Units.largeSpacing  :
    (container.flyoutImplicitHeight > (Kirigami.Units.iconSizes.small * 8 - trayHeading.height - Kirigami.Units.largeSpacing) ? container.flyoutImplicitHeight + container.headingHeight + container.footerHeight + trayHeading.height + Kirigami.Units.largeSpacing*4 : Kirigami.Units.iconSizes.small*19)
    //: Kirigami.Units.iconSizes.small * 19
    Layout.minimumWidth: flyoutWidth
    Layout.minimumHeight: flyoutHeight

    Layout.maximumWidth: flyoutWidth
    Layout.maximumHeight: flyoutHeight

    function updateHeight() {
        flyoutHeight = Qt.binding(() => hiddenItemsView.visible ?
                                            hiddenItemsView.implicitHeight + trayHeading.height + Kirigami.Units.largeSpacing :
                                            (container.flyoutImplicitHeight > (Kirigami.Units.iconSizes.small * 8 - trayHeading.height - Kirigami.Units.largeSpacing) ? container.flyoutImplicitHeight + container.headingHeight + container.footerHeight + trayHeading.height + Kirigami.Units.largeSpacing*4 : Kirigami.Units.iconSizes.small*19))
        popup.Layout.minimumHeight = Qt.binding(() => flyoutHeight);
        popup.Layout.maximumHeight = Qt.binding(() => flyoutHeight);
    }

    property bool shownDialog: dialog.visible
    //property bool changedItems: false
    property int intendedWidth: container.activeApplet ? (typeof container.activeApplet.fullRepresentationItem.flyoutIntendedWidth !== "undefined" ? container.activeApplet.fullRepresentationItem.flyoutIntendedWidth : -1) : -1

    onShownDialogChanged: {
        //changedItems = false;
        updateHeight();
    }

    property alias hiddenLayout: hiddenItemsView.layout
    property alias plasmoidContainer: container

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    // Header
    ToolButton {
        id: pinButton
        visible: !hiddenItemsView.visible
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.rightMargin: Kirigami.Units.largeSpacing
        width: Kirigami.Units.iconSizes.small+1;
        height: Kirigami.Units.iconSizes.small;
        checkable: true
        checked: Plasmoid.configuration.pin

        onClicked: (mouse) => {
            Plasmoid.configuration.pin = !Plasmoid.configuration.pin;
        }
        buttonIcon: "pin"

        z: 9999

        //KeyNavigation.down: backButton.KeyNavigation.down
        //KeyNavigation.left: configureButton.visible ? configureButton : configureButton.KeyNavigation.left

        /*PlasmaComponents.ToolTip {
         *       text: parent.text
    }*/
    }

    // Main content layout
    ColumnLayout {
        id: expandedRepresentation
        anchors {
            top: parent.top
            bottom: trayHeading.top
            left: parent.left
            right: parent.right
            bottomMargin: 0
        }
        //anchors.top: parent.top


        anchors.margins: Kirigami.Units.smallSpacing
        // TODO: remove this so the scrollview fully touches the header;
        // add top padding internally
        spacing: Kirigami.Units.smallSpacing
        // Grid view of all available items
        HiddenItemsView {
            id: hiddenItemsView
            Layout.preferredWidth: hiddenItemsView.width
            //Layout.minimumHeight: hiddenItemsView.flyoutHeight
            //Layout.maximumHeight: hiddenItemsView.flyoutHeight

            visible: !systemTrayState.activeApplet
            /*property int previousItemCount: 0
            onHiddenItemsCountChanged: {
                if(shownDialog) {
                    var itemCount = hiddenItemsView.hiddenItemsCount
                    if(itemCount > previousItemCount) {
                        if(itemCount % 3 == 1) {
                            console.log("big change " + hiddenItemsView.flyoutHeight + " " + hiddenItemsView.implicitHeight)
                            changedItems = true;
                        }
                    } else if(itemCount < previousItemCount) {
                        if(itemCount % 3 == 0) {
                           changedItems = true;
                        }
                    }
                }

                previousItemCount = hiddenItemsView.hiddenItemsCount;
            }*/
            onVisibleChanged: {

                if (visible) {
                    layout.forceActiveFocus();
                    systemTrayState.oldVisualIndex = systemTrayState.newVisualIndex = -1;
                }
            }
        }
        // Container for currently visible item
        PlasmoidPopupsContainer {
            id: container
            Layout.fillWidth: true
            Layout.fillHeight: true
            //Layout.topMargin: -dummyItem.height
            visible: systemTrayState.activeApplet
            // We need to add margin on the top so it matches the dialog's own margin
            Layout.margins: Kirigami.Units.smallSpacing //mergeHeadings ? 0 : dialog.topPadding
            Layout.bottomMargin: Kirigami.Units.mediumSpacing

            //clip: true
            KeyNavigation.up: pinButton
            KeyNavigation.backtab: pinButton
            /*Rectangle {
                id: rectxd
                color: "red"
                anchors.fill: parent
            }*/

            onVisibleChanged: {
                if (visible) {
                    forceActiveFocus();
                }
            }
        }

    }

    // Header content layout

    RowLayout {
        id: trayHeading
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            /*leftMargin: dialogSvg.margins.left
            rightMargin: dialogSvg.margins.right
            bottomMargin: dialogSvg.margins.bottom*/

        }
        property QtObject applet: systemTrayState.activeApplet || root
        visible: trayHeading.applet && trayHeading.applet.plasmoid.internalAction("configure")
        height: 40

        Item {
            id: paddingLeft
            Layout.fillWidth: true
        }
        Text {
            id: headingLabel
            color: "#0066cc"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            text: (systemTrayState.activeApplet ? systemTrayState.activeApplet.plasmoid.title : i18n("Customize..."))
            elide: Text.ElideRight
            font.underline: ma.containsMouse
            Item { // I don't know why the f*ck this works but it works
                id: rect
                anchors.fill: parent
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    //enabled: parent.hoveredLink
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        trayHeading.applet.plasmoid.internalAction("configure").trigger();
                    }
                    //z: 9999
                }
            }

        }

        Item {
            id: paddingRight
            Layout.fillWidth: true
        }

    }
    Rectangle {
        id: plasmoidFooter
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            /*leftMargin: dialogSvg.margins.left
            rightMargin: dialogSvg.margins.right
            bottomMargin: dialogSvg.margins.bottom*/

        }

        visible: trayHeading.visible
        //visible: container.appletHasFooter
        height: trayHeading.height + Kirigami.Units.smallSpacing / 2 //+ container.footerHeight + Kirigami.Units.smallSpacing
        //height: trayHeading.height + container.headingHeight + (container.headingHeight === 0 ? 0 : Kirigami.Units.smallSpacing/2)
        color: "#f1f5fb"
        Rectangle {
            id: plasmoidFooterBorder
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ccd9ea" }
                GradientStop { position: 1.0; color: "#f1f5fb" }
            }
            height: Kirigami.Units.smallSpacing
        }
        z: -9999
    }
}
