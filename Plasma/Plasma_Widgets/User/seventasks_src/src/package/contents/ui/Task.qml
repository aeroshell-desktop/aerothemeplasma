/*
    SPDX-FileCopyrightText: 2012-2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0

import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

import "code/layout.js" as LayoutManager
import "code/tools.js" as TaskTools
import QtGraphicalEffects 1.15


MouseArea {
    id: task
    
    width: groupDialog.contentWidth
    height: Math.max(theme.mSize(theme.defaultFont).height, PlasmaCore.Units.iconSizes.medium) + LayoutManager.verticalMargins()

    visible: true
    hoverEnabled: true
    preventStealing: true
    propagateComposedEvents: true
    z: 2
    LayoutMirroring.enabled: (Qt.application.layoutDirection == Qt.RightToLeft)
    LayoutMirroring.childrenInherit: (Qt.application.layoutDirection == Qt.RightToLeft)

    readonly property var m: model

    readonly property int pid: model.AppPid !== undefined ? model.AppPid : 0
    readonly property string appName: model.AppName
    readonly property variant winIdList: model.WinIdList
    property int itemIndex: index
    property bool inPopup: false
    property bool isWindow: model.IsWindow === true
    property int childCount: model.ChildCount !== undefined ? model.ChildCount : 0
    property int previousChildCount: 0
    property alias labelText: label.text
    property bool pressed: false
    property int pressX: -1
    property int pressY: -1
    property QtObject contextMenu: null // Pointer to the regular Qt context menu, which is no longer used (deprecated).
    property QtObject tasksMenu: null // Pointer to the reimplemented context menu.
    property int wheelDelta: 0
    readonly property bool smartLauncherEnabled: !inPopup && model.IsStartup !== true
    property QtObject smartLauncherItem: null
    property alias toolTipAreaItem: toolTipArea
    property alias audioStreamIconLoaderItem: audioStreamIconLoader
    // The dominant color of the task icon.
    property color hoverColor
    property real taskWidth: 0
    property real taskHeight: 0
    property string previousState: ""
    property bool rightClickDragging: false
    property bool toolTipOpen: false
    
    property Item audioStreamOverlay
    property var audioStreams: []
    property bool delayAudioStreamIndicator: false
    readonly property bool audioIndicatorsEnabled: plasmoid.configuration.indicateAudioStreams
    readonly property bool hasAudioStream: audioStreams.length > 0
    readonly property bool playingAudio: hasAudioStream && audioStreams.some(function (item) {
        return !item.corked
    })
    readonly property bool muted: hasAudioStream && audioStreams.every(function (item) {
        return item.muted
    })

    // This property determines when the task should be highlighted.
    // In the context of a task in a default state, it determines when hot tracking should be enabled.
    readonly property bool highlighted: (inPopup && activeFocus) || (!inPopup && ma.containsMouse)
        || (task.contextMenu && task.contextMenu.status === PlasmaComponents.DialogStatus.Open)
        || (groupDialog.visible && groupDialog.visualParent === task)
        
    
    onHighlightedChanged: {
        // ensure it doesn't get stuck with a window highlighted
        backend.cancelHighlightWindows();
    }

    // Unused so far.
    function closeTask() {
        closingAnimation.start();
    }
    function showToolTip() {
        toolTipArea.showToolTip();
    }
    function hideToolTipTemporarily() {
        toolTipArea.hideToolTip();
    }
    function updateHoverColor() {
        // Calls the C++ function which calculates the dominant color from the icon.
        hoverColor = plasmoid.nativeInterface.getDominantColor(icon.source);
        // When label visibility is toggled, that changes the size of each task item,
        // so we need to update the size of the hot tracking effect too.
        updateHoverSize();
        
    }
    function updateHoverSize() {
        hoverGradient.verticalRadius = LayoutManager.taskHeight();
        hoverGradient.horizontalRadius = LayoutManager.taskWidth();
    }

    // Updates the hot tracking gradient with the mouse position.
    function updateMousePosition(pos) {
        if(!model.IsStartup)
            hoverGradient.horizontalOffset = pos - hoverRect.width/2;
    }
    Behavior on opacity {
        NumberAnimation { duration: 250 }
    }


    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton | Qt.BackButton | Qt.ForwardButton

    onPidChanged: updateAudioStreams({delay: false})
    onAppNameChanged: updateAudioStreams({delay: false})

    onIsWindowChanged: {
        if (isWindow) {
            taskInitComponent.createObject(task);
        }
        hoverEnabled = true;
    }

    onChildCountChanged: {
        if (!childCount && groupDialog.visualParent == task) {
            groupDialog.visible = false;

            return;
        }

        if (containsMouse) {
            groupDialog.activeTask = null;
        }

        if (childCount > previousChildCount) {
            tasksModel.requestPublishDelegateGeometry(modelIndex(), backend.globalRect(task), task);
        }

        previousChildCount = childCount;
        hoverEnabled = true;
    }

    onItemIndexChanged: {
        hideToolTipTemporarily();

        if (!inPopup && !tasks.vertical
            && (LayoutManager.calculateStripes() > 1 || !plasmoid.configuration.separateLaunchers)) {
            tasks.requestLayout();
        }
        hoverEnabled = true;
        taskList.updateHoverFunc();
        toolTipArea.tooltipClicked = true;
    }

    onContainsMouseChanged:  {

        // Just in case
        if(tasksMenu !== null ) {
            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
        }
        if(taskList.firstTimeHover === false) {
            taskList.updateHoverFunc();
            taskList.firstTimeHover = true;
        }
        if (containsMouse) {
            if (inPopup) {
                forceActiveFocus();
            }
        } else {
            pressed = false;
            //if(!ma.pressed) tasks.dragSource = null;
        }
        hoverEnabled = true;

        updateMousePosition(ma.mouseX);
        toolTipArea.tooltipClicked = true;

    }

    onClicked: {
        if (mouse.button == Qt.RightButton && tasksMenu === null && !model.IsStartup) {
            // When we're a launcher, there's no window controls, so we can show all
            // places without the menu getting super huge.
            if (model.IsLauncher === true) {
                showContextMenu({showAllPlaces: true})
            } else {
                showContextMenu();
            }
            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
        }
    }
    onPressed: {

        if(tasksMenu !== null ) {
            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
        }
        if (mouse.button == Qt.LeftButton || mouse.button == Qt.MidButton || mouse.button === Qt.BackButton || mouse.button === Qt.ForwardButton) {
            pressed = true;
            pressX = mouse.x;
            pressY = mouse.y;
            
        }
        hoverEnabled = true;
    }

    onReleased: {

        if (pressed) {
            if (mouse.button == Qt.MidButton) {
                if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.NewInstance) {
                    hoverRect.state = "startup";
                    tasksModel.requestNewInstance(modelIndex());
                } else if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.Close) {
                    tasks.taskClosedWithMouseMiddleButton = winIdList.slice()
                    tasksModel.requestClose(modelIndex());
                } else if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.ToggleMinimized) {
                    tasksModel.requestToggleMinimized(modelIndex());
                } else if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.ToggleGrouping) {
                    tasksModel.requestToggleGrouping(modelIndex());
                } else if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.BringToCurrentDesktop) {
                    tasksModel.requestVirtualDesktops(modelIndex(), [virtualDesktopInfo.currentDesktop]);
                }
            } else if (mouse.button == Qt.LeftButton) {
                if (plasmoid.configuration.showToolTips && toolTipArea.active) {
                    hideToolTipTemporarily();
                }
                /*if(childCount >= 2 && plasmoid.configuration.showToolTips && toolTipArea.active) {
                    toolTipArea.tooltipClicked = !toolTipArea.tooltipClicked;
                }*/
                TaskTools.activateTask(modelIndex(), model, mouse.modifiers, task);

            } else if (mouse.button === Qt.BackButton || mouse.button === Qt.ForwardButton) {
                var sourceName = mpris2Source.sourceNameForLauncherUrl(model.LauncherUrlWithoutIcon, model.AppPid);
                if (sourceName) {
                    if (mouse.button === Qt.BackButton) {
                        mpris2Source.goPrevious(sourceName);
                    } else {
                        mpris2Source.goNext(sourceName);
                    }
                } else {
                    mouse.accepted = false;
                }
            }

            backend.cancelHighlightWindows();
        }

        pressed = false;
        pressX = -1;
        pressY = -1;
        hoverEnabled = true;
        rightClickDragging = false;
    }
    
    onPressAndHold: {
    }
    onPositionChanged: { //hoverEnabled: true, but this event still doesn't fire at all
                         //unless i am pressing the left mouse button for a short period of time

        if(tasksMenu !== null) {
            plasmoid.nativeInterface.setMouseGrab(true, tasksMenu);
        }
        if(mouse.buttons == Qt.RightButton) {
            rightClickDragging = true;
        }
        else if (pressX != -1 && mouse.buttons == Qt.LeftButton && dragHelper.isDrag(pressX, pressY, mouse.x, mouse.y)) {
            
            tasks.dragSource = task;
            dragHelper.startDrag(task, model.MimeType, model.MimeData,
                model.LauncherUrlWithoutIcon, model.decoration);
            pressX = -1;
            pressY = -1;
            return;
        }
        else
        {
            tasks.dragSource = null;
        }
        
        //code for dragging the task around
        
    }

    onWheel: {
        if (plasmoid.configuration.wheelEnabled && (!inPopup || !groupDialog.overflowing)) {
            wheelDelta = TaskTools.wheelActivateNextPrevTask(task, wheelDelta, wheel.angleDelta.y);
        } else {
            wheel.accepted = false;
        }
    }

    onSmartLauncherEnabledChanged: {
        if (smartLauncherEnabled && !smartLauncherItem) {
            var smartLauncher = Qt.createQmlObject("
    import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet;
    TaskManagerApplet.SmartLauncherItem { }", task);

            smartLauncher.launcherUrl = Qt.binding(function() { return model.LauncherUrlWithoutIcon; });

            smartLauncherItem = smartLauncher;
        }
    }

    onHasAudioStreamChanged: {
        audioStreamIconLoader.active = hasAudioStream && audioIndicatorsEnabled;
    }

    onAudioIndicatorsEnabledChanged: {
        audioStreamIconLoader.active = hasAudioStream && audioIndicatorsEnabled;
    }

    Keys.onReturnPressed: TaskTools.activateTask(modelIndex(), model, event.modifiers, task)
    Keys.onEnterPressed: Keys.onReturnPressed(event);

    function modelIndex() {
        return (inPopup ? tasksModel.makeModelIndex(groupDialog.visualParent.itemIndex, index)
            : tasksModel.makeModelIndex(index));
    }

    function showContextMenu(args) {
        toolTipArea.hideImmediately();
        tasksMenu = tasks.createTasksMenu(task, modelIndex(), args);
        tasksMenu.menuDecoration = model.decoration;
        tasksMenu.show();

        //contextMenu = tasks.createContextMenu(task, modelIndex(), args);
        //contextMenu.show();
    }

    function updateAudioStreams(args) {
        if (args) {
            // When the task just appeared (e.g. virtual desktop switch), show the audio indicator
            // right away. Only when audio streams change during the lifetime of this task, delay
            // showing that to avoid distraction.
            delayAudioStreamIndicator = !!args.delay;
        }

        var pa = pulseAudio.item;
        if (!pa) {
            task.audioStreams = [];
            return;
        }

        var streams = pa.streamsForPid(task.pid);
        if (streams.length) {
            pa.registerPidMatch(task.appName);
        } else {
            // We only want to fall back to appName matching if we never managed to map
            // a PID to an audio stream window. Otherwise if you have two instances of
            // an application, one playing and the other not, it will look up appName
            // for the non-playing instance and erroneously show an indicator on both.
            if (!pa.hasPidMatch(task.appName)) {
                streams = pa.streamsForAppName(task.appName);
            }
        }

        task.audioStreams = streams;
    }

    function toggleMuted() {
        if (muted) {
            task.audioStreams.forEach(function (item) { item.unmute(); });
        } else {
            task.audioStreams.forEach(function (item) { item.mute(); });
        }
    }

    Connections {
        target: pulseAudio.item
        ignoreUnknownSignals: true // Plasma-PA might not be available
        function onStreamsChanged() { 
            task.updateAudioStreams({delay: true})
        }
    }
    Component {
        id: taskInitComponent

        Timer {
            id: timer

            interval: PlasmaCore.Units.longDuration
            repeat: false

            onTriggered: {
                //parent.hoverEnabled = true;
                if (parent.isWindow) {
                    tasksModel.requestPublishDelegateGeometry(parent.modelIndex(),
                        backend.globalRect(parent), parent);
                }
                timer.destroy();
            }

            Component.onCompleted: { 
                
                taskList.updateHoverFunc();
                timer.start();
            }
        }
    }
    NumberAnimation {
        id: closingAnimation
        target: frame
        properties: "opacity"
        from: 1
        to: 0
        duration: 200
        
        onRunningChanged: { if(!closingAnimation.running) {
            opacity: 1;
            //tasksModel.requestClose(modelIndex());
        }
        }
    }
    PlasmaCore.FrameSvgItem {
        id: frame
        z: -1
        anchors {
            fill: parent

            topMargin: (!tasks.vertical && taskList.rows > 1) ? PlasmaCore.Units.smallSpacing / 4 : 0
            bottomMargin: (!tasks.vertical && taskList.rows > 1) ? PlasmaCore.Units.smallSpacing / 4 : 0
            leftMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4 : PlasmaCore.Units.smallSpacing / 4
            rightMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4 : PlasmaCore.Units.smallSpacing / 4
        }
        PlasmaCore.FrameSvgItem {
            id: stackFirst
            z: 2
            imagePath: Qt.resolvedUrl("svgs/tasks.svg")
            anchors.fill: parent
            visible: frame.basePrefix != "active-tab"
            opacity: {
                if(childCount == 0) return 1;
                else if(childCount == 2) return 0.6;
                else return 0.25;
            }
            //imagePath: (frame.isHovered && frame.basePrefix === "active-tab") ? "widgets/tabbar" : "widgets/tasks"
            prefix: childCount == 0 ? frame.prefix : TaskTools.taskPrefix("stacked+" + ((pressed) ? "focus" : frame.basePrefix));
        }
        PlasmaCore.FrameSvgItem {
            id: stackSecond
            imagePath: Qt.resolvedUrl("svgs/tasks.svg")
            prefix: frame.prefix
            anchors.fill: parent
            opacity: 1
            visible: childCount >= 2 ? true : false
            anchors.rightMargin: PlasmaCore.Units.smallSpacing * (childCount >= 3 ? 2 : 1.2);
        }
        PlasmaCore.FrameSvgItem {
            id: stackThird
            imagePath: Qt.resolvedUrl("svgs/tasks.svg")
            prefix: TaskTools.taskPrefix("stacked+" + ((pressed) ? "focus" : frame.basePrefix))
            anchors.fill: parent
            opacity: 0.6
            visible: childCount >= 3 ? true : false
            anchors.rightMargin: PlasmaCore.Units.smallSpacing
            enabledBorders: PlasmaCore.FrameSvg.RightBorder
            
        }
        Rectangle {
            id: contrastRect
            anchors {
                fill: parent
                topMargin: (!tasks.vertical && taskList.rows > 1) ? PlasmaCore.Units.smallSpacing / 4 +1 : 1
                bottomMargin: (!tasks.vertical && taskList.rows > 1) ? PlasmaCore.Units.smallSpacing / 4+1 : 1
                leftMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4+1 : 1
                rightMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4+1 : 1
            }
            visible: !iconsOnly && frame.basePrefix != "active-tab"
            color: "#22000000";

        }
        LinearGradient {
            
            id: highlightGradient
            opacity: (pressed && frame.isHovered && frame.basePrefix === "active-tab") ? 1 : 0
            
            anchors.fill: parent
            anchors.leftMargin: 3
            anchors.rightMargin: 3
            anchors.topMargin: 2
            
            start: Qt.point(3, 3)
            end: Qt.point(3, parent.height-3)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000"; }
                GradientStop { position: 0.5; color: "#66000000"; }
                GradientStop { position: 1.0; color: "#00000000"; }
            } 
        }

        imagePath: (frame.isHovered && frame.basePrefix === "active-tab") ? Qt.resolvedUrl("svgs/tabbar.svgz") : ""//"widgets/tasks"
        property bool isHovered: task.highlighted && plasmoid.configuration.taskHoverEffect && !rightClickDragging
        property string basePrefix: "normal"
        //prefix: isHovered ? (TaskTools.taskPrefixHovered(basePrefix)) : TaskTools.taskPrefix(basePrefix)
        //prefix: TaskTools.taskPrefix(basePrefix)
        prefix: {
            if(model.IsStartup || tasksMenu !== null) return TaskTools.taskPrefix("focus");
            if((pressed) && frame.basePrefix != "active-tab") return TaskTools.taskPrefix("focus");
            else if(isHovered && (basePrefix === "normal" || basePrefix === "minimized")) { return TaskTools.taskPrefix("hover"); }
            else return TaskTools.taskPrefix(basePrefix);
        }
        //prefix: ((pressed) && frame.basePrefix != "active-tab") ? TaskTools.taskPrefix("focus") :  TaskTools.taskPrefix(basePrefix)

        Rectangle {
            id: hoverRect
            
        anchors {
            fill: parent

            topMargin: (!tasks.vertical && taskList.rows > 1) ? PlasmaCore.Units.smallSpacing / 4 +1 : 1
            bottomMargin: (!tasks.vertical && taskList.rows > 1) ? PlasmaCore.Units.smallSpacing / 4+1 : 1
            leftMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4+1 : 1
            rightMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4+1 : 1
        }
        z: -5
        clip: true
            states: [
            State {
                        name: "startup"; when: (model.IsStartup === true)
                        
                        PropertyChanges { target: hoverRect; opacity: 1}
                        StateChangeScript {
                    script:  { 
                        if(previousState === "startup") {
                            hoverGradient.verticalRadius = LayoutManager.taskHeight();
                            hoverGradient.horizontalRadius = LayoutManager.taskWidth();
                        }
                        previousState = "startup";
                        //console.log("\nTurned to startup state\n" + previousState);
                    }
                }
                        
                    },
                    State {
                        name: "startup-finished"; when: (model.IsStartup === false)
                        
                        PropertyChanges { target: hoverRect; opacity: 1}
                        StateChangeScript {
                    script:  { 
                        if(previousState === "startup") {
                            hoverGradient.verticalRadius = LayoutManager.taskHeight();
                            hoverGradient.horizontalRadius = LayoutManager.taskWidth();
                        }
                        previousState = "startup";
                    }
                }
                        
                    },
            State {
                name: "mouse-over"; when: ((frame.isHovered && frame.basePrefix != "active-tab"))
                PropertyChanges { target: hoverRect; opacity: 1}
                StateChangeScript {
                    script:  { 
                        if(previousState === "startup") {
                            hoverGradient.verticalRadius = LayoutManager.taskHeight();
                            hoverGradient.horizontalRadius = LayoutManager.taskWidth();
                        }
                        previousState = "mouse-over";
                        //console.log("\nTurned to mouseover state\n" + previousState);
                    }
                }
                 
            },
            State {
                name: ""; 
                PropertyChanges { target: hoverRect; opacity: 0 }
                StateChangeScript {
                    script:  { 
                        if(previousState === "startup") {
                            hoverGradient.verticalRadius = LayoutManager.taskHeight();
                            hoverGradient.horizontalRadius = LayoutManager.taskWidth();
                        }
                        previousState = "";
                        //console.log("\nTurned to default state\n" + previousState);
                    }
                }
            }
            ]
            transitions: [ Transition {
                from: "*"; to: "*";
                NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 250 }
            },
                Transition {
                from: "*"; to: "startup";
                NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 250 }
                SequentialAnimation {
                    id: horizRad
                    NumberAnimation  {
                        id: horizRad1
                        target: hoverGradient
                        property: "horizontalRadius"
                        from: 0; to: LayoutManager.taskWidth();//task.height + taskFrame.margins.left + taskFrame.margins.right;
                        easing.type: Easing.OutQuad; duration: 400
                }
                /*NumberAnimation  {
                        id: horizRad11
                        target: hoverGradient
                        property: "horizontalRadius"
                        from: LayoutManager.taskWidth(); to: LayoutManager.taskWidth();//task.height + taskFrame.margins.left + taskFrame.margins.right;
                        easing.type: Easing.Linear; duration: 
                }*/
                NumberAnimation  {
                        id: horizRad2
                        target: hoverGradient
                        property: "horizontalRadius"
                        //to: 0;
                        from: LayoutManager.taskWidth()/*task.height + taskFrame.margins.left + taskFrame.margins.right*/; to: 0;
                        easing.type: Easing.InQuad; duration: 550
                }
                NumberAnimation  {
                        id: horizRad3
                        target: hoverGradient
                        property: "horizontalRadius"
                        //to: 0;
                        from: 0; to: 0; //LayoutManager.taskWidth()/*task.height + taskFrame.margins.left + taskFrame.margins.right*/; to: 0;
                        easing.type: Easing.Linear; duration: 3600
                }
                NumberAnimation {
                        id: frameOpacity
                        target: task
                        property: "opacity"
                        from: 1; to: 0;
                        easing.type: Easing.OutCubic; duration: 650
                }
                //loops: 3
                }
                
                 SequentialAnimation {
                    id: vertiRad
                    NumberAnimation  {
                        id: vertiRad1
                        target: hoverGradient
                        property: "verticalRadius"
                        from: 0; to: LayoutManager.taskHeight();
                        easing.type: Easing.OutQuad; duration: 400
                }
                /*NumberAnimation  {
                        id: vertiRad11
                        target: hoverGradient
                        property: "verticalRadius"
                        from: LayoutManager.taskHeight(); to: LayoutManager.taskHeight();
                        easing.type: Easing.Linear; duration: 50
                }*/
                NumberAnimation  {
                        id: vertiRad2
                        target: hoverGradient
                        property: "verticalRadius"
                        from: LayoutManager.taskHeight(); to: 0;
                        easing.type: Easing.InQuad; duration: 550
                }
                NumberAnimation  {
                        id: vertiRad3
                        target: hoverGradient
                        property: "verticalRadius"
                        from: 0; to: 0;
                        easing.type: Easing.Linear; duration: 1250
                }
                NumberAnimation  {
                        id: hoverBorder
                        target: hoverRect
                        property: "opacity"
                        from: 1; to: 0;
                        easing.type: Easing.Linear; duration: 550
                }
                //loops: 3
                }
                 
            } ] 
            opacity: 0//(frame.isHovered && frame.basePrefix != "") ? 1.0 : 0
            color: "#00000000"
            Rectangle {
                id: borderRect
                anchors {
                    fill: parent
                    topMargin: (!tasks.vertical && taskList.rows > 1) ? PlasmaCore.Units.smallSpacing / 4 : 0
                    bottomMargin: (!tasks.vertical && taskList.rows > 1) ? PlasmaCore.Units.smallSpacing / 4 : 0
                    leftMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4 : 0
                    rightMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4 : 0
                }
                z: -5
                border.color: Qt.rgba(hoverColor.r, hoverColor.g, hoverColor.b, 0.4);
                //border.color: Qt.tint(hoverColor, "#22777777")
                border.width: 2
                radius: 2
                color: "#00000000"
            }

            RadialGradient { 
                id: hoverGradient
                z: -3
                  anchors {
                fill: parent
                topMargin: -2 * PlasmaCore.Units.smallSpacing
                leftMargin: -2 * PlasmaCore.Units.smallSpacing
                bottomMargin: -2 * PlasmaCore.Units.smallSpacing
                rightMargin: -2 * PlasmaCore.Units.smallSpacing
                /*topMargin: (!tasks.vertical && taskList.rows > 1) ? -PlasmaCore.Units.smallSpacing / 4 : 0
                bottomMargin: (!tasks.vertical && taskList.rows > 1) ? -PlasmaCore.Units.smallSpacing / 4 : 0
                leftMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? PlasmaCore.Units.smallSpacing / 4 : 0
                rightMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? -PlasmaCore.Units.smallSpacing / 4 : 0*/
                }
                gradient: Gradient {
                    id: radialGrad
                    GradientStop { position: 0.0; color: Qt.tint(hoverColor, "#CFF8F8F8") }
                    GradientStop { position: 0.4; color: Qt.rgba(hoverColor.r, hoverColor.g, hoverColor.b, 0.75) }
                    //GradientStop { position: 0.4; color: Qt.tint(hoverColor, "#55AAAAAA") }
                    GradientStop { position: 0.85; color: Qt.rgba(hoverColor.r, hoverColor.g, hoverColor.b, 0.2) }
                }
                verticalOffset: hoverRect.height/2.2
                horizontalOffset: 0
            
                
                //hoverGradient.horizontalOffset = task.mouseX - hoverRect.width/2
                 
            }
            
            Blend {
                anchors.fill: borderRect
                source: borderRect
                foregroundSource: hoverGradient
                mode: "addition"
            }
            //z: -1
             
        }
        PlasmaCore.ToolTipArea {
            id: toolTipArea
            z: -1

            MouseArea {
               id: ma
               hoverEnabled: true
    	       propagateComposedEvents: true
               anchors.fill: parent
               onPositionChanged: {
                   task.updateMousePosition(ma.mouseX);
                   task.positionChanged(mouse);
               }
               onContainsMouseChanged: {
                    task.updateMousePosition(ma.mouseX);
               }
               onPressed: mouse.accepted = false;
               onReleased: mouse.accepted = false;
               onWheel: wheel.accepted = false;
            }
            anchors.fill: parent
            location: plasmoid.location
            property bool tooltipClicked: true
            active: !inPopup && !groupDialog.visible && (plasmoid.configuration.showToolTips || tasks.toolTipOpenedByClick === toolTipArea)
            interactive: model.IsWindow === true

            mainItem: (model.IsWindow === true) ? openWindowToolTipDelegate : pinnedAppToolTipDelegate
            property alias mainToolTip: toolTipArea.mainItem
            onToolTipVisibleChanged: {
                task.toolTipOpen = toolTipVisible;
                if(!toolTipVisible) {
                    tasks.toolTipOpenedByClick = null;
                } else {
                    tasks.toolTipAreaItem = toolTipArea;
                }

            }
            onContainsMouseChanged:  {
                updateMousePosition(ma.mouseX);
                if (containsMouse) {
                    mainItem.parentTask = task;
                    mainItem.rootIndex = tasksModel.makeModelIndex(itemIndex, -1);

                    /*mainItem.isWindowActive = Qt.binding(function() {
                        return false;
                    });*/
                    mainItem.appName = Qt.binding(function() {
                        return model.AppName;
                    });
                    mainItem.pidParent = Qt.binding(function() {
                        return model.AppPid !== undefined ? model.AppPid : 0;
                    });
                    mainItem.windows = Qt.binding(function() {
                        return model.WinIdList;
                    });
                    mainItem.isGroup = Qt.binding(function() {
                        return model.IsGroupParent === true;
                    });
                    mainItem.icon = Qt.binding(function() {
                        return model.decoration;
                    });
                    mainItem.launcherUrl = Qt.binding(function() {
                        return model.LauncherUrlWithoutIcon;
                    });
                    mainItem.isLauncher = Qt.binding(function() {
                        return model.IsLauncher === true;
                    });
                    mainItem.isMinimizedParent = Qt.binding(function() {
                        return model.IsMinimized === true;
                    });
                    mainItem.displayParent = Qt.binding(function() {
                        return model.display;
                    });
                    mainItem.genericName = Qt.binding(function() {
                        return model.GenericName;
                    });
                    mainItem.virtualDesktopParent = Qt.binding(function() {
                        return (model.VirtualDesktops !== undefined && model.VirtualDesktops.length > 0) ? model.VirtualDesktops : [0];
                    });
                    mainItem.isOnAllVirtualDesktopsParent = Qt.binding(function() {
                        return model.IsOnAllVirtualDesktops === true;
                    });
                    mainItem.activitiesParent = Qt.binding(function() {
                        return model.Activities;
                    });

                    mainItem.smartLauncherCountVisible = Qt.binding(function() {
                        return task.smartLauncherItem && task.smartLauncherItem.countVisible;
                    });
                    mainItem.smartLauncherCount = Qt.binding(function() {
                        return mainItem.smartLauncherCountVisible ? task.smartLauncherItem.count : 0;
                    });
                    tasks.toolTipAreaItem = toolTipArea;
                } else {
                    tasks.toolTipOpenedByClick = null;
                }
            }
        }
    }


    Loader {
        anchors.fill: frame
        asynchronous: true
        source: "TaskProgressOverlay.qml"
        active: task.isWindow && task.smartLauncherItem && task.smartLauncherItem.progressVisible
        z: -7
    }
    //TasksMenu {}
    Item {
        id: iconBox

        anchors {
            left: parent.left
            leftMargin: adjustMargin(true, parent.width, taskFrame.margins.left);
            top: parent.top
            topMargin: {
                if(parent.height <= 30) {
                    return parent.height / 2 - PlasmaCore.Units.iconSizes.small / 2;
                } else {
                    return adjustMargin(false, parent.height, taskFrame.margins.top);
                }}
        }

        width: height
        height: {
            if(parent.height <= 30) {
                return PlasmaCore.Units.iconSizes.small;
            } else {
                return (parent.height - adjustMargin(false, parent.height, taskFrame.margins.top) - adjustMargin(false, parent.height, taskFrame.margins.bottom));
            }
        }

        function adjustMargin(vert, size, margin) {
            if (!size) {
                return margin;
            }

            var margins = vert ? LayoutManager.horizontalMargins() : LayoutManager.verticalMargins();

            if ((size - margins) < PlasmaCore.Units.iconSizes.small) {
                return Math.ceil((margin * (PlasmaCore.Units.iconSizes.small / size)) / 2);
            }
            return margin;
        }

        //width: inPopup ? PlasmaCore.Units.iconSizes.small : Math.min(height, parent.width - LayoutManager.horizontalMargins())

        PlasmaCore.IconItem {
            id: icon

            anchors.fill: parent
            anchors.leftMargin: ((pressed) ? PlasmaCore.Units.smallSpacing / 5 : 0) - ((childCount > 0) ? PlasmaCore.Units.smallSpacing * ((childCount > 2) ? 2 : 1.2) : 0)
            anchors.topMargin: ((pressed) ? PlasmaCore.Units.smallSpacing / 5 : 0)

            //active: task.highlighted
            enabled: true
            usesPlasmaTheme: false

            source: model.decoration
            
            onSourceChanged: {
                //if(!icon.valid || icon.source == "" /*&& !model.IsLauncher && !model.IsStartup*/) icon.source = "application-x-executable";
               
                updateHoverColor();
            }
        }

        /*Loader {
            // QTBUG anchors.fill in conjunction with the Loader doesn't reliably work on creation:
            // have a window with a badge, move it from one screen to another, the new task item on the
            // other screen will now have a glitched out badge mask.
            width: parent.width
            height: parent.height
            asynchronous: true
            source: "TaskBadgeOverlay.qml"
            active: height >= PlasmaCore.Units.iconSizes.small
                    && task.smartLauncherItem && task.smartLauncherItem.countVisible
        }*/

        states: [
            // Using a state transition avoids a binding loop between label.visible and
            // the text label margin, which derives from the icon width.
            State {
                name: "standalone"
                when: !label.visible

                AnchorChanges {
                    target: iconBox
                    anchors.left: undefined
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                PropertyChanges {
                    target: iconBox
                    anchors.leftMargin: 0
                    width: parent.width - adjustMargin(true, task.width, taskFrame.margins.left)
                                        - adjustMargin(true, task.width, taskFrame.margins.right)
                }
            }
        ]

        /*Loader {
            anchors.fill: parent

            active: model.IsStartup === true
            sourceComponent: busyIndicator
        }

        Component {
            id: busyIndicator

            PlasmaComponents.BusyIndicator { anchors.fill: parent }
        }*/
    }

    Loader {
        id: audioStreamIconLoader

        readonly property bool shown: item && item.visible
        readonly property var indicatorScale: 1.2

        source: "AudioStream.qml"
        width: Math.min(Math.min(iconBox.width, iconBox.height) * 0.4, PlasmaCore.Units.iconSizes.smallMedium)
        height: width

        anchors {
            right: frame.right
            top: frame.top
            rightMargin: (iconsOnly && parent.height <= 30) ? PlasmaCore.Units.smallSpacing : taskFrame.margins.right
            topMargin: Math.round(taskFrame.margins.top * indicatorScale)
        }
     
    }

    PlasmaComponents.Label {
        id: label

        visible: (inPopup || !iconsOnly && model.IsLauncher !== true
            && (parent.width - iconBox.height - PlasmaCore.Units.smallSpacing) >= (theme.mSize(theme.defaultFont).width * LayoutManager.minimumMColumns()))

        anchors {
            fill: parent
            leftMargin: taskFrame.margins.left + iconBox.width + PlasmaCore.Units.smallSpacing
            topMargin: taskFrame.margins.top
            rightMargin: taskFrame.margins.right + (audioStreamIconLoader.shown ? (audioStreamIconLoader.width + PlasmaCore.Units.smallSpacing) : 0)
            bottomMargin: taskFrame.margins.bottom
        }

        text: model.display
        wrapMode: (maximumLineCount == 1) ? Text.NoWrap : Text.Wrap
        elide: Text.ElideRight
        textFormat: Text.PlainText
        verticalAlignment: Text.AlignVCenter
        maximumLineCount: plasmoid.configuration.maxTextLines || undefined
        style: Text.Outline
        styleColor: "#20404040"
        /*layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: parent
            source: parent
            verticalOffset: 1
            horizontalOffset: 1
            color: "#80000000"
            radius: 0
        }*/
    }

    states: [
        State {
            name: "launcher"
            when: model.IsLauncher === true

            PropertyChanges {
                target: frame
                basePrefix: "active-tab"
            }
        },
        State {
            name: "attention"
            when: model.IsDemandingAttention === true || (task.smartLauncherItem && task.smartLauncherItem.urgent)

            PropertyChanges {
                target: frame
                basePrefix: "attention"
            }
        },
        State {
            name: "minimized"
            when: model.IsMinimized === true

            PropertyChanges {
                target: frame
                basePrefix: "minimized"
            }
        },
        State {
            name: "active"
            when: model.IsActive === true

            PropertyChanges {
                target: frame
                basePrefix: "focus"
            }
        }
        
    ]

    Component.onCompleted: {
        /*if (!inPopup && model.IsWindow === true) {
            var component = Qt.createComponent("GroupExpanderOverlay.qml");
            component.createObject(task);
        }*/

        if (!inPopup && model.IsWindow !== true) {
            taskInitComponent.createObject(task);
        }
        taskList.updateHoverFunc();
        updateAudioStreams({delay: false});
        //toolTipArea.setBackgroundHints(2);
        
    }
}
