pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.pipewire as PipeWire
import org.kde.taskmanager as TaskManager
import org.kde.kwindowsystem

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mpris as Mpris

MouseArea {
    id: thumbnailRoot

    property QtObject root

    property bool isGroupDelegate: false
    readonly property var captionAlignment: {
        if(Plasmoid.configuration.thmbnlCaptionAlignment == 0) return Text.AlignLeft
        if(Plasmoid.configuration.thmbnlCaptionAlignment == 1) return Text.AlignHCenter
        if(Plasmoid.configuration.thmbnlCaptionAlignment == 2) return Text.AlignRight
    }

    readonly property var display: isGroupDelegate ? model.display : root.display
    readonly property var icon: isGroupDelegate ? model.decoration : root.icon
    readonly property var active: isGroupDelegate ? model.IsActive : root.active
    readonly property var modelIndex: isGroupDelegate ? (tasksModel.makeModelIndex(root.taskIndex, index)) : root.modelIndex
    readonly property var windows: isGroupDelegate ? model.WinIdList : root.windows
    readonly property var minimized: isGroupDelegate ? model.IsMinimized : root.minimized
    readonly property var demandsAttention: isGroupDelegate ? model.IsDemandingAttention : root.demandsAttention

    property int maxPreviewWidth: 164
    property int maxPreviewHeight: 94
    property real baselineAspectRatio: maxPreviewWidth / maxPreviewHeight

    property real thumbnailHeight: maxPreviewHeight

    readonly property int margins: Kirigami.Units.smallSpacing*8

    implicitWidth: maxPreviewWidth + margins
    implicitHeight: thumbnailHeight + margins +
        (tasks.iconsOnly ? header.height : 0) +
        (mprisControls.active ? (mprisControls.height - (Kirigami.Units.smallSpacing*2)) : 0)

    onImplicitHeightChanged: if(isGroupDelegate) {
        ListView.view.updateMaxSize()
    }

    width: implicitWidth
    height: {
        if(isGroupDelegate && ListView.view.maxThumbnailItem !== thumbnailRoot)
            return ListView.view.maxThumbnailHeight;
        else
            return implicitHeight;
    }

    hoverEnabled: true
    propagateComposedEvents: true

    Item {
        id: frames

        anchors.fill: content
        anchors.margins: -Kirigami.Units.smallSpacing*2

        KSvg.FrameSvgItem {
            id: attentionTexture

            anchors.fill: parent

            imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
            prefix: "attention"

            visible: demandsAttention
            opacity: root.parentTask.attentionAnimOpacity
        }

        KSvg.FrameSvgItem {
            id: activeTexture

            anchors.fill: parent

            imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
            prefix: "active"

            visible: active
        }

        KSvg.FrameSvgItem {
            id: hoverTexture

            anchors.fill: parent

            imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
            prefix: {
                if(contentMa.containsPress) return "pressed";
                else return "hover";
            }

            opacity: thumbnailCloseMa.containsMouse || contentMa.containsMouse || closeMa.containsMouse || (!tasks.iconsOnly && root.taskHovered && !isGroupDelegate)

            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }
        }
    }

    function closeTask() {
        tasksModel.requestClose(modelIndex);
        if(!isGroupDelegate) root.parentTask.hideImmediately();
    }
    DropArea {
        signal urlsDropped(var urls)

        anchors.fill: parent

        onPositionChanged: activationTimer.restart();
        onEntered: root.containsDrag = true;
        onExited: {
            activationTimer.stop();
            root.containsDrag = false;
        }
        onDropped: event => {
            if (event.hasUrls) {
                urlsDropped(event.urls);
                return;
            }
        }
        onUrlsDropped: (urls) => {
            tasksModel.requestOpenUrls(modelIndex, urls);
            root.containsDrag = false;
        }

        Timer {
            id: activationTimer

            interval: 250
            repeat: false

            onTriggered: tasksModel.requestActivate(modelIndex);
        }

        visible: isGroupDelegate
    }

    MouseArea {
        id: contentMa

        anchors.fill: content
        anchors.margins: -Kirigami.Units.smallSpacing*2

        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onContainsMouseChanged: {
            if(containsMouse) windowPeek.start();
            else {
                windowPeek.stop();
                root.isPeeking = false;
                tasks.windowsHovered(thumbnailRoot.windows, false)
            }
        }
        onClicked: (mouse) => {
            if(mouse.button == Qt.LeftButton) {
                tasksModel.requestActivate(modelIndex);
                tasks.windowsHovered(thumbnailRoot.windows, false)
                root.parentTask.hideImmediately();
            }
            if(mouse.button == Qt.MiddleButton) {
                thumbnailRoot.closeTask();
            }
        }
    }

    Timer {
        id: windowPeek

        interval: root.isPeeking ? 1 : 800
        repeat: false
        onTriggered: {
            if(!minimized) {
                tasks.windowsHovered(thumbnailRoot.windows, true);
                root.isPeeking = true;
            }
        }
    }

    ColumnLayout {
        id: content

        anchors.centerIn: parent
        anchors.verticalCenterOffset: mprisControls.active ? -(mprisControls.height / 4) - 2 : 0

        width: parent.width - margins
        height: parent.height - margins - (mprisControls.active ? (mprisControls.height - (Kirigami.Units.smallSpacing*2)) : 0)

        spacing: Kirigami.Units.smallSpacing/2

        RowLayout {
            id: header

            Layout.fillWidth: true
            Layout.minimumHeight: 16
            Layout.maximumHeight: 16

            spacing: Kirigami.Units.smallSpacing

            visible: tasks.iconsOnly

            Kirigami.Icon {
                Layout.preferredHeight: 16
                Layout.preferredWidth: 16

                source: icon
            }

            Text {
                id: txt
                Layout.fillWidth: true
                Layout.fillHeight: true

                verticalAlignment: Text.AlignVCenter
                text: display
                color: "white"
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                style: Text.Outline
                styleColor: "#02ffffff"
                horizontalAlignment: captionAlignment
                rightPadding: captionAlignment == Text.AlignHCenter ? (close.visible ? 0 : close.width + header.spacing) : 0
            }

            KSvg.FrameSvgItem {
                id: close

                Layout.preferredWidth: 14
                Layout.preferredHeight: 14

                imagePath: Qt.resolvedUrl("svgs/button-close.svg")
                prefix: closeMa.containsMouse ? (closeMa.containsPress ? "pressed" : "hover") : "normal"

                visible: opacity

                opacity: contentMa.containsMouse || closeMa.containsMouse

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }

                MouseArea {
                    id: closeMa

                    anchors.fill: parent

                    hoverEnabled: true
                    propagateComposedEvents: true

                    onClicked: {
                        thumbnailRoot.closeTask();
                    }
                }
            }
        }

        Item {
            id: thumbnail

            Layout.minimumWidth: thumbnailRoot.width - margins
            Layout.minimumHeight: thumbnailHeight
            Layout.fillHeight: true

            Loader {
                id: thumbnailLoader

                anchors.centerIn: parent

                width: parent.Layout.minimumWidth
                height: 94

                active: true
                asynchronous: true
                sourceComponent: minimized ? appIcon : (KWindowSystem.isPlatformWayland ? (tasks.toolTipOpen ? waylandThumbnail : undefined) : x11Thumbnail)

                onLoaded: {
                    if(sourceComponent !== x11Thumbnail) thumbnailRoot.thumbnailHeight = thumbnailLoader.height;
                    if(isGroupDelegate && ListView.view !== null) ListView.view.updateMaxSize()
                }

                Component {
                    id: x11Thumbnail

                    PlasmaCore.WindowThumbnail {
                        winId: windows !== undefined ? windows[0] : undefined

                        onPaintedSizeChanged: thumbnailRoot.thumbnailHeight = paintedHeight;

                        Rectangle {
                            anchors.centerIn: parent

                            width: parent.paintedWidth+2
                            height: parent.paintedHeight+2
                            color: "transparent"
                            border.width: 1
                            border.color: "black"

                            opacity: 0.5
                        }
                    }
                }

                Component {
                    id: waylandThumbnail

                    PipeWire.PipeWireSourceItem {
                        id: wl_pw_src
                        nodeId: waylandItem.nodeId

                        TaskManager.ScreencastingRequest {
                            id: waylandItem
                            uuid: windows[0]
                        }

                        // Calculates aspect ratio of the PipeWire stream size, which is effectively the window's dimensions
                        property real aspectRatio: (wl_pw_src.streamSize.height == 0) ? 0.0 : wl_pw_src.streamSize.width / wl_pw_src.streamSize.height
                        // If the stream's width is larger than the height, and also the aspectRatio is greater or equal to the
                        // aspect ratio of the maximum thumbnail's dimensions, then it follows that the thumbnail preview's width
                        // will be at the maximum, therefore it's a fixed known value.
                        // In this case, the height is calculated through simple proportions
                        // Otherwise the calculations can be derived in a similar manner
                        property bool widthTakesPrecedence: (wl_pw_src.streamSize.width > wl_pw_src.streamSize.height) &&
                                                                 (aspectRatio >= thumbnailRoot.baselineAspectRatio)
                        onStreamSizeChanged: {
                            outlineRect.updateSize();
                        }
                        onReadyChanged: {
                            if(ready) outlineRect.updateSize();
                        }
                        Rectangle {
                            id: outlineRect
                            anchors.centerIn: parent

                            function updateSize() {
                                if(wl_pw_src.aspectRatio === 0.0 || !wl_pw_src.ready) {
                                    width = 0;
                                    height = 0;
                                } else if(wl_pw_src.widthTakesPrecedence) {
                                    width = Math.floor(thumbnailRoot.maxPreviewWidth + 2);
                                    height = Math.floor((thumbnailRoot.maxPreviewWidth / wl_pw_src.aspectRatio) + 2);
                                } else {
                                    width = Math.floor((wl_pw_src.aspectRatio * thumbnailRoot.maxPreviewHeight) + 2);
                                    height = Math.floor(thumbnailRoot.maxPreviewHeight + 2);
                                }
                            }
                            onHeightChanged: {
                                thumbnailRoot.thumbnailHeight = ((outlineRect.height-2) > 0) ? outlineRect.height-2 : thumbnailRoot.maxPreviewHeight
                            }

                            color: "black"
                            border.width: 1
                            border.color: "black"

                            opacity: 0.5
                            z: -1
                        }
                    }
                }

                // Used when there's no thumbnail available.
                Component {
                    id: appIcon

                    Item {
                        Rectangle {
                            anchors.fill: parent

                            gradient: Gradient {
                                GradientStop { position: 0; color: "#ffffff" }
                                GradientStop { position: 1; color: "#cccccc" }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: -1

                                color: "transparent"

                                border.width: 1
                                border.color: "black"
                                radius: 1
                            }
                        }

                        Kirigami.Icon {
                            anchors.centerIn: parent

                            width: Kirigami.Units.iconSizes.small
                            height: Kirigami.Units.iconSizes.small

                            source: icon
                        }
                    }
                }

                Connections { // Reload the component when thumbnailRoot's windows property changes. This fixes a bug in which the thumbnail shows the wrong window.
                    target: thumbnailRoot
                    function onWindowsChanged() {
                        thumbnailLoader.active = false;
                        thumbnailLoader.active = true;
                    }
                }
            }

            Loader {
                id: shadowLoader

                anchors.fill: thumbnailLoader

                active: true
                asynchronous: true

                sourceComponent: DropShadow {
                    id: realShadow

                    horizontalOffset: 1
                    // Fix for shadow not appearing properly at the bottom
                    // when appIcon is the sourceComponent.
                    verticalOffset: thumbnailLoader.sourceComponent == appIcon ? 2 : 1

                    radius: 1
                    samples: 1
                    color: "#70000000"
                    source: thumbnailLoader.item
                }
            }

            KSvg.FrameSvgItem { // Shown when labels are turned on
                id: thumbnailClose

                anchors {
                    top: parent.top
                    right: parent.right
                }

                width: 14
                height: width

                imagePath: Qt.resolvedUrl("svgs/button-close.svg")
                prefix: thumbnailCloseMa.containsMouse ? (thumbnailCloseMa.containsPress ? "pressed" : "hover") : "normal"

                visible: opacity
                opacity: (contentMa.containsMouse || thumbnailCloseMa.containsMouse) && !tasks.iconsOnly

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }

                MouseArea {
                    id: thumbnailCloseMa

                    anchors.fill: parent

                    hoverEnabled: true
                    propagateComposedEvents: true

                    onClicked: {
                        thumbnailRoot.closeTask();
                    }
                }
            }
        }
    }

    Loader {
        id: mprisControls

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        readonly property QtObject root: thumbnailRoot.root

        active: root.playerData !== null
        asynchronous: true
        source: "PlayerController.qml"
    }

    Component.onDestruction: if(isGroupDelegate) ListView.view.updateMaxSize()
}
