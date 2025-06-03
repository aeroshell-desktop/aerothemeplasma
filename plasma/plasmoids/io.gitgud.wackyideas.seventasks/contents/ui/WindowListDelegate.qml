import QtQuick
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mpris as Mpris

MouseArea {
    id: thumbnailRoot

    property QtObject root

    property var captionAlignment: {
        if(Plasmoid.configuration.thmbnlCaptionAlignment == 0) return Text.AlignLeft
        if(Plasmoid.configuration.thmbnlCaptionAlignment == 1) return Text.AlignHCenter
        if(Plasmoid.configuration.thmbnlCaptionAlignment == 2) return Text.AlignRight
    }

    property var display: model.display
    property var icon: model.decoration
    property var active: model.IsActive
    property var modelIndex: tasksModel.makeModelIndex(root.taskIndex, index)
    property var windows: model.WinIdList
    property var minimized: model.IsMinimized

    implicitWidth: captionIcon.width + captionTitle.implicitWidth + 14 + Kirigami.Units.largeSpacing*8
    onImplicitWidthChanged: ListView.view.updateMaxSize()

    implicitHeight: 33 + Kirigami.Units.smallSpacing*4

    width: {
        if(ListView.view.maxThumbnailItem !== thumbnailRoot)
            return ListView.view.maxThumbnailWidth;
        else
            return implicitWidth;
    }

    function closeTask() {
        tasksModel.requestClose(modelIndex);
        if(!isGroupDelegate) root.parentTask.hideImmediately();
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

            opacity: contentMa.containsMouse || closeMa.containsMouse || (!tasks.iconsOnly && root.taskHovered && !isGroupDelegate)

            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }
        }
    }

    DropArea {
        signal urlsDropped(var urls)

        anchors.fill: parent

        onPositionChanged: {
            activationTimer.restart();
        }

        onEntered: {
            root.containsDrag = true;
        }

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

            onTriggered: {
                tasksModel.requestActivate(modelIndex);
            }
        }
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

        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing*4

        spacing: Kirigami.Units.smallSpacing/2

        RowLayout {
            id: header

            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                id: captionIcon

                Layout.preferredHeight: 16
                Layout.preferredWidth: 16

                source: icon
            }

            Text {
                id: captionTitle

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
                id: captionClose

                Layout.preferredWidth: 14
                Layout.preferredHeight: 14

                imagePath: Qt.resolvedUrl("svgs/button-close.svg")
                prefix: closeMa.containsMouse ? (closeMa.containsPress ? "pressed" : "hover") : "normal"

                visible: opacity

                opacity: contentMa.containsMouse || closeMa.containsMouse

                Behavior on opacity {
                    NumberAnimation { duration: compositionEnabled ? 250 : 0 }
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
    }

    Component.onDestruction: ListView.view.updateMaxSize()
}
