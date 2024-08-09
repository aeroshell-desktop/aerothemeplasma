/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012 Marco Martin <mart@kde.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQuick.Controls 2.15

import org.kde.kirigami as Kirigami

Item {
    id: sectionDelegate
    width: parent.width
    height: Kirigami.Units.iconSizes.medium-1 //childrenRect.height
    objectName: "SectionDelegate"
    function getName() {
        return sectionHeading.text;
    }
    property int sectionCount: 0
    PlasmaExtras.Heading {
        id: sectionHeading
        anchors {
            left: parent.left
            leftMargin: Kirigami.Units.smallSpacing*2
            verticalCenter: parent.verticalCenter
            //verticalCenterOffset: Kirigami.Units.smallSpacing/2
        }
        color: "#1d3287"
        //y: Math.round(Kirigami.Units.gridUnit / 4)
        level: 3
        text: section + (sectionCount > 0 ? " (" + sectionCount + ")" : "")
    }

    Rectangle {
        id: line
        anchors.left: sectionHeading.right
        anchors.leftMargin: Kirigami.Units.largeSpacing-1
        anchors.rightMargin: Kirigami.Units.largeSpacing+1 + (scrollView.ScrollBar.vertical.visible ? scrollView.ScrollBar.vertical.width : 0)
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 1
        height: 1
        color: "#e5e5e5"
    }
} // sectionDelegate
