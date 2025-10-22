/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.SelectableLabel {
    id: bodyLabel

    property ModelInterface modelInterface

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignTop

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    // Default WordWrap fails for long unbroken text e.g. URLs
    wrapMode: TextEdit.Wrap

    // HACK RichText does not allow to specify link color and since LineEdit
    // does not support StyledText, we have to inject some CSS to force the color,
    // cf. QTBUG-81463 and to some extent QTBUG-80354
    text: "<style>a { color: " + Kirigami.Theme.linkColor + "; }</style>" + modelInterface.body

    // Selectable only when we are in desktop mode
    selectByMouse: !Kirigami.Settings.tabletMode

    onLinkActivated: link => Qt.openUrlExternally(link)

    onClicked: modelInterface.bodyClicked()

    Binding {
        target: bodyLabel.modelInterface
        property: "bodyCursorShape"
        value: bodyLabel.cursorShape
    }
}
