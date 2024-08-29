import QtQuick 2.4
import QtQuick.Controls
import QtQuick.Layouts 1.1
import QtQuick.Dialogs
import QtQuick.Window 2.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

Item {
    id: sidePanelDelegate
    objectName: "SidePanelItemSeparator"
    //icon: itemIcon

    function findItem() {
        for(var i = 0; i < parent.visibleChildren.length; i++) {
            if(sidePanelDelegate == parent.visibleChildren[i])
                return i;
        }
        return -1;
    }
    function updateVisibility() {
        if(!visible) visible = true;
        var i = findItem();
        var pred = i-1;
        var succ = i+1;
        if(pred <= 0 || succ >= parent.visibleChildren.length) {
            sidePanelDelegate.visible = false;
            return;
        }
        if(parent.visibleChildren[pred].objectName !== "SidePanelItemDelegate" || parent.visibleChildren[succ].objectName !== "SidePanelItemDelegate") {
            sidePanelDelegate.visible = false;
            return;
        }
        sidePanelDelegate.visible = true;
    }
    //For some reason this is the only thing that prevents a width reduction bug, despite it being UB in QML
    /*anchors.left: parent.left;
    anchors.right: parent.right;*/
    height: 2;

    KSvg.SvgItem {
        id: itemFrame
        anchors.fill: parent
        svg: separatorSvg
        elementId: "separator-line"
    }
}
