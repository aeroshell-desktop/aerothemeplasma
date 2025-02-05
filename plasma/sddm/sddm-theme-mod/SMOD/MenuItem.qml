/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/
/*
 QQC2.Control* {
 height: Kirigami.Units.iconSizes.smallMedium
 width: parent.width
 onImplicitWidthChanged: session.contentItem.contentItem.childrenChanged()
 Rectangle {

 }
 }*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.ksvg as KSvg
//NOTE: importing PlasmaCore is necessary in order to make KSvg load the current Plasma Theme
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

T.MenuItem {
    id: controlRoot

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding + (arrow ? arrow.implicitWidth : 0))
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0
    spacing: Kirigami.Units.smallSpacing
    hoverEnabled: true

    Kirigami.MnemonicData.enabled: controlRoot.enabled && controlRoot.visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.MenuItem
    Kirigami.MnemonicData.label: controlRoot.text
    Shortcut {
        //in case of explicit & the button manages it by itself
        enabled: !(RegExp(/\&[^\&]/).test(controlRoot.text))
        sequence: controlRoot.Kirigami.MnemonicData.sequence
        onActivated: {
            if (controlRoot.checkable) {
                controlRoot.toggle();
            } else {
                controlRoot.clicked();
            }
        }
    }

    onHoveredChanged: {
        if(controlRoot.highlighted) {
            controlRoot.highlighted = false
        }
    }
    contentItem: RowLayout {
        Item {
           Layout.preferredWidth: (controlRoot.ListView.view && controlRoot.ListView.view.hasCheckables) || controlRoot.checkable ? controlRoot.indicator.width : 0 //Kirigami.Units.smallSpacing
        }
        Kirigami.Icon {
            id: defaultIcon
            Layout.alignment: Qt.AlignVCenter
            visible: (controlRoot.ListView.view && controlRoot.ListView.view.hasIcons) || (controlRoot.icon != undefined && (controlRoot.icon.name.length > 0))
            source: controlRoot.icon ? (controlRoot.icon.name || controlRoot.icon.source) : ""
            Layout.preferredHeight: Math.max(label.height, Kirigami.Units.iconSizes.small)
            Layout.preferredWidth: Layout.preferredHeight
        }
        Image {
            id: fallback
            visible: (controlRoot.ListView.view && controlRoot.ListView.view.hasIcons) || ((controlRoot.icon.source !== ""))
            source: controlRoot.icon ? (controlRoot.icon.source) : ""
            smooth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: Math.max(label.height, Kirigami.Units.iconSizes.small)
            Layout.preferredWidth: Layout.preferredHeight
        }
        Item {
           Layout.preferredWidth: (controlRoot.ListView.view && controlRoot.ListView.view.hasCheckables) || controlRoot.checkable ? 0 : Kirigami.Units.smallSpacing //Kirigami.Units.smallSpacing
        }
        Text {
            id: label
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            text: controlRoot.Kirigami.MnemonicData.richTextLabel
            font: controlRoot.font
            elide: Text.ElideRight
            visible: controlRoot.text
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
    }

    arrow: Kirigami.Icon {
        x: controlRoot.mirrored ? controlRoot.padding : controlRoot.width - width - controlRoot.padding
        y: controlRoot.topPadding + (controlRoot.availableHeight - height) / 2
        source: controlRoot.mirrored ? "go-next-symbolic-rtl" : "go-next-symbolic"
        width: Math.max(label.height, Kirigami.Units.iconSizes.small)
        height: width
        visible: controlRoot.subMenu
    }

    indicator: Loader {
        x: controlRoot.mirrored ? controlRoot.width - width - controlRoot.rightPadding : controlRoot.leftPadding
        y: controlRoot.topPadding + Math.round((controlRoot.availableHeight - height) / 2)

        visible: controlRoot.checkable && controlRoot.checked
        sourceComponent: radioComponent
    }

    Component {
        id: radioComponent
        Item {
            width: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.mediumSpacing
            height: Kirigami.Units.iconSizes.smallMedium

            KSvg.FrameSvgItem {
                imagePath: Qt.resolvedUrl("../Assets/viewitem.svg")
                prefix: "hover"
                anchors.left: parent.left
                anchors.top: parent.top
                width: Kirigami.Units.iconSizes.smallMedium
                height: width
                Image {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.small
                    height: Kirigami.Units.iconSizes.small
                    smooth: true
                    source: "../Assets/radio.png"
                }
            }
        }
    }

    background: Item {
        implicitWidth: Kirigami.Units.gridUnit * 8

        KSvg.FrameSvgItem {
            id: highlight
            imagePath: Qt.resolvedUrl("../Assets/viewitem.svg")
            prefix: "hover"
            anchors.fill: parent
            opacity: {
                if (controlRoot.hovered || controlRoot.down) {
                    return 1
                } else if(controlRoot.highlighted) {
                    return 0.66
                } else {
                    return 0
                }
            }
        }
    }
}
