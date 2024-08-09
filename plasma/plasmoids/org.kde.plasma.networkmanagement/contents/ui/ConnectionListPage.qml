/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.networkmanager as NMQt

ColumnLayout {
    id: connectionListPage

    required property PlasmaNM.NetworkStatus nmStatus
    property alias model: connectionView.model
    property alias count: connectionView.count

    spacing: Kirigami.Units.smallSpacing * 2

    Keys.forwardTo: [connectionView]

    Kirigami.InlineMessage {
        id: connectivityMessage
        Layout.fillWidth: true
        Layout.leftMargin: connectionView.leftMargin
        Layout.rightMargin: connectionView.rightMargin
        Layout.topMargin: Kirigami.Units.smallSpacing * 2
        Layout.preferredHeight: contentItem.implicitHeight + topPadding + bottomPadding
        type: Kirigami.MessageType.Information
        icon.name: "dialog-password"
        text: i18n("You need to log in to this network")
        visible: connectionListPage.nmStatus.connectivity === NMQt.NetworkManager.Portal

        actions: Kirigami.Action {
            text: i18nc("@action:button", "Log in")
            onTriggered: {
                Qt.openUrlExternally(connectionListPage.nmStatus.networkCheckUrl);
            }
        }
    }

    PlasmaComponents3.ScrollView {
        id: scrollView

        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth - contentItem.leftMargin - contentItem.rightMargin
        PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff

        contentItem: ListView {
            id: connectionView

            property int currentVisibleButtonIndex: -1
            property bool showSeparator: false

            Keys.onDownPressed: event => {
                connectionView.incrementCurrentIndex();
                connectionView.currentItem.forceActiveFocus();
            }
            Keys.onUpPressed: event => {
                if (connectionView.currentIndex === 0) {
                    connectionView.currentIndex = -1;
                    toolbar.searchTextField.forceActiveFocus();
                    toolbar.searchTextField.selectAll();
                } else {
                    event.accepted = false;
                }
            }

            // We use the spacing around the connectivity message, if shown.
            //topMargin: connectivityMessage.visible ? 0 : Kirigami.Units.smallSpacing
            bottomMargin: Kirigami.Units.smallSpacing * 2
            //leftMargin: Kirigami.Units.smallSpacing * 2
            //rightMargin: Kirigami.Units.smallSpacing * 2
            spacing: Kirigami.Units.smallSpacing
            model: appletProxyModel
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds
            section.property: showSeparator ? "Section" : ""
            section.delegate: ListItem {
                separator: true
            }
            highlight: PlasmaExtras.Highlight { }
            highlightMoveDuration: 0//Kirigami.Units.shortDuration
            highlightResizeDuration: 0//Kirigami.Units.shortDuration
            delegate: ConnectionItem {
                width: connectionView.width// - Kirigami.Units.smallSpacing * 4
            }

            // Placeholder message
            Loader {
                anchors.centerIn: parent
                width: parent.width - (Kirigami.Units.largeSpacing * 4)
                active: connectionView.count === 0
                asynchronous: true
                visible: status === Loader.Ready
                sourceComponent: PlasmaExtras.PlaceholderMessage {
                    iconName: {
                        if (toolbar.displayplaneModeMessage) {
                            return "network-flightmode-on"
                        }
                        if (toolbar.displayWifiMessage) {
                            return "network-wireless-off"
                        }
                        if (toolbar.displayWwanMessage) {
                            return "network-mobile-off"
                        }
                        return "edit-none"
                    }
                    text: {
                        if (toolbar.displayplaneModeMessage) {
                            return i18n("Airplane mode is enabled")
                        }
                        if (toolbar.displayWifiMessage) {
                            if (toolbar.displayWwanMessage) {
                                return i18n("Wireless and mobile networks are deactivated")
                            }
                            return i18n("Wireless is deactivated")
                        }
                        if (toolbar.displayWwanMessage) {
                            return i18n("Mobile network is deactivated")
                        }
                        if (toolbar.searchTextField.text.length > 0) {
                            return i18n("No matches")
                        }
                        return i18n("No available connections")
                    }
                }
            }
        }
    }
}
