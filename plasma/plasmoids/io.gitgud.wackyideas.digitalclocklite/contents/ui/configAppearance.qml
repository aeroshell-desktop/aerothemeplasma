/*
 * Copyright 2013  Bhushan Shah <bhush94@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 * Copyright 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts
import QtQuick.Dialogs as QtDialogs
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kcmutils // For KCMLauncher
import org.kde.config // For KAuthorized
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.calendar as PlasmaCalendar

SimpleKCM {
    id: appearancePage
    width: childrenRect.width
    height: childrenRect.height

    signal configurationChanged

    property font cfg_font
    property alias cfg_useDefaultFont: useDefaultFont.checked
    property alias cfg_boldText: boldCheckBox.checked
    property string cfg_timeFormat: ""
    property alias cfg_italicText: italicCheckBox.checked

    property alias cfg_showLocalTimezone: showLocalTimezone.checked
    property alias cfg_displayTimezoneAsCode: timezoneCodeRadio.checked
    property alias cfg_showSeconds: showSeconds.checked

    property alias cfg_showDate: showDate.checked
    property alias cfg_shortTaskbarHideDate: shortTaskbarHideDate.checked
    property string cfg_dateFormat: "shortDate"
    property alias cfg_customFormat: customFormatField.text
    property alias cfg_use24hFormat: use24hFormat.checkState
    property alias cfg_showPinButton: showPinButton.checked


    QtLayouts.ColumnLayout {
        anchors.left: parent.left

        CustomGroupBox {
            QtLayouts.Layout.fillWidth: true
            title: i18n("Information")
            //flat: true

            QtLayouts.ColumnLayout {
                QtControls.CheckBox {
                    id: showDate
                    text: i18n("Show date")
                }
                QtControls.CheckBox {
                    id: shortTaskbarHideDate
                    text: i18n("Hide date on shorter taskbars")
                }

                QtControls.CheckBox {
                    id: showSeconds
                    text: i18n("Show seconds")
                }
                QtControls.CheckBox {
                    id: showPinButton
                    text: i18n("Show pin button")
                }

                QtControls.CheckBox {
                    id: use24hFormat
                    text: i18nc("Checkbox label; means 24h clock format, without am/pm", "Use 24-hour Clock")
                }

                QtControls.CheckBox {
                    id: showLocalTimezone
                    text: i18n("Show local time zone")
                }

                /*QtControls.Label {
                    text: i18n("Display time zone as:")
                }*/


                QtControls.ButtonGroup {
                    buttons: timezoneColumn.children
                }
                CustomGroupBox {
                    QtLayouts.Layout.fillWidth: true
                    visible: false
                    //flat: true
                    QtLayouts.ColumnLayout {

                        id: timezoneColumn
                        //QtControls.ExclusiveGroup { id: timezoneDisplayType }

                        QtControls.RadioButton {
                            id: timezoneCityRadio
                            text: i18n("Time zone city")
                            //exclusiveGroup: timezoneDisplayType
                        }

                        QtControls.RadioButton {
                            id: timezoneCodeRadio
                            text: i18n("Time zone code")
                            //exclusiveGroup: timezoneDisplayType
                        }
                    }
                }

                QtLayouts.RowLayout {
                    QtControls.Label {
                        text: i18n("Date format:")
                    }

                    QtControls.ComboBox {
                        id: dateFormat
                        enabled: showDate.checked
                        textRole: "label"
                        model: [
                            {
                                'label': i18n("Long Date"),
                                'name': "longDate"
                            },
                            {
                                'label': i18n("Short Date"),
                                'name': "shortDate"
                            },
                            {
                                'label': i18n("ISO Date"),
                                'name': "isoDate"
                            },
                            {
                                'label': i18n("Custom Date"),
                                'name': "customDate"
                            }
                        ]
                        onCurrentIndexChanged: cfg_dateFormat = model[currentIndex]["name"]

                        Component.onCompleted: {
                            for (var i = 0; i < model.length; i++) {
                                if (model[i]["name"] == Plasmoid.configuration.dateFormat) {
                                    dateFormat.currentIndex = i;
                                }
                            }
                        }
                    }
                }

                QtLayouts.RowLayout {
                    visible: dateFormat.currentIndex === dateFormat.model.length-1

                    QtControls.Label {
                        text: i18n("Custom format:")
                    }
                    QtControls.TextField {
                        id: customFormatField
                        Component.onCompleted: {
                            customFormatField.text = Plasmoid.configuration.customFormat
                        }
                    }

                    Text {
                        id: testDate
                        text: Qt.formatDate(new Date(), customFormatField.text)
                    }

                }
            }
        }
        
        QtLayouts.RowLayout {
            QtLayouts.Layout.fillWidth: true

            QtControls.CheckBox {
                id: useDefaultFont
                text: i18n("Use default font")

            }

            QtControls.TextField {
                enabled: !useDefaultFont.checked
                readOnly: true
                text: i18nc("@info The selected font family (%1) and font size (%2)", "%1 %2 pt", font.family, font.pointSize)
                font: fontDialog.selectedFont
            }

            QtControls.Button {
                id: fontChooserButton
                enabled: !useDefaultFont.checked
                text: i18n("Select Font...")
                display: QtControls.AbstractButton.IconOnly
                icon.name: "kfontview"
                onClicked: {
                    fontDialog.open();
                }
                QtControls.ToolTip {
                    visible: fontChooserButton.hovered
                    text: fontChooserButton.text
                }
            }
            
            QtControls.Button {
                id: boldCheckBox
                //tooltip: i18n("Bold text")
                icon.name: "format-text-bold"
                display: QtControls.AbstractButton.IconOnly
                checkable: true
                //Accessible.name: tooltip
                QtControls.ToolTip {
                    visible: boldCheckBox.hovered
                    text: i18n("Bold")
                }
            }

            QtControls.Button {
                id: italicCheckBox
                //tooltip: i18n("Italic text")
                icon.name: "format-text-italic"
                display: QtControls.AbstractButton.IconOnly
                checkable: true
                //Accessible.name: tooltip
                QtControls.ToolTip {
                    visible: italicCheckBox.hovered
                    text: i18n("Italic")
                }
            }
        }
    }

    QtDialogs.FontDialog {
        id: fontDialog
        title: i18nc("@title:window", "Select Font")

        selectedFont: (!appearancePage.cfg_font || appearancePage.cfg_font.family === "") ? Kirigami.Theme.defaultFont : appearancePage.cfg_font

        onAccepted: {
            appearancePage.cfg_font = selectedFont;
        }
    }

    Component.onCompleted: {
        if (Plasmoid.configuration.displayTimezoneAsCode) {
            timezoneCodeRadio.checked = true;
        } else {
            timezoneCityRadio.checked = true;
        }

        boldCheckBox.checked = Plasmoid.configuration.boldText;
        italicCheckBox.checked = Plasmoid.configuration.italicText;

    }
}
