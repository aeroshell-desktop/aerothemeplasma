/*
    SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2011 Viranch Mehta <viranch.mehta@gmail.com>
    SPDX-FileCopyrightText: 2013-2015 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2021-2022 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.coreaddons as KCoreAddons
import org.kde.kcmutils // KCMLauncher
import org.kde.config // KAuthorized
import org.kde.notification
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

import "logic.js" as Logic

PlasmoidItem {
    id: batterymonitor

    property QtObject pmSource: P5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: sources
        onSourceAdded: source => {
            disconnectSource(source);
            connectSource(source);
        }
        onSourceRemoved: source => {
            disconnectSource(source);
        }
        onDataChanged: {
            Logic.updateInhibitions(batterymonitor, pmSource);
        }
    }
    property QtObject batteries: KItemModels.KSortFilterProxyModel {
        id: batteries
        filterRoleName: "Is Power Supply"
        sortOrder: Qt.DescendingOrder
        sourceModel: KItemModels.KSortFilterProxyModel {
            sortRoleName: "Pretty Name"
            sortOrder: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
            sourceModel: P5Support.DataModel {
                dataSource: pmSource
                sourceFilter: "Battery[0-9]+"
            }
        }
    }



    property int batteryCapacity: batteries.sourceModel.sourceModel.dataSource.data["Battery0"] !== undefined ? batteries.sourceModel.sourceModel.dataSource.data["Battery0"].Capacity : 0
    readonly property bool isBroken: batteryCapacity > 0 && batteryCapacity < 50
    readonly property bool hasBatteries: batteries.count > 0 && pmSource.data["Battery"]["Has Cumulative"]
    readonly property bool kcmAuthorized: KAuthorized.authorizeControlModule("powerdevilprofilesconfig")
    readonly property bool kcmEnergyInformationAuthorized: KAuthorized.authorizeControlModule("kcm_energyinfo")
    readonly property bool isPluggedIn: pmSource.data["AC Adapter"]["Plugged in"]
    readonly property bool isSomehowFullyCharged: (pmSource.data["AC Adapter"]["Plugged in"] && pmSource.data["Battery"]["State"] === "FullyCharged") ||
                                                   // When we are using a charge threshold, the kernel
                                                   // may stop charging within a percentage point of the actual threshold
                                                   // and this is considered correct behavior, so we have to handle
                                                   // that. See https://bugzilla.kernel.org/show_bug.cgi?id=215531.
                                                   (pmSource.data["AC Adapter"]["Plugged in"]
                                                   && typeof pmSource.data["Battery"]["Charge Stop Threshold"] === "number"
                                                   && (pmSource.data.Battery.Percent  >= pmSource.data["Battery"]["Charge Stop Threshold"] - 1
                                                       && pmSource.data.Battery.Percent  <= pmSource.data["Battery"]["Charge Stop Threshold"] + 1)
                                                   // Also, Upower may give us a status of "Not charging" rather than
                                                   // "Fully charged", so we need to account for that as well. See
                                                   // https://gitlab.freedesktop.org/upower/upower/-/issues/142.
                                                   && (pmSource.data["Battery"]["State"] === "NoCharge" || pmSource.data["Battery"]["State"] === "FullyCharged"))
    readonly property int remainingTime: Number(pmSource.data["Battery"]["Smoothed Remaining msec"])

    readonly property var profiles: pmSource.data["Power Profiles"] ? (pmSource.data["Power Profiles"]["Profiles"] || []) : []
    property bool isManuallyInPerformanceMode: false // to be set on power profile requested through the applet
    property bool isManuallyInPowerSaveMode: false // to be set on power profile requested through the applet
    readonly property bool isSomehowInPerformanceMode: actuallyActiveProfile === "performance"// Don't care about whether it was manually one or due to holds
    readonly property bool isSomehowInPowerSaveMode: actuallyActiveProfile === "power-saver" // Don't care about whether it was manually one or due to holds
    readonly property bool isHeldOnPerformanceMode: isSomehowInPerformanceMode && activeProfileHolds.length > 0
    readonly property bool isHeldOnPowerSaveMode: isSomehowInPowerSaveMode && activeProfileHolds.length > 0

    readonly property bool inPanel: (Plasmoid.location === PlasmaCore.Types.TopEdge
        || Plasmoid.location === PlasmaCore.Types.RightEdge
        || Plasmoid.location === PlasmaCore.Types.BottomEdge
        || Plasmoid.location === PlasmaCore.Types.LeftEdge)

    property bool powermanagementDisabled: false

    // List of active power management inhibitions (applications that are
    // blocking sleep and screen locking).
    //
    // type: [{
    //  Icon: string,
    //  Name: string,
    //  Reason: string,
    // }]
    property var inhibitions: []
    property bool manuallyInhibited: false
    readonly property var activeProfileHolds: pmSource.data["Power Profiles"] ? (pmSource.data["Power Profiles"]["Profile Holds"] || []) : []
    readonly property string actuallyActiveProfile: pmSource.data["Power Profiles"] ? (pmSource.data["Power Profiles"]["Current Profile"] || "") : ""

    function symbolicizeIconName(iconName) {
        const symbolicSuffix = "-symbolic";
        if (iconName.endsWith(symbolicSuffix)) {
            return iconName;
        }

        return iconName + symbolicSuffix;
    }

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 10

    Plasmoid.title: "More power options"//hasBatteries ? i18n("Power and Battery") : i18n("Power Management")

    LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Plasmoid.status: {
        if (powermanagementDisabled) {
            return PlasmaCore.Types.ActiveStatus;
        }

        if (pmSource.data.Battery["Has Cumulative"] && pmSource.data["Battery"]["State"] === "Discharging") {
            return PlasmaCore.Types.ActiveStatus;
        }

        if (isManuallyInPerformanceMode || isManuallyInPowerSaveMode || isHeldOnPerformanceMode || isHeldOnPowerSaveMode) {
            return PlasmaCore.Types.ActiveStatus;
        }

        return PlasmaCore.Types.PassiveStatus;
    }

    toolTipMainText: {
        if (!hasBatteries) {
            return Plasmoid.title
        } else if (isSomehowFullyCharged) {
            return i18n("Fully Charged");
        }

        const percent = pmSource.data.Battery.Percent;
        if (pmSource.data["AC Adapter"] && pmSource.data["AC Adapter"]["Plugged in"]) {
            const state = pmSource.data.Battery.State;
            if (state === "NoCharge") {
                return i18n("Battery at %1%, not Charging", percent);
            } else if (state === "Discharging") {
                return i18n("Battery at %1%, plugged in but still discharging", percent);
            } else if (state === "Charging") {
                return i18n("Battery at %1%, Charging", percent);
            }
        }
        return i18n("Battery at %1%", percent);
    }

    toolTipSubText: {
        const parts = [];

        // Add special text for the "plugged in but still discharging" case
        if (pmSource.data["AC Adapter"] && pmSource.data["AC Adapter"]["Plugged in"] && pmSource.data.Battery.State === "Discharging") {
            parts.push(i18n("The power supply is not powerful enough to charge the battery"));
        }

        if (batteries.count === 0) {
            parts.push(i18n("No Batteries Available"));
        } else if (remainingTime > 0) {
            const remainingTimeString = KCoreAddons.Format.formatDuration(remainingTime, KCoreAddons.FormatTypes.HideSeconds);
            if (pmSource.data["Battery"]["State"] === "FullyCharged") {
                // Don't add anything
            } else if (pmSource.data["AC Adapter"] && pmSource.data["AC Adapter"]["Plugged in"] && pmSource.data.Battery.State === "Charging") {
                parts.push(i18nc("time until fully charged - HH:MM","%1 until fully charged", remainingTimeString));
            } else {
                parts.push(i18nc("remaining time left of battery usage - HH:MM","%1 remaining", remainingTimeString));
            }
        } else if (pmSource.data.Battery.State === "NoCharge" && !isSomehowFullyCharged) {
            parts.push(i18n("Not charging"));
        } // otherwise, don't add anything

        if (powermanagementDisabled) {
            parts.push(i18n("Automatic sleep and screen locking are disabled"));
        }

        if (isSomehowInPerformanceMode) {
            if (isHeldOnPerformanceMode) {
                parts.push(i18np("An application has requested activating Performance mode",
                                 "%1 applications have requested activating Performance mode",
                                 activeProfileHolds.length));
            } else {
                parts.push(i18n("System is in Performance mode"));
            }
        } else if (isSomehowInPowerSaveMode) {
            if (isHeldOnPowerSaveMode) {
                parts.push(i18np("An application has requested activating Power Save mode",
                                "%1 applications have requested activating Power Save mode",
                                activeProfileHolds.length));
            } else {
                parts.push(i18n("System is in Power Save mode"));
            }
        }

        return parts.join("\n");
    }

    Plasmoid.icon: {
        let iconName;
        if (hasBatteries) {
            iconName = "battery-full";
        } else {
            iconName = "battery-profile-performance";
        }

        if (inPanel) {
            return symbolicizeIconName(iconName);
        }

        return iconName;
    }

    compactRepresentation: CompactRepresentation {
        hasBatteries: batterymonitor.hasBatteries
        batteries: batterymonitor.batteries
        isSetToPerformanceMode: batterymonitor.isHeldOnPerformanceMode || batterymonitor.isManuallyInPerformanceMode
        isSetToPowerSaveMode: batterymonitor.isHeldOnPowerSaveMode || batterymonitor.isManuallyInPowerSaveMode
        isSomehowFullyCharged: batterymonitor.isSomehowFullyCharged
    }

    fullRepresentation: PopupDialog {
        id: dialogItem

        readonly property var appletInterface: batterymonitor
        readonly property int flyoutIntendedWidth: 16 * 15

        Layout.minimumWidth: 16 * 10

        Layout.minimumHeight: Kirigami.Units.gridUnit * 5
        Layout.maximumHeight: Kirigami.Units.gridUnit * 40
        Layout.preferredHeight: implicitHeight

        model: batteries

        pluggedIn: pmSource.data["AC Adapter"] !== undefined && pmSource.data["AC Adapter"]["Plugged in"]
        remainingTime: batterymonitor.remainingTime
        activeProfile: batterymonitor.actuallyActiveProfile
        inhibitions: batterymonitor.inhibitions
        manuallyInhibited: batterymonitor.manuallyInhibited
        inhibitsLidAction: pmSource.data["PowerDevil"] && pmSource.data["PowerDevil"]["Is Lid Present"] && !pmSource.data["PowerDevil"]["Triggers Lid Action"] ? true : false
        profilesInstalled: pmSource.data["Power Profiles"] ? pmSource.data["Power Profiles"]["Installed"] : false
        profiles: pmSource.data["Power Profiles"] ? (pmSource.data["Power Profiles"]["Profiles"] || []) : []
        inhibitionReason: pmSource.data["Power Profiles"] ? (pmSource.data["Power Profiles"]["Performance Inhibited Reason"] || "") : ""
        degradationReason: pmSource.data["Power Profiles"] ? (pmSource.data["Power Profiles"]["Performance Degraded Reason"] || "") : ""
        profileHolds: batterymonitor.activeProfileHolds

        onInhibitionChangeRequested: inhibit => {
            const service = pmSource.serviceForSource("PowerDevil");
            if (inhibit) {
                const reason = i18n("The battery applet has enabled system-wide inhibition");
                const op1 = service.operationDescription("beginSuppressingSleep");
                op1.reason = reason;
                const op2 = service.operationDescription("beginSuppressingScreenPowerManagement");
                op2.reason = reason;

                const job1 = service.startOperationCall(op1);
                const job2 = service.startOperationCall(op2);
            } else {
                const op1 = service.operationDescription("stopSuppressingSleep");
                const op2 = service.operationDescription("stopSuppressingScreenPowerManagement");

                const job1 = service.startOperationCall(op1);
                const job2 = service.startOperationCall(op2);
            }
            Logic.updateInhibitions(batterymonitor, pmSource);
        }
        onPowerManagementChanged: disabled => {
            batterymonitor.powermanagementDisabled = disabled
        }

        Notification {
            id: powerProfileError
            componentName: "plasma_workspace"
            eventId: "warning"
            iconName: "speedometer"
            title: i18n("Power Management")
        }

        onActivateProfileRequested: profile => {
            dialogItem.activeProfile = profile;
            const service = pmSource.serviceForSource("PowerDevil");
            const op = service.operationDescription("setPowerProfile");
            op.profile = profile;

            const job = service.startOperationCall(op);
            job.finished.connect(job => {
                dialogItem.activeProfile = Qt.binding(() => actuallyActiveProfile);
                if (!job.result) {
                    powerProfileError.text = i18n("Failed to activate %1 mode", profile);
                    powerProfileError.sendEvent();
                    return;
                }
                batterymonitor.isManuallyInPerformanceMode = profile == "performance";
                batterymonitor.isManuallyInPowerSaveMode = profile == "power-saver";
            });
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("&Show Energy Information…")
            icon.name: "documentinfo"
            visible: batterymonitor.kcmEnergyInformationAuthorized
            onTriggered: KCMLauncher.openInfoCenter("kcm_energyinfo")
        }/*,
        PlasmaCore.Action {
            text: i18n("Show Battery Percentage on Icon When Not Fully Charged")
            icon.name: "format-number-percent"
            visible: batterymonitor.hasBatteries
            checkable: true
            checked: Plasmoid.configuration.showPercentage
            onTriggered: checked => {
                Plasmoid.configuration.showPercentage = checked
            }
        }*/
    ]

    PlasmaCore.Action {
        id: configureAction
        text: i18n("&Configure Energy Saving…")
        icon.name: "configure"
        shortcut: "alt+d, s"
        onTriggered: {
            KCMLauncher.openSystemSettings("kcm_powerdevilprofilesconfig");
        }
    }

    Component.onCompleted: {
        Logic.updateInhibitions(batterymonitor, pmSource)

        Plasmoid.setInternalAction("configure", configureAction);

    }
}
