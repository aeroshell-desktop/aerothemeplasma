/*
    SPDX-FileCopyrightText: 2013 Heena Mahour <heena393@gmail.com>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2021 Jan Blackquill <uhhadd@gmail.com>
    SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick 2.2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQml.Models 2.15

import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.workspace.calendar 2.0

PlasmaComponents3.AbstractButton {
    id: dayStyle

    hoverEnabled: true
    property var dayModel: null

    signal activated


    readonly property date thisDate: new Date(yearNumber, typeof monthNumber !== "undefined" ? monthNumber - 1 : 0, typeof dayNumber !== "undefined" ? dayNumber : 1)
    readonly property bool today: {
        const today = root.today;
        let result = true;
        if (dateMatchingPrecision >= Calendar.MatchYear) {
            result = result && today.getFullYear() === thisDate.getFullYear()
        }
        if (dateMatchingPrecision >= Calendar.MatchYearAndMonth) {
            result = result && today.getMonth() === thisDate.getMonth()
        }
        if (dateMatchingPrecision >= Calendar.MatchYearMonthAndDay) {
            result = result && today.getDate() === thisDate.getDate()
        }
        return result
    }
    readonly property bool selected: {
        const current = root.currentDate;
        let result = true;
        if (dateMatchingPrecision >= Calendar.MatchYear) {
            result = result && current.getFullYear() === thisDate.getFullYear()
        }
        if (dateMatchingPrecision >= Calendar.MatchYearAndMonth) {
            result = result && current.getMonth() === thisDate.getMonth()
        }
        if (dateMatchingPrecision >= Calendar.MatchYearMonthAndDay) {
            result = result && current.getDate() === thisDate.getDate()
        }
        return result
    }

    PlasmaExtras.Highlight {
        id: todayRect
        anchors.fill: parent
        hovered: true
        opacity: {
            if (today && !dayStyle.hovered && !selected) {
                return 0;
            } else if (selected) {
                return 0.8;
            } else if (dayStyle.pressed) {
                return 0.3;
            } else if (dayStyle.hovered) {
                return 0.6;
            }
            return 0;
        }
        z: -1;
    }

    Rectangle {
        id: currentDayRect
        anchors.fill: parent
        visible: today
        radius: 2
        border.color: "#0066cc"
        color: "transparent"
    }
    contentItem: PlasmaExtras.Heading {
        id: label
        horizontalAlignment: dateMatchingPrecision != Calendar.MatchYearMonthAndDay ? Text.AlignHCenter: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        bottomPadding: dateMatchingPrecision != Calendar.MatchYearMonthAndDay ? 0 : 1
        rightPadding: dateMatchingPrecision != Calendar.MatchYearMonthAndDay ? 0 : Kirigami.Units.smallSpacing+1
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        font.bold: calendar.showAgenda && model.eventCount !== undefined && model.eventCount > 0
        fontSizeMode: Text.Fit

        color: today || (!dayStyle.pressed && dayStyle.hovered) ? "#0066cc" : Kirigami.Theme.textColor

        text: {
            if(model.label) {
                if(dateMatchingPrecision == Calendar.MatchYearAndMonth) return model.label.substring(0, 3);
                return model.label;
            }
            return dayNumber;
        }
        opacity: isCurrent ? 1.0 : 0.5
        level: 5
    }
}
