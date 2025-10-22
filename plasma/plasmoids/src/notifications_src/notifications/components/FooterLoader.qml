/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.notificationmanager as NotificationManager

Loader {
    id: footerLoader

    property ModelInterface modelInterface
    property Item iconContainerItem

    Layout.fillWidth: true

    visible: active && sourceComponent !== null

    property string footerType: ""

    sourceComponent: {
        if (modelInterface.notificationType === NotificationManager.Notifications.JobType) {
            footerType = "job";
            return jobComponent;
        } else if (modelInterface.urls.length > 0) {
            footerType = "thumbnail";
            return thumbnailComponent;
        } else if ((modelInterface.inHistory && modelInterface.hasSomeActions) || (modelInterface.actionNames.length > 0 || modelInterface.hasReplyAction)) {
            footerType = "actions";
            return actionComponent;
        }
        return null;
    }

    // Actions
    Component {
        id: actionComponent
        ActionContainer {
            id: actionContainer
            Layout.fillWidth: true
            modelInterface: footerLoader.modelInterface
        }
    }

    // Jobs
    Component {
        id: jobComponent
        JobItem {
            modelInterface: footerLoader.modelInterface
        }
    }

    // Thumbnails (contains actions as well)
    Component {
        id: thumbnailComponent
        ThumbnailStrip {
            modelInterface: footerLoader.modelInterface
        }
    }
}
