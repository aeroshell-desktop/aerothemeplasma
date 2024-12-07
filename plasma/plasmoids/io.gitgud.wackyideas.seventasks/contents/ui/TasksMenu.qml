/*
 *    SPDX-FileCopyrightText: 2012-2016 Eike Hein <hein@kde.org>
 *    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *    SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.private.mpris as Mpris

import org.kde.taskmanager as TaskManager

import "code/layoutmetrics.js" as LayoutManager
import org.kde.plasma.extras as PlasmaExtras

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

    property int taskWidth: 0
    property int taskHeight: 0
    property int taskX: 0
    property int taskY: 0

    readonly property int menuItemHeight: Kirigami.Units.smallSpacing*5
    readonly property int menuWidth: 238
    readonly property int slide: Kirigami.Units.smallSpacing*3
    property bool finishedAnimating: false

    property bool showAllPlaces: false
    property bool alsoCloseTask: false
    property bool secondaryColumn: false

    property color backgroundColorStatic: "#f1f6fb"
    property color backgroundColorGradient: "white"
    property color borderColor: "#ccd9ea"
    property alias sliderAnimation: sliderAnimation

    // Functions inherited from the original ContextMenu
    function get(modelProp) {
        return tasksModel.data(modelIndex, modelProp)
    }
    function showContextMenuWithAllPlaces() {
        visualParent.showContextMenu({showAllPlaces: true});
    }

    function newPlasmaMenuItem(parent) {
        return Qt.createQmlObject(`
        import org.kde.plasma.extras 2.0 as PlasmaExtras

        PlasmaExtras.MenuItem {}
        `, parent);
    }

    function newPlasmaSeparator(parent) {
        return Qt.createQmlObject(`
        import org.kde.plasma.extras 2.0 as PlasmaExtras

        PlasmaExtras.MenuItem { separator: true }
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
        NumberAnimation { duration: 100; }
    }
    Behavior on y {
        NumberAnimation {
            id: sliderAnimation
            onRunningChanged: {
                Plasmoid.setMouseGrab(true, tasksMenu);
            }
            duration: 150;
        }
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
            var globalPos = parent.mapToGlobal(tasks.x, tasks.y);
            tasksMenu.y = globalPos.y - tasksMenu.height;
            //var diff = parent.mapToGlobal(tasksMenu.x, tasksMenu.y).x - tasksMenu.x;

            var parentPos = parent.mapToGlobal(taskX, taskY);
            xpos = parentPos.x + taskWidth / 2;
            tasksMenu.x = parentPos.x + taskWidth / 2;
            xpos = parentPos.x +  taskWidth / 2 - Kirigami.Units.largeSpacing + 1;
            xpos -= menuWidth / 2;
            if(xpos <= 0) {
               xpos = Kirigami.Units.largeSpacing;
               tasksMenu.x = Kirigami.Units.largeSpacing;
            }
            tasksMenu.x = xpos;
        }
        else if(!visible) {
            tasksMenu.closeMenu();
        }
    }

    onActiveChanged: {
        if(!active) tasksMenu.close();
    }
    // Set to Floating so that the borders are visible all the time, even when it is right next to another object.
    location: PlasmaCore.Types.Floating;
    // Used publicly by other objects to show the dynamically created context menu.
    function show() {
        loadDynamicLauncherActions(get(atm.LauncherUrlWithoutIcon));
        visible = true;
        tasksMenu.y -= slide;
        opacity = 1;
        Qt.callLater(() => {Plasmoid.setMouseGrab(true, tasksMenu); tasksMenu.x = xpos;});
        if(xpos !== tasksMenu.x) tasksMenu.x = xpos;
        openTimer.start();
    }
    // Closes the menu gracefully, by first showing a fade out animation before freeing the object from memory.
    function closeMenu() {
        Plasmoid.disableBlurBehind(tasksMenu);
        tasksMenu.y += slide;
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
        var textMetrics = Qt.createQmlObject("import QtQuick; TextMetrics {}", menuitems);
        var maximumWidth = LayoutManager.maximumContextMenuTextWidth() + Kirigami.Units.smallSpacing*2;

        for(var i = 0; i < sections.length; i++) {
            var section = sections[i];
            if(section["actions"].length == 0) continue;

            // Make a separator header
            var sepHeader = tasksMenu.newSeparator(menuitems);
            sepHeader.menuText = section["title"];
            //addItemToMenu(sepHeader);

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
                mItem.icon= mAction.icon;
                mItem.clicked.connect(mAction.trigger);
                //addItemToMenu(mItem);
                secondaryColumn = true;
            }

        }

        // Add Media Player control actions
        var playerData = mpris2Source.playerForLauncherUrl(launcherUrl, get(atm.AppPid));

        if (playerData && playerData.canControl && !(get(atm.WinIdList) !== undefined && get(atm.WinIdList).length > 1)) {
            var menuItem = tasksMenu.newMenuItem(menuitems);
            menuItem.text = i18nc("Play previous track", "Previous Track");
            menuItem.icon = "media-skip-backward";
            menuItem.enabled = Qt.binding(function() {
                return playerData.canGoPrevious;
            });
            menuItem.clicked.connect(function() {
                playerData.Previous();
            });

            menuItem = tasksMenu.newMenuItem(menuitems);
            // PlasmaCore Menu doesn't actually handle icons or labels changing at runtime...
            // Since we're not using PlasmaCore Menu anymore, we can achieve runtime changes like this'
            menuItem.text = Qt.binding(function() {
                var playing = playerData.playbackStatus === Mpris.PlaybackStatus.Playing;
                // if CanPause, toggle the menu entry between Play & Pause, otherwise always use Play
                return playing && playerData.canPause ? i18nc("Pause playback", "Pause") : i18nc("Start playback", "Play");
            });
            menuItem.icon= Qt.binding(function() {
                var playing = playerData.playbackStatus === Mpris.PlaybackStatus.Playing;
                return playing && playerData.canPause ? "media-playback-pause" : "media-playback-start";
            });
            menuItem.enabled = Qt.binding(function() {
                var playing = playerData.playbackStatus === Mpris.PlaybackStatus.Playing;
                return playing ? playerData.canPause : playerData.canPlay;
            });
            menuItem.clicked.connect(function() {
                var playing = playerData.playbackStatus === Mpris.PlaybackStatus.Playing;
                if (playing) {
                    playerData.Pause();
                } else {
                    playerData.Play();
                }
            });

            menuItem = tasksMenu.newMenuItem(menuitems);
            menuItem.text = i18nc("Play next track", "Next Track");
            menuItem.icon = "media-skip-forward";
            menuItem.enabled = Qt.binding(function() {
                return playerData.canGoNext;
            });
            menuItem.clicked.connect(function() {
                playerData.Next();
            });

            menuItem = tasksMenu.newMenuItem(menuitems);
            menuItem.text = i18nc("Stop playback", "Stop");
            menuItem.icon= "media-playback-stop";
            menuItem.enabled = Qt.binding(function() {
                return playerData.canStop;
            });
            menuItem.clicked.connect(function() {
                playerData.Stop();
            });

            // If we don't have a window associated with the player but we can quit
            // it through MPRIS we'll offer a "Quit" option instead of "Close"
            if (!closeWindowItem.visible && playerData.canQuit) {
                menuItem = tasksMenu.newMenuItem(menuitems);
                menuItem.text = i18nc("Quit media player app", "Quit");
                menuItem.icon= "application-exit";
                menuItem.visible = Qt.binding(function() {
                    return !closeWindowItem.visible;
                });
                menuItem.clicked.connect(function() {
                    playerData.Quit();
                });
            }

            // If we don't have a window associated with the player but we can raise
            // it through MPRIS we'll offer a "Restore" option
            if (get(atm.IsLauncher) && !startNewInstanceItem.visible && playerData.canRaise) {
                menuItem = tasksMenu.newMenuItem(menuitems);
                menuItem.text = i18nc("Open or bring to the front window of media player app", "Restore");
                menuItem.icon = playerData.iconName;
                menuItem.visible = Qt.binding(function() {
                    return !startNewInstanceItem.visible;
                });
                menuItem.clicked.connect(function() {
                    playerData.Raise();
                });
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
            secondaryColumn = true;
        }
    }

    function delayedMenu(delay, func) {
        Plasmoid.disableBlurBehind(tasksMenu);
        tasksMenu.y += slide;
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
        Layout.minimumHeight: staticMenuItems.height + menuitems.height + Kirigami.Units.smallSpacing*3 - (!menuitems.isEmpty() ? 0 : Kirigami.Units.smallSpacing*2)
        Layout.maximumHeight: staticMenuItems.height + menuitems.height + Kirigami.Units.smallSpacing*3 - (!menuitems.isEmpty() ? 0 : Kirigami.Units.smallSpacing*2)
        // This is the last resort to avoiding the dialog displacement bug. It's set to correct the x position at a delay of 18ms.
        // This may result in a brief but noticeable jump in position when the context menu is shown.
        //enabled: !sliderAnimation.running;
        Timer {
            id: delayTimer
        }
        Timer {
            id: openTimer
            interval: 25
            repeat: false
            onTriggered: {
                tasksMenu.x = xpos;
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

            function isEmpty() {
                return menuitems.visibleChildren.length <= 2;
            }
            onHeightChanged: {
                if(sliderAnimation.running)
                    tasksMenu.y -= tasksMenu.slide;
            }
            spacing: Kirigami.Units.smallSpacing/2
            anchors {
                left: parent.left
                right: parent.right
                bottom: staticMenuItems.top
                leftMargin: Kirigami.Units.mediumSpacing
                rightMargin: Kirigami.Units.mediumSpacing
                bottomMargin: 10
            }

            Item {
                Layout.fillHeight: true
            }
            Item {
                height: Kirigami.Units.smallSpacing
            }
        }
        ColumnLayout {
            id: staticMenuItems
            z: 1
            spacing: Kirigami.Units.smallSpacing/2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 6
            anchors.bottomMargin: 6
            anchors.rightMargin: 6

            Item {
                height: 1
            }

            TasksMenuItemWrapper {
                id: startNewInstanceItem
                visible: true
                text: get(atm.AppName) === "" ? get(atm.Decoration) : get(atm.AppName)
                icon: menuDecoration
                onClicked: tasksModel.requestNewInstance(modelIndex)
            }

            TasksMenuItemWrapper {
                id: launcherToggleAction
                text: "Pin program to taskbar"
                icon: "window-pin"
                visible: visualParent
                && get(atm.IsLauncher) !== true
                && get(atm.IsStartup) !== true
                && plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
                && (activityInfo.numberOfRunningActivities < 2)
                && !doesBelongToCurrentActivity()

                enabled: visible
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
                id: unpinFromTaskMan

                enabled: visible
                visible: (visualParent
                && Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
                && !launcherToggleAction.visible
                && activityInfo.numberOfRunningActivities < 2)

                text: i18n("Unpin program from taskbar")
                icon: "window-unpin"
                onClicked: {
                    delayedMenu(150, function() {
                        tasksModel.requestRemoveLauncher(get(atm.LauncherUrlWithoutIcon));
                        tasksMenu.destroy();
                    });
                }
            }

            TasksMenuItemWrapper {
                id: closeWindowItem

                visible: (visualParent && get(atm.IsLauncher) !== true && get(atm.IsStartup) !== true)

                enabled: visualParent && get(atm.IsClosable) === true

                text: get(atm.IsGroupParent) ? "Close all windows" : "Close window"
                //icon: "window-close" RIP ????-2024......
                icon: "window-close"
                // I'M BACK'
                onClicked: {
                    alsoCloseTask = true;
                    closeMenu();
                }
            }
            /*TasksMenuItemWrapper {
             *                id: testItem
             *                Layout.fillWidth: true
             *                Layout.preferredHeight: menuItemHeight
             *
             *                text: "Test"
             *                icon: "window-close"
             *                onClicked: {
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
                leftMargin: 0
                rightMargin: 0
                topMargin: 0
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
                leftMargin: 0
                rightMargin: 0
                topMargin: -4
            }
            Rectangle {
                id: bgStaticBorderLine
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: Kirigami.Units.smallSpacing
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
        Keys.onPressed: event => {
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
            target: Plasmoid;
            function onMouseEventDetected(mouse) {
                if(!fscope.contains(Plasmoid.getPosition(fscope)) && !sliderAnimation.running) {
                    tasksMenu.closeMenu();
                }
            }
        }

    }

    Component.onCompleted: {
        backend.showAllPlaces.connect(showContextMenuWithAllPlaces)
        tasksMenu.backgroundHints = 2; // Sets the dialog background to the solid SVG variant.
        tasksMenu.y = tasksMenu.taskY - tasksMenu.slide;
        Plasmoid.setMouseGrab(true, tasksMenu);
    }
    Component.onDestruction: {
        backend.showAllPlaces.disconnect(showContextMenuWithAllPlaces)
        if(alsoCloseTask)
            tasksModel.requestClose(modelIndex);
    }
}

