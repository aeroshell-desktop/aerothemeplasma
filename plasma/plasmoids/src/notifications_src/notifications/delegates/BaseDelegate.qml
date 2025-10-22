/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

import "../components" as Components

GridLayout {
    id: baseDelegate

    Layout.fillWidth: true
    Layout.minimumHeight: Kirigami.Units.iconSizes.large

    //property ModelInterface modelInterface
    property Components.ModelInterface modelInterface: Components.ModelInterface {}

    property Components.Body body
    property Components.Icon icon
    property Item footer // It's not the FooterLoader, but the loaded item
    //property bool menuOpen
    readonly property real textPreferredWidth: Kirigami.Units.gridUnit * 18
    readonly property bool menuOpen: Boolean(body?.menuOpen)
                                     || Boolean(footer?.menuOpen)
    readonly property bool dragging: Boolean(icon?.dragging) || Boolean(footer?.dragging)
    // Cannot do text !== "" because RichText adds some HTML tags even when empty
    readonly property bool hasBodyText: modelInterface.body.length > 0

    rowSpacing: 0
    columnSpacing: Kirigami.Units.smallSpacing

    Accessible.role: Accessible.NoRole
    Accessible.name: modelInterface.summary
    Accessible.description: modelInterface.accessibleDescription
    columns: 3
}

