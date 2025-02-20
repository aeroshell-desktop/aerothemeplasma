/*****************************************************************************
 *   Copyright (C) 2022 by Friedrich Schriewer <friedrich.schriewer@gmx.net> *
 *                                                                           *
 *   This program is free software; you can redistribute it and/or modify    *
 *   it under the terms of the GNU General Public License as published by    *
 *   the Free Software Foundation; either version 2 of the License, or       *
 *   (at your option) any later version.                                     *
 *                                                                           *
 *   This program is distributed in the hope that it will be useful,         *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 *   GNU General Public License for more details.                            *
 *                                                                           *
 *   You should have received a copy of the GNU General Public License       *
 *   along with this program; if not, write to the                           *
 *   Free Software Foundation, Inc.,                                         *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .          *
 ****************************************************************************/
import QtQuick 2.12

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import QtQuick.Controls 2.15

import org.kde.draganddrop 2.0

FocusScope {
  id: navGrid

  signal keyNavUp
  signal keyNavDown

  property alias triggerModel: listView.model
  property alias count: listView.count
  property alias currentIndex: listView.currentIndex
  property alias currentItem: listView.currentItem
  property alias contentItem: listView.contentItem
  property Item flickableItem: listView
  property int inhibitMouseEvents: 0

  /*onFocusChanged: {
      if (!focus) {
          currentIndex = -1;
      }
  }*/
  function tryActivate() {

    if(currentIndex === -1 && listView.count > 0) {
      listView.itemAtIndex(0).trigger();
      return;
    }
    if (currentItem){
      currentItem.trigger()
    }
  }
  function setFocus() {
    currentIndex = 0
    focus = true
  }
  function setFocusLast() {
    if (count > 0) {
      currentIndex = count - 1
      focus = true
    } else {
      setFocus()
    }
  }


  Text {
    id: noResults
    opacity: 0.6
    text: "No items match your search."
    anchors.fill: parent
    anchors.topMargin: 13
    horizontalAlignment: Text.AlignHCenter
    visible: listView.count === 0 && searching
  }
  ScrollView {
    id: scrollView
    anchors.fill: parent
    anchors.rightMargin: 4
  ListView {
    anchors.fill: parent
    id: listView
    currentIndex: -1
    focus: true

    property alias scrollBar: scrollView
    highlightMoveDuration: 0
    highlightResizeDuration: 0
    snapMode: ListView.SnapToItem
    interactive: false
    boundsBehavior: Flickable.StopAtBounds

    section {
      criteria: ViewSection.FullString
      property: "group"

      delegate: SectionDelegate {
        sectionCount: {
          var x = 0;
          if(!listView) return 0;
          for(var i = 0; i < listView.count; i++) {
            if(listView.itemAtIndex(i)) {
              if(listView.itemAtIndex(i).itemSection === section) x++;
            }
          }
          return x;
        }
      }
    }
    delegate: GenericItem {
      canNavigate: true
      canDrag: true
      triggerModel: listView.model
    }
  
    onCurrentIndexChanged: {
      if (currentIndex != -1) {
        focus = true;
      }
    }
    onModelChanged: {
      currentIndex = -1;
    }
    /*onFocusChanged: {
      if (!focus) {
        currentIndex = -1
      }
    }*/
  }
  }
}
