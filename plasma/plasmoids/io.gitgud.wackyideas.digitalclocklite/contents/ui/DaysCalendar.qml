/*
    SPDX-FileCopyrightText: 2013 Heena Mahour <heena393@gmail.com>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015, 2016 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls as QQC1

import org.kde.plasma.workspace.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

Item {
    id: daysCalendar

    signal headerClicked
    signal scrollUp
    signal scrollDown
    signal activated(int index, var date, var item)
    // so it forwards it to the delegate which then emits activated with all the necessary data
    signal activateHighlightedItem

    readonly property int gridColumns: showWeekNumbers ? calendarGrid.columns + 1 : calendarGrid.columns

    property int rows
    property int columns

    property bool showWeekNumbers

    // how precise date matching should be, 3 = day+month+year, 2 = month+year, 1 = just year
    property int dateMatchingPrecision

    property alias headerModel: days.model
    property alias gridModel: repeater.model

    // Take the calendar width, subtract the inner and outer spacings and divide by number of columns (==days in week)
    readonly property int cellWidth: Math.floor((swipeView.width - (daysCalendar.columns + 1) * root.borderWidth) / (daysCalendar.columns + (showWeekNumbers ? 1 : 0)))
    // Take the calendar height, subtract the inner spacings and divide by number of rows (root.weeks + one row for day names)
    readonly property int cellHeight:  Math.floor((swipeView.height - heading.height - calendarGrid.rows * root.borderWidth) / calendarGrid.rows)

    KSvg.Svg {
        id: calendarSvg
        imagePath: "widgets/calendar"
    }

    Column {
        id: weeksColumn
        visible: showWeekNumbers
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            // The borderWidth needs to be counted twice here because it goes
            // in fact through two lines - the topmost one (the outer edge)
            // and then the one below weekday strings
            topMargin: daysCalendar.cellHeight + root.borderWidth + root.borderWidth
        }
        spacing: root.borderWidth

        Repeater {
            model: showWeekNumbers ? calendarBackend.weeksModel : []

            PlasmaComponents3.Label {
                height: daysCalendar.cellHeight
                width: daysCalendar.cellWidth
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: 0.4
                text: modelData
                font.pixelSize: Math.max(Kirigami.Theme.smallestFont.pixelSize, daysCalendar.cellHeight / 3)
            }
        }
    }

    Rectangle {
        visible: days.count > 0
        anchors.top: calendarGrid.top
        anchors.topMargin: daysCalendar.cellHeight
        height: 1
        anchors.left: calendarGrid.left
        anchors.right: calendarGrid.right
        color: "#f5f5f5"
    }
    Grid {
        id: calendarGrid

        anchors {
            top: parent.top
            right: parent.right
            rightMargin: root.borderWidth
            bottom: parent.bottom
            bottomMargin: root.borderWidth
        }

        columns: daysCalendar.columns
        rows: daysCalendar.rows + (daysCalendar.headerModel ? 1 : 0)

        spacing: 0//root.borderWidth
        columnSpacing: parent.squareCell ? (daysCalendar.width - daysCalendar.columns * (daysCalendar.cellWidth - root.borderWidth)) / daysCalendar.columns : root.borderWidth
        property bool containsEventItems: false // FIXME
        property bool containsTodoItems: false // FIXME

        Repeater {
            id: days

            PlasmaComponents3.Label {
                width: daysCalendar.cellWidth
                height: daysCalendar.cellHeight
                text: (Qt.locale(Qt.locale().uiLanguages[0]).dayName(((calendarBackend.firstDayOfWeek + index) % days.count), Locale.ShortFormat)).substring(0, 2);
                font.pixelSize: Math.max(Kirigami.Theme.smallestFont.pixelSize, daysCalendar.cellHeight / 3)
                //opacity: 0.8
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                fontSizeMode: Text.HorizontalFit
            }
        }


        Repeater {
            id: repeater

            DayDelegate {
                id: delegate
                width: daysCalendar.cellWidth
                height: daysCalendar.cellHeight
                dayModel: repeater.model

                Connections {
                    target: daysCalendar
                    function onActivateHighlightedItem(delegate) {
                        if (delegate.containsMouse) {
                            delegate.clicked(null)
                        }
                    }
                }
                onClicked: {
                    daysCalendar.activated(index, model, delegate);
                }
            }
        }
    }
}

