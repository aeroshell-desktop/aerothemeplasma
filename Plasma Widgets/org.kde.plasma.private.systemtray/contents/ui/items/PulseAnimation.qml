/*
 *   Copyright 2013 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore

SequentialAnimation {
    id: pulseAnimation
    objectName: "pulseAnimation"

    property Item targetItem
    readonly property int duration: PlasmaCore.Units.veryLongDuration * 5

    loops: Animation.Infinite
    alwaysRunToEnd: true

    ScaleAnimator {
        target: targetItem
        from: 1
        to: 1.2
        duration: pulseAnimation.duration * 0.15
        easing.type: Easing.InQuad
    }

    ScaleAnimator {
        target: targetItem
        from: 1.2
        to: 1
        duration: pulseAnimation.duration * 0.15
        easing.type: Easing.InQuad
    }

    PauseAnimation {
        duration: pulseAnimation.duration * 0.7
    }
}
