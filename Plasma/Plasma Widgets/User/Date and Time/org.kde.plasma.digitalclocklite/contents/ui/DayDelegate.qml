/*
    SPDX-FileCopyrightText: 2013 Heena Mahour <heena393@gmail.com>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2021 Jan Blackquill <uhhadd@gmail.com>
    SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick 2.0
import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQml.Models 2.15
import org.kde.kirigami 2.12 as Kirigami
import QtGraphicalEffects 1.15

import org.kde.plasma.calendar 2.0

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
            if (today) {
                return 0.7;
            } else if (selected) {
                return 0.6;
            } else if (dayStyle.hovered) {
                return 0.3;
            }
            return 0;
        }
        z: -1;
    }

    /*Loader {
        active: model.eventCount !== undefined && model.eventCount > 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: PlasmaCore.Units.smallSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: Row {
            spacing: PlasmaCore.Units.smallSpacing
            Repeater {
                model: DelegateModel {
                    model: dayStyle.dayModel
                    delegate: Rectangle {
                        width: PlasmaCore.Units.smallSpacing * 1.5
                        height: width
                        radius: width / 2
                        color: model.eventColor ? Kirigami.ColorUtils.linearInterpolation(model.eventColor, PlasmaCore.Theme.textColor, 0.2) : PlasmaCore.Theme.highlightColor
                    }

                    Component.onCompleted: rootIndex = modelIndex(index)
                }
            }
        }
    }*/

    contentItem: PlasmaExtras.Heading {
        id: label
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: model.label || dayNumber
        opacity: isCurrent ? 1.0 : 0.5
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        fontSizeMode: Text.Fit
        level: 5
        //font.pixelSize: 12
        //color: (model.eventCount !== undefined && model.eventCount > 0) ? Qt.darker(PlasmaCore.Theme.textColor, 0.5) : PlasmaCore.Theme.textColor
    }
}
