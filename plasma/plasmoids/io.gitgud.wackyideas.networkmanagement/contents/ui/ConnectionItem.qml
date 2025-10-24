/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kcmutils as KCMUtils

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasmoid 2.0

import org.kde.networkmanager as NMQt

ExpandableListItem {
    id: connectionItem

    property bool activating: ConnectionState === PlasmaNM.Enums.Activating
    deactivated: ConnectionState === PlasmaNM.Enums.Deactivated
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
            if(ConnectionState !== PlasmaNM.Enums.Activated ||
               !(mainWindow.networkStatus.connectivity === NMQt.NetworkManager.Full ||
               mainWindow.networkStatus.connectivity === NMQt.NetworkManager.Portal)) return "network-type-public";
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

    iconEmblem: {
        //return "stock_lock"
        if(SecurityType == PlasmaNM.Enums.UnknownSecurity) return "stock_lock"
        else if(Type == PlasmaNM.Enums.Bluetooth) return "bluetooth-active-symbolic"
        else return undefined;
    }
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
            visible: showSpeed
            onClicked: {
                var winHandler = mainWindow.windowManager.getWindow(model.ItemUniqueName+Uuid);
                if(typeof winHandler !== "undefined") {
                    winHandler.tabBar.currentIndex = 1;
                    winHandler.show();
                } else {
                    mainWindow.windowManager.addWindow(Uuid, ConnectionState, Type, model.ItemUniqueName, full.connectionModel, DevicePath, 1);
                }
                mainWindow.expanded = true; // just in case.
            }
        }
        PlasmaExtras.MenuItem {
            text: i18n("Show Network's QR Code")
            icon: "view-barcode-qr"
            visible: Uuid && Type === PlasmaNM.Enums.Wireless && passwordIsStatic && ConnectionState === PlasmaNM.Enums.Activated
            onClicked: {
                handler.requestWifiCode(ConnectionPath, Ssid, SecurityType);
            }
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
                connectionItem.toggleExpanded();
                var winHandler = mainWindow.windowManager.getWindow(model.ItemUniqueName+Uuid);
                if(typeof winHandler !== "undefined") {
                    winHandler.tabBar.currentIndex = 0;
                    winHandler.show();
                } else {
                    mainWindow.windowManager.addWindow(Uuid, ConnectionState, Type, model.ItemUniqueName, full.connectionModel, DevicePath, 0);
                }
                //mainWindow.expanded = false; // just in case.
            }
        }
    ]

    Accessible.description: `${model.AccessibleDescription} ${subtitle}`

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
            if(mainWindow.networkStatus.connectivity === NMQt.NetworkManager.Portal)
                return "Sign in required";
            else if(mainWindow.networkStatus.connectivity === NMQt.NetworkManager.Limited)
                return "No network access";
            else if(mainWindow.networkStatus.connectivity === NMQt.NetworkManager.Full)
                return "Internet access";
            else
                return "No Internet access";
        }
        return ""
    }

    function setDelayModelUpdates(delay: bool) {
        appletProxyModel.setData(appletProxyModel.index(index, 0), delay, PlasmaNM.NetworkModel.DelayModelUpdatesRole);
    }

    onShowSpeedChanged: {

        var winHandler = mainWindow.windowManager.getWindow(model.ItemUniqueName+Uuid);
        connectionModel.setDeviceStatisticsRefreshRateMs(DevicePath, (typeof winHandler !== "undefined" || showSpeed) ? 2000 : 0)
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

        if (appletProxyModel.data(appletProxyModel.index(0, 0), PlasmaNM.NetworkModel.SectionRole) !== i18n("Available")) {
            if (connectionView.showSeparator != true) {
                connectionView.showSeparator = true;
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
