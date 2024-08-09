/*
 *    Copyright 2014 Sebastian Kügler <sebas@kde.org>
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License along
 *    with this program; if not, write to the Free Software Foundation, Inc.,
 *    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.ksvg as KSvg

import org.kde.kirigami as Kirigami

Item {

    id: highlight
 
     /** true if the user is hovering over the component */
     //in the case we are the highlight of a listview, it follows the mouse, so hover = true
     property bool hover: ListView ? true : false
 
     /** true if the mouse button is pressed over the component. */
     property bool pressed: false
     width: ListView.view ? ListView.view.width : undefined
     property alias marginHints: background.margins;
 
     Connections {
         target: highlight.ListView.view
         function onCurrentIndexChanged() {
             if (highlight.ListView.view.currentIndex >= 0) {
                 background.opacity = 1
             } else {
                 background.opacity = 0
             }
         }
     }
 
     Behavior on opacity {
         NumberAnimation {
             duration: Kirigami.Units.veryShortDuration
             easing.type: Easing.OutQuad
         }
     }

    KSvg.FrameSvgItem {
         id: background
         imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
         prefix: {
             if (pressed)
                 return hover ? "selected+hover" : "selected";
 
             if (hover)
                 return "hover";
 
             return "normal";
         }
 
         Behavior on opacity {
             NumberAnimation {
                 duration: Kirigami.Units.veryShortDuration
                 easing.type: Easing.OutQuad
             }
         }
 
         anchors {
             fill: parent
        leftMargin: Kirigami.Units.smallSpacing
        rightMargin: Kirigami.Units.smallSpacing
         //FIXME: breaks listviews and highlight item
         //    topMargin: -background.margins.top
         //    leftMargin: -background.margins.left
         //    bottomMargin: -background.margins.bottom
         //    rightMargin: -background.margins.right
         }
     }
 }
