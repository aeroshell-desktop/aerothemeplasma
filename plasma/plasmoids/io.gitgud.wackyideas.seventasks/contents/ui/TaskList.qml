/*
    SPDX-FileCopyrightText: 2012-2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasmoid 2.0
import "code/layoutmetrics.js" as LayoutMetrics
import QtQuick.Shapes 1.7

ListView {
    property bool animating: false

    layoutDirection: (Plasmoid.configuration.reverseMode && !tasks.vertical)
        ? (Qt.application.layoutDirection === Qt.LeftToRight)
            ? Qt.RightToLeft
            : Qt.LeftToRight
        : Qt.application.layoutDirection

    boundsBehavior: Flickable.StopAtBounds
    rebound: Transition {}
    clip: true
    interactive: false
    cacheBuffer: 9999
    spacing: 2
    readonly property int transitionDuration: 200
    property alias taskAnimation: taskAnimation
    property alias resetTransition: resetTransition
    property alias resetAddTransition: resetAddTransition
    Timer {
        id: resetTransition
        interval: transitionDuration+50
        onTriggered: {
            taskList.displaced = taskList.taskAnimation;
        }
    }
    Timer {
        id: resetAddTransition
        interval: 100
        onTriggered: {
            taskList.add = addAnimation;
        }
    }

    Transition {
        id: taskAnimation
        NumberAnimation {
            properties: "x,y,width,height"
            easing.type: Easing.OutQuad
            duration: transitionDuration
        }
    }
    //populate: taskAnimation
    move: taskAnimation
    /*removeDisplaced: Transition {
        NumberAnimation {
            properties: "x,y,width,height"
            easing.type: Easing.OutQuad
            duration: transitionDuration
        }
    }
    moveDisplaced: Transition {
        NumberAnimation {
            properties: "x,y,width,height"
            easing.type: Easing.OutQuad
            duration: transitionDuration
        }
    }
    addDisplaced: Transition {
        NumberAnimation {
            properties: "x,y,width,height"
            easing.type: Easing.OutQuad
            duration: transitionDuration
        }
    }*/
    displaced: taskAnimation
    remove: Transition {
            NumberAnimation { properties: tasks.iconsOnly ? "opacity" : ""; to: 0; duration: transitionDuration; easing.type: Easing.OutQuad; }
    }
    Transition {
        id: addAnimation
        ParallelAnimation {
            NumberAnimation { property: tasks.iconsOnly ? "" : "implicitWidth"; duration: transitionDuration; easing.type: Easing.OutQuad; }
            NumberAnimation { property: tasks.iconsOnly ? "opacity" : ""; from: 0; to: 1; duration: transitionDuration; easing.type: Easing.OutQuad; }
        }
    }
    add: addAnimation
    populate: addAnimation


    property int scrollIndex: 0
    KSvg.FrameSvgItem {
        id: scrollLeft
        imagePath: Qt.resolvedUrl("svgs/scroll.svg");
        prefix: "normal"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Kirigami.Units.gridUnit-1
        visible: !taskList.atXBeginning;

        Shape {
            width: 4
            height: 7
            anchors.centerIn: parent
            ShapePath {
                strokeWidth: 0
                fillColor: {
                    if(scrollLeftMA.containsPress) return "#404040";
                    else if(scrollLeftMA.containsMouse) return "#808080";
                    else return "white"
                }

                startX: 4; startY: 0
                PathLine { x: 4; y: 8 }
                PathLine { x: 0; y: 4 }
                PathLine { x: 4; y: 0 }
            }
        }
        MouseArea {
            id: scrollLeftMA
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                scrollIndex = taskList.indexAt(scrollLeft.x + taskList.contentX - 1, scrollLeft.y + Kirigami.Units.mediumSpacing);
                if(scrollIndex < 0) scrollIndex = 0;
                taskList.positionViewAtIndex(scrollIndex, ListView.Beginning);
                tasks.publishIconGeometries(taskList);
            }
        }
    }
    KSvg.FrameSvgItem {
        id: scrollRight
        imagePath: Qt.resolvedUrl("svgs/scroll.svg");
        prefix: "normal"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Kirigami.Units.gridUnit-1
        visible: !taskList.atXEnd;

        Shape {
            width: 4
            height: 7
            anchors.centerIn: parent
            ShapePath {
                fillColor: {
                    if(scrollRightMA.containsPress) return "#404040";
                    else if(scrollRightMA.containsMouse) return "#808080";
                    else return "white"
                }
                startX: 0; startY: 0
                PathLine { x: 0; y: 8 }
                PathLine { x: 4; y: 4 }
                PathLine { x: 0; y: 0 }
            }
        }
        MouseArea {
            id: scrollRightMA
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                scrollIndex = taskList.indexAt(scrollRight.x + scrollRight.width + 1 + taskList.contentX, scrollRight.y + Kirigami.Units.mediumSpacing);
                if(scrollIndex >= tasksModel.count) scrollIndex = tasksModel.count-1;
                taskList.positionViewAtIndex(scrollIndex, ListView.End);
                tasks.publishIconGeometries(taskList);
            }
        }
    }
    //property int animationsRunning: 0
    //onAnimationsRunningChanged: animating = animationsRunning > 0
    property real minimumWidth: {
        let min = Infinity;
        for (let item of children) {
            if (item.visible && item.width > 0 && item.width < min) {
                min = item.width;
            }
        }
        return min;
    }

    readonly property int stripeCount: {
        if (tasks.Plasmoid.configuration.maxStripes == 1) {
            return 1;
        }

        // The maximum number of stripes allowed by the applet's size
        const stripeSizeLimit = tasks.vertical
            ? Math.floor(tasks.width / children[0].implicitWidth)
            : Math.floor(tasks.height / children[0].implicitHeight)
        const maxStripes = Math.min(tasks.Plasmoid.configuration.maxStripes, stripeSizeLimit)

        if (tasks.Plasmoid.configuration.forceStripes) {
            return maxStripes;
        }

        // The number of tasks that will fill a "stripe" before starting the next one
        const maxTasksPerStripe = tasks.vertical
            ? Math.ceil(tasks.height / LayoutMetrics.preferredMinHeight())
            : Math.ceil(tasks.width / LayoutMetrics.preferredMinWidth())

        return Math.min(Math.ceil(tasksModel.count / maxTasksPerStripe), maxStripes)
    }

    readonly property int orthogonalCount: {
        return Math.ceil(tasksModel.count / stripeCount);
    }

    //rows: tasks.vertical ? orthogonalCount : stripeCount
    //columns: tasks.vertical ? stripeCount : orthogonalCount
}
