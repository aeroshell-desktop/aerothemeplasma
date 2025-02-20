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

KCM.SimpleKCM {
    id: configGeneral

    width: childrenRect.width
    height: childrenRect.height

    property string cfg_icon: Plasmoid.configuration.icon

    property bool cfg_useCustomButtonImage: Plasmoid.configuration.useCustomButtonImage

    property string cfg_customButtonImage: Plasmoid.configuration.customButtonImage
    property string cfg_customButtonImageHover: Plasmoid.configuration.customButtonImageHover
    property string cfg_customButtonImageActive: Plasmoid.configuration.customButtonImageActive
    
    property alias cfg_showRecentsView: showRecentsView.checked
    property alias cfg_offsetFloatingOrb: offsetFloatingOrb.checked
    property alias cfg_accurateSearchBar: accurateSearchBar.checked

    property alias cfg_appNameFormat: appNameFormat.currentIndex
    property alias cfg_switchCategoriesOnHover: switchCategoriesOnHover.checked
    property alias cfg_stickOutOrb: stickOutOrb.checked
    property alias cfg_enableShadow: enableShadow.checked
    property alias cfg_useFullName: useFullName.checked
    property alias cfg_useGenericIcons: useGenericIcons.checked

    property alias cfg_useExtraRunners: useExtraRunners.checked

    property alias cfg_numberRows: numberRows.value
    property alias cfg_orbWidth: orbWidth.value

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
            id: orbGroup


            title: i18n("Orb texture")

            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                IconPicker {
                    id: iconPickerNormal
                    currentIcon: cfg_customButtonImage
                    defaultIcon: ""
                    onIconChanged: iconName => { cfg_customButtonImage = iconName; }
                    Layout.fillWidth: true
                }
                RowLayout {

                    Text {
                        text: "Orb size (0 for default/no scaling):"
                    }
                    SpinBox{
                        id: orbWidth
                        from: 0
                        to: 500
                    }
                }

            }


        }
        CustomGroupBox {
            Layout.fillWidth: true

            title: i18n("Behavior")

            //flat: false

            ColumnLayout {

                RowLayout {
                    visible: false
                    Label {
                        text: i18n("Show applications as:")
                    }

                    ComboBox {
                        id: appNameFormat

                        Layout.fillWidth: true

                        model: [i18n("Name only"), i18n("Description only"), i18n("Name (Description)"), i18n("Description (Name)")]
                    }
                }

                CheckBox {
                    id: switchCategoriesOnHover

                    visible: false
                    text: i18n("Switch categories on hover")
                }
                CheckBox {
                    id: useExtraRunners
                    visible: false
                    text: i18n("Expand search to bookmarks, files and emails")
                }
                CheckBox {
                    id: stickOutOrb

                    text: i18n("Enable floating orb for shorter taskbars")
                }
                CheckBox {
                    id: showRecentsView
                    text: i18n("Show recent programs")
                    visible: false
                }
                CheckBox {
                    id: useFullName
                    text: i18n("Display full name");
                }
                CheckBox {
                    id: useGenericIcons
                    text: i18n("Display generic folder icons for categories");
                }
                RowLayout{
                    Layout.fillWidth: true

                    Label {
                        Layout.leftMargin: Kirigami.Units.smallSpacing
                        text: i18n("Number of recent programs to display:")
                    }
                    SpinBox{
                        id: numberRows
                        from: 0
                        to: 15
                    }
                }
            }
        }

        CustomGroupBox {
            Layout.fillWidth: true
            title: i18n("Tweaks")

            ColumnLayout {
                CheckBox {
                    id: accurateSearchBar
                    text: i18n("Apply uneven padding on the search text box")
                }
                CheckBox {
                    id: offsetFloatingOrb
                    text: i18n("Offset floating orb into the taskbar")
                }
                CheckBox {
                    id: enableShadow
                    text: i18n("Enable shadow")
                }
            }
        }

    }


    Component.onCompleted: {
		if(Plasmoid.configuration.stickOutOrb) Plasmoid.setTransparentWindow();
    }
	Component.onDestruction: {
		if(Plasmoid.configuration.stickOutOrb) Plasmoid.setTransparentWindow();
    }
}
