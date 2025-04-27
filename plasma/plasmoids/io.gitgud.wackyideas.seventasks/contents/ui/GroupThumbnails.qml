import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kwindowsystem

import org.kde.plasma.core as PlasmaCore

MouseArea {
    id: groupThumbnails

    property QtObject root

    readonly property alias bg: bg

    readonly property bool isList: thumbnailModel.count >= 8 || !Plasmoid.configuration.showPreviews
    readonly property bool compositionEnabled: root.compositionEnabled

    readonly property bool containsDrag: root.containsDrag

    readonly property alias thumbnailHeight: thumbnailList.maxThumbnailHeight

    implicitWidth: (isList || !compositionEnabled ? thumbnailList.maxThumbnailWidth : thumbnailList.listWidth) + thumbnailList.anchors.rightMargin + thumbnailList.anchors.leftMargin
    implicitHeight: (isList || !compositionEnabled ? thumbnailList.listHeight : thumbnailList.maxThumbnailHeight) + thumbnailList.anchors.topMargin + thumbnailList.anchors.bottomMargin

    hoverEnabled: true
    propagateComposedEvents: true

    KSvg.FrameSvgItem {
        id: bg

        anchors.fill: parent

        imagePath: Qt.resolvedUrl("svgs/tooltip.svg")

        visible: compositionEnabled
        z: -1
    }
    Rectangle {
        anchors.fill: parent

        color: "transparent"

        border.width: 1
        border.color: "#434d58"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1

            color: "#75869a"

            border.width: 1
            border.color: "#cad9ea"
        }

        visible: !compositionEnabled
        z: -1
    }

    Timer {
        interval: 200
        running: (!root.taskHovered && !groupThumbnails.containsMouse) && !root.dragDrop && !containsDrag
        onTriggered: root.destroy();
    }

    DelegateModel {
        id: thumbnailModel

        model: tasksModel
        rootIndex: tasksModel.makeModelIndex(root.taskIndex)
        delegate: WindowThumbnail {
            isGroupDelegate: true
            root: groupThumbnails.root
        }
    }
    DelegateModel {
        id: listModel

        model: tasksModel
        rootIndex: tasksModel.makeModelIndex(root.taskIndex)
        delegate: WindowListDelegate {
            root: groupThumbnails.root
            compositionEnabled: groupThumbnails.compositionEnabled
        }
    }

    ListView {
        id: thumbnailList

        property int maxThumbnailWidth: maxThumbnailItem.implicitWidth
        property int maxThumbnailHeight: maxThumbnailItem.implicitHeight
        property Item maxThumbnailItem

        property int listWidth: contentWidth == 0 ? 196 : contentWidth
        property int listHeight: contentHeight == 0 ? 142 : contentHeight

        anchors.fill: parent
        anchors.bottomMargin: !isList ? 0 : (compositionEnabled ? Kirigami.Units.smallSpacing*2 : 0)
        anchors.topMargin: !isList ? 0 : (compositionEnabled ? Kirigami.Units.smallSpacing*2 : 0)
        anchors.leftMargin: compositionEnabled ? 0 : Kirigami.Units.smallSpacing
        anchors.rightMargin: compositionEnabled ? 0 : Kirigami.Units.smallSpacing

        function updateMaxSize() {
            if(isList) {
                for(var i = 0; i < thumbnailList.count; i++) {
                    var thumbnailItem = itemAtIndex(i);
                    if(thumbnailItem.implicitWidth >= thumbnailList.maxThumbnailWidth)
                        thumbnailList.maxThumbnailItem = thumbnailItem;
                }
            }
            else {
                for(var i = 0; i < thumbnailList.count; i++) {
                    var thumbnailItem = itemAtIndex(i);
                    if(thumbnailItem.implicitHeight >= thumbnailList.maxThumbnailHeight)
                        thumbnailList.maxThumbnailItem = thumbnailItem;
                }
            }
        }

        interactive: false
        spacing: -Kirigami.Units.smallSpacing*4
        orientation: !isList ? (compositionEnabled ? ListView.Horizontal : ListView.Vertical) : ListView.Vertical
        model: !isList ? (compositionEnabled ? thumbnailModel : listModel) : listModel

        // HACK: delay the update by 5 ms to leave time for the thumbnail item's implicitHeight property to correct itself
        onCountChanged: if(count > 1) updateDelayTimer.start()

        Timer {
            id: updateDelayTimer

            interval: 5
            repeat: false
            triggeredOnStart: false
            onTriggered: thumbnailList.updateMaxSize();
        }
    }
}
