/*
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

import org.kde.kquickcontrolsaddons as KQCAddons

import plasma.applet.io.gitgud.wackyideas.notifications as Notifications

Item {
    id: thumbnailArea

    property ModelInterface modelInterface

    // The protocol supports multiple URLs but so far it's only used to show
    // a single preview image, so this code is simplified a lot to accommodate
    // this usecase and drops everything else (fallback to app icon or ListView
    // for multiple files)
    property var urls: modelInterface.urls

    readonly property alias menuOpen: fileMenu.visible
    readonly property alias dragging: dragArea.dragging

    // Fix for BUG:462399
    implicitHeight: Kirigami.Units.iconSizes.huge + Kirigami.Units.iconSizes.medium

    property int urlIndex: 0

    function baseName(u) {
        if(!thumbnailArea.urls[thumbnailArea.urlIndex].toString().startsWith("file://")) return u.toString();
        var str = u.toString();
        var list = str.split('/');
        return list[list.length-1];
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: "#898c95"
    }

    Notifications.FileMenu {
        id: fileMenu
        url: thumbnailer.url
        visualParent: menuButton
        onActionTriggered: action => thumbnailArea.modelInterface.fileActionInvoked(action)
    }

    Notifications.Thumbnailer {
        id: thumbnailer

        readonly property real ratio: pixmapSize.height ? pixmapSize.width / pixmapSize.height : 1

        url: thumbnailArea.urls[thumbnailArea.urlIndex]
        // height is dynamic, so request a "square" size and then show it fitting to aspect ratio
        // Also use popupWidth instead of our width to ensure it is fixed and doesn't
        // change temporarily during (re)layouting
        size: Qt.size(Notifications.Globals.popupWidth, Notifications.Globals.popupWidth)
    }


    DraggableFileArea {
        id: dragArea
        anchors {
            fill: parent
            leftMargin: -thumbnailArea.modelInterface.popupLeftPadding
            topMargin: -thumbnailArea.modelInterface.popupTopPadding
            rightMargin: -thumbnailArea.modelInterface.popupRightPadding
            bottomMargin: -thumbnailArea.modelInterface.popupBottomPadding
        }
        dragParent: previewIcon
        dragPixmapSize: previewIcon.height
        dragPixmap: thumbnailer.hasPreview ? thumbnailer.pixmap : thumbnailer.iconName
        dragUrl: thumbnailer.url

        onActivated: thumbnailArea.modelInterface.openUrl(thumbnailer.url)
        onContextMenuRequested: (pos) => {
            // avoid menu button glowing if we didn't actually press it
            menuButton.checked = false;

            fileMenu.visualParent = this;
            fileMenu.open(pos.x, pos.y);
        }
    }
    KQCAddons.QPixmapItem {
        id: emptyPixmap
    }

    KQCAddons.QPixmapItem {
        id: previewPixmap
        anchors {
            fill: parent
            margins: Kirigami.Units.smallSpacing
        }
        pixmap: {
            if(previewIcon.source == "unknown") {
                // In the case of a url that can't be represented in any defined way, use an empty pixmap to fix a persistence bug
                return emptyPixmap.pixmap
            }
            return thumbnailer.pixmap
        }
        smooth: true
        fillMode: Image.PreserveAspectFit
        opacity: thumbnailer.busy ? 0.5 : 1
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }


        Kirigami.Icon {
            id: previewIcon
            anchors.centerIn: parent
            width: height
            height: Kirigami.Units.iconSizes.roundedIconSize(parent.height)
            active: dragArea.hovered
            source: {
                if(!thumbnailArea.urls[thumbnailArea.urlIndex].toString().startsWith("file://")) return "unknown";
                return !thumbnailer.busy && !thumbnailer.hasPreview ? thumbnailer.iconName : ""
            }

        }
        PlasmaComponents3.ToolTip {
            id: urlToolTip
            parent: parent
            visible: dragArea.hovered
            text: thumbnailArea.baseName(thumbnailArea.urls[thumbnailArea.urlIndex])
            delay: Kirigami.Units.veryLongDuration
        }

        RowLayout {
            id: thumbnailActionRow
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            spacing: Kirigami.Units.smallSpacing

            Item {
                Layout.fillWidth: true
            }
            ActionContainer {
                id: actionContainer
                modelInterface: thumbnailArea.modelInterface
            }

            PlasmaComponents3.Button {
                id: menuButton
                Layout.alignment: Qt.AlignBottom
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
                    text: i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "More Options…")
                }
            }
        }
        RowLayout {
            id: flipButtons
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            visible: thumbnailArea.urls.length > 1
            spacing: Kirigami.Units.smallSpacing

            Item {
                Layout.fillWidth: true
            }

            PlasmaComponents3.Button {
                id: backButton
                Layout.alignment: Qt.AlignTop
                Accessible.name: backTooltip.text
                icon.name: "back"

                enabled: thumbnailArea.urlIndex !== 0
                onClicked: thumbnailArea.urlIndex--;

                PlasmaComponents3.ToolTip {
                    id: backTooltip
                    text: i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Previous")
                }
            }
            PlasmaComponents3.Button {
                id: nextButton
                Layout.alignment: Qt.AlignTop
                Accessible.name: nextTooltip.text
                icon.name: "next"

                enabled: thumbnailArea.urlIndex !== (thumbnailArea.urls.length - 1)
                onClicked: thumbnailArea.urlIndex++;

                PlasmaComponents3.ToolTip {
                    id: nextTooltip
                    text: i18nd("plasma_applet_io.gitgud.wackyideas.notifications", "Next")
                }
            }


        }
    }
}
