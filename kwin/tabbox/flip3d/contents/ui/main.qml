/*
 SPDX-FileCopyrightText: 2021 Ismael Asensio <isma.af@gmail.com>

 SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PC3

import org.kde.kwin 3.0 as KWin
import org.kde.kwin.private.effects 1.0


KWin.TabBoxSwitcher {
    id: tabBox
    currentIndex: thumbnailView ? thumbnailView.currentIndex : -1

    // TODO: Make it user configurable ?
    property bool enableBlur: true

    Window {
        id: window

        x: tabBox.screenGeometry.x
        y: tabBox.screenGeometry.y
        width: tabBox.screenGeometry.width
        height: tabBox.screenGeometry.height
        flags: Qt.BypassWindowManagerHint | Qt.FramelessWindowHint
        visibility: Window.FullScreen
        // Workaround QTBUG-35244. Do not directly assign here to avoid warning
        visible: true

        color: "transparent"

        KWin.DesktopBackground {
            activity: KWin.Workspace.currentActivity
            desktop: KWin.Workspace.currentVirtualDesktop
            outputName: window.screen.name

            /*layer.enabled: true
            layer.effect: FastBlur {
                radius: enableBlur ? 64 : 0
            }*/
        }

        Rectangle {
            anchors {
                top: enableBlur ? parent.top : infoBar.top
                topMargin: enableBlur ? 0 : -infoBar.anchors.bottomMargin
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            color: Kirigami.Theme.backgroundColor
            opacity: enableBlur ? 0.5 : 0.75
        }

        PathView {
            id: thumbnailView

            readonly property int visibleCount: Math.min(count, pathItemCount)
            // Make thumbnails slightly smaller the more there are, so it doesn't feel too crowded
            // The sizeFactor curve parameters have been calculated experimentally
            readonly property real boxScaleFactor: 0.35 + (0.5 / (visibleCount + 1))
            readonly property int boxWidth: tabBox.screenGeometry.width * boxScaleFactor
            readonly property int boxHeight: tabBox.screenGeometry.height * boxScaleFactor

            focus: true

            anchors.fill: parent

            preferredHighlightBegin: 1/(visibleCount + 1)
            preferredHighlightEnd: preferredHighlightBegin
            highlightRangeMode: PathView.StrictlyEnforceRange

            // This property sets the animation duration between the current position to the next one,
            // without taking into account how much distance the thumbnails travel in that time.
            // To compensate the speed, we slowly reduce the duration with the number of thumbnails,
            // starting from `veryLongDuration` when there are 2 of them
            highlightMoveDuration: Kirigami.Units.longDuration * (2 / Math.sqrt(visibleCount + 1))

            pathItemCount: 12

            path: Path {
                // Nearest point of the path
                startX: Math.round(thumbnailView.width * 0.75)
                startY: Math.round(thumbnailView.height * 0.80)
                PathAttribute { name: "progress"; value: 1 }
                PathAttribute { name: "scale"; value: 1 }

                // Back point of the path on top-left corner
                PathLine {
                    x: Math.round(thumbnailView.width * 0.25)
                    y: Math.round(thumbnailView.height * 0.20)
                }
                PathAttribute { name: "progress"; value: 0 }
                PathAttribute { name: "scale"; value: 0.6 }
            }

            model: tabBox.model

            delegate: Item {
                readonly property string caption: model.caption
                readonly property var icon: model.icon

                readonly property real scaleFactor: {
                    if (thumbnail.implicitWidth < thumbnailView.boxWidth && thumbnail.implicitHeight < thumbnailView.boxHeight) {
                        // Do not scale up thumbnails smaller than the box frame
                        return 1;
                    } else if (thumbnail.ratio > thumbnailView.boxWidth / thumbnailView.boxHeight) {
                        // Thumbnail is wider than the box
                        return thumbnailView.boxWidth / thumbnail.implicitWidth;
                    } else {
                        // Thumbnail is taller than the box
                        return thumbnailView.boxHeight / thumbnail.implicitHeight;
                    }
                }

                width: Math.round(thumbnail.implicitWidth * scaleFactor)
                height: Math.round(thumbnail.implicitHeight * scaleFactor)
                scale: PathView.onPath ? PathView.scale : 0
                z: PathView.onPath ? Math.floor(PathView.progress * thumbnailView.visibleCount) : -1

                // Reduce opacity on the end so items dissapear more naturally
                opacity: Math.min(1, (1 - PathView.progress) / thumbnailView.preferredHighlightBegin);

                KWin.WindowThumbnail {
                    id: thumbnail
                    readonly property double ratio: implicitWidth / implicitHeight

                    wId: windowId
                    anchors.fill: parent
                }

                Kirigami.ShadowedRectangle {
                    anchors.fill: parent
                    z: -1

                    color: "transparent"
                    shadow.size: Kirigami.Units.gridUnit
                    shadow.color: "black"
                    opacity: 0.5
                    shadow.yOffset: 1
                }

                TapHandler {
                    grabPermissions: PointerHandler.TakeOverForbidden
                    gesturePolicy: TapHandler.WithinBounds
                    onSingleTapped: {
                        if (index === thumbnailView.currentIndex) {
                            thumbnailView.model.activate(index);
                            return;
                        }
                        thumbnailView.movementDirection = PathView.Positive
                        thumbnailView.currentIndex = index
                    }
                }
            }

            transform: Rotation {
                origin { x: thumbnailView.width/2; y: thumbnailView.height/2 }
                axis { x: 0; y: 1; z: -0.15 }
                angle: 10
            }

            highlight: Item {} /*KSvg.FrameSvgItem {
                imagePath: "widgets/viewitem"
                prefix: "hover"

                readonly property Item target: thumbnailView.currentItem

                visible: target !== null
                anchors.centerIn: target
                width: target ? target.width + 6 * Kirigami.Units.smallSpacing : 0
                height: target ? target.height + 6 * Kirigami.Units.smallSpacing : 0
                scale: target ? target.scale : 1
                z: target ? target.z - 0.5 : -0.5
            }*/

            layer.enabled: true
            layer.smooth: true

            onMovementStarted: movementDirection = PathView.Shortest

            Keys.onUpPressed: decrementCurrentIndex()
            Keys.onLeftPressed: decrementCurrentIndex()
            Keys.onDownPressed: incrementCurrentIndex()
            Keys.onRightPressed: incrementCurrentIndex()
        }

        /*RowLayout {
            id: infoBar

            height: Kirigami.Units.iconSizes.large
            spacing: Kirigami.Units.gridUnit
            visible: thumbnailView.count > 0

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                margins: Kirigami.Units.gridUnit
            }

            Kirigami.Icon {
                source: thumbnailView.currentItem?.icon ?? ""
                implicitWidth: Kirigami.Units.iconSizes.large
                implicitHeight: Kirigami.Units.iconSizes.large
                Layout.alignment: Qt.AlignCenter
            }

            PC3.Label {
                font.bold: true
                font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 1.6)
                text: thumbnailView.currentItem?.caption ?? ""
                textFormat: Text.PlainText
                maximumLineCount: 1
                elide: Text.ElideMiddle
                Layout.maximumWidth: tabBox.screenGeometry.width * 0.8
                Layout.alignment: Qt.AlignCenter
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.largeSpacing * 2
            icon.source: "edit-none"
            text: i18ndc("kwin", "@info:placeholder no entries in the task switcher", "No open windows")
            visible: thumbnailView.count === 0
        }*/
    }

    onCurrentIndexChanged: {
        if (currentIndex === thumbnailView.currentIndex) {
            return
        }

        // WindowSwitcher always changes currentIndex in increments of 1.
        // Detect the change direction and set the PathView movement accordingly, so fast changes
        // in the same direction don't result into a combination of forward and backward movements.
        if (thumbnailView.count === 2 || (currentIndex === 0 && thumbnailView.currentIndex === thumbnailView.count - 1)) {
            thumbnailView.movementDirection = PathView.Positive
        } else if (currentIndex === thumbnailView.count - 1 && thumbnailView.currentIndex === 0) {
            thumbnailView.movementDirection = PathView.Negative
        } else {
            thumbnailView.movementDirection = (currentIndex > thumbnailView.currentIndex) ? PathView.Positive : PathView.Negative
        }

        thumbnailView.currentIndex = tabBox.currentIndex
    }

    onVisibleChanged: {
        // Reset the PathView index when hiding to avoid unwanted animations on relaunch
        if (!visible) {
            thumbnailView.currentIndex = 0;
        }
        window.visible = visible && thumbnailView.count !== 0;
    }
}
