/*
    SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

RowLayout {
    property alias iconSource: iconItem.source
    property alias text: label.text
    property int leftPadding: 0

    spacing: Kirigami.Units.smallSpacing

    Kirigami.Icon {
        id: iconItem
        Layout.preferredWidth: Kirigami.Units.iconSizes.small
        Layout.preferredHeight: Kirigami.Units.iconSizes.small
        Layout.leftMargin: leftPadding
        Layout.alignment: Qt.AlignTop
        visible: valid
    }

    PlasmaComponents3.Label {
        id: label
        Layout.fillWidth: true
        //font: Kirigami.Theme.smallFont
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
        maximumLineCount: 4
    }
}
