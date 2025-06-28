/*
 KWin - the KDE window manager
 This file is part of the KDE project.

 SPDX-FileCopyrightText: 2020 Chris Holland <zrenfire@gmail.com>

 SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtCore
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kwin 3.0 as KWin
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kwindowsystem 1.0
import org.kde.plasma.workspace.dbus as DBus

import Qt5Compat.GraphicalEffects

// https://techbase.kde.org/Development/Tutorials/KWin/WindowSwitcher
// https://github.com/KDE/kwin/blob/master/tabbox/switcheritem.h
KWin.TabBoxSwitcher {
    id: tabBox
	function toggleMinimizeAll() {
        const promise = new Promise((resolve, reject) => {
            DBus.SessionBus.asyncCall({
                service: "org.kde.kglobalaccel",
                path: "/component/kwin",
                iface: "org.kde.kglobalaccel.Component",
                member: "invokeShortcut",
                arguments: [new DBus.string("MinimizeAll")],
                                      signature: "(s)"},
                                      resolve, reject);
        }).then((reply) => {
            console.log(reply.value);
        }).catch((reply) => {
            console.log(reply.value);
        });
    }

    PlasmaCore.Dialog {
        id: dialog
        location: PlasmaCore.Types.Floating
        visible: tabBox.visible && dialog.mainItem.count > 1
        opacity: 1
        flags: Qt.BypassWindowManagerHint | Qt.WindowStaysOnTopHint | Qt.Popup
        x: tabBox.screenGeometry.x + tabBox.screenGeometry.width * 0.5 - dialogMainItem.width * 0.5
        y: tabBox.screenGeometry.y + tabBox.screenGeometry.height * 0.5 - dialogMainItem.height * 0.5
        title: "aerothemeplasma-tabbox"

        onVisibleChanged: {
            if(!visible) {
                if(mainItem.currentItem.isShowDesktop) {
                    tabBox.toggleMinimizeAll();
                    KWindowSystem.showingDesktop = false;
                }
            }
        }
        FocusScope {
            id: dialogMainItem

            focus: true

            property int maxWidth: 1024
            property int maxHeight: tabBox.screenGeometry.height * 0.8
            property real screenFactor: tabBox.screenGeometry.width / tabBox.screenGeometry.height
            property int maxGridRowsByHeight: 5
            property int maxGridColumnsByWidth: 7

            property int count: thumbnailGridView.count
            property int currentIndex: thumbnailGridView.currentIndex
            property Item currentItem: thumbnailGridView.currentItem
            property int currentColumnCount: Math.min(7, count)

            property int intendedWidth: Math.max(360, thumbnailGridView.cellWidth*currentColumnCount + Kirigami.Units.largeSpacing*2)
            Layout.minimumWidth: intendedWidth
            Layout.minimumHeight: windowTitle.Layout.preferredHeight + windowTitle.Layout.topMargin + windowTitle.Layout.bottomMargin
                                    + thumbnailGridView.height + thumbnailGridView.Layout.bottomMargin;
            Layout.maximumHeight: Layout.minimumHeight
            Layout.maximumWidth: Layout.minimumWidth

            // Just to get the margin sizes
            KSvg.FrameSvgItem {
                id: hoverItem
                imagePath: "widgets/viewitem"
                prefix: "hover"
                visible: false
            }
            ColumnLayout {
                id: columnLayout
                spacing: 0
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                Text {
                    id: windowTitle
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 16
                    Layout.preferredHeight: windowTitle.implicitHeight
                    Layout.maximumWidth: thumbnailGridView.Layout.maximumWidth
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pixelSize: 16
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    text: thumbnailGridView.currentItem ? (thumbnailGridView.currentItem.isShowDesktop ? "Desktop" : thumbnailGridView.currentItem.caption) : ""
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    layer.enabled: true
                    layer.effect: Glow {
                        x: windowTitle.x
                        y: windowTitle.y
                        width: windowTitle.width
                        height: windowTitle.height
                        //anchors.fill: windowTitle
                        radius: 15
                        samples: 31
                        color: "#77ffffff"
                        spread: 0.60
                        source: windowTitle
                        cached: true
                    }
                }
                GridView {
                    id: thumbnailGridView
                    Layout.maximumWidth: 7*cellWidth
                    Layout.maximumHeight: 5*cellHeight
                    Layout.minimumWidth: 2*cellWidth
                    Layout.minimumHeight: cellHeight
                    Layout.preferredWidth: thumbnailGridView.count * cellWidth
                    Layout.preferredHeight: Math.ceil(thumbnailGridView.count / Math.min(thumbnailGridView.count, 7)) * cellHeight
                    Layout.bottomMargin: 2
                    Layout.leftMargin: 2
                    Layout.rightMargin: 2
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    focus: true
                    model: tabBox.model
                    currentIndex: tabBox.currentIndex

                    interactive: false

                    property int iconSize: Kirigami.Units.iconSizes.medium
                    property int captionRowHeight: 30  // The close button is 30x30 in Breeze
                    property int thumbnailWidth: cellWidth - 22
                    property int thumbnailHeight: cellHeight - Kirigami.Units.largeSpacing*2//thumbnailWidth * (1.0/dialogMainItem.screenFactor)
                    cellWidth: Math.min(144, tabBox.screenGeometry.width * 0.10)
                    cellHeight: Math.min(75, tabBox.screenGeometry.height * 0.10)

                    keyNavigationWraps: true
                    highlightMoveDuration: 0
                    delegate: Item {
                        id: thumbnailGridItem
                        width: thumbnailGridView.cellWidth
                        height: thumbnailGridView.cellHeight

                        property variant caption: model.caption
                        property bool canClose: model.closeable

                        property bool isShowDesktop: {
                            //console.log(index === mainItem.count-1 && !canClose && model.icon.toString().includes("user-desktop"))
                            return index === dialogMainItem.count-1 && !canClose && model.icon.toString().includes("user-desktop")
                        }

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
                            tabBox.currentIndex = index;
                        }
                        KSvg.FrameSvgItem {
                            id: highlightItem
                            imagePath: Qt.resolvedUrl("textures/highlight.svg");//"widgets/viewitem"
                            anchors.fill: parent
                            prefix: {
                                if((ma.containsMouse && thumbnailGridView.currentIndex === index) || ma.containsPress) return "highlight-pressed";
                                else if(thumbnailGridView.currentIndex === index) return "highlight-pressed";
                                else if(ma.containsMouse) return "highlight-hover";
                            }
                            opacity: {
                                if((ma.containsMouse && thumbnailGridView.currentIndex === index) || ma.containsPress) return 1.0;
                                else if(thumbnailGridView.currentIndex === index) return 0.75;
                                else if(ma.containsMouse) return 1.0;
                                return 1.0
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
                                DropShadow {
                                    anchors.fill: thumbnailItem
                                    horizontalOffset: 2
                                    verticalOffset: 2
                                    radius: 4.0
                                    color: "#a0000000"
                                    source: thumbnailItem
                                }
                                Kirigami.Icon {
                                    id: iconItem
                                    width: thumbnailGridView.iconSize
                                    height: width
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    anchors.bottomMargin: -2
                                    source: isShowDesktop ? "desktop" : model.icon
                                    //usesPlasmaTheme: false
                                    visible: tabBox.compositing
                                }
                            }
                        }
                    } // GridView.delegate
                    onCurrentIndexChanged: tabBox.currentIndex = thumbnailGridView.currentIndex;
                } // GridView

            }



            Keys.onPressed: event => {
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

                thumbnailGridView.currentIndexChanged();
            }
        } // Dialog.mainItem
    } // Dialog
}
