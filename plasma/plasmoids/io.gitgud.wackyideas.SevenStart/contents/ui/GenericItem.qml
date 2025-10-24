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
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import QtQuick.Window 2.2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Controls 2.15

import "code/tools.js" as Tools

Item {
  id: allItem

  width: scrollView.availableWidth - Kirigami.Units.mediumSpacing
  height: Kirigami.Units.iconSizes.smallMedium

  property var itemSection: model.group
  property bool highlighted: false
  property bool isDraging: false
  property bool canDrag: true
  property bool canNavigate: false
  property bool isCurrentlySelected: listView.currentIndex === index
  signal highlightChanged
  signal aboutToShowActionMenu(variant actionMenu)

  property bool hasActionList: ((model.favoriteId !== null)
      || (("hasActionList" in model) && (model.hasActionList !== null)))

  property var triggerModel

  onIsCurrentlySelectedChanged: {
    if(isCurrentlySelected && toolTip.location) {
      toolTipTimer.start();
    } else {
      toolTipTimer.stop();
      toolTip.hideImmediately();
    }
  }

  onAboutToShowActionMenu: actionMenu => {
    var actionList = allItem.hasActionList ? model.actionList : [];
    if(model.favoriteId) { // If we have a launchable application, try allowing the user to pin it
      // Find seventasks instance, if available
      const entry = model.favoriteId; //kicker.convertUrl(model.url);
      console.log(entry);
      var panel = kicker.parent;
      while(panel !== null && typeof panel.sevenTasksReference === "undefined") { // Find seventasks loader reference from the panel
        panel = panel.parent;
      }
      if(panel.sevenTasksReference) { // If found, add the pin/unpin menu item
        const unpin = (panel.sevenTasksReference.applet.findTask(entry) !== -1);
        var pinAction = {   // Add custom action
          icon: "pin",
          actionId: "pinToTasks",
          text: unpin ? i18n("Unpin from taskbar") : i18n("Pin to taskbar"),
          action: () => {
            if(unpin) {
              panel.sevenTasksReference.applet.unpinTask(entry);
            } else {
              panel.sevenTasksReference.applet.pinTask(entry);
            }
          }};
          actionList = [...actionList, pinAction]; // Use spread operator and pass that to the fillActionMenu function
      }
    }

    Tools.fillActionMenu(i18n, actionMenu, actionList, ListView.view.model.favoritesModel, model.favoriteId);
  }

  function openActionMenu(x, y) {
    aboutToShowActionMenu(actionMenu);
    if(actionMenu.actionList.length === 0) return;
    actionMenu.visualParent = allItem;
    actionMenu.open(x, y);
  }
  function actionTriggered(actionId, actionArgument) {
      var close = (Tools.triggerAction(triggerModel, index, actionId, actionArgument) === true);
      if (close) {
          //root.toggle();
        kicker.expanded = false;
      }
  }
  function trigger() {
    triggerModel.trigger(index, "", null);
    kicker.expanded = false;
    root.visible = false;
  }
  function updateHighlight() {
    if (navGrid.currentIndex == index){
      highlighted = true
    } else {
      highlighted = false
    }
  }
  function deselect(){
    highlighted = false
    listView.currentIndex = -1
  }
  Kirigami.Icon {
    id: appicon
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: Kirigami.Units.smallSpacing*2 + Kirigami.Units.iconSizes.small
    width: Kirigami.Units.iconSizes.small
    height: width
    source: model.decoration
  }
  PlasmaComponents.Label {
    id: appname
    anchors.left: appicon.right
    anchors.right: parent.right
    anchors.rightMargin: Kirigami.Units.smallSpacing
    anchors.leftMargin: Kirigami.Units.smallSpacing
    anchors.verticalCenter: appicon.verticalCenter
    text: ("name" in model ? model.name : model.display)
    font.underline: ma.containsMouse
    elide: Text.ElideRight
  }
  
  KickoffHighlight {
    id: rectFill
    anchors.fill: parent
    anchors.leftMargin: Kirigami.Units.iconSizes.small
    opacity: (listView.currentIndex === index) * 0.7 + ma.containsMouse * 0.3
    z: -1
  }

  Timer {
    id: toolTipTimer
    interval: Kirigami.Units.longDuration*4
    onTriggered: {
      toolTip.showToolTip();
    }
  }
  PlasmaCore.ToolTipArea {
    id: toolTip

    anchors {
      fill: parent
    }

    active: appname.truncated
    interactive: false
    location: {
      var result = PlasmaCore.Types.Floating;
      if(ma.containsMouse) result |= PlasmaCore.Types.Desktop;
      return result;
    }

    mainText: appname.text
  }
  MouseArea {
      id: ma
      anchors.fill: parent
      anchors.leftMargin: Kirigami.Units.iconSizes.small
      z: parent.z + 1
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true
      onClicked: mouse => {
          if (mouse.button == Qt.RightButton) {
            if (allItem.hasActionList) {
              var mapped = mapToItem(allItem, mouse.x, mouse.y);
              allItem.openActionMenu(mapped.x, mapped.y);
            }
          } else {
            trigger()
          }
        
      }
      onReleased: {
        isDraging: false
      }
      // to prevent crashing
      onEntered: {
        if(parent.parent) {
          listView.currentIndex = index;

        }
        toolTipTimer.start();
      }
      onExited: {
        if(parent.parent)  {
          listView.currentIndex = -1;
          toolTipTimer.stop();
          toolTip.hideToolTip();
        }

      }
      onPositionChanged: {
        isDraging = pressed
        if (pressed && canDrag){
          if ("pluginName" in model) {
            dragHelper.startDrag(kicker, model.url, model.decoration,
                "text/x-plasmoidservicename", model.pluginName);
          } else {
            dragHelper.startDrag(kicker, model.url, model.icon);
          }
        }
        listView.currentIndex = containsMouse ? index : -1
      }
  }
  ActionMenu {
      id: actionMenu

      onActionClicked: (actionId, actionArgument) => {
          visualParent.actionTriggered(actionId, actionArgument);
          //root.toggle()
      }
  }
}
