/*
    SPDX-FileCopyrightText: 2013-2015 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kwindowsystem 1.0

PlasmaCore.ColorScope {
    property Item toolTip
    property int preferredTextWidth: PlasmaCore.Units.gridUnit * 10
    property bool compositing: kwindowsystem.compositingActive
    KWindowSystem { id: kwindowsystem }
    // gridUnit is effectively equal to `PlasmaCore.Units.smallSpacing * 4`
    // which is a double (both sides) of RowLayout's `anchors.margins`.
    Layout.minimumWidth: compositing ? childrenRect.width + horizontalMargin*2 - PlasmaCore.Units.smallSpacing :
                                       tooltipBackground.width - tooltipSvg.margins.left*2 - PlasmaCore.Units.smallSpacing / 2
    Layout.minimumHeight: compositing ? childrenRect.height + verticalMargin*2 :
                                        tooltipBackground.height - tooltipSvg.margins.top*4 - PlasmaCore.Units.smallSpacing / 2
    Layout.maximumWidth: compositing ? childrenRect.width + horizontalMargin*2 - PlasmaCore.Units.smallSpacing :
                                       tooltipBackground.width - tooltipSvg.margins.left*2 - PlasmaCore.Units.smallSpacing / 2

    Layout.maximumHeight: compositing ? childrenRect.height +verticalMargin*2 :
                                        tooltipBackground.height - tooltipSvg.margins.top*4 - PlasmaCore.Units.smallSpacing / 2
    Layout.margins: PlasmaCore.Units.largeSpacing

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    colorGroup: PlasmaCore.Theme.ViewColorGroup
    inherit: false

    // Used for margins
    PlasmaCore.FrameSvgItem {
        id: tooltipSvg
        imagePath: "solid/widgets/tooltip"
        visible: false
    }

    property int verticalMargin: (-tooltipSvg.margins.top - PlasmaCore.Units.smallSpacing)*1.5
    property int horizontalMargin: (-tooltipSvg.margins.left - PlasmaCore.Units.smallSpacing / 2)*1.5

    property int tooltipMarginLeft: horizontalMargin + (compositing ? (-PlasmaCore.Units.smallSpacing/2) : PlasmaCore.Units.smallSpacing)
    property int tooltipMarginTop: verticalMargin + (compositing ? (-PlasmaCore.Units.smallSpacing/2) : PlasmaCore.Units.smallSpacing)
    PlasmaCore.FrameSvgItem {

        id: tooltipBackground
        imagePath: "solid/widgets/tooltip"
        prefix: ""
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: tooltipMarginLeft //horizontalMargin + PlasmaCore.Units.smallSpacing
            topMargin: tooltipMarginTop //verticalMargin + PlasmaCore.Units.smallSpacing
        }

        width: rows.width - horizontalMargin - PlasmaCore.Units.smallSpacing / 2
        height: rows.height - verticalMargin - PlasmaCore.Units.smallSpacing

    }

    RowLayout {
        id: rows
        anchors {
            left: compositing ? parent.left : tooltipBackground.left
            top: compositing ? parent.top : tooltipBackground.top
            leftMargin: compositing ? horizontalMargin + PlasmaCore.Units.smallSpacing / 2 : PlasmaCore.Units.smallSpacing
            topMargin: compositing ? verticalMargin : PlasmaCore.Units.smallSpacing / 2
            //margins: PlasmaCore.Units.smallSpacing
        }

        //spacing: PlasmaCore.Units.gridUnit

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
                opacity: 0.75
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                // Unset Label default height, confuses the layout engine completely
                // either shifting the item vertically or letting it get too wide
                height: undefined
                wrapMode: Text.WordWrap
                text: toolTip ? toolTip.subText : ""
                textFormat: toolTip ? toolTip.textFormat : Text.AutoText
                opacity: 0.75
                visible: text !== ""
                maximumLineCount: 8
            }
        }
    }
}
