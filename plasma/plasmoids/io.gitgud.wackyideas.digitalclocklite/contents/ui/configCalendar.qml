/*
 * Copyright 2015 Martin Klapetek <mklapetek@kde.org>
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

import QtQuick 2.0
import QtQuick.Controls as QtControls
import QtQuick.Layouts 1.0 as QtLayouts
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.workspace.calendar 2.0 as PlasmaCalendar
import org.kde.kcmutils as KCM
import org.kde.kirigami 2.20 as Kirigami

KCM.SimpleKCM {
    id: calendarPage
    width: childrenRect.width
    height: childrenRect.height

    signal configurationChanged()

    property alias cfg_showWeekNumbers: showWeekNumbers.checked
    property int cfg_firstDayOfWeek

    PlasmaCalendar.EventPluginsManager {
        id: eventPluginsManager
        Component.onCompleted: {
            populateEnabledPluginsList(Plasmoid.configuration.enabledCalendarPlugins);
        }
    }
    function saveConfig()
    {
        Plasmoid.configuration.enabledCalendarPlugins = eventPluginsManager.enabledPlugins;
    }

    QtLayouts.ColumnLayout {
        anchors.left: parent.left
        QtControls.CheckBox {
            id: showWeekNumbers
            text: i18n("Show week numbers in Calendar")
            visible: false
        }

        QtLayouts.RowLayout {
            QtLayouts.Layout.fillWidth: true

            Text {
                text: i18n("First day of week:")
            }
            //Kirigami.FormData.label: i18n("First day of week:")

            QtControls.ComboBox {
                id: firstDayOfWeekCombo
                textRole: "text"
                model: [-1, 0, 1, 5, 6].map(day => ({
                    day,
                    text: day === -1 ? i18n("Use Region Defaults") : Qt.locale().dayName(day),
                }))
                onActivated: cfg_firstDayOfWeek = model[index].day
                currentIndex: model.findIndex(item => item.day === cfg_firstDayOfWeek)
            }
        }

        CustomGroupBox {
            QtLayouts.Layout.fillWidth: true
            title: i18n("Available Calendar Plugins")
            //flat: true

            QtLayouts.ColumnLayout {
                Repeater {
                    id: calendarPluginsRepeater
                    model: eventPluginsManager.model
                    delegate: QtLayouts.RowLayout {
                        QtControls.CheckBox {
                            text: model.display
                            checked: model.checked
                            onClicked: {
                                //needed for model's setData to be called
                                model.checked = checked;
                                calendarPage.configurationChanged();
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        eventPluginsManager.populateEnabledPluginsList(Plasmoid.configuration.enabledCalendarPlugins);
    }
}

