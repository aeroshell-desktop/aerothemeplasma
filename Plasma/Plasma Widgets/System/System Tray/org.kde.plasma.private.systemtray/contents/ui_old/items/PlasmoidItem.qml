/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.1
import QtQml 2.15

import org.kde.plasma.core 2.0 as PlasmaCore

AbstractItem {
    id: plasmoidContainer

    property Item applet: model.applet || null
    text: applet ? applet.title : ""

    itemId: applet ? applet.pluginName : ""
    mainText: applet ? applet.toolTipMainText : ""
    subText: applet ? applet.toolTipSubText : ""
    mainItem: applet && applet.toolTipItem ? applet.toolTipItem : null
    textFormat: applet ? applet.toolTipTextFormat : ""
    active: systemTrayState.activeApplet !== applet

    onClicked: {
        if (!applet) {
            return
        }
        //forward click event to the applet
        if (mouse.button === Qt.LeftButton || mouse.button === Qt.MidButton) {
            const mouseArea = findMouseArea(applet.compactRepresentationItem)
            if (mouseArea) {
                mouseArea.clicked(mouse)
            } else if (mouse.button === Qt.LeftButton) {//falback
                applet.expanded = true
            }
        }
    }
    onPressed: {
        if (mouse.button === Qt.RightButton) {
            plasmoidContainer.contextMenu(mouse);
        }
    }
    onContextMenu: {
        if (applet) {
            plasmoid.nativeInterface.showPlasmoidMenu(applet, 0, plasmoidContainer.inHiddenLayout ? applet.height : 0);
        }
    }
    onWheel: {
        if (!applet) {
            return
        }
        //forward wheel event to the applet
        const mouseArea = findMouseArea(applet.compactRepresentationItem)
        if (mouseArea) {
            mouseArea.wheel(wheel)
        }
    }

    //some heuristics to find MouseArea
    function findMouseArea(item) {
        if (!item) {
            return null
        }

        if (item instanceof MouseArea) {
            return item
        }
        for (var i = 0; i < item.children.length; i++) {
            const child = item.children[i]
            if (child instanceof MouseArea && child.enabled) {
                //check if MouseArea covers the entire item
                if (child.anchors.fill === item || (child.x === 0 && child.y === 0 && child.height === item.height && child.width === item.width)) {
                    return child
                }
            }
        }

        return null
    }

    //This is to make preloading effective, minimizes the scene changes
    function preloadFullRepresentationItem(fullRepresentationItem) {
        if (fullRepresentationItem && fullRepresentationItem.parent === null) {
            fullRepresentationItem.width = expandedRepresentation.width
            fullRepresentationItem.width = expandedRepresentation.height
            fullRepresentationItem.parent = preloadedStorage;
        }
    }

    onAppletChanged: {
        if (applet) {
            applet.parent = plasmoidContainer.iconContainer
            applet.anchors.fill = applet.parent
            applet.visible = true

            preloadFullRepresentationItem(applet.fullRepresentationItem)
        }
    }

    Connections {
        target: applet

        //activation using global keyboard shortcut
        function onActivated() {
            plasmoidContainer.activated()
        }

        function onExpandedChanged(expanded) {
            if (expanded) {
                systemTrayState.setActiveApplet(applet, model.row)
                plasmoidContainer.activated()
            }
        }

        function onFullRepresentationItemChanged(fullRepresentationItem) {
            preloadFullRepresentationItem(fullRepresentationItem)
        }
    }

    Binding {
        property: "hideOnWindowDeactivate"
        value: !plasmoid.configuration.pin
        target: plasmoidContainer.applet
        when: null !== plasmoidContainer.applet
        restoreMode: Binding.RestoreBinding
    }
}
