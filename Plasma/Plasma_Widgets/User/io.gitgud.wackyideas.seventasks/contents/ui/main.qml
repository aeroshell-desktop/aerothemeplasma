/*
    SPDX-FileCopyrightText: 2012-2016 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

import "code/layout.js" as LayoutManager
import "code/tools.js" as TaskTools

MouseArea {
    id: tasks

    anchors.fill: parent
    hoverEnabled: true 

    property bool vertical: (plasmoid.formFactor === PlasmaCore.Types.Vertical)
    // This property tells the plasmoid to render labels next to task icons.
    // Previously, this property was determined by the value of (plasmoid.pluginName === "org.kde.plasma.icontasks")
    property bool iconsOnly: !plasmoid.configuration.labelVisible
    property var toolTipOpenedByClick: null
    property var toolTipAreaItem: null
    //property QtObject contextMenuComponent: Qt.createComponent("ContextMenu.qml");
    property QtObject tasksMenuComponent: Qt.createComponent("TasksMenu.qml");
    property QtObject pulseAudioComponent: Qt.createComponent("PulseAudio.qml");

    property bool needLayoutRefresh: false;
    property variant taskClosedWithMouseMiddleButton: []

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    Plasmoid.constraintHints: PlasmaCore.Types.CanFillArea

    Plasmoid.onUserConfiguringChanged: {
        if (plasmoid.userConfiguring) {
            LayoutManager.layout(taskRepeater);
            groupDialog.visible = false;
        }
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: tasks.vertical ? 0 : LayoutManager.preferredMinWidth()
    Layout.minimumHeight: !tasks.vertical ? 0 : LayoutManager.preferredMinHeight()

//BEGIN TODO: this is not precise enough: launchers are smaller than full tasks
    Layout.preferredWidth: tasks.vertical ? PlasmaCore.Units.gridUnit * 10 : ((LayoutManager.logicalTaskCount() * LayoutManager.preferredMaxWidth()) / LayoutManager.calculateStripes());
    Layout.preferredHeight: tasks.vertical ? ((LayoutManager.logicalTaskCount() * LayoutManager.preferredMaxHeight()) / LayoutManager.calculateStripes()) : PlasmaCore.Units.gridUnit * 2;
//END TODO

    property Item dragSource: null

    signal requestLayout
    signal windowsHovered(variant winIds, bool hovered)
    signal activateWindowView(variant winIds)
    signal presentWindows(variant winIds)

    onWidthChanged: {
        taskList.width = LayoutManager.layoutWidth();

        if (plasmoid.configuration.forceStripes) {
            taskList.height = LayoutManager.layoutHeight();
        }
        taskList.updateHoverSizes();
    }

    onHeightChanged: {
        if (plasmoid.configuration.forceStripes) {
            taskList.width = LayoutManager.layoutWidth();
        }

        taskList.height = LayoutManager.layoutHeight();
        taskList.updateHoverSizes();
    }

    onDragSourceChanged: {
        if (dragSource == null) {
            tasksModel.syncLaunchers();
        }
    }

    onExited: {
        if (needLayoutRefresh) {
            LayoutManager.layout(taskRepeater)
            needLayoutRefresh = false;
        }
    }

    /*ContextMenu {
        id: testMenu
    }*/

    // TasksModel which acts as a data source of currently present tasks.
    TaskManager.TasksModel {
        id: tasksModel

        readonly property int logicalLauncherCount: {
            if (plasmoid.configuration.separateLaunchers) {
                return launcherCount;
            }

            var startupsWithLaunchers = 0;

            for (var i = 0; i < taskRepeater.count; ++i) {
                var item = taskRepeater.itemAt(i);

                if (item && item.m.IsStartup === true && item.m.HasLauncher === true) {
                    ++startupsWithLaunchers;
                }
            }

            return launcherCount + startupsWithLaunchers;
        }

        virtualDesktop: virtualDesktopInfo.currentDesktop
        screenGeometry: plasmoid.screenGeometry
        activity: activityInfo.currentActivity

        filterByVirtualDesktop: plasmoid.configuration.showOnlyCurrentDesktop
        filterByScreen: plasmoid.configuration.showOnlyCurrentScreen
        filterByActivity: plasmoid.configuration.showOnlyCurrentActivity
        filterNotMinimized: plasmoid.configuration.showOnlyMinimized

        sortMode: sortModeEnumValue(plasmoid.configuration.sortingStrategy)
        launchInPlace: iconsOnly && plasmoid.configuration.sortingStrategy === 1
        separateLaunchers: {
            if (!iconsOnly && !plasmoid.configuration.separateLaunchers
                && plasmoid.configuration.sortingStrategy === 1) {
                return false;
            }

            return true;
        }

        groupMode: groupModeEnumValue(plasmoid.configuration.groupingStrategy)
        groupInline: !plasmoid.configuration.groupPopups
        groupingWindowTasksThreshold: (plasmoid.configuration.onlyGroupWhenFull && !iconsOnly
            ? LayoutManager.optimumCapacity(width, height) + 1 : -1)

        onLauncherListChanged: {
            layoutTimer.restart();
            plasmoid.configuration.launchers = launcherList;
            taskList.updateHoverFunc();
        }

        onGroupingAppIdBlacklistChanged: {
            plasmoid.configuration.groupingAppIdBlacklist = groupingAppIdBlacklist;
        }

        onGroupingLauncherUrlBlacklistChanged: {
            plasmoid.configuration.groupingLauncherUrlBlacklist = groupingLauncherUrlBlacklist;
        }

        function sortModeEnumValue(index) {
            switch (index) {
                case 0:
                    return TaskManager.TasksModel.SortDisabled;
                case 1:
                    return TaskManager.TasksModel.SortManual;
                case 2:
                    return TaskManager.TasksModel.SortAlpha;
                case 3:
                    return TaskManager.TasksModel.SortVirtualDesktop;
                case 4:
                    return TaskManager.TasksModel.SortActivity;
                default:
                    return TaskManager.TasksModel.SortDisabled;
            }
        }

        function groupModeEnumValue(index) {
            switch (index) {
                case 0:
                    return TaskManager.TasksModel.GroupDisabled;
                case 1:
                    return TaskManager.TasksModel.GroupApplications;
            }
        }

        Component.onCompleted: {
            launcherList = plasmoid.configuration.launchers;
            groupingAppIdBlacklist = plasmoid.configuration.groupingAppIdBlacklist;
            groupingLauncherUrlBlacklist = plasmoid.configuration.groupingLauncherUrlBlacklist;

            // Only hook up view only after the above churn is done.
            taskRepeater.model = tasksModel;
        }
    }

    Connections {
        target: tasksModel

        function onActiveTaskChanged() {
            if (!plasmoid.configuration.groupPopups) {
                return;
            }
            if (tasksModel.activeTask.parent.valid) {
                groupDialog.activeTask = tasksModel.activeTask;
            }
        }
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
        readonly property string nullUuid: "00000000-0000-0000-0000-000000000000"
    }

    TaskManagerApplet.Backend {
        id: backend

        taskManagerItem: tasks
        highlightWindows: plasmoid.configuration.highlightWindows

        onAddLauncher: {
            tasks.addLauncher(url);
        }
    }
    
    // Allows SevenTasks to launch programs from the context menu. See function below as an example.
    PlasmaCore.DataSource {
        id: menu_executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            if (cmd) {
                connectSource(cmd)
            }
        }
        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    // Opens KSysGuard from the taskbar context menu.
    function action_taskman() {
        menu_executable.exec("ksysguard");
    }

    // Data source of all tasks which are playing media. Allows for playback controls from within SevenTasks.
    PlasmaCore.DataSource {
        id: mpris2Source
        engine: "mpris2"
        connectedSources: sources
        function sourceNameForLauncherUrl(launcherUrl, pid) {
            if (!launcherUrl || launcherUrl === "") {
                return "";
            }

            // MPRIS spec explicitly mentions that "DesktopEntry" is with .desktop extension trimmed
            // Moreover, remove URL parameters, like wmClass (part after the question mark)
            var desktopFileName = launcherUrl.toString().split('/').pop().split('?')[0].replace(".desktop", "")
            if (desktopFileName.indexOf("applications:") === 0) {
                desktopFileName = desktopFileName.substr(13)
            }

            for (var i = 0, length = connectedSources.length; i < length; ++i) {
                var source = connectedSources[i];
                // we intend to connect directly, otherwise the multiplexer steals the connection away
                if (source === "@multiplex") {
                    continue;
                }

                var sourceData = data[source];
                if (!sourceData) {
                    continue;
                }

                if (sourceData.DesktopEntry === desktopFileName || (pid && sourceData.InstancePid === pid)) {
                    return source;
                }

                var metadata = sourceData.Metadata;
                if (metadata) {
                    var kdePid = metadata["kde:pid"];
                    if (kdePid && pid === kdePid) {
                        return source;
                    }
                }
            }

            return ""
        }

        function startOperation(source, op) {
            var service = serviceForSource(source)
            var operation = service.operationDescription(op)
            return service.startOperationCall(operation)
        }

        function goPrevious(source) {
            startOperation(source, "Previous");
        }
        function goNext(source) {
            startOperation(source, "Next");
        }
        function play(source) {
            startOperation(source, "Play");
        }
        function pause(source) {
            startOperation(source, "Pause");
        }
        function playPause(source) {
            startOperation(source, "PlayPause");
        }
        function stop(source) {
            startOperation(source, "Stop");
        }
        function raise(source) {
            startOperation(source, "Raise");
        }
        function quit(source) {
            startOperation(source, "Quit");
        }
    }

    Loader {
        id: pulseAudio
        sourceComponent: pulseAudioComponent
        active: pulseAudioComponent.status === Component.Ready
    }

    Timer {
        id: iconGeometryTimer

        interval: 500
        repeat: false

        onTriggered: {
            TaskTools.publishIconGeometries(taskList.children);
        }
    }

    Binding {
        target: plasmoid
        property: "status"
        value: (tasksModel.anyTaskDemandsAttention && plasmoid.configuration.unhideOnAttention
            ? PlasmaCore.Types.NeedsAttentionStatus : PlasmaCore.Types.PassiveStatus)
        restoreMode: Binding.RestoreBinding
    }

    Connections {
        target: plasmoid

        function onLocationChanged() {
            // This is on a timer because the panel may not have
            // settled into position yet when the location prop-
            // erty updates.
            iconGeometryTimer.start();
        }
    }

    Connections {
        target: plasmoid.configuration

        function onLabelVisibleChanged() {
            taskList.updateHoverFunc();
            LayoutManager.layout(taskRepeater);
            taskList.firstTimeHover = false;
            tasks.needsLayoutRefresh = true;
        }
        function onLaunchersChanged() { 
            tasksModel.launcherList = plasmoid.configuration.launchers 
        }
        function onGroupingAppIdBlacklistChanged() { 
            tasksModel.groupingAppIdBlacklist = plasmoid.configuration.groupingAppIdBlacklist;
        }
        function onGroupingLauncherUrlBlacklistChanged() {
            tasksModel.groupingLauncherUrlBlacklist = plasmoid.configuration.groupingLauncherUrlBlacklist;
        }
    }

    TaskManagerApplet.DragHelper {
        id: dragHelper

        dragIconSize: PlasmaCore.Units.iconSizes.medium
    }

    // Used for getting margin data.
    PlasmaCore.FrameSvgItem {
        id: taskFrame

        visible: false;

        imagePath: Qt.resolvedUrl("svgs/tasks.svg");
        prefix: "normal"
    }

    PlasmaCore.Svg {
        id: taskSvg

        imagePath: Qt.resolvedUrl("svgs/tasks.svg");
    }
    PlasmaCore.Svg {
        id: mediaIcons
        imagePath: Qt.resolvedUrl("svgs/media-icons.svg")
    }

    MouseHandler {
        id: mouseHandler

        anchors.fill: parent

        target: taskList

        onUrlsDropped: {
            // If all dropped URLs point to application desktop files, we'll add a launcher for each of them.
            var createLaunchers = urls.every(function (item) {
                return backend.isApplication(item)
            });

            if (createLaunchers) {
                urls.forEach(function (item) {
                    addLauncher(item);
                });
                return;
            }

            if (!hoveredItem) {
                return;
            }

            // DeclarativeMimeData urls is a QJsonArray but requestOpenUrls expects a proper QList<QUrl>.
            var urlsList = backend.jsonArrayToUrlList(urls);

            // Otherwise we'll just start a new instance of the application with the URLs as argument,
            // as you probably don't expect some of your files to open in the app and others to spawn launchers.
            tasksModel.requestOpenUrls(hoveredItem.modelIndex(), urlsList);
        }
    }
    
    ToolTipDelegate {
        id: openWindowToolTipDelegate
        visible: false
    }
    
    ToolTipDelegate {
        id: pinnedAppToolTipDelegate
        visible: false
    }

    // This is the main object that contains all of the task icons.
    /*
     * A desirable feature would be to implement a transition animation that happens when
     * a task is removed from the TaskList, but because TaskList is based on QML's Flow view
     * this makes it impossible (or at least, very difficult) because Flow doesn't have a remove
     * transition like other view types do.
     *
     * Potential solutions include forking Flow or basing TaskList on GridView and implementing a Flow
     * logic (stacking items left to right and wrapping them around on overflow). Both solutions are
     * fairly difficult, and while hack solutions exist, I'd prefer to not pollute the code any further.
     */
    TaskList {
        id: taskList
        anchors {
            left: parent.left
            top: parent.top
        }
        // In order to prevent weird bugs regarding hot tracking and how the dominant color is determined,
        // we prepare the plasmoid for the first time the user hovers over a task icon.
        property bool firstTimeHover: false
        onWidthChanged: LayoutManager.layout(taskRepeater)
        onHeightChanged: LayoutManager.layout(taskRepeater)

        flow: {
            if (tasks.vertical) {
                return plasmoid.configuration.forceStripes ? Flow.LeftToRight : Flow.TopToBottom
            }
            return plasmoid.configuration.forceStripes ? Flow.TopToBottom : Flow.LeftToRight
        }

        onAnimatingChanged: {
            if (!animating) {
                TaskTools.publishIconGeometries(children);
            }
        }

        function layout() {
            taskList.width = LayoutManager.layoutWidth();
            taskList.height = LayoutManager.layoutHeight();
            LayoutManager.layout(taskRepeater);
            //taskList.updateHoverFunc();
        }
        // Updates the dominant color of every task present in the TaskList.
        // With this, we can update each task icon pretty much globally.
        function updateHoverFunc() {
            for(var i = 0; i < taskRepeater.count; i++) {
                if(taskRepeater.itemAt(i)) {
                    taskRepeater.itemAt(i).updateHoverColor();
                }
            }
            tasks.state = "";
            //console.log("Updated hovers");
        }
        function updateHoverSizes() {
            for(var i = 0; i < taskRepeater.count; i++) {
                if(taskRepeater.itemAt(i)) {
                    taskRepeater.itemAt(i).updateHoverSize();
                }
            }
            tasks.state = "";
            //console.log("Updated hovers");
        }

        Timer {
            id: layoutTimer

            interval: 0
            repeat: false

            onTriggered: taskList.layout()
        }


        Repeater {
            id: taskRepeater
            
            delegate: Task { id: task }
            onItemAdded: {
                taskList.layout();
                taskList.updateHoverFunc();
            }
            onItemRemoved: {
                if (tasks.containsMouse && index != taskRepeater.count &&
                    item.winIdList && item.winIdList.length > 0 &&
                    taskClosedWithMouseMiddleButton.indexOf(item.winIdList[0]) > -1) {
                    needLayoutRefresh = true;
                } else {
                    taskList.layout();
                }
                taskClosedWithMouseMiddleButton = [];
                taskList.updateHoverFunc();
            }
            
        }
    }

    GroupDialog { id: groupDialog }
    function hasLauncher(url) {
        return tasksModel.launcherPosition(url) != -1;
    }

    function addLauncher(url) {
        if (plasmoid.immutability !== PlasmaCore.Types.SystemImmutable) {
            tasksModel.requestAddLauncher(url);
        }
    }

    // This is called by plasmashell in response to a Meta+number shortcut.
    function activateTaskAtIndex(index) {
        if (typeof index !== "number") {
            return;
        }

        var task = taskRepeater.itemAt(index);
        if (task) {
            TaskTools.activateTask(task.modelIndex(), task.m, null, task);
        }
    }

    function resetDragSource() {
        dragSource = null;
    }

    function createTasksMenu(rootTask, modelIndex, args) {
        var initialArgs = args || {}
        initialArgs.visualParent = rootTask;
        initialArgs.modelIndex = modelIndex;
        initialArgs.mpris2Source = mpris2Source;
        initialArgs.backend = backend;

        return tasks.tasksMenuComponent.createObject(rootTask, initialArgs);
    }
    function createContextMenu(rootTask, modelIndex, args) {
        var initialArgs = args || {}
        initialArgs.visualParent = rootTask;
        initialArgs.modelIndex = modelIndex;
        initialArgs.mpris2Source = mpris2Source;
        initialArgs.backend = backend;

        return tasks.contextMenuComponent.createObject(rootTask, initialArgs);
    }

    Component.onCompleted: {
        plasmoid.setAction("taskman", i18n("Task Manager")); // Add a context menu entry to SevenTasks.
        function action_taskman() {
            menu_executable.exec("ksysguard");
        }
        tasks.requestLayout.connect(layoutTimer.restart);
        tasks.requestLayout.connect(iconGeometryTimer.restart);
        tasks.windowsHovered.connect(backend.windowsHovered);
        //tasks.presentWindows.connect(backend.presentWindows);
        tasks.activateWindowView.connect(backend.activateWindowView);
        dragHelper.dropped.connect(resetDragSource);
        taskList.updateHoverFunc();
    }
}
