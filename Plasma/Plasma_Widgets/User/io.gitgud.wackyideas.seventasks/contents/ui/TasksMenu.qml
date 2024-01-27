/*
    SPDX-FileCopyrightText: 2012-2016 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.taskmanager 0.1 as TaskManager

import "code/layout.js" as LayoutManager
import org.kde.plasma.extras 2.0 as PlasmaExtras

/*
 * This is the custom context menu control for SevenTasks.
 * It is designed to look and feel like the context menu from Windows Vista and onwards,
 * while making sure that it behaves just like a normal context menu under KDE. This means:
 *
 * 1. The context menu grabs *all* mouse and key inputs.
 * 2. The context menu must disappear if an event outside of it causes it to 'lose focus'.
 * 3. The context menu must disappear if a menu item has been activated either with the mouse or the keyboard.
 * 4. The context menu must disappear if the user clicks away from it or the Escape key is pressed on the keyboard.
 *
 * As PlasmaCore.Dialog inherits QWindow, we can use QWindow::setMouseGrabEnabled(bool) and QWindow::setKeyboardGrabEnabled(bool)
 * to steal all mouse and keyboard events from the system and direct it towards the context menu. This is done through C++, more
 * info in the C++ source files.
 *
 */

PlasmaCore.Dialog {
    id: tasksMenu

    // Properties passed by the task when the context menu is created dynamically.
    // Context menu specific stuff.
    property QtObject backend
    property QtObject mpris2Source
    property var modelIndex
    readonly property var atm: TaskManager.AbstractTasksModel
    property var menuDecoration: "exec"
    property QtObject currentItem: null
    property int currentItemIndex: -1

    readonly property int menuItemHeight: PlasmaCore.Units.smallSpacing*5
    readonly property int menuWidth: 263

    property bool showAllPlaces: false
    property bool alsoCloseTask: false
    property bool secondaryColumn: false

    property color backgroundColorStatic: "#f1f6fb"
    property color backgroundColorGradient: "white"
    property color borderColor: "#ccd9ea"


    // Functions inherited from the original ContextMenu
    function get(modelProp) {
        return tasksModel.data(modelIndex, modelProp)
    }
    function showContextMenuWithAllPlaces() {
        visualParent.showContextMenu({showAllPlaces: true});
    }

    function newPlasmaMenuItem(parent) {
        return Qt.createQmlObject(`
            import org.kde.plasma.components 2.0 as PlasmaComponents

            PlasmaComponents.MenuItem {}
        `, parent);
    }

    function newPlasmaSeparator(parent) {
        return Qt.createQmlObject(`
            import org.kde.plasma.components 2.0 as PlasmaComponents

            PlasmaComponents.MenuItem { separator: true }
            `, parent);
    }
    function newMenuItem(parent) {
        return Qt.createQmlObject(`
            TasksMenuItemWrapper {}
        `, parent);
    }

    function newSeparator(parent) {
        return Qt.createQmlObject(`
            TasksMenuItemSeparator {}
            `, parent);
    }
    function addItemToMenu(obj) {
        obj.Layout.fillWidth = true;
        obj.Layout.preferredHeight = menuItemHeight;
        menuitems.height += obj.Layout.preferredHeight + menuitems.spacing;
    }
    function clearIndices() {
        if(currentItem !== null) {
            currentItem.selected = false;
            currentItem = null;
        }
        currentItemIndex = -1;
    }
    function setCurrentItem(obj) {
        clearIndices();
        var i = Array.prototype.indexOf.call(menuitems.children, obj);
        if(i === -1) {
            i = menuitems.children.length + Array.prototype.indexOf.call(staticMenuItems.children, obj);
        }
        currentItemIndex = i;
        currentItem = obj;
        currentItem.selected = true;
    }

    // Tasksmenu specific stuff
    property alias tMenu: tasksMenu
    property int xpos: -1 // Variable is used to keep track of the original x position which sometimes gets changed for no reason.
    visible: false
    opacity: 0
    objectName: "tasksMenuDialog"
    hideOnWindowDeactivate: true // Makes it so that the context menu disappears if it gets forcibly out of focus by an external event.
    flags: Qt.WindowStaysOnTopHint | Qt.Dialog

    // Used to animate the context menu appearing and disappearing.
    Behavior on opacity {
        NumberAnimation { duration: 125; }
    }
    Behavior on y {
        NumberAnimation {duration: 125; }
    }

    // Tries to detect when the x position resets to 0.
    onXChanged: {
        if(tasksMenu.x !== xpos) {
            tasksMenu.x = xpos;
        }
    }
    // If the context menu is no longer visible (most often when it loses focus), close the menu.
    onVisibleChanged: {
        if(visible) {
            var diff = parent.mapToGlobal(tasksMenu.x, tasksMenu.y).x - tasksMenu.x;
            xpos = visualParent.x + diff + visualParent.width/2 - PlasmaCore.Units.smallSpacing;
            xpos -= menuWidth / 2;

            if(xpos < 0) xpos = 0;
            tasksMenu.x = xpos;
            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
        }
        else if(!visible) {
            tasksMenu.closeMenu();
        }
    }
    onActiveChanged: {
        if(!active) tasksMenu.close();
    }
    // Set to Floating so that the borders are visible all the time, even when it is right next to another object.
    location: {
        return PlasmaCore.Types.Floating;
    }
    // Used publicly by other objects to show the dynamically created context menu.
    function show() {
        loadDynamicLauncherActions(get(atm.LauncherUrlWithoutIcon));
        visible = true;
        opacity = 1;
        tasksMenu.y -= PlasmaCore.Units.smallSpacing*2;
        openTimer.start();
    }
    // Closes the menu gracefully, by first showing a fade out animation before freeing the object from memory.
    function closeMenu() {
        plasmoid.nativeInterface.disableBlurBehind(tasksMenu);
        tasksMenu.y += PlasmaCore.Units.smallSpacing*2;
        opacity = 0;
        closeTimer.start();
    }

    function loadDynamicLauncherActions(launcherUrl) {
        var sections = [
            {
                title:   i18n("Frequent"),
                group:   "places",
                actions: backend.placesActions(launcherUrl, showAllPlaces, tasksMenu)
            },
            {
                title:   i18n("Recent"),
                group:   "recents",
                actions: backend.recentDocumentActions(launcherUrl, tasksMenu)
            },
            {
                title:   i18n("Tasks"),
                group:   "actions",
                actions: backend.jumpListActions(launcherUrl, tasksMenu)
            }
        ]

        // C++ can override section heading by returning a QString as first action
        sections.forEach((section) => {
            if (typeof section.actions[0] === "string") {
                section.title = section.actions.shift(); // take first
            }
        });

        // QMenu does not limit its width automatically. Even if we set a maximumWidth
        // it would just cut off text rather than eliding. So we do this manually.
        var textMetrics = Qt.createQmlObject("import QtQuick 2.4; TextMetrics {}", menuitems);
        var maximumWidth = LayoutManager.maximumContextMenuTextWidth() + PlasmaCore.Units.smallSpacing*2;

        for(var i = 0; i < sections.length; i++) {
            var section = sections[i];
            if(section["actions"].length == 0) continue;

            // Make a separator header
            var sepHeader = tasksMenu.newSeparator(menuitems);
            sepHeader.menuText = section["title"];
            addItemToMenu(sepHeader);

            for(var j = 0; j < section["actions"].length; j++) {
                if(section["group"] == "recents" && j == section["actions"].length-2) continue;
                var mAction = section["actions"][j];
                var mItem = tasksMenu.newMenuItem(menuitems);
                // Crude way of manually eliding...
                var elided = false;
                textMetrics.text = Qt.binding(function() {
                    return mAction.text;
                });

                while (textMetrics.width > maximumWidth) {
                    mAction.text = mAction.text.slice(0, -1);
                    elided = true;
                }

                if (elided) {
                    mAction.text += "…";
                }
                mItem.text = mAction.text;
                mItem.icon = mAction.icon;
                mItem.clicked.connect(mAction.trigger);
                addItemToMenu(mItem);
                secondaryColumn = true;
            }

        }

        // Add Media Player control actions
        var sourceName = mpris2Source.sourceNameForLauncherUrl(launcherUrl, get(atm.AppPid));

        if (sourceName && !(get(atm.WinIdList) !== undefined && get(atm.WinIdList).length > 1)) {
            var playerData = mpris2Source.data[sourceName]
            var sepHeader = tasksMenu.newSeparator(menuitems);
            sepHeader.menuText = "Media controls";
            addItemToMenu(sepHeader);
            secondaryColumn = true;
            if (playerData.CanControl) {
                var playing = (playerData.PlaybackStatus === "Playing");
                var menuItem = tasksMenu.newMenuItem(menuitems);
                menuItem.text = i18nc("Play previous track", "Previous Track");
                menuItem.icon = "media-skip-backward";
                menuItem.enabled = Qt.binding(function() {
                    return playerData.CanGoPrevious;
                });
                menuItem.clicked.connect(function() {
                    mpris2Source.goPrevious(sourceName);
                    tasksMenu.closeMenu();
                });
                tasksMenu.addItemToMenu(menuItem);

                menuItem = tasksMenu.newMenuItem(menuitems);
                // PlasmaCore Menu doesn't actually handle icons or labels changing at runtime...
                menuItem.text = Qt.binding(function() {
                    // if CanPause, toggle the menu entry between Play & Pause, otherwise always use Play
                    return playing && playerData.CanPause ? i18nc("Pause playback", "Pause") : i18nc("Start playback", "Play");
                });
                menuItem.icon = Qt.binding(function() {
                    return playing && playerData.CanPause ? "media-playback-pause" : "media-playback-start";
                });
                menuItem.enabled = Qt.binding(function() {
                    return playing ? playerData.CanPause : playerData.CanPlay;
                });
                menuItem.clicked.connect(function() {
                    if (playing) {
                        mpris2Source.pause(sourceName);
                    } else {
                        mpris2Source.play(sourceName);
                    }
                    tasksMenu.closeMenu();
                });
                tasksMenu.addItemToMenu(menuItem);

                menuItem = tasksMenu.newMenuItem(menuitems);
                menuItem.text = i18nc("Play next track", "Next Track");
                menuItem.icon = "media-skip-forward";
                menuItem.enabled = Qt.binding(function() {
                    return playerData.CanGoNext;
                });
                menuItem.clicked.connect(function() {
                    mpris2Source.goNext(sourceName);
                    tasksMenu.closeMenu();
                });
                tasksMenu.addItemToMenu(menuItem);

                menuItem = tasksMenu.newMenuItem(menuitems);
                menuItem.text = i18nc("Stop playback", "Stop");
                menuItem.icon = "media-playback-stop";
                menuItem.enabled = Qt.binding(function() {
                    return playerData.PlaybackStatus !== "Stopped";
                });
                menuItem.clicked.connect(function() {
                    mpris2Source.stop(sourceName);
                    tasksMenu.closeMenu();
                });
                tasksMenu.addItemToMenu(menuItem);

                // If we don't have a window associated with the player but we can quit
                // it through MPRIS we'll offer a "Quit" option instead of "Close"
                if (!closeWindowItem.visible && playerData.CanQuit) {
                    menuItem = tasksMenu.newMenuItem(menuitems);
                    menuItem.text = i18nc("Quit media player app", "Quit");
                    menuItem.icon = "application-exit";
                    menuItem.visible = Qt.binding(function() {
                        return !closeWindowItem.visible;
                    });
                    menuItem.clicked.connect(function() {
                        mpris2Source.quit(sourceName);
                        tasksMenu.closeMenu();
                    });
                    tasksMenu.addItemToMenu(menuItem);
                }

                // If we don't have a window associated with the player but we can raise
                // it through MPRIS we'll offer a "Restore" option
                if (get(atm.IsLauncher) === true && !startNewInstanceItem.visible && playerData.CanRaise) {
                    menuItem = tasksMenu.newMenuItem(menuitems);
                    menuItem.text = i18nc("Open or bring to the front window of media player app", "Restore");
                    menuItem.icon = playerData["Desktop Icon Name"];
                    menuItem.visible = Qt.binding(function() {
                        return !startNewInstanceItem.visible;
                    });
                    menuItem.clicked.connect(function() {
                        mpris2Source.raise(sourceName);
                        tasksMenu.closeMenu();
                    });
                    tasksMenu.addItemToMenu(menuItem);
                }
            }
        }

        // We allow mute/unmute whenever an application has a stream, regardless of whether it
        // is actually playing sound.
        // This way you can unmute, e.g. a telephony app, even after the conversation has ended,
        // so you still have it ringing later on.
        if (tasksMenu.visualParent.hasAudioStream) {
            var muteItem = tasksMenu.newMenuItem(menuitems);
            muteItem.checkable = true;
            muteItem.checked = Qt.binding(function() {
                return tasksMenu.visualParent && tasksMenu.visualParent.muted;
            });
            muteItem.clicked.connect(function() {
                tasksMenu.visualParent.toggleMuted();
                muteItem.text = !muteItem.checked ? "Unmute" : "Mute";
                muteItem.icon = !muteItem.checked ? "audio-volume-muted" : "audio-volume-high";
            });
            muteItem.text = muteItem.checked ? "Unmute" : "Mute";
            muteItem.icon = muteItem.checked ? "audio-volume-muted" : "audio-volume-high";
            tasksMenu.addItemToMenu(muteItem);
            secondaryColumn = true;

        }
    }

    function delayedMenu(delay, func) {
        plasmoid.nativeInterface.disableBlurBehind(tasksMenu);
        tasksMenu.y += PlasmaCore.Units.smallSpacing*2;
        opacity = 0;
        delayTimer.interval = delay;
        delayTimer.repeat = false;
        delayTimer.triggered.connect(func);
        delayTimer.start();
    }

    FocusScope {
        id: fscope
        focus: true
        Layout.minimumWidth: menuWidth
        Layout.maximumWidth: menuWidth
        Layout.minimumHeight: staticMenuItems.height + menuitems.height + PlasmaCore.Units.smallSpacing*3 - (secondaryColumn ? 0 : PlasmaCore.Units.smallSpacing*2)
        Layout.maximumHeight: staticMenuItems.height + menuitems.height + PlasmaCore.Units.smallSpacing*3 - (secondaryColumn ? 0 : PlasmaCore.Units.smallSpacing*2)
        // This is the last resort to avoiding the dialog displacement bug. It's set to correct the x position at a delay of 18ms.
        // This may result in a brief but noticeable jump in position when the context menu is shown.
        Timer {
            id: delayTimer
        }
        Timer {
            id: openTimer
            interval: 20
            repeat: false
            onTriggered: {
                tasksMenu.x = xpos;
                plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
            }
        }
        // Timer used to free the object from memory after the fade out animation has finished.
        Timer {
            id: closeTimer
            interval: 150
            onTriggered: {
                tasksMenu.destroy();
            }
        }
        ColumnLayout {
            id: menuitems
            z: 1
            spacing: PlasmaCore.Units.smallSpacing/2
            anchors {
                left: parent.left
                right: parent.right
                bottom: staticMenuItems.top
                leftMargin: PlasmaCore.Units.smallSpacing*2
                rightMargin: PlasmaCore.Units.smallSpacing*2
                bottomMargin: PlasmaCore.Units.smallSpacing
            }

            Item {
                Layout.fillHeight: true
            }
            Item {
                height: PlasmaCore.Units.smallSpacing
            }
        }
        ColumnLayout {
            id: staticMenuItems
            z: 1
            spacing: PlasmaCore.Units.smallSpacing/2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: PlasmaCore.Units.smallSpacing*2

            Item {
                Layout.fillHeight: true
            }
            Item {
                height: PlasmaCore.Units.smallSpacing
            }

            TasksMenuItemWrapper {
                id: startNewInstanceItem
                visible: get(atm.CanLaunchNewInstance)
                text: get(atm.AppName)
                icon: menuDecoration
                onClicked: tasksModel.requestNewInstance(modelIndex)
                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight
            }
            TasksMenuItemWrapper {
                id: virtualDesktopsMenuItem
                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight
                text: i18n("Move to Desktop...")
                icon: "virtual-desktops"

                visible: virtualDesktopInfo.numberOfDesktops > 1 && (visualParent && get(atm.IsLauncher) !== true && get(atm.IsStartup) !== true && get(atm.IsVirtualDesktopsChangeable) === true)

                onClicked: virtualDesktopsMenu.openRelative()

                Connections {
                    target: virtualDesktopInfo

                    function onNumberOfDesktopsChanged() {Qt.callLater(virtualDesktopsMenu.refresh)}
                    function onDesktopIdsChanged() {Qt.callLater(virtualDesktopsMenu.refresh)}
                    function onDesktopNamesChanged() {Qt.callLater(virtualDesktopsMenu.refresh)}
                }
                PlasmaComponents.ContextMenu {
                    id: virtualDesktopsMenu

                    visualParent: virtualDesktopsMenuItem
                    onTriggered: {
                        tasksMenu.closeMenu();
                    }

                    function refresh() {
                        clearMenuItems();

                        if (virtualDesktopInfo.numberOfDesktops <= 1) {
                            return;
                        }

                        var menuItem = tasksMenu.newPlasmaMenuItem(virtualDesktopsMenu);
                        menuItem.text = i18n("Move &To Current Desktop");
                        menuItem.enabled = Qt.binding(function() {
                            return tasksMenu.visualParent && tasksMenu.get(atm.VirtualDesktops).indexOf(virtualDesktopInfo.currentDesktop) === -1;
                        });
                        menuItem.clicked.connect(function() {
                            tasksModel.requestVirtualDesktops(tasksMenu.modelIndex, [virtualDesktopInfo.currentDesktop]);
                        });

                        menuItem = tasksMenu.newPlasmaMenuItem(virtualDesktopsMenu);
                        menuItem.text = i18n("&All Desktops");
                        menuItem.checkable = true;
                        menuItem.checked = Qt.binding(function() {
                            return tasksMenu.visualParent && tasksMenu.get(atm.IsOnAllVirtualDesktops) === true;
                        });
                        menuItem.clicked.connect(function() {
                            tasksModel.requestVirtualDesktops(tasksMenu.modelIndex, []);
                        });
                        backend.setActionGroup(menuItem.action);

                        tasksMenu.newPlasmaSeparator(virtualDesktopsMenu);

                        for (var i = 0; i < virtualDesktopInfo.desktopNames.length; ++i) {
                            menuItem = tasksMenu.newPlasmaMenuItem(virtualDesktopsMenu);
                            menuItem.text = i18nc("1 = number of desktop, 2 = desktop name", "&%1 %2", i + 1, virtualDesktopInfo.desktopNames[i]);
                            menuItem.checkable = true;
                            menuItem.checked = Qt.binding((function(i) {
                                return function() { return tasksMenu.visualParent && tasksMenu.get(atm.VirtualDesktops).indexOf(virtualDesktopInfo.desktopIds[i]) > -1 };
                            })(i));
                            menuItem.clicked.connect((function(i) {
                                return function() { return tasksModel.requestVirtualDesktops(tasksMenu.modelIndex, [virtualDesktopInfo.desktopIds[i]]); };
                            })(i));
                            backend.setActionGroup(menuItem.action);
                        }

                        tasksMenu.newPlasmaSeparator(virtualDesktopsMenu);

                        menuItem = tasksMenu.newPlasmaMenuItem(virtualDesktopsMenu);
                        menuItem.text = i18n("&New Desktop");
                        menuItem.clicked.connect(function() {
                            tasksModel.requestNewVirtualDesktop(tasksMenu.modelIndex);
                        });
                    }

                    // Return mouse grabbing to the original context menu when the context menu closes
                    onStatusChanged: {
                        if(status == 3) {
                            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
                        }
                    }
                    Component.onCompleted: {
                        if(virtualDesktopsMenuItem.visible) refresh()
                    }
                }
            }

            TasksMenuItemWrapper {
                id: activitiesDesktopsMenuItem

                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight
                visible: activityInfo.numberOfRunningActivities > 1
                         && (visualParent && !get(atm.IsLauncher)
                         && !get(atm.IsStartup))

                enabled: visible

                text: i18n("Show in Activities...")
                icon: "activities"
                onClicked: activitiesDesktopsMenu.openRelative()

                Connections {
                    target: activityInfo

                    function onNumberOfRunningActivitiesChanged() {
                        activitiesDesktopsMenu.refresh()
                    }
                }
                PlasmaComponents.ContextMenu {
                    id: activitiesDesktopsMenu

                    visualParent: activitiesDesktopsMenuItem

                    onTriggered: {
                        tasksMenu.closeMenu();
                    }
                    function refresh() {
                        clearMenuItems();

                        if (activityInfo.numberOfRunningActivities <= 1) {
                            return;
                        }

                        var menuItem = tasksMenu.newPlasmaMenuItem(activitiesDesktopsMenu);
                        menuItem.text = i18n("Add To Current Activity");
                        menuItem.enabled = Qt.binding(function() {
                            return tasksMenu.visualParent && tasksMenu.get(atm.Activities).length > 0 &&
                                   tasksMenu.get(atm.Activities).indexOf(activityInfo.currentActivity) < 0;
                        });
                        menuItem.clicked.connect(function() {
                            tasksModel.requestActivities(tasksMenu.modelIndex, tasksMenu.get(atm.Activities).concat(activityInfo.currentActivity));
                        });

                        menuItem = tasksMenu.newPlasmaMenuItem(activitiesDesktopsMenu);
                        menuItem.text = i18n("All Activities");
                        menuItem.checkable = true;
                        menuItem.checked = Qt.binding(function() {
                            return tasksMenu.visualParent && tasksMenu.get(atm.Activities).length === 0;
                        });
                        menuItem.toggled.connect(function(checked) {
                            let newActivities = []; // will cast to an empty QStringList i.e all activities
                            if (!checked) {
                                newActivities = new Array(activityInfo.currentActivity);
                            }
                            tasksModel.requestActivities(tasksMenu.modelIndex, newActivities);
                        });

                        tasksMenu.newPlasmaSeparator(activitiesDesktopsMenu);

                        var runningActivities = activityInfo.runningActivities();
                        for (var i = 0; i < runningActivities.length; ++i) {
                            var activityId = runningActivities[i];

                            menuItem = tasksMenu.newPlasmaMenuItem(activitiesDesktopsMenu);
                            menuItem.text = activityInfo.activityName(runningActivities[i]);
                            menuItem.checkable = true;
                            menuItem.checked = Qt.binding( (function(activityId) {
                                return function() {
                                    return tasksMenu.visualParent && tasksMenu.get(atm.Activities).indexOf(activityId) >= 0;
                                };
                            })(activityId));
                            menuItem.toggled.connect((function(activityId) {
                                return function (checked) {
                                    var newActivities = tasksMenu.get(atm.Activities);
                                    if (checked) {
                                        newActivities = newActivities.concat(activityId);
                                    } else {
                                        var index = newActivities.indexOf(activityId)
                                        if (index < 0) {
                                            return;
                                        }

                                        newActivities.splice(index, 1);
                                    }
                                    return tasksModel.requestActivities(tasksMenu.modelIndex, newActivities);
                                };
                            })(activityId));
                        }

                        tasksMenu.newPlasmaSeparator(activitiesDesktopsMenu);

                        for (var i = 0; i < runningActivities.length; ++i) {
                            var activityId = runningActivities[i];
                            var onActivities = tasksMenu.get(atm.Activities);

                            // if the task is on a single activity, don't insert a "move to" item for that activity
                            if(onActivities.length == 1 && onActivities[0] == activityId) {
                                continue;
                            }

                            menuItem = tasksMenu.newPlasmaMenuItem(activitiesDesktopsMenu);
                            menuItem.text = i18n("Move to %1", activityInfo.activityName(activityId))
                            menuItem.clicked.connect((function(activityId) {
                                return function () {
                                    return tasksModel.requestActivities(tasksMenu.modelIndex, [activityId]);
                                };
                            })(activityId));
                        }

                        tasksMenu.newPlasmaSeparator(activitiesDesktopsMenu);
                    }

                    onStatusChanged: {
                        if(status == 3) {
                            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
                        }
                    }
                    Component.onCompleted: {
                        if(activitiesDesktopsMenuItem.visible) refresh()
                    }
                }
            }

            TasksMenuItemWrapper {
                id: launcherToggleAction
                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight
                text: i18n("Pin this program to taskbar")
                icon: "window-pin"
                visible: visualParent
                     && get(atm.IsLauncher) !== true
                     && get(atm.IsStartup) !== true
                     && plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
                     && (activityInfo.numberOfRunningActivities < 2)
                     && !doesBelongToCurrentActivity()

                function doesBelongToCurrentActivity() {
                    return tasksModel.launcherActivities(get(atm.LauncherUrlWithoutIcon)).some(function(activity) {
                        return activity === activityInfo.currentActivity || activity === activityInfo.nullUuid;
                    });
                }

                onClicked: {
                    tasksModel.requestAddLauncher(get(atm.LauncherUrl));
                    tasksMenu.closeMenu();
                }
            }
            TasksMenuItemWrapper {
                id: showLauncherInActivitiesItem
                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight
                text: i18n("Pin this program to taskbar") + "..."
                icon: "window-pin"

                visible: visualParent
                     && get(atm.IsStartup) !== true
                     && plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
                     && (activityInfo.numberOfRunningActivities >= 2)

                onClicked: activitiesLaunchersMenu.openRelative()
                Connections {
                    target: activityInfo
                    function onNumberOfRunningActivitiesChanged() {
                        activitiesDesktopsMenu.refresh()
                    }
                }

                PlasmaComponents.ContextMenu {
                    id: activitiesLaunchersMenu
                    visualParent: showLauncherInActivitiesItem

                    function refresh() {
                        clearMenuItems();
                        if (tasksMenu.visualParent === null) return;

                        var createNewItem = function(id, title, url, activities) {
                            var result = tasksMenu.newPlasmaMenuItem(activitiesLaunchersMenu);
                            result.text = title;

                            result.visible = true;
                            result.checkable = true;

                            result.checked = activities.some(function(activity) { return activity === id });

                            result.clicked.connect(
                                function() {
                                    delayedMenu(150, function() {
                                        if (result.checked) {
                                            tasksModel.requestAddLauncherToActivity(url, id);
                                        } else {
                                            tasksModel.requestRemoveLauncherFromActivity(url, id);
                                        }
                                        tasksMenu.destroy();
                                    });
                                }
                            );

                            return result;
                        }

                        if (tasksMenu.visualParent === null) return;
                        var url = tasksMenu.get(atm.LauncherUrlWithoutIcon);
                        var activities = tasksModel.launcherActivities(url);
                        createNewItem(activityInfo.nullUuid, i18n("On All Activities"), url, activities);

                        if (activityInfo.numberOfRunningActivities <= 1) {
                            return;
                        }

                        createNewItem(activityInfo.currentActivity, i18n("On The Current Activity"), url, activities);
                        tasksMenu.newPlasmaSeparator(activitiesLaunchersMenu);
                        var runningActivities = activityInfo.runningActivities();
                        runningActivities.forEach(function(id) {
                            createNewItem(id, activityInfo.activityName(id), url, activities);
                        });
                    }

                    onStatusChanged: {
                        if(status == 3) {
                            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
                        }
                    }
                    Component.onCompleted: {
                        tasksMenu.onVisualParentChanged.connect(refresh);
                        refresh();
                    }
                }

            }
            TasksMenuItemWrapper {
                id: unpinFromTaskMan
                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight

                visible: (visualParent
                && plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
                && !launcherToggleAction.visible
                && activityInfo.numberOfRunningActivities < 2)

                text: i18n("Unpin this program from taskbar")
                icon: "window-unpin"
                onClicked: {
                    delayedMenu(150, function() {
                        tasksModel.requestRemoveLauncher(get(atm.LauncherUrlWithoutIcon));
                        tasksMenu.destroy();
                    });
                }

            }
            TasksMenuItemWrapper {
                id: moreActionsMenuItem

                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight
                visible: (visualParent && get(atm.IsLauncher) !== true && get(atm.IsStartup) !== true)

                enabled: visible

                text: i18n("More") + "..."
                icon: "view-more-symbolic"

                onClicked: moreActionsMenu.openRelative();

                PlasmaComponents.ContextMenu {
                    id: moreActionsMenu
                    visualParent: moreActionsMenuItem

                    onTriggered: {
                        plasmoid.nativeInterface.setMouseGrab(false, tasksMenu);
                        tasksMenu.closeMenu();
                    }
                    onStatusChanged: {
                        if(status == 3) {
                            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
                        }
                    }

                    PlasmaComponents.MenuItem {
                        enabled: tasksMenu.visualParent && tasksMenu.get(atm.IsMovable) === true

                        text: i18n("&Move")
                        icon: "transform-move"

                        onClicked: tasksModel.requestMove(tasksMenu.modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        enabled: tasksMenu.visualParent && tasksMenu.get(atm.IsResizable) === true

                        text: i18n("Re&size")
                        icon: "transform-scale"

                        onClicked: tasksModel.requestResize(tasksMenu.modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        visible: (tasksMenu.visualParent && get(atm.IsLauncher) !== true && get(atm.IsStartup) !== true)

                        enabled: tasksMenu.visualParent && get(atm.IsMaximizable) === true

                        checkable: true
                        checked: tasksMenu.visualParent && get(atm.IsMaximized) === true

                        text: i18n("Ma&ximize")
                        icon: "window-maximize"

                        onClicked: tasksModel.requestToggleMaximized(modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        visible: (tasksMenu.visualParent && get(atm.IsLauncher) !== true && get(atm.IsStartup) !== true)

                        enabled: tasksMenu.visualParent && get(atm.IsMinimizable) === true

                        checkable: true
                        checked: tasksMenu.visualParent && get(atm.IsMinimized) === true

                        text: i18n("Mi&nimize")
                        icon: "window-minimize"

                        onClicked: tasksModel.requestToggleMinimized(modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        checkable: true
                        checked: tasksMenu.visualParent && tasksMenu.get(atm.IsKeepAbove) === true

                        text: i18n("Keep &Above Others")
                        icon: "window-keep-above"

                        onClicked: tasksModel.requestToggleKeepAbove(tasksMenu.modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        checkable: true
                        checked: tasksMenu.visualParent && tasksMenu.get(atm.IsKeepBelow) === true

                        text: i18n("Keep &Below Others")
                        icon: "window-keep-below"

                        onClicked: tasksModel.requestToggleKeepBelow(tasksMenu.modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        enabled: tasksMenu.visualParent && tasksMenu.get(atm.IsFullScreenable) === true

                        checkable: true
                        checked: tasksMenu.visualParent && tasksMenu.get(atm.IsFullScreen) === true

                        text: i18n("&Fullscreen")
                        icon: "view-fullscreen"

                        onClicked: tasksModel.requestToggleFullScreen(tasksMenu.modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        enabled: tasksMenu.visualParent && tasksMenu.get(atm.IsShadeable) === true

                        checkable: true
                        checked: tasksMenu.visualParent && tasksMenu.get(atm.IsShaded) === true

                        text: i18n("&Shade")
                        icon: "window-shade"

                        onClicked: tasksModel.requestToggleShaded(tasksMenu.modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        separator: true
                    }

                    PlasmaComponents.MenuItem {
                        visible: (plasmoid.configuration.groupingStrategy !== 0) && tasksMenu.get(atm.IsWindow) === true

                        checkable: true
                        checked: tasksMenu.visualParent && tasksMenu.get(atm.IsGroupable) === true

                        text: i18n("Allow this program to be grouped")
                        icon: "view-group"

                        onClicked: tasksModel.requestToggleGrouping(menu.modelIndex)
                    }

                    PlasmaComponents.MenuItem {
                        separator: true
                    }

                    PlasmaComponents.MenuItem {
                        property QtObject configureAction: null

                        enabled: configureAction && configureAction.enabled
                        visible: configureAction && configureAction.visible

                        text: configureAction ? configureAction.text : ""
                        icon: configureAction ? configureAction.icon : ""

                        onClicked: configureAction.trigger()

                        Component.onCompleted: configureAction = plasmoid.action("configure")
                    }

                    PlasmaComponents.MenuItem {
                        property QtObject alternativesAction: null

                        enabled: alternativesAction && alternativesAction.enabled
                        visible: alternativesAction && alternativesAction.visible

                        text: alternativesAction ? alternativesAction.text : ""
                        icon: alternativesAction ? alternativesAction.icon : ""

                        onClicked: alternativesAction.trigger()

                        Component.onCompleted: alternativesAction = plasmoid.action("alternatives")
                    }
                }
            }

            TasksMenuItemWrapper {
                id: closeWindowItem
                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight

                visible: (visualParent && get(atm.IsLauncher) !== true && get(atm.IsStartup) !== true)

                enabled: visualParent && get(atm.IsClosable) === true

                text: get(atm.IsGroupParent) ? "Close all windows" : i18n("Close window")
                icon: "window-close"
                onClicked: {
                    alsoCloseTask = true;
                    closeMenu();
                }
            }
            /*TasksMenuItemWrapper {
                id: testItem
                Layout.fillWidth: true
                Layout.preferredHeight: menuItemHeight

                text: "Test"
                icon: "window-close"
                onClicked: {
                }
            }*/
        }

        Rectangle {
            id: bgRect
            visible: secondaryColumn
            anchors {
                top: parent.top
                bottom: bgStatic.top
                left: parent.left
                right: parent.right
                leftMargin: 2
                rightMargin: PlasmaCore.Units.smallSpacing-1
                topMargin: PlasmaCore.Units.smallSpacing-1
            }
            gradient: Gradient {
                GradientStop { position: 0; color: backgroundColorStatic }
                GradientStop { position: 0.5; color: backgroundColorGradient }
                GradientStop { position: 1; color: backgroundColorStatic }
            }
            z: -2
        }
        Rectangle {
            id: bgStatic
            anchors {
                top: staticMenuItems.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                leftMargin: 2
                rightMargin: PlasmaCore.Units.smallSpacing-1
                bottomMargin: 2
            }
            Rectangle {
                id: bgStaticBorderLine
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: PlasmaCore.Units.smallSpacing
                gradient: Gradient {
                    GradientStop { position: 0; color: borderColor }
                    GradientStop { position: 1; color: "transparent"}
                }
            }
            z: -1
            color: backgroundColorStatic
        }
        function decreaseItemIndex() {
            currentItemIndex--;
            if(currentItemIndex < 0) {
                currentItemIndex = menuitems.children.length + staticMenuItems.children.length - 1;
            }
            var temp = currentItemIndex;
            var container = menuitems.children;
            if(currentItemIndex >= menuitems.children.length) {
                temp -= menuitems.children.length;
                container = staticMenuItems.children;
            }
            if(container[temp].objectName !== "menuitemwrapper" || (container[temp].objectName === "menuitemwrapper" && (!container[temp].enabled || !container[temp].visible))) {
                decreaseItemIndex();
            } else {
                if(currentItem !== null) currentItem.selected = false;
                container[temp].selected = true;
                currentItem = container[temp];
            }

        }
        function increaseItemIndex() {
            currentItemIndex++;
            if(currentItemIndex == menuitems.children.length + staticMenuItems.children.length) {
                currentItemIndex = 0;
            }
            var temp = currentItemIndex;
            var container = menuitems.children;
            if(currentItemIndex >= menuitems.children.length) {
                temp -= menuitems.children.length;
                container = staticMenuItems.children;
            }
            if(container[temp].objectName !== "menuitemwrapper" || (container[temp].objectName === "menuitemwrapper" && (!container[temp].enabled || !container[temp].visible))) {
                increaseItemIndex();
            } else {
                if(currentItem !== null) currentItem.selected = false;
                container[temp].selected = true;
                currentItem = container[temp];
            }

        }
        Keys.onPressed: {
            if(event.key == Qt.Key_Up) {
                decreaseItemIndex();
            }
            else if(event.key == Qt.Key_Down || event.key == Qt.Key_Tab) {
                increaseItemIndex();
            }
            else if(event.key == Qt.Key_Escape) {
                tasksMenu.closeMenu();
            }
            else if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                if(currentItem !== null) {
                    currentItem.clicked();
                }
            }

        }

        /*
         * Connects the context menu with the C++ part of the plasmoid.
         * The native interface installs itself onto this dialog as an event filter, upon which
         * all mouse click events are captured. By checking if the mouse has been clicked outside of
         * the context menu, we can then safely close it.
         *
         * This works because right after creating the context menu, we have set this dialog window to
         * grab all mouse events, which mimicks the way context menus work under Linux.
         *
         */
        Connections {
            target: plasmoid.nativeInterface;
            function onMouseEventDetected(mouse) {
                if(!fscope.contains(plasmoid.nativeInterface.getPosition(tasksMenu))) {
                    tasksMenu.closeMenu();
                }
            }
            /*onMouseEventDetected: {

            }*/
        }

    }

    Component.onCompleted: {
        backend.showAllPlaces.connect(showContextMenuWithAllPlaces)
        tasksMenu.backgroundHints = 2; // Sets the dialog background to the solid SVG variant.
    }
    Component.onDestruction: {
        backend.showAllPlaces.disconnect(showContextMenuWithAllPlaces)
        if(alsoCloseTask)
            tasksModel.requestClose(modelIndex);
    }
}
