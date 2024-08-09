/*
    SPDX-FileCopyrightText: 2013-2015 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.kwindowsystem 1.0
import org.kde.ksvg as KSvg

Item {
    property Item toolTip
    property int preferredTextWidth: Kirigami.Units.gridUnit * 10
    property bool compositing: KWindowSystem.isPlatformX11 ? KX11Extras.compositingActive : true
    //KWindowSystem { id: kwindowsystem }

    // Used for margins
    KSvg.FrameSvgItem {
        id: tooltipSvg
        imagePath: compositing ? "widgets/tooltip" : "opaque/widgets/tooltip"
        visible: false
    }

    implicitWidth: mainLayout.implicitWidth - tooltipSvg.margins.left
    implicitHeight: mainLayout.implicitHeight - tooltipSvg.margins.left*2 + Kirigami.Units.smallSpacing

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    KSvg.FrameSvgItem {
        id: tooltipBackground
        imagePath: "solid/widgets/tooltip"
        prefix: ""
        anchors {
            //fill: parent
            top: parent.top
            left: parent.left
            leftMargin: -tooltipSvg.margins.left
            topMargin: -tooltipSvg.margins.top
        }

        width: mainLayout.width + tooltipSvg.margins.left
        height: mainLayout.height + Kirigami.Units.smallSpacing
    }
    RowLayout {
        id: mainLayout
        anchors.centerIn: parent

        Image {
            source: toolTip ? toolTip.image : ""
            visible: toolTip !== null && toolTip.image !== ""
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        Kirigami.Icon {
            animated: false
            source: toolTip ? toolTip.icon : ""
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible: toolTip !== null && toolTip.icon !== "" && toolTip.image === "" && valid
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            Layout.leftMargin: Kirigami.Units.smallSpacing*2
        }

        ColumnLayout {
            Layout.maximumWidth: preferredTextWidth
            spacing: 0

            Kirigami.Heading {
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
