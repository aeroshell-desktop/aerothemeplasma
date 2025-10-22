/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager

//TODO remove this file?
Kirigami.Heading {
    id: summaryLabel

    Layout.fillWidth: true

    property ModelInterface modelInterface
    property alias metrics: summaryLabelTextMetrics

    textFormat: Text.PlainText
    maximumLineCount: 3
    // WordWrap fails for long unbroken text e.g. URLs
    wrapMode: Text.Wrap
    elide: Text.ElideRight
    level: 5
    opacity: 0.66

    // Give it a bit more visual prominence than the app name in the header
    //type: Kirigami.Heading.Type.Primary
    text: {
        if (modelInterface.notificationType === NotificationManager.Notifications.JobType) {
            if (modelInterface.jobState === NotificationManager.Notifications.JobStateSuspended) {
                if (modelInterface.summary) {
                    return i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Job name, e.g. Copying is paused", "%1 (Paused)", modelInterface.summary);
                }
            } else if (jobState === NotificationManager.Notifications.JobStateStopped) {
                if (modelInterface.jobError) {
                    if (modelInterface.summary) {
                        return i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Job name, e.g. Copying has failed", "%1 (Failed)", modelInterface.summary);
                    } else {
                        return i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Job Failed");
                    }
                } else {
                    if (modelInterface.summary) {
                        return i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Job name, e.g. Copying has finished", "%1 (Finished)", modelInterface.summary);
                    } else {
                        return i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Job Finished");
                    }
                }
            }
        }
        // some apps use their app name as summary, avoid showing the same text twice
        // try very hard to match the two
        if (modelInterface.summary && modelInterface.summary.toLocaleLowerCase().trim() != modelInterface.applicationName.toLocaleLowerCase().trim()) {
            return modelInterface.summary;
        }
        return "";
    }
    visible: text !== ""

    TextMetrics {
        id: summaryLabelTextMetrics
        font: summaryLabel.font
        text: summaryLabel.text
    }
}
