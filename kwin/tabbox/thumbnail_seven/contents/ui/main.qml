/*
 KWin - the KDE window manager
 This file is part of the KDE project.

 SPDX-FileCopyrightText: 2020 Chris Holland <zrenfire@gmail.com>

 SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtCore
import QtQuick
import QtQuick.Layouts 1.1
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kwin 3.0 as KWin
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2.20 as Kirigami

import Qt5Compat.GraphicalEffects
//import QtGraphicalEffects 1.15

// https://techbase.kde.org/Development/Tutorials/KWin/WindowSwitcher
// https://github.com/KDE/kwin/blob/master/tabbox/switcheritem.h
KWin.TabBoxSwitcher {
    id: tabBox
    //currentIndex: thumbnailGridView.currentIndex

    Instantiator {
        active: tabBox.visible
        delegate: PlasmaCore.Dialog {

        id: dialog
        location: PlasmaCore.Types.Floating
        visible: true
        //visible: tabBox.visible
        //opacity: tabBox.visible
        flags: Qt.X11BypassWindowManagerHint | Qt.WindowStaysOnTopHint | Qt.Popup
        x: tabBox.screenGeometry.x + tabBox.screenGeometry.width * 0.5 - dialogMainItem.width * 0.5
        y: tabBox.screenGeometry.y + tabBox.screenGeometry.height * 0.5 - dialogMainItem.height * 0.5

        mainItem: FocusScope {
            id: dialogMainItem

            focus: true

            property int maxWidth: tabBox.screenGeometry.width * 0.9
            property int maxHeight: tabBox.screenGeometry.height * 0.7
            property real screenFactor: tabBox.screenGeometry.width / tabBox.screenGeometry.height
            property int maxGridColumnsByWidth: Math.floor(maxWidth / thumbnailGridView.cellWidth)

            property int gridColumns: {         // Simple greedy algorithm
                // respect screenGeometry
                const c = Math.min(thumbnailGridView.count, maxGridColumnsByWidth);
                const residue = thumbnailGridView.count % c;
                if (residue == 0) {
                    return c;
                }
                // start greedy recursion
                return columnCountRecursion(c, c, c - residue);
            }

            property int gridRows: Math.ceil(thumbnailGridView.count / gridColumns)
            property int optimalWidth: thumbnailGridView.cellWidth * gridColumns
            property int optimalHeight: thumbnailGridView.cellHeight * gridRows
            width: Math.min(Math.max(thumbnailGridView.cellWidth, optimalWidth), maxWidth)
            height: Math.min(Math.max(thumbnailGridView.cellHeight, optimalHeight) + windowTitle.height + Kirigami.Units.smallSpacing*4, maxHeight)

            //clip: true

            // Step for greedy algorithm
            function columnCountRecursion(prevC, prevBestC, prevDiff) {
                const c = prevC - 1;

                // don't increase vertical extent more than horizontal
                // and don't exceed maxHeight
                if (prevC * prevC <= thumbnailGridView.count + prevDiff ||
                        maxHeight < Math.ceil(thumbnailGridView.count / c) * thumbnailGridView.cellHeight) {
                    return prevBestC;
                }
                const residue = thumbnailGridView.count % c;
                // halts algorithm at some point
                if (residue == 0) {
                    return c;
                }
                // empty slots
                const diff = c - residue;

                // compare it to previous count of empty slots
                if (diff < prevDiff) {
                    return columnCountRecursion(c, c, diff);
                } else if (diff == prevDiff) {
                    // when it's the same try again, we'll stop early enough thanks to the landscape mode condition
                    return columnCountRecursion(c, prevBestC, diff);
                }
                // when we've found a local minimum choose this one (greedy)
                return columnCountRecursion(c, prevBestC, diff);
            }

            // Just to get the margin sizes
            KSvg.FrameSvgItem {
                id: hoverItem
                imagePath: "widgets/viewitem"
                prefix: "hover"
                visible: false
            }
            KSvg.FrameSvgItem {
                id: dialogSvg
                imagePath: "dialogs/background"
                visible: false

            }
            Item {
                id: glowCorners
                anchors.fill: parent
                anchors.topMargin: -dialogSvg.margins.top
                anchors.leftMargin: -dialogSvg.margins.left
                anchors.rightMargin: -dialogSvg.margins.right
                anchors.bottomMargin: -dialogSvg.margins.bottom
                visible: true


                Image {
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: -dialogSvg.margins.left + 8
                        topMargin: -dialogSvg.margins.top + 8
                    }
                    source: StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + "/smod/framecornereffect.png" //"~/.local/share/smod/reflections.png"
                    //clip: true
                    smooth: true
                }
                Image {
                    anchors {
                        top: parent.top
                        right: parent.right
                        rightMargin: 2//-dialogSvg.margins.right
                        topMargin: 2//-dialogSvg.margins.top + 4
                    }
                    source: StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + "/smod/framecornereffect.png"
                    //clip: true
                    mirror: true
                    smooth: true
                }

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        x: glowCorners.x
                        y: glowCorners.y
                        width: glowCorners.width
                        height: glowCorners.height
                        radius: 10
                    }
                }
            }
            Text {
                id: windowTitle
                anchors {
                    top: parent.top
                    topMargin: Kirigami.Units.smallSpacing*2
                    left: parent.left
                    right: parent.right
                }
                font.pixelSize: 16
                color: "black"
                horizontalAlignment: Text.AlignHCenter
                text: thumbnailGridView.currentItem ? thumbnailGridView.currentItem.caption : ""
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            Glow {
                anchors.fill: windowTitle
                radius: 15
                samples: 31
                color: "#77ffffff"
                spread: 0.60
                source: windowTitle
                cached: true
            }

            GridView {
                id: thumbnailGridView
                anchors {
                    top: windowTitle.bottom
                    topMargin: Kirigami.Units.smallSpacing*2
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                focus: true
                model: tabBox.model
                currentIndex: tabBox.currentIndex

                property int iconSize: Kirigami.Units.iconSizes.medium
                property int captionRowHeight: 30  // The close button is 30x30 in Breeze
                property int thumbnailWidth: 125
                property int thumbnailHeight: thumbnailWidth * (1.0/dialogMainItem.screenFactor)
                cellWidth: hoverItem.margins.left + thumbnailWidth + hoverItem.margins.right
                cellHeight: hoverItem.margins.top + thumbnailHeight + hoverItem.margins.bottom

                keyNavigationWraps: true
                highlightMoveDuration: 0


                delegate: Item {
                    id: thumbnailGridItem
                    width: thumbnailGridView.cellWidth
                    height: thumbnailGridView.cellHeight

                    property variant caption: model.caption

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: (mouse) => {
                            if(mouse.button === Qt.RightButton) {
                                thumbnailGridItem.select();
                            } else if(mouse.button === Qt.MiddleButton) {
                                tabBox.model.close(index);
                            } else if(mouse.button === Qt.LeftButton) {
                                tabBox.model.activate(index);
                                return;
                            }
                        }
                    }
                    function select() {
                        thumbnailGridView.currentIndex = index;
                        thumbnailGridView.currentIndexChanged(/*thumbnailGridView.currentIndex*/);
                    }
                    KSvg.FrameSvgItem {
                        id: highlightItem
                        imagePath: "widgets/viewitem"
                        anchors.fill: parent
                        prefix: {
                            if((ma.containsMouse && thumbnailGridView.currentIndex === index) || ma.containsPress) return "selected+hover";
                            else if(thumbnailGridView.currentIndex === index) return "selected";
                            else if(ma.containsMouse) return "hover";
                        }
                    }

                    ColumnLayout {
                        z: 0
                        spacing: 0
                        anchors.fill: parent
                        anchors.leftMargin: hoverItem.margins.left
                        anchors.topMargin: hoverItem.margins.top
                        anchors.rightMargin: hoverItem.margins.right
                        anchors.bottomMargin: hoverItem.margins.bottom

                        // KWin.ThumbnailItem needs a container
                        // otherwise it will be drawn the same size as the parent ColumnLayout
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            // Cannot draw anything (like an icon) on top of thumbnail
                            KWin.WindowThumbnail {
                                id: thumbnailItem
                                anchors.fill: parent
                                wId: windowId
                            }
                            Kirigami.Icon {
                                id: iconItem
                                width: thumbnailGridView.iconSize
                                height: width
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                source: model.icon
                                //usesPlasmaTheme: false
                                visible: tabBox.compositing
                            }
                        }
                    }
                } // GridView.delegate

                onCurrentIndexChanged: tabBox.currentIndex = thumbnailGridView.currentIndex;
                /*Connections {
                    target: tabBox
                    function onCurrentIndexChanged() {
                        thumbnailGridView.currentIndex = tabBox.currentIndex;
                    }
                }*/
            } // GridView

            Keys.onPressed: {
                if (event.key == Qt.Key_Left) {
                    thumbnailGridView.moveCurrentIndexLeft();
                } else if (event.key == Qt.Key_Right) {
                    thumbnailGridView.moveCurrentIndexRight();
                } else if (event.key == Qt.Key_Up) {
                    thumbnailGridView.moveCurrentIndexUp();
                } else if (event.key == Qt.Key_Down) {
                    thumbnailGridView.moveCurrentIndexDown();
                } else {
                    return;
                }

                thumbnailGridView.currentIndexChanged(thumbnailGridView.currentIndex);
            }
        } // Dialog.mainItem
    } // Dialog
    } // Instantiator
}
