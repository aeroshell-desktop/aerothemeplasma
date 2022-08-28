/*
    SPDX-FileCopyrightText: 2013 Heena Mahour <heena393@gmail.com>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015, 2016 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1 as QQC1

import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

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

    PlasmaCore.Svg {
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
                font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, daysCalendar.cellHeight / 3)
            }
        }
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

        spacing: root.borderWidth
        columnSpacing: parent.squareCell ? (daysCalendar.width - daysCalendar.columns * (daysCalendar.cellWidth - root.borderWidth)) / daysCalendar.columns : root.borderWidth
        property bool containsEventItems: false // FIXME
        property bool containsTodoItems: false // FIXME

        Repeater {
            id: days

            PlasmaComponents3.Label {
                width: daysCalendar.cellWidth
                height: daysCalendar.cellHeight
                text: Qt.locale(Qt.locale().uiLanguages[0]).dayName(((calendarBackend.firstDayOfWeek + index) % days.count), Locale.ShortFormat)
                font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, daysCalendar.cellHeight / 3)
                opacity: 0.8
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

                MouseArea {
                    anchors.fill: parent
                    property int wheelDelta: 0

                    onClicked: {
                        daysCalendar.activated(index, model, delegate)
                    }
                    onWheel: {
                        var delta = wheel.angleDelta.y || wheel.angleDelta.x
                        wheelDelta += delta

                        // magic number 120 for common "one click"
                        // See: https://doc.qt.io/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop


                        while(wheelDelta >= 120) {
                            wheelDelta -= 120;
                            daysCalendar.scrollDown()
                        }

                        while(wheelDelta <= -120) {
                            wheelDelta += 120
                            daysCalendar.scrollUp()
                        }
                    }
                }
            }
        }
    }
}

