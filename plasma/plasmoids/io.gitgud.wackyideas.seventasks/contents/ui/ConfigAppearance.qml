/*
    SPDX-FileCopyrightText: 2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM
import org.kde.kwindowsystem

KCM.SimpleKCM {
    readonly property bool iconOnly: Plasmoid.configuration.showLabels //Plasmoid.pluginName === "org.kde.plasma.icontasks"

    property alias cfg_showPreviews: showPreviews.checked
    property alias cfg_highlightWindows: highlightWindows.checked
    property alias cfg_thmbnlCaptionAlignment: thmbnlCaptionAlignment.currentIndex
    property alias cfg_showMuteBtn: showMuteBtn.checked

    property alias cfg_showLabels: showLabels.checked
    property alias cfg_disableHottracking: disableHottracking.checked
    property alias cfg_disableJumplists: disableJumplists.checked

    component CustomGroupBox: GroupBox {
        id: gbox
        label: Label {
            id: lbl
            x: gbox.leftPadding + 2
            y: lbl.implicitHeight/2-gbox.bottomPadding-1
            width: lbl.implicitWidth
            text: gbox.title
            elide: Text.ElideRight
            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -2
                anchors.rightMargin: -2
                color: Kirigami.Theme.backgroundColor
                z: -1
            }
        }
        background: Rectangle {
            y: gbox.topPadding - gbox.bottomPadding*2
            width: parent.width
            height: parent.height - gbox.topPadding + gbox.bottomPadding*2
            color: "transparent"
            border.color: "#d5dfe5"
            radius: 3
        }
    }

    ColumnLayout {
        CustomGroupBox {
            id: thumbnailSettings

            Layout.fillWidth: true

            title: i18n("Window previews")

            ColumnLayout {
                anchors.fill: parent

                CheckBox {
                    id: showPreviews
                    text: i18n("Enabled")
                }
                CheckBox {
                    id: highlightWindows
                    text: i18n("Use Window Peek to peek at a single application")
                    enabled: showPreviews.checked
                }
                RowLayout {
                    Text {
                        text: i18n("Caption alignment:")
                    }
                    ComboBox {
                        id: thmbnlCaptionAlignment
                        enabled: showPreviews.checked
                        model: [
                            i18n("Left"),
                            i18n("Center"),
                            i18n("Right")
                        ]
                        currentIndex: Plasmoid.configuration.thmbnlCaptionAlignment
                    }
                }
                CheckBox {
                    id: showMuteBtn
                    text: i18n("Show mute button when an app is playing audio")
                }
            }
        }

        CustomGroupBox {
            id: generalSettings

            Layout.fillWidth: true

            title: i18n("General")

            ColumnLayout {
                anchors.fill: parent

                CheckBox {
                    id: showLabels
                    text: i18n("Show labels next to task icons")
                }
                CheckBox {
                    id: disableHottracking
                    text: i18n("Disable hot tracking")
                }
                CheckBox {
                    id: disableJumplists
                    text: i18n("Use traditional context menus instead of jumplists")
                }
            }
        }
    }
}
