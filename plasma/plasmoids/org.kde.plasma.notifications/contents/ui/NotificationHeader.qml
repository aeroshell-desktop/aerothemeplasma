/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

import org.kde.notificationmanager as NotificationManager

import org.kde.coreaddons 1.0 as KCoreAddons

import org.kde.quickcharts 1.0 as Charts

import "global"

RowLayout {
    id: notificationHeading

    readonly property bool hasIcon: applicationIconItem.visible
    property bool inGroup
    property bool inHistory
    property int notificationType

    property var applicationIconSource
    property string applicationName
    property string originName

    property string configureActionLabel

    property alias configurable: configureButton.visible
    property alias dismissable: dismissButton.visible
    property bool dismissed
    property string closeButtonTooltip: ""//closeButtonToolTip.text
    property alias closable: closeButton.visible

    property var time

    property int jobState
    property QtObject jobDetails
    property int urgency

    property real timeout: 5000
    property real remainingTime: 0

    signal configureClicked
    signal dismissClicked
    signal closeClicked

    // notification created/updated time changed
    onTimeChanged: updateAgoText()

    function updateAgoText() {
        ageLabel.agoText = ageLabel.generateAgoText();
    }

    spacing: Kirigami.Units.smallSpacing
    Layout.preferredHeight: Math.max(applicationNameLabel.implicitHeight, Kirigami.Units.iconSizes.smallMedium)


    Component.onCompleted: updateAgoText()

    Connections {
        target: Globals
        // clock time changed
        function onTimeChanged() {
            notificationHeading.updateAgoText()
        }
    }

    Kirigami.Icon {
        id: applicationIconItem
        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
        Layout.topMargin: Kirigami.Units.smallSpacing/2
        source: notificationHeading.applicationIconSource
        visible: valid
    }

    Kirigami.Heading {
        id: applicationNameLabel
        Layout.fillWidth: true
        Layout.leftMargin: applicationIconItem.visible ? Kirigami.Units.smallSpacing : 0
        level: 3
        color: notificationPopup.urgency === NotificationManager.Notifications.CriticalUrgency ? "#9d3939" : "#1d3287"
        type: notificationPopup.urgency === NotificationManager.Notifications.CriticalUrgency ? Kirigami.Heading.Type.Primary : Kirigami.Heading.Type.Normal
        textFormat: Text.PlainText
        elide: Text.ElideRight
        maximumLineCount: 2
        text: notificationHeading.applicationName + (notificationHeading.originName ? " · " + notificationHeading.originName : "")
    }

    Item {
        id: spacer
        Layout.fillWidth: true
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

        function generateAgoText() {
            if (!time || isNaN(time.getTime())
                    || notificationHeading.jobState === NotificationManager.Notifications.JobStateRunning
                    || notificationHeading.jobState === NotificationManager.Notifications.JobStateSuspended) {
                return "";
            }

            var deltaMinutes = Math.floor((Date.now() - time.getTime()) / 1000 / 60);
            if (deltaMinutes < 1) {
                // "Just now" is implied by
                return notificationHeading.inHistory
                    ? i18ndc("plasma_applet_org.kde.plasma.notifications", "Notification was added less than a minute ago, keep short", "Just now")
                    : "";
            }

            // Received less than an hour ago, show relative minutes
            if (deltaMinutes < 60) {
                return i18ndcp("plasma_applet_org.kde.plasma.notifications", "Notification was added minutes ago, keep short", "%1 min ago", "%1 min ago", deltaMinutes);
            }
            // Received less than a day ago, show time, 22 hours so the time isn't as ambiguous between today and yesterday
            if (deltaMinutes < 60 * 22) {
                return Qt.formatTime(time, Qt.locale().timeFormat(Locale.ShortFormat).replace(/.ss?/i, ""));
            }

            // Otherwise show relative date (Yesterday, "Last Sunday", or just date if too far in the past)
            return KCoreAddons.Format.formatRelativeDate(time, Locale.ShortFormat);
        }

        function generateRemainingText() {
            if (notificationHeading.notificationType !== NotificationManager.Notifications.JobType
                || notificationHeading.jobState !== NotificationManager.Notifications.JobStateRunning) {
                return "";
            }

            var details = notificationHeading.jobDetails;
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
                return i18ndcp("plasma_applet_org.kde.plasma.notifications", "seconds remaining, keep short",
                              "%1 s remaining", "%1 s remaining", Math.round(eta));
            }
            if (eta < 60 * 60) {// 1 hour
                return i18ndcp("plasma_applet_org.kde.plasma.notifications", "minutes remaining, keep short",
                              "%1 min remaining", "%1 min remaining",
                              Math.round(eta / 60));
            }
            if (eta < 60 * 60 * 5) { // 5 hours max, if it takes even longer there's no real point in showing that
                return i18ndcp("plasma_applet_org.kde.plasma.notifications", "hours remaining, keep short",
                              "%1 h remaining", "%1 h remaining",
                              Math.round(eta / 60 / 60));
            }

            return "";
        }

        /*PlasmaCore.ToolTipArea {
            anchors.fill: parent
            active: ageLabel.agoText !== ""
            subText: notificationHeading.time ? notificationHeading.time.toLocaleString(Qt.locale(), Locale.LongFormat) : ""
        }*/
    }


    ToolButton {
        id: configureButton
        buttonIcon: "settings"
        visible: false

        Layout.alignment: Qt.AlignTop
        //Layout.topMargin: -Kirigami.Units.smallSpacing / 2

        //display: PlasmaComponents3.AbstractButton.IconOnly
        //text: notificationHeading.configureActionLabel || i18nd("plasma_applet_org.kde.plasma.notifications", "Configure")
        //Accessible.description: applicationNameLabel.text

        onClicked: (mouse) => { notificationHeading.configureClicked(); }

        /*PlasmaComponents3.ToolTip {
            text: parent.text
        }*/
    }

    ToolButton {
        id: dismissButton
        buttonIcon: notificationHeading.dismissed ? "restore" : "minimize"
        visible: false
        Layout.alignment: Qt.AlignTop
        Layout.rightMargin: closeButton.visible ? 0 : Kirigami.Units.smallSpacing / 2
        //Layout.topMargin: -Kirigami.Units.smallSpacing
        //display: PlasmaComponents3.AbstractButton.IconOnly
        /*text: notificationHeading.dismissed
            ? i18ndc("plasma_applet_org.kde.plasma.notifications", "Opposite of minimize", "Restore")
            : i18nd("plasma_applet_org.kde.plasma.notifications", "Minimize")
        Accessible.description: applicationNameLabel.text*/

        onClicked: (mouse) => { notificationHeading.dismissClicked(); }

        /*PlasmaComponents3.ToolTip {
            text: parent.text
        }*/
    }

    ToolButton {
        id: closeButton
        //visible: false
        buttonIcon: "close"

        Layout.alignment: Qt.AlignTop
        Layout.rightMargin: Kirigami.Units.smallSpacing / 2
        onClicked: (mouse) => { notificationHeading.closeClicked(); }
    }

    states: [
        State {
            when: notificationHeading.inGroup
            PropertyChanges {
                target: applicationIconItem
                source: ""
            }
            PropertyChanges {
                target: applicationNameLabel
                visible: false
            }
        }

    ]
}
