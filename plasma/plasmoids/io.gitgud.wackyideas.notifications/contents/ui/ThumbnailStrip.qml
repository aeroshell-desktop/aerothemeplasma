/*
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import Qt5Compat.GraphicalEffects

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

import org.kde.kquickcontrolsaddons 2.0 as KQCAddons

import org.kde.plasma.private.notifications 2.0 as Notifications

import "global"

Item {
    id: thumbnailArea

    // The protocol supports multiple URLs but so far it's only used to show
    // a single preview image, so this code is simplified a lot to accommodate
    // this usecase and drops everything else (fallback to app icon or ListView
    // for multiple files)
    property var urls

    readonly property alias menuOpen: fileMenu.visible
    readonly property alias dragging: dragArea.dragging

    property int leftPadding: 0
    property int rightPadding: 0
    property int topPadding: 0
    property int bottomPadding: 0

    property alias actionContainer: thumbnailActionContainer

    signal openUrl(string url)
    signal fileActionInvoked(QtObject action)

    implicitHeight: Math.max(thumbnailActionRow.implicitHeight + 2 * thumbnailActionRow.anchors.topMargin,
                             Math.round(Math.min(width / 3, width / thumbnailer.ratio)))
                    + topPadding + bottomPadding

    Notifications.FileMenu {
        id: fileMenu
        url: thumbnailer.url
        visualParent: menuButton
        onActionTriggered: thumbnailArea.fileActionInvoked(action)
    }

    Notifications.Thumbnailer {
        id: thumbnailer

        readonly property real ratio: pixmapSize.height ? pixmapSize.width / pixmapSize.height : 1

        url: urls[0]
        // height is dynamic, so request a "square" size and then show it fitting to aspect ratio
        // Also use popupWidth instead of our width to ensure it is fixed and doesn't
        // change temporarily during (re)layouting
        size: Qt.size(Globals.popupWidth, Globals.popupWidth)
    }

    KQCAddons.QPixmapItem {
        id: previewBackground
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        opacity: 0.25
        pixmap: thumbnailer.pixmap
        layer.effect: FastBlur {
            source: previewBackground
            anchors.fill: parent
            radius: 30
        }
    }

    DraggableFileArea {
        id: dragArea
        anchors.fill: parent
        dragParent: previewIcon
        dragPixmapSize: previewIcon.height

        onActivated: thumbnailArea.openUrl(thumbnailer.url)
        onContextMenuRequested: (pos) => {
            // avoid menu button glowing if we didn't actually press it
            menuButton.checked = false;

            fileMenu.visualParent = this;
            fileMenu.open(pos.x, pos.y);
        }
    }

    KQCAddons.QPixmapItem {
        id: previewPixmap
        anchors {
            fill: parent
            leftMargin: thumbnailArea.leftPadding
            rightMargin: thumbnailArea.rightPadding
            topMargin: thumbnailArea.topPadding
            bottomMargin: thumbnailArea.bottomPadding
        }
        pixmap: thumbnailer.pixmap
        smooth: true
        fillMode: Image.PreserveAspectFit

        Kirigami.Icon {
            id: previewIcon
            anchors.centerIn: parent
            width: height
            height: Kirigami.Units.iconSizes.roundedIconSize(parent.height)
            active: dragArea.hovered
            source: !thumbnailer.busy && !thumbnailer.hasPreview ? thumbnailer.iconName : ""

            Drag.dragType: Drag.Automatic
            Drag.mimeData: {
                "text/uri-list": [thumbnailer.url],
            }
        }

        PlasmaComponents3.BusyIndicator {
            anchors.centerIn: parent
            running: thumbnailer.busy
            visible: thumbnailer.busy
        }

        RowLayout {
            id: thumbnailActionRow
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.smallSpacing

            Item {
                id: thumbnailActionContainer
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height

                // actionFlow is reparented here
            }

            PlasmaComponents3.Button {
                id: menuButton
                Layout.alignment: Qt.AlignTop
                Accessible.name: tooltip.text
                icon.name: "application-menu"
                checkable: true

                onPressedChanged: {
                    if (pressed) {
                        // fake "pressed" while menu is open
                        checked = Qt.binding(function() {
                            return fileMenu.visible;
                        });

                        fileMenu.visualParent = this;
                        // -1 tells it to "align bottom left of visualParent (this)"
                        fileMenu.open(-1, -1);
                    }
                }

                PlasmaComponents3.ToolTip {
                    id: tooltip
                    text: i18nd("plasma_applet_org.kde.plasma.notifications", "More Options…")
                }
            }
        }
    }
}
