/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import QtQuick.Effects

import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasmoid 2.0


MouseArea {
    id: detailsMA

    implicitHeight: detailsGrid.height
    property var details: []

    property var modelIndex: -1
    property string networkName: ""
    property string uuid: ""

    property var connectionState: PlasmaNM.Enums.Deactivated
    property double rxBytes: 0
    property double txBytes: 0

    property double previousRxBytes: 0
    property double previousTxBytes: 0

    property var connectionModel: null

    function numberWithCommas(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    function getModelIndex() {
        if(uuid !== "" && connectionModel) {
            modelIndex = connectionModel.match(connectionModel.index(0, 0), PlasmaNM.NetworkModel.UuidRole, uuid)[0];
        } else if(networkName !== "" && connectionModel) {
            modelIndex = connectionModel.match(connectionModel.index(0, 0), PlasmaNM.NetworkModel.ItemUniqueNameRole, networkName)[0];
        }
    }
    Component.onCompleted: {
        getModelIndex();
    }

    Timer {
        id: reloadTimer
        interval: 2000
        repeat: true
        running: parent.modelIndex !== -1
        triggeredOnStart: true
        // property int can overflow with the amount of bytes.
        onTriggered: {
            detailsMA.getModelIndex();
            connectionState = detailsMA.connectionModel.data(modelIndex, PlasmaNM.NetworkModel.ConnectionStateRole);
            details = detailsMA.connectionModel.data(modelIndex, PlasmaNM.NetworkModel.ConnectionDetailsRole);

            if(connectionState === PlasmaNM.Enums.Activated) {
                txBytes = detailsMA.connectionModel.data(modelIndex, PlasmaNM.NetworkModel.TxBytesRole);
                rxBytes = detailsMA.connectionModel.data(modelIndex, PlasmaNM.NetworkModel.RxBytesRole);
                if(txBytes !== previousTxBytes || rxBytes !== previousRxBytes) {
                    detailsMA.colorizationOpacity = 0.8;
                    colorizationTimer.start();
                }
                previousRxBytes = rxBytes;
                previousTxBytes = txBytes;
            }
        }
    }
    property real colorizationOpacity: 0
    Timer {
        id: colorizationTimer
        interval: 500
        onTriggered: {
            detailsMA.colorizationOpacity = 0;
        }
    }

    acceptedButtons: Qt.RightButton

    onPressed: mouse => {
        const item = detailsGrid.childAt(mouse.x, mouse.y);
        if (!item || !item.isContent) {
            return;
        }
        contextMenu.show(this, item.text, mouse.x, mouse.y);
    }

    KQuickControlsAddons.Clipboard {
        id: clipboard
    }

    PlasmaExtras.Menu {
        id: contextMenu
        property string text

        function show(item, text, x, y) {
            contextMenu.text = text
            visualParent = item
            open(x, y)
        }

        PlasmaExtras.MenuItem {
            text: i18n("Copy")
            icon: "edit-copy"
            enabled: contextMenu.text !== ""
            onClicked: clipboard.content = contextMenu.text
        }
    }

    RowLayout {
        id: connectionText
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Kirigami.Units.largeSpacing+1
        PlasmaComponents3.Label {
            font: Kirigami.Theme.defaultFont
            text: "Connection"
            textFormat: Text.PlainText
            color: "black"
        }
        Rectangle {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: "#a0a0a0"
        }
    }
    GridLayout {
        id: detailsGrid
        width: parent.width
        columns: 2
        rowSpacing: 1
        anchors.top: connectionText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.largeSpacing*2-1
        anchors.rightMargin: Kirigami.Units.largeSpacing*2-1
        anchors.topMargin: Kirigami.Units.smallSpacing

        Repeater {
            id: repeater

            model: details.length

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                required property int index
                readonly property bool isContent: index % 2

                elide: isContent ? Text.ElideRight : Text.ElideNone
                font: Kirigami.Theme.defaultFont
                horizontalAlignment: isContent ? Text.AlignRight : Text.AlignLeft
                text: isContent ? details[index] : `${details[index]}:`
                textFormat: Text.PlainText
                //opacity: isContent ? 1 : 0.6
                color: "black"
            }
        }
    }
    RowLayout {
        id: activityText
        anchors.top: detailsGrid.bottom
        anchors.topMargin: Kirigami.Units.smallSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Kirigami.Units.largeSpacing+1
        visible: detailsMA.connectionState === PlasmaNM.Enums.Activated
        PlasmaComponents3.Label {
            font: Kirigami.Theme.defaultFont
            text: "Activity"
            textFormat: Text.PlainText
            color: "black"
        }
        Rectangle {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: "#a0a0a0"
        }
    }

    GridLayout {
        anchors.top: activityText.bottom
        anchors.topMargin: Kirigami.Units.smallSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.largeSpacing*2-1
        anchors.rightMargin: Kirigami.Units.largeSpacing*2-1

        visible: detailsMA.connectionState === PlasmaNM.Enums.Activated
        rows: 2
        columns: 5
        rowSpacing: 0
        Item { Layout.fillWidth: true }
        RowLayout {
            Layout.bottomMargin: Kirigami.Units.largeSpacing+2
            Layout.rightMargin: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.mediumSpacing
            Text { text: "Sent" }
            Rectangle { Layout.preferredHeight: 2; Layout.preferredWidth: 20; color: "#a0a0a0" }
            //Layout.alignment: Qt.AlignVCenter
        }
        Item {
            id: networkIcon
            Layout.preferredHeight: 48
            Layout.preferredWidth: 48
            Kirigami.Icon {
                source: "monitor"
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                anchors.top: parent.top
                anchors.left: parent.left
                Kirigami.Icon {
                    source: "monitor"
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.topMargin: -2
                    width: Kirigami.Units.iconSizes.medium
                    height:Kirigami.Units.iconSizes.medium
                    z: -1
                }
            }
            Kirigami.Icon {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                source: "network-wired"
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                roundToIconSize: false
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                id: iconEffect
                colorization: detailsMA.colorizationOpacity
                colorizationColor: "#8bd6f9"
            }
        }
        Rectangle { Layout.bottomMargin: Kirigami.Units.largeSpacing+2; Layout.preferredHeight: 2; Layout.preferredWidth: 20; color: "#a0a0a0" }
        Text { text: "Received"; Layout.alignment: Qt.AlignRight; Layout.bottomMargin: Kirigami.Units.largeSpacing+2 }

        Text { text: "Bytes:"; Layout.fillWidth: true }
        Text {
            id: txText
            text: detailsMA.numberWithCommas(detailsMA.txBytes)
            Layout.preferredWidth: txTextMetrics.width
            TextMetrics {
                id: txTextMetrics
                font.family: txText.font.family
                text: txText.text.replace(/[0-9]/g, "0");
            }

        }
        Rectangle { Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 2; Layout.rightMargin: 2; Layout.preferredHeight: 16; color: "#a0a0a0" }
        Item { }
        Text {
            id: rxText
            text: detailsMA.numberWithCommas(detailsMA.rxBytes)
            Layout.preferredWidth: rxTextMetrics.width
            TextMetrics {
                id: rxTextMetrics
                font.family: rxText.font.family
                text: rxText.text.replace(/[0-9]/g, "0");
            }

        }

    }

}
