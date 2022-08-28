/*
    SPDX-FileCopyrightText: 2013-2015 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaCore.ColorScope {
    property Item toolTip
    property int preferredTextWidth: PlasmaCore.Units.gridUnit * 10

    // gridUnit is effectively equal to `PlasmaCore.Units.smallSpacing * 4`
    // which is a double (both sides) of RowLayout's `anchors.margins`.
    Layout.minimumWidth: childrenRect.width// + PlasmaCore.Units.smallSpacing
    Layout.minimumHeight: childrenRect.height// + PlasmaCore.Units.smallSpacing
    Layout.maximumWidth: childrenRect.width// + PlasmaCore.Units.smallSpacing
    Layout.maximumHeight: childrenRect.height// + PlasmaCore.Units.smallSpacing

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    colorGroup: PlasmaCore.Theme.NormalColorGroup
    inherit: false

    RowLayout {

        anchors {
            left: parent.left
            top: parent.top
            //margins: PlasmaCore.Units.smallSpacing
        }

        spacing: PlasmaCore.Units.gridUnit

        Image {
            source: toolTip ? toolTip.image : ""
            visible: toolTip !== null && toolTip.image !== ""
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        PlasmaCore.IconItem {
            animated: false
            source: toolTip ? toolTip.icon : ""
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible: toolTip !== null && toolTip.icon !== "" && toolTip.image === "" && valid
            Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
            Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
            Layout.leftMargin: PlasmaCore.Units.smallSpacing*2
        }

        ColumnLayout {
            Layout.maximumWidth: preferredTextWidth
            spacing: 0

            PlasmaExtras.Heading {
                level: 5
                Layout.fillWidth: true
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                text: toolTip ? toolTip.mainText : ""
                textFormat: Text.PlainText
                visible: text !== ""
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                // Unset Label default height, confuses the layout engine completely
                // either shifting the item vertically or letting it get too wide
                height: undefined
                wrapMode: Text.WordWrap
                text: toolTip ? toolTip.subText : ""
                textFormat: toolTip ? toolTip.textFormat : Text.AutoText
                opacity: 0.85
                visible: text !== ""
                maximumLineCount: 8
            }
        }
    }
}
