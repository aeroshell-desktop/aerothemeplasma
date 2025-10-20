/*
    SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
    SPDX-FileCopyrightText: 2013-2015 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls

import org.kde.coreaddons as KCoreAddons
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.workspace.components as WorkspaceComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.private.battery

QtControls.ItemDelegate {
    id: root

    property int batteryPercent: 0

    property int batteryCapacity: 0

    property real batteryEnergy: 0.0

    // NOTE: According to the UPower spec this property is only valid for primary batteries, however
    // UPower seems to set the Present property false when a device is added but not probed yet
    property bool batteryPluggedIn: false

    property bool batteryIsPowerSupply: false

    // NoCharge: 0
    // Charging: 1
    // Discharging: 2
    // FullyCharged: 3
    property int batteryChargeState: 0

    property string batteryPrettyName: ""

    property string batteryType: ""

    readonly property bool isBroken: root.batteryCapacity > 0 && root.batteryCapacity < 50

    readonly property bool isBrokenPowerSupply: isBroken && batteryIsPowerSupply

    property bool pluggedIn: false

    property int remainingTime: 0

    property int chargeStopThreshold: 0

    // Existing instance of a slider to use as a reference to calculate extra
    // margins for a progress bar, so that the row of labels on top of it
    // could visually look as if it were on the same distance from the bar as
    // they are from the slider.
    property PlasmaComponents3.Slider matchHeightOfSlider: PlasmaComponents3.Slider {}
    readonly property real extraMargin: Math.max(0, Math.floor((matchHeightOfSlider.height) / 2))

    background.visible: false
    //highlighted: activeFocus
    hoverEnabled: false
    text: batteryPrettyName

    Accessible.description: `${batteryPrettyName} ${batteryPercent}%; ${pluggedIn ? i18n("plugged in") : i18n("not plugged in")}`

    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        FlyoutBatteryIcon {
            id: batteryIcon
            Layout.alignment: Qt.AlignTop
            // Primary batteries get bigger icons
            Layout.preferredWidth: root.batteryType === "Battery" ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.small
            Layout.preferredHeight: root.batteryType === "Battery" ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.small
            hasBattery: root.batteryPluggedIn
            percent: root.batteryPercent
            pluggedIn: root.pluggedIn && root.batteryIsPowerSupply
            batteryType: root.batteryType
            broken: root.isBroken

            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                location: PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop
                mainText: root.batteryPrettyName
                subText: {
                    var result = "";
                    if(root.batteryCapacity !== 0) {
                        result += i18n("Health: %1%", root.batteryCapacity) + "\n";
                    }
                    result += i18n("Type: %1", root.batteryType);
                    return result;
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: root.batteryPluggedIn ? Qt.AlignTop : Qt.AlignVCenter
            spacing: 0

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents3.Label {
                    id: detailsLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap

                    readonly property bool remainingTimeRowVisible: root.remainingTime > 0
                        && root.batteryIsPowerSupply
                        && [BatteryControlModel.Discharging, BatteryControlModel.Charging].includes(root.batteryChargeState)

                    readonly property bool isEstimatingRemainingTime: root.batteryIsPowerSupply
                        && root.remainingTime === 0
                        && root.batteryChargeState === BatteryControlModel.Discharging
                    text: {

                        // First row
                        if(root.batteryPluggedIn) {
                            var result = "";
                            if(root.batteryChargeState === BatteryControlModel.FullyCharged) {
                                result = i18nc("Battery is fully charged", "Fully charged (%1%)", root.batteryPercent);

                            } else if(root.batteryChargeState === BatteryControlModel.Charging || root.batteryChargeState === BatteryControlModel.NoCharge) {

                                if(root.batteryChargeState === BatteryControlModel.NoCharge && !root.batteryIsPowerSupply) {
                                    result = i18n("%1% available", root.batteryPercent);

                                } else {
                                    result = i18n("%1% available (plugged in, %2)", root.batteryPercent, root.batteryChargeState === BatteryControlModel.NoCharge ? i18n("not charging") : i18n("charging"));

                                }

                            } else if(root.batteryChargeState === BatteryControlModel.Discharging) {
                                if(detailsLabel.remainingTimeRowVisible && !detailsLabel.isEstimatingRemainingTime) {
                                    result = i18nc("Battery is discharging", "%1 (%2%) remaining", KCoreAddons.Format.formatDuration(root.remainingTime, KCoreAddons.FormatTypes.AbbreviatedDuration | KCoreAddons.FormatTypes.HideSeconds), root.batteryPercent);
                                } else {
                                    result = i18nc("Battery is discharging", "%1% remaining", root.batteryPercent);
                                }

                            }
                        } else {
                          return i18nc("Battery is currently not present in the bay", "Not present");
                        }

                        // Second row
                        if(root.pluggedIn && root.batteryIsPowerSupply && root.chargeStopThreshold > 0 && root.chargeStopThreshold < 100) {
                            result += "\n" + i18n("Battery is configured to charge up to approximately %1%.", root.chargeStopThreshold);
                        }

                        if(root.isBroken) {
                            result += "\n" + i18n("Consider replacing your battery.");
                        }

                        return result;
                    }
                    textFormat: Text.PlainText
                }

                //visible: root.batteryIsPowerSupply || root.batteryChargeState !== BatteryControlModel.NoCharge
            }
        }
    }
}
