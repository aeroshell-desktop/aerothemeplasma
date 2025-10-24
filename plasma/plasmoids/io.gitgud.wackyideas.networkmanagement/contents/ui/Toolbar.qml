/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Controls
import QtQuick.Layouts 1.2
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kcmutils as KCMUtils
import QtQuick.Controls 2.15 as QQC2
import org.kde.ksvg 1.0 as KSvg

ColumnLayout {
    id: toolbar

    readonly property var displayWifiMessage: !wifiSwitchButton.checked && wifiSwitchButton.visible
    readonly property var displayWwanMessage: !wwanSwitchButton.checked && wwanSwitchButton.visible
    readonly property var displayplaneModeMessage: planeModeSwitchButton.checked && planeModeSwitchButton.visible

    property bool hasConnections
    property alias searchTextField: searchTextField

    PlasmaNM.EnabledConnections {
        id: enabledConnections

        // When user interactively toggles a checkbox, a binding may be
        // preserved, but the state gets out of sync until next relevant
        // notify signal is dispatched. So, we refresh the bindings here.

        onWirelessEnabledChanged: wifiSwitchButton.checked = Qt.binding(() =>
            wifiSwitchButton.administrativelyEnabled && enabledConnections.wirelessEnabled
        );

        onWwanEnabledChanged: wwanSwitchButton.checked = Qt.binding(() =>
            wwanSwitchButton.administrativelyEnabled && enabledConnections.wwanEnabled
        );
    }


    Keys.forwardTo: [searchTextField]

    RowLayout {
        // Add margin before switches for consistency with other applets
        Layout.leftMargin: Kirigami.Units.smallSpacing / 2
        Layout.topMargin: 2

        spacing: parent.spacing

        // Only show when switches are visible (and avoid parent spacing otherwise)
        visible: availableDevices.wirelessDeviceAvailable || availableDevices.modemDeviceAvailable

        QQC2.CheckBox {
            id: wifiSwitchButton

            // can't overload Item::enabled, because it's being used for other things, like Edit Mode on a desktop
            readonly property bool administrativelyEnabled:
                !PlasmaNM.Configuration.airplaneModeEnabled
                && availableDevices.wirelessDeviceAvailable
                && enabledConnections.wirelessHwEnabled

            checked: administrativelyEnabled && enabledConnections.wirelessEnabled
            enabled: administrativelyEnabled

            icon.name: administrativelyEnabled ? ( timer.running ? "network-wireless-acquiring" : "network-wireless-on" ) : "network-wireless-off"
            visible: availableDevices.wirelessDeviceAvailable

            KeyNavigation.right: wwanSwitchButton.visible ? wwanSwitchButton : wwanSwitchButton.KeyNavigation.right

            onToggled: handler.enableWireless(checked);
            text: i18n("Wi-Fi")

            PlasmaComponents3.BusyIndicator {
                parent: wifiSwitchButton
                anchors {
                    fill: wifiSwitchButton.contentItem
                    leftMargin: wifiSwitchButton.indicator.width + wifiSwitchButton.spacing
                }
                z: 1

                visible: false
                // Scanning may be too fast to notice. Prolong the animation up to at least `humanMoment`.
                running: handler.scanning || timer.running
                Timer {
                    id: timer
                    interval: Kirigami.Units.humanMoment
                }
                Connections {
                    target: handler
                    function onScanningChanged() {
                        if (handler.scanning) {
                            timer.restart();
                        }
                    }
                }
            }
        }

        QQC2.CheckBox {
            id: wwanSwitchButton

            // can't overload Item::enabled, because it's being used for other things, like Edit Mode on a desktop
            readonly property bool administrativelyEnabled:
                !PlasmaNM.Configuration.airplaneModeEnabled
                && availableDevices.modemDeviceAvailable
                && enabledConnections.wwanHwEnabled

            checked: administrativelyEnabled && enabledConnections.wwanEnabled
            enabled: administrativelyEnabled

            icon.name: administrativelyEnabled ? "network-mobile-on" : "network-mobile-off"
            visible: availableDevices.modemDeviceAvailable

            KeyNavigation.left: wifiSwitchButton
            KeyNavigation.right: planeModeSwitchButton.visible ? planeModeSwitchButton : planeModeSwitchButton.KeyNavigation.right

            onToggled: handler.enableWwan(checked);

            text: i18n("Mobile network")

        }

        QQC2.CheckBox {
            id: planeModeSwitchButton

            property bool initialized: false

            checked: PlasmaNM.Configuration.airplaneModeEnabled

            icon.name: PlasmaNM.Configuration.airplaneModeEnabled ? "network-flightmode-on" : "network-flightmode-off"

            visible: availableDevices.modemDeviceAvailable || availableDevices.wirelessDeviceAvailable

            KeyNavigation.left: wwanSwitchButton.visible ? wwanSwitchButton : wwanSwitchButton.KeyNavigation.left
            KeyNavigation.right: searchTextField

            text: i18n("Airplane mode")
            onToggled: {
                handler.enableAirplaneMode(checked);
                PlasmaNM.Configuration.airplaneModeEnabled = checked;
            }
        }
        Item {
            Layout.fillWidth: true
        }
        QQC2.Button {
            id: refresh
            checkable: false
            flat: true
            text: ""
            icon.name: "gtk-refresh"
            icon.height: Kirigami.Units.iconSizes.small
            icon.width: Kirigami.Units.iconSizes.small
            Layout.rightMargin: -Kirigami.Units.smallSpacing
            Layout.topMargin: -Kirigami.Units.smallSpacing
            KeyNavigation.right: searchTextField
            KeyNavigation.tab: searchTextField
            onClicked: {
                mainWindow.nmhandler.requestScan()
            }
            Keys.onPressed: event => {
                if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                    mainWindow.nmhandler.requestScan();
                    event.accepted = true;
                }
            }

        }

    }

    TextField {
        id: searchTextField

        Layout.fillWidth: true
        Layout.preferredHeight: text.length > 0 ? Kirigami.Units.smallSpacing * 6 : 0
        opacity: text.length > 0


        visible: true //text.length > 0
        enabled: toolbar.hasConnections || text.length > 0
        rightPadding: Kirigami.Units.iconSizes.small + Kirigami.Units.largeSpacing
        background:	KSvg.FrameSvgItem {
            anchors.fill: parent
            anchors.left: parent.left
            imagePath: Qt.resolvedUrl("svgs/lineedit.svg")
            prefix: "base"

            Kirigami.Icon {
                source: "gtk-search"
                smooth: true
                width: Kirigami.Units.iconSizes.small;
                height: width
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    bottomMargin: 1
                    right: parent.right
                    rightMargin: Kirigami.Units.smallSpacing+1
                }
            }
        }

        // This uses expanded to ensure the binding gets reevaluated
        // when the plasmoid is shown again and that way ensure we are
        // always in the correct state on show.
        focus: true //mainWindow.expanded// && !Kirigami.InputMethod.willShowOnActive
        inputMethodHints: Qt.ImhNoPredictiveText


        KeyNavigation.tab: wifiSwitchButton
        KeyNavigation.backtab: refresh

        onTextChanged: {
            appletProxyModel.setFilterFixedString(text)
        }
    }

    PlasmaComponents3.ToolButton {
        id: openEditorButton

        //visible: mainWindow.kcmAuthorized && !(plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentDrawsPlasmoidHeading)
        visible: false

        icon.name: "configure"

        PlasmaComponents3.ToolTip {
            text: i18n("Configure network connections…")
        }

        onClicked: {
            KCMUtils.KCMLauncher.openSystemSettings(mainWindow.kcm)
        }
    }
}
