/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasmoid

PlasmaExtras.Representation {
    id: full

    required property PlasmaNM.Handler nmHandler
    required property PlasmaNM.NetworkStatus nmStatus
    property alias appletProxyModel: appletProxyModel

    collapseMarginsHint: true

    Component {
        id: networkModelComponent
        PlasmaNM.NetworkModel {}
    }

    property var connectionModel: mainWindow.connectionModel

    PlasmaNM.AppletProxyModel {
        id: appletProxyModel

        sourceModel: full.connectionModel
    }

    header: PlasmaExtras.PlasmoidHeading {
        focus: true
        contentItem: RowLayout {
            Layout.fillWidth: true

            Toolbar {
                id: toolbar
                Layout.fillWidth: true
                hasConnections: connectionListPage.count > 0
                visible: stack.depth === 1
            }

            Loader {
                sourceComponent: stack.currentItem?.headerItems
                visible: !!item
            }
        }
    }

    Connections {
        target: full.nmHandler
        function onWifiCodeReceived(data, ssid) {
            if (data.length === 0) {
                console.error("Cannot create QR code component: Unsupported connection");
                return;
            }

            const showQRComponent = Qt.createComponent("ShareNetworkQrCodePage.qml");
            if (showQRComponent.status === Component.Error) {
                console.warn("Cannot create QR code component:", showQRComponent.errorString());
                return;
            }

            mainWindow.expanded = true; // just in case.
            stack.push(showQRComponent, {
                content: data,
                ssid
            });
        }
    }

    Keys.forwardTo: [stack.currentItem]
    Keys.onPressed: event => {
        if (event.modifiers & Qt.ControlModifier && event.key == Qt.Key_F) {
            toolbar.searchTextField.forceActiveFocus();
            toolbar.searchTextField.selectAll();
            event.accepted = true;
        } else if (event.key === Qt.Key_Back || (event.modifiers & Qt.AltModifier && event.key == Qt.Key_Left)) {
            if (stack.depth > 1) {
                stack.pop();
                event.accepted = true;
            }
        } else {
            event.accepted = false;
        }
    }

    contentItem: Item {

    QQC2.StackView {
        id: stack
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: backButton.visible ? backButton.top : parent.bottom
        anchors.leftMargin: -Kirigami.Units.largeSpacing
        anchors.bottomMargin: -Kirigami.Units.largeSpacing
        //anchors.bottomMargin: Kirigami.Units.smallSpacing
        initialItem: ConnectionListPage {
            id: connectionListPage
            model: appletProxyModel
            nmStatus: full.nmStatus
        }

        popEnter: Transition {}
        popExit: Transition {}
        pushEnter: Transition {}
        pushExit: Transition {}
        replaceEnter: Transition {}
        replaceExit: Transition {}
    }

    QQC2.Button {
        id: backButton
        //anchors.top: stack.bottom

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        //Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        text: "Back"
        visible: stack.depth > 1
        onClicked: {
            stack.pop()
        }
    }
    }

    Connections {
        target: mainWindow
        function onExpandedChanged(expanded) {
            if (expanded) {
                handler.requestScan();
                if (!full.connectionModel) {
                    full.connectionModel = networkModelComponent.createObject(full);
                }
            } else {
                /*if (full.connectionModel) {
                    full.connectionModel.destroy();
                    full.connectionModel = null;
                }*/
            }
        }
    }
}
