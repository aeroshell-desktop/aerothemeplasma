/*
    SPDX-FileCopyrightText: 2011 Viranch Mehta <viranch.mehta@gmail.com>
    SPDX-FileCopyrightText: 2013-2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls

import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.Representation {
    id: dialog

    property alias model: batteryRepeater.model
    property bool pluggedIn
    property int chargeStopThreshold
    property bool isManuallyInhibited
    property bool isManuallyInhibitedError

    property int remainingTime

    property bool profilesInstalled
    property string activeProfile
    property string activeProfileError
    property var profiles

    property bool isTlpInstalled

    property bool containsBrokenBatteries

    // List of active power management inhibitions (applications that are
    // blocking sleep and screen locking).
    //
    // type: [{
    //  Icon: string,
    //  Name: string,
    //  Reason: string,
    // }]
    property var requestedInhibitions: []
    property bool inhibitsLidAction

    property string inhibitionReason
    property string degradationReason
    // type: [{ Name: string, Icon: string, Profile: string, Reason: string }]
    required property var profileHolds

    signal inhibitionChangeRequested(bool inhibit)
    signal activateProfileRequested(string profile)

    //collapseMarginsHint: true

    KeyNavigation.down: powerProfileSelector
    KeyNavigation.up: inhibitionController
    KeyNavigation.tab: powerProfileSelector
    KeyNavigation.backtab: inhibitionController

    contentItem: QtControls.ScrollView {
        id: scrollView

        width: dialog.Layout.preferredWidth

        function positionViewAtItem(item: Item): void {
            if (!PlasmaComponents3.ScrollBar.vertical.visible) {
                return;
            }
            const rect = batteryRepeater.contentItem.mapFromItem(item, 0, 0, item.width, item.height);
            if (rect.y < scrollView.contentItem.contentY) {
                scrollView.contentItem.contentY = rect.y;
            } else if (rect.y + rect.height > scrollView.contentItem.contentY + scrollView.height) {
                scrollView.contentItem.contentY = rect.y + rect.height - scrollView.height;
            }
        }

        ColumnLayout {

            spacing: 0
            width: scrollView.availableWidth

            ListView {
                id: batteryRepeater

                focus: false

                spacing: 0
                Layout.preferredWidth: scrollView.availableWidth
                Layout.preferredHeight: contentItem.childrenRect.height
                acceptedButtons: Qt.NoButton
                boundsBehavior: Flickable.StopAtBounds

                delegate: BatteryItem {
                    id: batteryDelegate
                    focus: false
                    width: batteryRepeater.Layout.preferredWidth
                    batteryPercent: Percent
                    batteryCapacity: Capacity
                    batteryEnergy: Energy
                    batteryPluggedIn: PluggedIn
                    batteryIsPowerSupply: IsPowerSupply
                    batteryChargeState: ChargeState
                    batteryPrettyName: PrettyName
                    batteryType: Type
                    remainingTime: dialog.remainingTime

                    pluggedIn: dialog.pluggedIn
                    chargeStopThreshold: dialog.chargeStopThreshold

                    onActiveFocusChanged: if (activeFocus) scrollView.positionViewAtItem(this)
                }
            }
            Separator {
                Layout.preferredHeight: 1
                Layout.fillWidth: true
                visible: batteryRepeater.count > 0
            }

            PowerProfileItem {
                id: powerProfileSelector
                Layout.preferredWidth: scrollView.availableWidth
                Layout.fillHeight: true

                profilesInstalled: dialog.profilesInstalled
                profilesAvailable: dialog.profiles.length > 0
                activeProfile: dialog.activeProfile
                activeProfileError: dialog.activeProfileError
                inhibitionReason: dialog.inhibitionReason
                degradationReason: dialog.degradationReason
                profileHolds: dialog.profileHolds
                inhibitionControllerRef: inhibitionController

                isTlpInstalled: dialog.isTlpInstalled

                onActivateProfileRequested: profile => {
                    dialog.activateProfileRequested(profile);
                }

                onActiveFocusChanged: if (activeFocus) scrollView.positionViewAtItem(this)
            }

            InhibitionItem {
                id: inhibitionController
                readonly property var inhibitionControl: dialog.inhibitionControl

                focus: true
                Layout.maximumWidth: scrollView.availableWidth
                Layout.preferredWidth: scrollView.availableWidth
                Layout.preferredHeight: inhibitionController.implicitHeight

                KeyNavigation.up: powerProfileSelector.profilesAvailable ? powerProfileSelector.performanceRadio : inhibitionController
                KeyNavigation.down: powerProfileSelector.profilesAvailable ? powerProfileSelector.powerSaverRadio : inhibitionController
                KeyNavigation.backtab:KeyNavigation.up
                KeyNavigation.tab:KeyNavigation.down

                requestedInhibitions: dialog.requestedInhibitions
                isManuallyInhibited: dialog.isManuallyInhibited
                isManuallyInhibitedError: dialog.isManuallyInhibitedError
                inhibitsLidAction: dialog.inhibitsLidAction
                pluggedIn: dialog.pluggedIn

                onInhibitionChangeRequested: inhibit => {
                    batterymonitor.inhibitionChangeRequested(inhibit);
                }

                onActiveFocusChanged: if (activeFocus) scrollView.positionViewAtItem(this)
            }
            InhibitionHint {
                Layout.preferredWidth: scrollView.availableWidth - Layout.leftMargin
                Layout.leftMargin: Kirigami.Units.largeSpacing
                visible: dialog.containsBrokenBatteries
                iconSource: "info"
                text: i18n("There is a problem with your battery, so your computer might shut down suddenly.")
            }
        }
    }
}
