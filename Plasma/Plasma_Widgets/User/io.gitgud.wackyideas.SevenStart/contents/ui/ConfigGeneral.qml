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

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
    id: configGeneral

    width: childrenRect.width
    height: childrenRect.height

    property string cfg_icon: plasmoid.configuration.icon

    property bool cfg_useCustomButtonImage: plasmoid.configuration.useCustomButtonImage

    property string cfg_customButtonImage: plasmoid.configuration.customButtonImage
    property string cfg_customButtonImageHover: plasmoid.configuration.customButtonImageHover
    property string cfg_customButtonImageActive: plasmoid.configuration.customButtonImageActive
    
    property alias cfg_showRecentsView: showRecentsView.checked

    property alias cfg_appNameFormat: appNameFormat.currentIndex
    property alias cfg_switchCategoriesOnHover: switchCategoriesOnHover.checked

    property alias cfg_useExtraRunners: useExtraRunners.checked

    property alias cfg_numberRows: numberRows.value

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        RowLayout {
            spacing: units.smallSpacing

            Label {
                text: i18n("Icon:")
            }

            IconPicker {
                id: iconPickerNormal
                currentIcon: cfg_customButtonImage
                defaultIcon: ""
                onIconChanged: cfg_customButtonImage = iconName
                enabled: true
                
            }
            Label {
                text: i18n("Hover Icon:")
            }
            IconPicker {
                id: iconPickerHover
                currentIcon: cfg_customButtonImageHover
                defaultIcon: ""
                onIconChanged: cfg_customButtonImageHover = iconName
                enabled: true
                
            }
            Label {
                text: i18n("Active Icon:")
            }
            IconPicker {
                id: iconPickerActive
                currentIcon: cfg_customButtonImageActive
                defaultIcon: ""
                onIconChanged: cfg_customButtonImageActive = iconName
                enabled: true
                
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Behavior")

            flat: false

            ColumnLayout {
                RowLayout {
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

                    text: i18n("Switch categories on hover")
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true
            title: i18n("Search")
            flat: false

            ColumnLayout {
                CheckBox {
                    id: useExtraRunners

                    text: i18n("Expand search to bookmarks, files and emails")
                }
            }
        }

        GroupBox {
            title: i18n("Rows")
            flat: false
            ColumnLayout {
                RowLayout{
                    Layout.fillWidth: true

                    RowLayout{
                        Layout.fillWidth: true
                        SpinBox{
                            id: numberRows
                            minimumValue: 10
                            maximumValue: 15
                        }
                        Label {
                            Layout.leftMargin: units.smallSpacing
                            text: i18n("Number of rows")
                        }
                    }
                }
            }
        }
        GroupBox {
            title: i18n("View")
            flat: false
            ColumnLayout {
                RowLayout{
                    Layout.fillWidth: true

                    RowLayout{
                        Layout.fillWidth: true
                        CheckBox {
                            id: showRecentsView
                            text: i18n("Show recent programs")
                        }
                    }
                }
            }
        }
    }
}
