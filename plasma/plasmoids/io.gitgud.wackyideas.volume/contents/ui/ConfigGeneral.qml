/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kcmutils as KCM
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami 2.3 as Kirigami
import org.kde.plasma.plasmoid 2.0

import org.kde.iconthemes as KIconThemes
import org.kde.plasma.private.kicker 0.1 as Kicker

// Minimal example of a KCM page
KCM.SimpleKCM {
    id: configGeneral

    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_showDeviceName: showDeviceName.checked

    property alias cfg_showLabels: showLabels.checked
    property alias cfg_hideDefaultInput: hideDefaultInput.checked

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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.gridUnit*4
        anchors.rightMargin: Kirigami.Units.gridUnit*4

        CustomGroupBox {
            Layout.fillWidth: true
            title: i18n("General tweaks")

            ColumnLayout {
                CheckBox {
                    id: showDeviceName
                    text: i18n("Show device name instead of placeholder")
                }
            }
        }

        CustomGroupBox {
            Layout.fillWidth: true
            title: i18n("Flyout tweaks")

            ColumnLayout {
                CheckBox {
                    id: showLabels
                    text: i18n("Show labels under icons")
                }
                CheckBox {
                    id: hideDefaultInput
                    text: i18n("Hide default input")
                }
            }
        }

    }
}
