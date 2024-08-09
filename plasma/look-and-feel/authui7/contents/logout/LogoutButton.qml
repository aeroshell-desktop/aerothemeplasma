/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.2
import QtQuick.Layouts 1.2

import org.kde.kirigami 2.20 as Kirigami

import org.kde.breeze.components
import "timer.js" as AutoTriggerTimer

ActionButton {
    Layout.alignment: Qt.AlignTop

    iconSize: Kirigami.Units.iconSizes.huge

    labelRendering: Text.QtRendering // Remove once we've solved Qt bug: https://bugreports.qt.io/browse/QTBUG-70138 (KDE bug: https://bugs.kde.org/show_bug.cgi?id=401644)
    font.underline: false
    font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1

    circleVisiblity: activeFocus || containsMouse
    circleOpacity: 0.15 // Selected option's circle is instantly visible
    opacity: activeFocus || containsMouse ? 1 : 0.5
    Behavior on opacity {
        PropertyAnimation { // OpacityAnimator makes it turn black at random intervals
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Keys.onPressed: {
        AutoTriggerTimer.cancelAutoTrigger();
    }
}
