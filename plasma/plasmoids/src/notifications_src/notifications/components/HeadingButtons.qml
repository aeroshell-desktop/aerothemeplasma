/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import org.kde.notificationmanager as NotificationManager

import org.kde.coreaddons as KCoreAddons

import plasma.applet.io.gitgud.wackyideas.notifications as Notifications

RowLayout {
    id: headingButtons

    property ModelInterface modelInterface: ModelInterface {}

    readonly property string __applicationName: modelInterface.applicationName + (modelInterface.originName ? " · " + modelInterface.originName : "")

    Connections {
        target: headingButtons.modelInterface
        function onTimeChanged() {
            headingButtons.updateAgoText()
        }
    }
    function updateAgoText() {
        ageLabel.agoText = ageLabel.generateAgoText();
    }

    spacing: Kirigami.Units.smallSpacing / 2

    Component.onCompleted: updateAgoText()

    Connections {
        target: Notifications.Globals
        // clock time changed
        function onTimeChanged() {
            headingButtons.updateAgoText()
        }
    }

    Kirigami.Heading {
        id: ageLabel

        // the "n minutes ago" text, for jobs we show remaining time instead
        // updated periodically by a Timer hence this property with generate() function
        property string agoText: ""
        visible: text !== ""
        level: 5
        opacity: 0.9
        wrapMode: Text.NoWrap
        text: generateRemainingText() || agoText
        textFormat: Text.PlainText
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false


        function generateAgoText() {
            const time = headingButtons.modelInterface.time;
            if (!time || isNaN(time.getTime())
                    || headingButtons.modelInterface.jobState === NotificationManager.Notifications.JobStateRunning
                    || headingButtons.modelInterface.jobState === NotificationManager.Notifications.JobStateSuspended) {
                return "";
            }

            var deltaMinutes = Math.floor((Date.now() - time.getTime()) / 1000 / 60);
            if (deltaMinutes < 1) {
                // "Just now" is implied by
                return headingButtons.modelInterface.inHistory
                    ? i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Notification was added less than a minute ago, keep short", "Just now")
                    : "";
            }

            // Received less than an hour ago, show relative minutes
            if (deltaMinutes < 60) {
                return i18ndcp("plasma_applet_io.gitgud.wackyideas.notifications", "Notification was added minutes ago, keep short", "%1 min ago", "%1 min ago", deltaMinutes);
            }
            // Received less than a day ago, show time, 22 hours so the time isn't as ambiguous between today and yesterday
            if (deltaMinutes < 60 * 22) {
                return Qt.formatTime(time, Qt.locale().timeFormat(Locale.ShortFormat).replace(/.ss?/i, ""));
            }

            // Otherwise show relative date (Yesterday, "Last Sunday", or just date if too far in the past)
            return KCoreAddons.Format.formatRelativeDate(time, Locale.ShortFormat);
        }

        function generateRemainingText() {
            if (headingButtons.modelInterface.notificationType !== NotificationManager.Notifications.JobType
                || headingButtons.modelInterface.jobState !== NotificationManager.Notifications.JobStateRunning) {
                return "";
            }

            var details = headingButtons.modelInterface.jobDetails;
            if (!details || !details.speed) {
                return "";
            }

            var remaining = details.totalBytes - details.processedBytes;
            if (remaining <= 0) {
                return "";
            }

            var eta = remaining / details.speed;
            if (eta < 0.5) { // Avoid showing "0 seconds remaining"
                return "";
            }

            if (eta < 60) { // 1 minute
                return i18ndcp("plasma_applet_io.gitgud.wackyideas.notifications", "seconds remaining, keep short",
                              "%1 s remaining", "%1 s remaining", Math.round(eta));
            }
            if (eta < 60 * 60) {// 1 hour
                return i18ndcp("plasma_applet_io.gitgud.wackyideas.notifications", "minutes remaining, keep short",
                              "%1 min remaining", "%1 min remaining",
                              Math.round(eta / 60));
            }
            if (eta < 60 * 60 * 5) { // 5 hours max, if it takes even longer there's no real point in showing that
                return i18ndcp("plasma_applet_io.gitgud.wackyideas.notifications", "hours remaining, keep short",
                              "%1 h remaining", "%1 h remaining",
                              Math.round(eta / 60 / 60));
            }

            return "";
        }

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            active: ageLabel.agoText !== ""
            subText: headingButtons.modelInterface.time ? headingButtons.modelInterface.time.toLocaleString(Qt.locale(), Locale.LongFormat) : ""
            location: PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop
        }
    }

    ToolButton {
        id: configureButton
        buttonIcon: "settings"
        visible: headingButtons.modelInterface.configurable

        property string text: headingButtons.modelInterface.configureActionLabel || i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Configure")
        Accessible.description: headingButtons.__applicationName

        onClicked: headingButtons.modelInterface.configureClicked()

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainText: parent.text
            location: PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop
        }
    }

    ToolButton {
        id: dismissButton
        buttonIcon: headingButtons.modelInterface.dismissed ? "restore" : "minimize"
        visible: headingButtons.modelInterface.dismissable

        property string text: headingButtons.modelInterface.dismissed
            ? i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Opposite of minimize", "Restore")
            : i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Minimize")
        Accessible.description: headingButtons.__applicationName

        onClicked: headingButtons.modelInterface.dismissClicked()

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainText: parent.text
            location: PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop
        }
    }

    ToolButton {
        id: closeButton
        visible: headingButtons.modelInterface.closable
        buttonIcon: "close"

        Accessible.description: headingButtons.__applicationName
        onClicked: headingButtons.modelInterface.closeClicked()

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainText: i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Close")
            location: PlasmaCore.Types.Floating | PlasmaCore.Types.Desktop
        }
    }
}
