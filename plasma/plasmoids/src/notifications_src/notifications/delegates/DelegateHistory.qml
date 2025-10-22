/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import "../components" as Components


BaseDelegate {
    id: delegateRoot

    body: bodyLabel
    icon: icon
    footer: footerLoader.item
    columns: 2

    Components.NotificationHeader {
        Layout.fillWidth: true
        Layout.columnSpan: 2
        modelInterface: delegateRoot.modelInterface
    }


    Components.Summary {
        id: summary
        Layout.fillWidth: true
        Layout.row: 1
        Layout.column: 0
        modelInterface: delegateRoot.modelInterface
    }

    Components.Icon {
        id: icon
        Layout.row: 1
        Layout.column: 1
        Layout.rowSpan: 2
        modelInterface: delegateRoot.modelInterface
    }

    Components.Body {
        id: bodyLabel
        Layout.fillWidth: true
        Layout.row: summary.visible ? 2 : 1
        Layout.column: 0
        visible: delegateRoot.hasBodyText
        modelInterface: delegateRoot.modelInterface
    }

    Components.FooterLoader {
        id: footerLoader
        Layout.fillWidth: true
        Layout.row: 3
        Layout.column: 0
        Layout.columnSpan: 2
        modelInterface: delegateRoot.modelInterface
        iconContainerItem: icon
    }
}

