import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kwindowsystem

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

MouseArea {
    id: groupThumbnails

    property QtObject root

    readonly property bool isList: (196 * thumbnailModel.count) > tasks.availableScreenRect.width
    readonly property bool containsDrag: root.containsDrag
    readonly property bool isOverflowing: thumbnailList.listHeight > tasks.availableScreenRect.height

    readonly property alias thumbnailHeight: thumbnailList.maxThumbnailHeight

    implicitWidth: (isList ? thumbnailList.maxThumbnailWidth : thumbnailList.listWidth)
    implicitHeight: (isList ? (isOverflowing ? tasks.availableScreenRect.height : thumbnailList.listHeight) : thumbnailList.maxThumbnailHeight) + (isOverflowing ? 0 : scrollView.anchors.topMargin + scrollView.anchors.bottomMargin)

    hoverEnabled: true
    propagateComposedEvents: true

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
        }
    }

    QQC2.ScrollView {
        id: scrollView

        anchors.fill: parent
        anchors.bottomMargin: !isList ? 0 : Kirigami.Units.smallSpacing*2
        anchors.topMargin: !isList ? 0 : Kirigami.Units.smallSpacing*2
        anchors.leftMargin: 0
        anchors.rightMargin: 0

        rightPadding: QQC2.ScrollBar.vertical.visible ? QQC2.ScrollBar.vertical.width : 0

        ListView {
            id: thumbnailList

            // check for null to get rid of null errors in console
            property int maxThumbnailWidth: maxThumbnailItem == null ? 0 : maxThumbnailItem.implicitWidth
            property int maxThumbnailHeight: maxThumbnailItem == null ? 0 : maxThumbnailItem.implicitHeight
            property Item maxThumbnailItem

            property int listWidth: contentWidth == 0 ? 196 : contentWidth
            property int listHeight: contentHeight == 0 ? 142 : contentHeight

            function updateMaxSize() {
                var thumbnailItem = itemAtIndex(0);
                if(thumbnailItem !== null) {
                    if(isList) {
                        for(var i = 0; i < thumbnailList.count; i++) {
                            thumbnailItem = itemAtIndex(i);
                            if(thumbnailItem) {
                                if(thumbnailItem.implicitWidth >= thumbnailList.maxThumbnailWidth)
                                    thumbnailList.maxThumbnailItem = thumbnailItem;
                            }
                        }
                    }
                    else {
                        if(KWindowSystem.isPlatformWayland) maxThumbnailItem = null;
                        for(var i = 0; i < thumbnailList.count; i++) {
                            thumbnailItem = itemAtIndex(i);
                            if(thumbnailItem) {
                                if(thumbnailItem.implicitHeight >= thumbnailList.maxThumbnailHeight)
                                    thumbnailList.maxThumbnailItem = thumbnailItem;

                            }
                        }
                    }
                }
            }

            interactive: false
            spacing: -Kirigami.Units.smallSpacing*4 + 2
            orientation: !isList ? ListView.Horizontal : ListView.Vertical
            model: !isList ? thumbnailModel : listModel
            clip: true

            // HACK: delay the update by 15 ms to leave time for the thumbnail item's implicitHeight/implicitWidth property to correct itself
            onCountChanged: if(count > 1) updateDelayTimer.start()

            Timer {
                id: updateDelayTimer

                interval: 15
                repeat: false
                triggeredOnStart: false
                onTriggered: thumbnailList.updateMaxSize();
            }
        }
    }
}
