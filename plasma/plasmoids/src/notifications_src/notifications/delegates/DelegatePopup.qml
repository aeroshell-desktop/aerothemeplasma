/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import Qt5Compat.GraphicalEffects

import org.kde.notificationmanager as NotificationManager
import plasma.applet.io.gitgud.wackyideas.notifications as Notifications
import QtQuick.Effects

import "../components" as Components


BaseDelegate {
    id: delegateRoot

    Layout.preferredWidth: footerLoader.item?.implicitWidth ?? -1

    body: bodyLabel
    icon: icon
    footer: footerLoader.item
    columns: 3

    Accessible.role: Accessible.Notification

    readonly property int __firstColumn: modelInterface.urgency === NotificationManager.Notifications.CriticalUrgency ? 1 : 0

    Components.NotificationHeader {
        id: heading
        Layout.fillWidth: true
        Layout.columnSpan: delegateRoot.__firstColumn + 2
        modelInterface: delegateRoot.modelInterface
        Layout.topMargin: Kirigami.Units.mediumSpacing
        Component.onCompleted: Notifications.InputDisabler.makeTransparentForInput(this)
    }

    Components.Summary {
        id: summary
        // Base layout intentionally has no row spacing, so add top padding here when needed
        Layout.topMargin: delegateRoot.hasBodyText || icon.visible ? Kirigami.Units.smallSpacing : 0
        Layout.fillWidth: true
        Layout.bottomMargin: (delegateRoot.hasBodyText || footerLoader.visible) ? 0 : Kirigami.Units.largeSpacing
        Layout.row: 2
        Layout.column: delegateRoot.__firstColumn
        Layout.columnSpan: icon.visible ? 1 : 2
        modelInterface: delegateRoot.modelInterface
        Layout.leftMargin: (heading.iconVisible ? Kirigami.Units.smallSpacing*2 + Kirigami.Units.iconSizes.smallMedium : 0)

        KQuickControlsAddons.MouseEventListener {
            anchors.fill: parent
            visible: delegateRoot.modelInterface.hasDefaultAction && !delegateRoot.hasBodyText
            onClicked: delegateRoot.modelInterface.defaultActionInvoked();
        }
    }

    Components.Icon {
        id: icon
        // Base layout intentionally has no row spacing, so add top padding here
        Layout.topMargin: -Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        Layout.row: 2
        Layout.column: delegateRoot.__firstColumn + 1
        Layout.rowSpan: 2
        modelInterface: delegateRoot.modelInterface
    }

    KQuickControlsAddons.MouseEventListener {
        id: mouseListener
        // Base layout intentionally has no row spacing, so add top padding here when needed
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.leftMargin: (heading.iconVisible ? Kirigami.Units.smallSpacing*2 + Kirigami.Units.iconSizes.smallMedium : 0)
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: Math.min(bodyLabel.contentHeight, Kirigami.Theme.defaultFont.pointSize * delegateRoot.modelInterface.maximumLineCount * 2)
        Layout.row: summary.visible ? 3 : 2
        Layout.column: delegateRoot.__firstColumn
        Layout.columnSpan: icon.visible ? 1 : 2
        Layout.maximumHeight: Kirigami.Theme.defaultFont.pointSize * delegateRoot.modelInterface.maximumLineCount * 2
        // The body doesn't need to influence the implicit width in any way, this avoids a binding loop
        implicitWidth: -1
        implicitHeight: bodyLabel.contentHeight + Kirigami.Units.largeSpacing
        visible: delegateRoot.hasBodyText
        onClicked: {

            if (delegateRoot.modelInterface.hasDefaultAction) {
                delegateRoot.modelInterface.defaultActionInvoked();
            }
        }

        QQC2.ScrollView {
            id: scroll
            anchors.fill: parent
            contentWidth: bodyLabel.width
            contentHeight: bodyLabel.contentHeight

            property real scrollBarOpacity: (hoverHandler.hovered) ? 1 : 0
            Behavior on scrollBarOpacity {
                NumberAnimation { duration: 250 }
            }
            // This avoids a binding loop
            QQC2.ScrollBar.vertical.visible: scrollbarVisible //delegateRoot.modelInterface.maximumLineCount > 0 && bodyLabel.implicitHeight > parent.Layout.maximumHeight
            QQC2.ScrollBar.horizontal.visible: false
            QQC2.ScrollBar.vertical.opacity: scrollBarOpacity
            property double scrollBarPosition: QQC2.ScrollBar.vertical.position
            property real scrollBarSize: QQC2.ScrollBar.vertical.size
            property bool scrollbarVisible: delegateRoot.modelInterface.maximumLineCount > 0 && bodyLabel.implicitHeight > parent.Layout.maximumHeight
            property int scrollBarWidth: scroll.QQC2.ScrollBar.vertical.width

            Components.Body {
                id: bodyLabel
                width: scroll.width -scroll.scrollBarWidth
                modelInterface: delegateRoot.modelInterface
                Accessible.ignored: true // ignore HTML body in favor of Accessible.description on delegateRoot
                opacity: (hoverHandler.hovered || !scroll.scrollbarVisible) ? 1 : 0.01

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }
            }
            OpacityMask {
                anchors.fill: bodyLabel
                source: bodyLabel
                maskSource: mask
                opacity: (hoverHandler.hovered || !scroll.scrollbarVisible) ? 0 : 1
                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }
                smooth: false
            }

        }
        LinearGradient {
            id: mask
            anchors.fill: scroll
            property double startPos: scroll.scrollBarPosition
            property double endPos: scroll.scrollBarPosition + scroll.scrollBarSize
            property double middlePos: (startPos + endPos) / 2.0
            property bool atEnd: endPos == 1.0

            gradient: Gradient {
                GradientStop { position: mask.startPos; color: (scroll.scrollBarPosition == 0.0) ? "white" : "#20000000" }
                GradientStop { position: mask.middlePos-0.1; color: "white" }
                GradientStop { position: mask.middlePos; color: "white" }
                GradientStop { position: mask.middlePos+0.1; color: "white" }
                GradientStop { position: mask.endPos; color: (mask.atEnd) ? "white" : "#20000000" }
            }
            visible: false
        }
        HoverHandler {
            id: hoverHandler
        }


    }

    Components.FooterLoader {
        id: footerLoader
        Layout.fillWidth: true
        Layout.minimumHeight: implicitHeight
        Layout.leftMargin: ((heading.iconVisible && footerType !== "thumbnail") ? Kirigami.Units.smallSpacing + Kirigami.Units.iconSizes.smallMedium : 0)
        Layout.topMargin: Kirigami.Units.largeSpacing
        Layout.bottomMargin: footerType != "actions" ? 0 : ((mouseListener.visible && !icon.visible) ? 0 : Kirigami.Units.largeSpacing)
        Layout.row: 4
        Layout.column: delegateRoot.__firstColumn
        Layout.columnSpan: 2
        modelInterface: delegateRoot.modelInterface
        iconContainerItem: icon
    }
}

