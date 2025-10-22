/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import plasma.applet.io.gitgud.wackyideas.notifications as Notifications
import org.kde.notificationmanager as NotificationManager

RowLayout {
    id: notificationHeading

    property ModelInterface modelInterface: ModelInterface {}

    spacing: Kirigami.Units.smallSpacing
    property bool iconVisible: applicationIconItem.visible

    Kirigami.Icon {
        id: applicationIconItem
        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
        source: notificationHeading.modelInterface.applicationIconSource
        visible: valid
    }

    Kirigami.Heading {
        id: applicationNameLabel
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        Layout.fillWidth: true
        Layout.leftMargin: applicationIconItem.visible ? Kirigami.Units.smallSpacing : 0
        level: 3
        color: notificationHeading.modelInterface.urgency === NotificationManager.Notifications.CriticalUrgency ? "#9d3939" : "#1d3287"
        type: notificationHeading.modelInterface.urgency === NotificationManager.Notifications.CriticalUrgency ? Kirigami.Heading.Type.Primary : Kirigami.Heading.Type.Normal

        textFormat: Text.PlainText
        elide: Text.ElideMiddle
        maximumLineCount: 2
        text: notificationHeading.modelInterface.applicationName + (notificationHeading.modelInterface.originName ? " · " + notificationHeading.modelInterface.originName : "")
    }
    HeadingButtons {
        id: headingButtons
        modelInterface: notificationHeading.modelInterface
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: -2
        Layout.rightMargin: -Kirigami.Units.smallSpacing
    }
}
