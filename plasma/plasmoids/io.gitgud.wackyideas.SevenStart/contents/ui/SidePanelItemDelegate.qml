pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window 2.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kwindowsystem 1.0
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

Item {
    id: sidePanelDelegate
    objectName: "SidePanelItemDelegate"
    property int iconSizeSide: Kirigami.Units.iconSizes.smallMedium
    property string itemText: ""
    property string itemIcon: ""
    property string itemIconFallback: "unknown"
    property string executableString: ""
    property bool executeProgram: false
    property alias textLabel: label
    //text: itemText
    property var menuModel: null

    //icon: itemIcon
    width: label.implicitWidth + Kirigami.Units.largeSpacing*2+1
    //Layout.preferredWidth: label.implicitWidth
    height: 33

    KeyNavigation.backtab: findPrevious();
    KeyNavigation.tab: findNext();

    function findItem() {
        for(var i = 0; i < parent.visibleChildren.length-1; i++) {
            if(sidePanelDelegate == parent.visibleChildren[i])
                return i;
        }
        return -1;
    }
    function findPrevious() {
        var i = findItem()-1;
        if(i < 0) {
            return root.m_searchField;
        }
        if(parent.visibleChildren[i].objectName == "SidePanelItemSeparator") {
            i--;
        }
        return parent.visibleChildren[i];
    }

    function findNext() {
        var i = findItem()+1;
        if(i >= parent.visibleChildren.length-1) {
            return root.m_shutDownButton;
        }
        if(parent.visibleChildren[i].objectName == "SidePanelItemSeparator") {
            i++;
        }
        return parent.visibleChildren[i];
    }
    Keys.onPressed: event => {
        if(event.key == Qt.Key_Return) {
            sidePanelMouseArea.clicked(null);
        } else if(event.key == Qt.Key_Up) {
            //console.log(findPrevious());
            findPrevious().focus = true;
        } else if(event.key == Qt.Key_Down) {
            //console.log(findNext());
            findNext().focus = true;
        } else if(event.key == Qt.Key_Left) {
            var obj;
            if(root.showingAllPrograms) obj = root.m_allApps;
            else {
                var pos = parent.mapToItem(root.m_mainPanel, sidePanelDelegate.x, sidePanelDelegate.y);
                obj = root.m_mainPanel.childAt(Kirigami.Units.smallSpacing*10, pos.y);
                if(!obj) {
                    pos = parent.mapToItem(root.m_bottomControls, sidePanelDelegate.x, sidePanelDelegate.y);
                    obj = root.m_bottomControls.childAt(Kirigami.Units.smallSpacing*10, pos.y);
                    if(!obj) {
                        obj = root.m_faves;
                    }
                }
            }

            obj.focus = true;
        }
    }
    //For some reason this is the only thing that prevents a width reduction bug, despite it being UB in QML
    /*anchors.left: parent.left;
    anchors.right: parent.right;*/

    KSvg.FrameSvgItem {
        id: itemFrame
        z: -1
        opacity: sidePanelMouseArea.containsMouse || parent.focus

        anchors.fill: parent
        anchors.rightMargin: 1
        imagePath: Qt.resolvedUrl("svgs/sidebaritem.svg")
        prefix: "menuitem"

    }
    PlasmaComponents.Label {
        id: label
        wrapMode: Text.NoWrap
        //elide: Text.ElideRight
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
        anchors.verticalCenter: sidePanelDelegate.verticalCenter
        anchors.verticalCenterOffset: -1
        style: Text.Sunken
        styleColor: "transparent"
        text: itemText
    }
    PlasmaComponents.Label {
        id: label_highlight
        wrapMode: Text.NoWrap
        //elide: Text.ElideRight
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
        anchors.verticalCenter: sidePanelDelegate.verticalCenter
        anchors.verticalCenterOffset: -1
        style: Text.Sunken
        styleColor: "transparent"
        opacity: 0.66
        text: itemText
    }
    KSvg.SvgItem {
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.smallSpacing*2
        anchors.verticalCenter: parent.verticalCenter

        implicitWidth: 6
        implicitHeight: 10

        imagePath: Qt.resolvedUrl("svgs/arrows.svgz")
        elementId: "group-expander-left"
        visible: sidePanelDelegate.menuModel !== null
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
                if(KWindowSystem.isPlatformX11)
                    Qt.callLater(Qt.openUrlExternally, executableString)
                else // Workaround for Wayland to prevent crashing
                    executable.exec("xdg-open " + executableString)

            }
        }
        hoverEnabled: true
        anchors.fill: parent
    }

    Timer {
        id: recentsMenuTimer
        interval: 500
        running: sidePanelMouseArea.containsMouse && sidePanelDelegate.menuModel !== null
        onTriggered: contextMenu.openRelative();
    }

    Connections {
        target: contextMenu
        enabled: sidePanelDelegate.menuModel !== null
        function onStatusChanged() {
            if(contextMenu.status === 3) {
                sidePanelDelegate.focus = false;
                root.m_delayTimer.restart();
            }
        }
    }
    PlasmaExtras.Menu {
        id: contextMenu
        visualParent: sidePanelDelegate
        placement: {
            switch (Plasmoid.location) {
                case PlasmaCore.Types.LeftEdge:
                case PlasmaCore.Types.RightEdge:
                case PlasmaCore.Types.TopEdge:
                    return PlasmaExtras.Menu.BottomPosedRightAlignedPopup;
                case PlasmaCore.Types.BottomEdge:
                default:
                    return PlasmaExtras.Menu.RightPosedBottomAlignedPopup;
            }
        }
    }
    Instantiator {
        model: sidePanelDelegate.menuModel
        delegate: PlasmaExtras.MenuItem {
            required property int index
            required property var model

            text: model.display + "      "
            icon: model.decoration
            onClicked: sidePanelDelegate.menuModel.trigger(index, "", null)
        }
        onObjectAdded: (index, object) =>   contextMenu.addMenuItem(object);
        onObjectRemoved: (index, object) => contextMenu.removeMenuItem(object)
    }

}
