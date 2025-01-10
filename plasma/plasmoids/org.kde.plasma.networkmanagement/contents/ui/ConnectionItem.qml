/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kcmutils as KCMUtils

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasmoid 2.0

ExpandableListItem {
    id: connectionItem

    property bool activating: ConnectionState === PlasmaNM.Enums.Activating
    property bool deactivated: ConnectionState === PlasmaNM.Enums.Deactivated
    property bool passwordIsStatic: (SecurityType === PlasmaNM.Enums.StaticWep || SecurityType == PlasmaNM.Enums.WpaPsk ||
                                     SecurityType === PlasmaNM.Enums.Wpa2Psk || SecurityType == PlasmaNM.Enums.SAE)
    property bool predictableWirelessPassword: !Uuid && Type === PlasmaNM.Enums.Wireless && passwordIsStatic
    property bool showSpeed: mainWindow.expanded &&
                             ConnectionState === PlasmaNM.Enums.Activated &&
                             (Type === PlasmaNM.Enums.Wired ||
                              Type === PlasmaNM.Enums.Wireless ||
                              Type === PlasmaNM.Enums.Gsm ||
                              Type === PlasmaNM.Enums.Cdma)

    property real rxSpeed: 0
    property real txSpeed: 0

    icon: {
        if(Type === PlasmaNM.Enums.Wired) {
            if(ConnectionState !== PlasmaNM.Enums.Activated) return "network-type-public";
            else {
                var details = model.ConnectionDetails;
                var privateIp = details.length >= 1 ? details[1] : ""
                if(privateIp.startsWith("192.168")) return "network-type-home";
                else return "network-type-work";
            }
        } else {
            return model.ConnectionIcon + "-flyout";
        }

    }//model.ConnectionIcon

    // Hotfix to "hide" undefined items
    Component.onCompleted: {
        if(typeof model.ItemUniqueName == "undefined") {
            height = -connectionView.spacing;
            visible = false;
        }
    }

    title: model.ItemUniqueName
    subtitle: itemText()
    isBusy: false
    //isBusy: mainWindow.expanded && model.ConnectionState === PlasmaNM.Enums.Activating
    isDefault: ConnectionState === PlasmaNM.Enums.Activated
    //defaultActionButtonAction:
    showDefaultActionButtonWhenBusy: false

    Keys.onPressed: event => {
        if (!connectionItem.expanded) {
            event.accepted = false;
            return;
        }

        /*if ((customExpandedViewContent === detailsComponent) && showSpeed) {
            if (event.key === Qt.Key_Right) {
                customExpandedViewContentItem.detailsTabBar.currentIndex = 1;
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                customExpandedViewContentItem.detailsTabBar.currentIndex = 0;
                event.accepted = true;
            }
        }*/
    }

    Connections {
        target: connectionItem.mouseArea
        function onPressed(mouse) {
            contextMenu.show(this, mouse.x, mouse.y);
        }
    }
    PlasmaExtras.Menu {
        id: contextMenu
        property string text

        function show(item, x, y) {
            visualParent = connectionItem
            open(x, y)
        }


        PlasmaExtras.MenuItem {
            readonly property bool isDeactivated: model.ConnectionState === PlasmaNM.Enums.Deactivated
            enabled: {
                if (!connectionItem.expanded) {
                    return true;
                }
                if (connectionItem.customExpandedViewContent === passwordDialogComponent) {
                    return connectionItem.customExpandedViewContentItem?.passwordField.acceptableInput ?? false;
                }
                return true;
            }

            //icon.name: isDeactivated ? "network-connect" : "network-disconnect"
            text: isDeactivated ? i18n("Connect") : i18n("Disconnect")
            onClicked: changeState()
        }
        PlasmaExtras.MenuItem {
            text: i18n("Speed")
            icon: "preferences-system-performance"
            onClicked: {
                const speedGraphComponent = Qt.createComponent("SpeedGraphPage.qml");
                if (speedGraphComponent.status === Component.Error) {
                    console.warn("Cannot create speed graph component:", speedGraphComponent.errorString());
                    return;
                }

                mainWindow.expanded = true; // just in case.
                stack.push(speedGraphComponent, {
                    downloadSpeed: Qt.binding(() => rxSpeed),
                    uploadSpeed: Qt.binding(() => txSpeed),
                    connectionTitle: Qt.binding(() => model.ItemUniqueName)
                });
            }
        }
        PlasmaExtras.MenuItem {
            //text: i18n("Copy")
            text: i18n("Show Network's QR Code")
            icon: "view-barcode-qr"
            visible: Uuid && Type === PlasmaNM.Enums.Wireless && passwordIsStatic
            onClicked: handler.requestWifiCode(ConnectionPath, Ssid, SecurityType);
        }
        PlasmaExtras.MenuItem {
            text: i18n("Configure…")
            icon: "configure"
            onClicked: KCMUtils.KCMLauncher.openSystemSettings(mainWindow.kcm, ["--args", "Uuid=" + Uuid])
        }
    }
    contextualActions: [
        Action {
            id: stateChangeButton

            readonly property bool isDeactivated: model.ConnectionState === PlasmaNM.Enums.Deactivated

            enabled: {
                if (!connectionItem.expanded) {
                    return true;
                }
                if (connectionItem.customExpandedViewContent === passwordDialogComponent) {
                    return connectionItem.customExpandedViewContentItem?.passwordField.acceptableInput ?? false;
                }
                return true;
            }

            //icon.name: isDeactivated ? "network-connect" : "network-disconnect"
            text: isDeactivated ? i18n("Connect") : i18n("Disconnect")
            onTriggered: changeState()
        },
        Action {
            text: i18n("Details")
            //icon.name: "configure"
            onTriggered: {
                const showDetailscomponent = Qt.createComponent("NetworkDetailsPage.qml");
                if (showDetailscomponent.status === Component.Error) {
                    console.warn("Cannot create details page component:", showDetailscomponent.errorString());
                    return;
                }

                mainWindow.expanded = true; // just in case.
                connectionItem.collapse()
                stack.push(showDetailscomponent, {
                    details: Qt.binding(() => ConnectionDetails),
                    connectionTitle: Qt.binding(() => model.ItemUniqueName)
                });
            }
        }/*,
        Action {
            enabled: Uuid && Type === PlasmaNM.Enums.Wireless && passwordIsStatic
            text: i18n("Show Network's QR Code")
            icon.name: "view-barcode-qr"
            onTriggered: handler.requestWifiCode(ConnectionPath, Ssid, SecurityType);
        },
        Action {
            text: i18n("Configure…")
            icon.name: "configure"
            onTriggered: KCMUtils.KCMLauncher.openSystemSettings(mainWindow.kcm, ["--args", "Uuid=" + Uuid])
        }*/
    ]

    /*Component {
        id: buttonsComponent
        Column {
            Button {
                text: i18n("Details")
                onClicked: {
                    const showDetailscomponent = Qt.createComponent("NetworkDetailsPage.qml");
                    if (showDetailscomponent.status === Component.Error) {
                        console.warn("Cannot create QR code component:", showDetailscomponent.errorString());
                        return;
                    }

                    mainWindow.expanded = true; // just in case.
                    stack.push(showDetailscomponent, {
                        details: ConnectionDetails
                    });
                }
            }
        }
    }*/

    //customExpandedViewContent: detailsComponent

    Accessible.description: `${model.AccessibleDescription} ${subtitle}`

    /*Component {
        id: detailsComponent

        Column {
            visible: false
            spacing: Kirigami.Units.smallSpacing
            property Item detailsTabBar: detailsTabBar


            PlasmaComponents3.TabBar {
                id: detailsTabBar

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: visible ? implicitHeight : 0
                implicitHeight: contentHeight
                position: PlasmaComponents3.TabBar.Header
                visible: false //showSpeed

                onCurrentIndexChanged: {
                    // Only if there are the two tabs.
                    if (showSpeed) {
                        Plasmoid.configuration.currentDetailsTab = ["speed", "details"][currentIndex];
                    }
                }

                onVisibleChanged: {
                    if (!visible) {
                        currentIndex = 1;
                    }
                }

                PlasmaComponents3.TabButton {
                    id: speedTabButton
                    text: i18n("Speed")
                }

                PlasmaComponents3.TabButton {
                    id: detailsTabButton
                    text: i18n("Details")
                }

                Component.onCompleted: {
                    if (!showSpeed || Plasmoid.configuration.currentDetailsTab === "details") {
                        currentIndex = 1;
                    }
                }
            }

            DetailsText {
                id: detailsTextColumn

                width: parent.width
                visible: detailsTabBar.currentIndex === 1

                activeFocusOnTab: details.length > 0
                details: ConnectionDetails

                Accessible.description: details.join(" ")

                Loader {
                    anchors.fill: parent
                    active: parent.activeFocus
                    asynchronous: true
                    z: -1

                    sourceComponent: PlasmaExtras.Highlight {
                        hovered: true
                    }
                }
            }

            FocusScope {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: trafficMonitorGraph.implicitHeight
                visible: false// detailsTabBar.currentIndex === 0

                activeFocusOnTab: true

                Accessible.description: i18nc("@info:tooltip", "Current download speed is %1 kibibytes per second; current upload speed is %2 kibibytes per second", Math.round(rxSpeed / 1024), Math.round(txSpeed / 1024))

                Loader {
                    anchors.fill: parent
                    active: parent.activeFocus
                    asynchronous: true
                    z: -1

                    sourceComponent: PlasmaExtras.Highlight {
                        hovered: true
                    }
                }

                TrafficMonitor {
                    id: trafficMonitorGraph
                    width: parent.width
                    downloadSpeed: rxSpeed
                    uploadSpeed: txSpeed
                }
            }

        }
    }*/

    Component {
        id: passwordDialogComponent

        ColumnLayout {
            property alias password: passwordField.text
            property alias passwordField: passwordField

            PasswordField {
                id: passwordField

                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.iconSizes.small
                Layout.rightMargin: Kirigami.Units.iconSizes.small

                securityType: SecurityType

                onAccepted: {
                    stateChangeButton.trigger()
                    //connectionItem.customExpandedViewContent = detailsComponent
                }

                Component.onCompleted: {
                    passwordField.forceActiveFocus()
                    setDelayModelUpdates(true)
                }
            }
        }
    }

    Timer {
        id: timer
        repeat: true
        interval: 2000
        running: showSpeed
        triggeredOnStart: true
        // property int can overflow with the amount of bytes.
        property double prevRxBytes: 0
        property double prevTxBytes: 0
        onTriggered: {
            rxSpeed = prevRxBytes === 0 ? 0 : (RxBytes - prevRxBytes) * 1000 / interval
            txSpeed = prevTxBytes === 0 ? 0 : (TxBytes - prevTxBytes) * 1000 / interval
            prevRxBytes = RxBytes
            prevTxBytes = TxBytes
        }
    }

    function changeState() {
        if (Uuid || !predictableWirelessPassword || connectionItem.customExpandedViewContent == passwordDialogComponent) {
            if (ConnectionState == PlasmaNM.Enums.Deactivated) {
                if (!predictableWirelessPassword && !Uuid) {
                    handler.addAndActivateConnection(DevicePath, SpecificPath)
                } else if (connectionItem.customExpandedViewContent == passwordDialogComponent) {
                    const item = connectionItem.customExpandedViewContentItem;
                    if (item && item.password !== "") {
                        handler.addAndActivateConnection(DevicePath, SpecificPath, item.password)
                        //connectionItem.customExpandedViewContent = detailsComponent
                        connectionItem.collapse()
                    } else {
                        connectionItem.expand()
                    }
                } else {
                    handler.activateConnection(ConnectionPath, DevicePath, SpecificPath)
                }
            } else {
                handler.deactivateConnection(ConnectionPath, DevicePath)
            }
        } else if (predictableWirelessPassword) {
            setDelayModelUpdates(true)
            connectionItem.customExpandedViewContent = passwordDialogComponent
            connectionItem.expand()
        }
    }

    /* This generates the formatted text under the connection name
       in the popup where the connections can be "Connect"ed and
       "Disconnect"ed. */
    function itemText() {
        if (ConnectionState === PlasmaNM.Enums.Activating) {
            if (Type === PlasmaNM.Enums.Vpn) {
                return VpnState
            } else {
                return DeviceState
            }
        } else if (ConnectionState === PlasmaNM.Enums.Deactivating) {
            if (Type === PlasmaNM.Enums.Vpn) {
                return VpnState
            } else {
                return DeviceState
            }
        } else if (Uuid && ConnectionState === PlasmaNM.Enums.Deactivated) {
            return LastUsed
        } else if (ConnectionState === PlasmaNM.Enums.Activated) {
            if (showSpeed) {
                return i18n("Connected, ⬇ %1/s, ⬆ %2/s",
                    KCoreAddons.Format.formatByteSize(rxSpeed),
                    KCoreAddons.Format.formatByteSize(txSpeed))
            } else {
                return i18n("Connected")
            }
        }
        return ""
    }

    function setDelayModelUpdates(delay: bool) {
        appletProxyModel.setData(appletProxyModel.index(index, 0), delay, PlasmaNM.NetworkModel.DelayModelUpdatesRole);
    }

    onShowSpeedChanged: {
        connectionModel.setDeviceStatisticsRefreshRateMs(DevicePath, showSpeed ? 2000 : 0)
    }

    onActivatingChanged: {
        if (ConnectionState === PlasmaNM.Enums.Activating) {
            ListView.view.positionViewAtBeginning()
        }
    }

    onDeactivatedChanged: {
        /* Separator is part of section, which is visible only when available connections exist. Need to determine
           if there is a connection in use, to show Separator. Otherwise need to hide it from the top of the list.
           Connections in use are always on top, only need to check the first one. */
        if (appletProxyModel.data(appletProxyModel.index(0, 0), PlasmaNM.NetworkModel.SectionRole) !== "Available connections") {
            if (connectionView.showSeparator != true) {
                connectionView.showSeparator = true
            }
            return
        }
        connectionView.showSeparator = false
        return
    }

    onItemCollapsed: {
        //connectionItem.customExpandedViewContent = detailsComponent;
        setDelayModelUpdates(false);
    }
    Component.onDestruction: {
        setDelayModelUpdates(false);
    }
}
