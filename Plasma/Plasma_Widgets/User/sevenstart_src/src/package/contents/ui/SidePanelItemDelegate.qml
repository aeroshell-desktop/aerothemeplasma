import QtQuick 2.4
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ListDelegate {
    id: sidePanelDelegate
    objectName: "SidePanelItemDelegate"
    property int iconSizeSide: units.iconSizes.smallMedium
    property string itemText: ""
    property string itemIcon: ""
    property string executableString: ""
    property bool executeProgram: false
    text: itemText
    //icon: itemIcon
    size: iconSizeSide + units.smallSpacing / 1.5 + 1

    KeyNavigation.backtab: findPrevious();
    KeyNavigation.tab: findNext();

    function findPrevious() {
        var i = Array.prototype.indexOf.call(parent.visibleChildren, sidePanelDelegate)-1;
        if(i < 0) {
            return root.m_searchField;
        }
        return parent.visibleChildren[i];
    }

    function findNext() {
        var i = Array.prototype.indexOf.call(parent.visibleChildren, sidePanelDelegate)+1;
        if(i >= parent.visibleChildren.length) {
            return root.m_shutDownButton;
        }
        return parent.visibleChildren[i];
    }
    Keys.onPressed: {
        if(event.key == Qt.Key_Return) {
            sidePanelMouseArea.clicked(null);
        } else if(event.key == Qt.Key_Up) {
            findPrevious().focus = true;
        } else if(event.key == Qt.Key_Down) {
            findNext().focus = true;
        } else if(event.key == Qt.Key_Left) {
            var pos = parent.mapToItem(mainFocusScope, sidePanelDelegate.x, sidePanelDelegate.y);
            var obj = mainFocusScope.childAt(units.smallSpacing*10, pos.y);
            if(obj.objectName == "") {
                obj = root.m_recents;
            }
            obj.focus = true;
        }
    }
    //For some reason this is the only thing that prevents a width reduction bug, despite it being UB in QML
    anchors.left: parent.left;
    anchors.right: parent.right;

    PlasmaCore.FrameSvgItem {
        id: itemFrame
        z: -1
        opacity: sidePanelMouseArea.containsMouse || parent.focus

        anchors.fill: parent
        imagePath: Qt.resolvedUrl("svgs/sidebaritem.svg")
        prefix: "menuitem"

    }
    onFocusChanged: {
        /*if(focus) {
            root.m_sidebarIcon.source = itemIcon;
        } else {
            root.m_sidebarIcon.source = "";
        }*/
        if(root.m_delayTimer.running) root.m_delayTimer.restart();
        else root.m_delayTimer.start();
    }
    MouseArea {
        id: sidePanelMouseArea
        enabled: !root.hoverDisabled
        acceptedButtons: Qt.LeftButton
        onEntered: {
            sidePanelDelegate.focus = true;
        }
        onExited: {
            sidePanelDelegate.focus = false;
        }
        onClicked: {
            root.visible = false;
            if(executeProgram)
                executable.exec(executableString);
            else {
                Qt.openUrlExternally(executableString);
            }
        }
        hoverEnabled: true
        anchors.fill: parent
    }
}
