/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQml 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3

AbstractItem {
    id: plasmoidContainer

    property Item applet: model.applet || null
    text: applet ? applet.plasmoid.title : ""

    itemId: applet ? applet.plasmoid.pluginName : ""
    mainText: applet ? applet.toolTipMainText : ""
    subText: applet ? applet.toolTipSubText : ""
    mainItem: applet && applet.toolTipItem ? applet.toolTipItem : null
    textFormat: applet ? applet.toolTipTextFormat : 0 /* Text.AutoText, the default value */
    active: systemTrayState.activeApplet !== applet

    // Fixes issue with KDE Connect not being able to get dragged and dropped
    onHeldChanged: {
        if(applet) {
            var appletItem = applet.compactRepresentationItem ?? applet.fullRepresentationItem;
            if(appletItem) {
                if(typeof appletItem.containsDrag !== "undefined") {
                    appletItem.enabled = !held;
                }
            }
        }
    }
    // FIXME: Use an input type agnostic way to activate whatever the primary
    // action of a plasmoid is supposed to be, even if it's just expanding the
    // Plasmoid. Not all plasmoids are supposed to expand and not all plasmoids
    // do anything with onActivated.
    onActivated: {
        if (applet) {
            applet.plasmoid.activated()
        }
    }

    onClicked: mouse => {
        if (!applet) {
            return
        }
        //forward click event to the applet
        var appletItem = applet.compactRepresentationItem ?? applet.fullRepresentationItem
        const mouseArea = findMouseArea(appletItem)

        if (mouseArea && mouse.button !== Qt.RightButton) {
            var temp = applet.expanded;
            mouseArea.clicked(mouse);

            if(mouse.button === Qt.LeftButton && inVisibleLayout && applet.expanded && temp) {
                applet.expanded = false;
            }
        } else if (mouse.button === Qt.LeftButton) {//fallback
            activated(null)
        }
    }
    onPressed: mouse => {
        // Only Plasmoids can show context menu on the mouse pressed event.
        // SNI has few problems, for example legacy applications that still use XEmbed require mouse to be released.
        if (mouse.button === Qt.RightButton) {
            contextMenu(mouse);
        } /*else {
            const appletItem = applet.compactRepresentationItem ?? applet.fullRepresentationItem
            const mouseArea = findMouseArea(appletItem)

        }*/
    }
    onContextMenu: if (applet) {
        effectivePressed = false;
        Plasmoid.showPlasmoidMenu(applet, 0, inHiddenLayout ? applet.height : 0);
    }
    onWheel: (wheel) => {
        if (!applet) {
            return
        }
        //forward wheel event to the applet
        var appletItem = applet.compactRepresentationItem ?? applet.fullRepresentationItem
        const mouseArea = findMouseArea(appletItem)
        if (mouseArea) {
            mouseArea.wheel(wheel)
        }
    }

    //some heuristics to find MouseArea
    function findMouseArea(item: Item): MouseArea {
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
            fullRepresentationItem.height = expandedRepresentation.height
            fullRepresentationItem.parent = preloadedStorage;
        }
    }

    onAppletChanged: {
        if (applet) {
            applet.parent = iconContainer
            applet.anchors.fill = applet.parent
            applet.visible = true

            preloadFullRepresentationItem(applet.fullRepresentationItem)
        }
    }

    Connections {
        enabled: plasmoidContainer.applet !== null
        target: findMouseArea(
            plasmoidContainer.applet?.compactRepresentationItem ??
            plasmoidContainer.applet?.fullRepresentationItem ??
            plasmoidContainer.applet
        )

        function onContainsPressChanged() {
            plasmoidContainer.effectivePressed = target.containsPress;
        }

        // TODO For touch/stylus only, since the feature is not desired for mouse users
        function onPressAndHold(mouse) {
            if (mouse.button === Qt.LeftButton) {
                plasmoidContainer.contextMenu(mouse)
            }
        }
    }

    Connections {
        target: plasmoidContainer.applet?.plasmoid ?? null

        //activation using global keyboard shortcut
        function onActivated() {
            plasmoidContainer.effectivePressed = true;
            Qt.callLater(() => {
                plasmoidContainer.effectivePressed = false;
            });
        }
    }

    Connections {
        target: plasmoidContainer.applet

        function onFullRepresentationItemChanged(fullRepresentationItem) {
            preloadFullRepresentationItem(fullRepresentationItem)
        }

        function onExpandedChanged(expanded) {
            if (expanded) {
                systemTrayState.setActiveApplet(plasmoidContainer.applet, model.row)
                effectivePressed = false;
            }
        }
    }

    /*PlasmaComponents3.BusyIndicator {
        anchors.fill: parent
        z: 999
        running: plasmoidContainer.applet?.plasmoid.busy ?? false
    }*/

    Binding {
        property: "hideOnWindowDeactivate"
        value: !Plasmoid.configuration.pin
        target: plasmoidContainer.applet
        when: plasmoidContainer.applet !== null
        restoreMode: Binding.RestoreBinding
    }
}
