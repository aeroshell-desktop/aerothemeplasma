/*
    SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2012 Viranch Mehta <viranch.mehta@gmail.com>
    SPDX-FileCopyrightText: 2014-2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

function stringForBatteryState(batteryData, source) {
    if (batteryData["Plugged in"]) {
        // When we are using a charge threshold, the kernel
        // may stop charging within a percentage point of the actual threshold
        // and this is considered correct behavior, so we have to handle
        // that. See https://bugzilla.kernel.org/show_bug.cgi?id=215531.
        if (typeof source.data["Battery"]["Charge Stop Threshold"] === "number"
            && (batteryData.Percent >= source.data["Battery"]["Charge Stop Threshold"] - 1
            && batteryData.Percent <= source.data["Battery"]["Charge Stop Threshold"] + 1)
            // Also, Upower may give us a status of "Not charging" rather than
            // "Fully charged", so we need to account for that as well. See
            // https://gitlab.freedesktop.org/upower/upower/-/issues/142.
            && (batteryData.State === "NoCharge" || batteryData.State === "FullyCharged")
            && batteryData["Is Power Supply"]
        ) {
            return i18n("Fully Charged");
        }

        // Otherwise, just look at the charge state
        switch(batteryData["State"]) {
            case "Discharging": return i18n("Discharging");
            case "FullyCharged": return i18n("Fully Charged");
            case "Charging": return i18n("Charging");
            // when in doubt we're not charging
            default: return i18n("Not Charging");
        }
    } else {
        return i18nc("Battery is currently not present in the bay", "Not present");
    }
}

function updateInhibitions(rootItem, source) {
    const inhibitions = [];
    const manualInhibitions = [];

    if (source.data["Inhibitions"]) {
        for (let key in pmSource.data["Inhibitions"]) {
            if (key === "plasmashell" || key === "plasmoidviewer") {
                manualInhibitions.push(key);
            } else {
                inhibitions.push(pmSource.data["Inhibitions"][key]);
            }
        }
    }

    rootItem.manuallyInhibited = manualInhibitions.length > 0;
    rootItem.inhibitions = inhibitions;
}
