/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2017 Roman Gilg <subdiff@gmail.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQml.Models 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
// for Highlight
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

Item {
    id: tooltipInstance
    property var submodelIndex
    property int flatIndex: isGroup && index != undefined ? index : 0

    readonly property string mprisSourceName: mpris2Source.sourceNameForLauncherUrl(toolTipDelegate.launcherUrl, isGroup ? AppPid : pidParent)
    readonly property var playerData: mprisSourceName != "" ? mpris2Source.data[mprisSourceName] : 0
    readonly property bool hasPlayer: !!mprisSourceName && !!playerData
    readonly property bool playing: hasPlayer && playerData.PlaybackStatus === "Playing"
    readonly property bool canControl: hasPlayer && playerData.CanControl
    readonly property bool canPlay: hasPlayer && playerData.CanPlay
    readonly property bool canPause: hasPlayer && playerData.CanPause
    readonly property bool canGoBack: hasPlayer && playerData.CanGoPrevious
    readonly property bool canGoNext: hasPlayer && playerData.CanGoNext
    readonly property bool canRaise: hasPlayer && playerData.CanRaise
    readonly property var currentMetadata: hasPlayer ? playerData.Metadata : ({})
    // Used to highlight the tooltip that points to the window that's currently in focus.
    property bool activeWindow: plasmoid.nativeInterface.isActiveWindow(thumbnailSourceItem.winId);

    readonly property string track: {
        var xesamTitle = currentMetadata["xesam:title"]
        if (xesamTitle) {
            return xesamTitle;
        }
        // if no track title is given, print out the file name
        var xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
        if (!xesamUrl) {
            return "";
        }
        var lastSlashPos = xesamUrl.lastIndexOf('/')
        if (lastSlashPos < 0) {
            return "";
        }
        var lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
        return decodeURIComponent(lastUrlPart);
    }
    readonly property string artist: currentMetadata["xesam:artist"] || ""
    readonly property string albumArt: currentMetadata["mpris:artUrl"] || ""

    property int tooltipWidth: 203 * PlasmaCore.Units.devicePixelRatio
    property int tooltipHeight: 104 * PlasmaCore.Units.devicePixelRatio
    readonly property int totalHeight: columnLayout.height //x11Thumbnail.visible ? x11Thumbnail.paintedHeight : -1

    width: columnLayout.width
    height: isGroup ? toolTipDelegate.getMaxHeight() : columnLayout.height

    // This component tracks the mouse and highlights the tooltip when it's hovered over or clicked on.
        ToolTipWindowMouseArea {
            id: hoverHandler

            anchors.fill: parent;
            anchors.margins: PlasmaCore.Units.smallSpacing / 2
            anchors.bottomMargin: PlasmaCore.Units.smallSpacing / 2 + (playerControls.visible ? playerControls.height : 0)
            rootTask: parentTask
            modelIndex: submodelIndex
            winId: thumbnailSourceItem.winId
            z: 0
            enabled: visible
            closeBtn: closeButtonMA

            PlasmaCore.FrameSvgItem {
                imagePath: Qt.resolvedUrl("svgs/taskbarhover.svg")
                z: -1

                anchors {
                    top: parent.top;
                    left: parent.left;
                    right: parent.right;
                    bottom: parent.bottom;
                    margins: PlasmaCore.Units.smallSpacing / 2
                    bottomMargin: PlasmaCore.Units.smallSpacing / 2 -(playerControls.visible ? playerControls.height : 0);
                }

                // The currently active window has a blue tinted version of the same texture.
                prefix: {
                    if(activeWindow) return "active";
                    return "normal";
                }
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
                opacity: isWin ? (hoverHandler.containsPress ? 1.0 : ( (hoverHandler.opacityHover || closeButton.hovered) ? ((activeWindow) ? 1.0 : 0.7) : (activeWindow ? 0.7 : 0) )) : 0;
            }
        }



        ColumnLayout {

        id: columnLayout
        Layout.margins: isWin ? PlasmaCore.Units.smallSpacing / 2 : 0
        Layout.fillHeight: true
        spacing: isWin ? PlasmaCore.Units.smallSpacing / 2 : 0

    // text labels + close button
    RowLayout {
        id: header
        // match spacing of DefaultToolTip.qml in plasma-framework
        //spacing: isWin ? PlasmaCore.Units.smallSpacing : 0 //isWin ? PlasmaCore.Units.smallSpacing : PlasmaCore.Units.largeSpacing
        spacing: 0
        // This number controls the overall size of the window tooltips
        Layout.minimumWidth: isWin ? tooltipWidth : 0;
        Layout.maximumWidth: isWin ? tooltipWidth : PlasmaCore.Units.gridUnit*12;
        //Layout.maximumHeight: isWin ? 104 * PlasmaCore.Units.devicePixelRatio : 0;
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        // match margins of DefaultToolTip.qml in plasma-framework
        Layout.margins: isWin ? 0 : PlasmaCore.Units.smallSpacing / 2
        Layout.bottomMargin: 0
        // There's no PlasmaComponents3 version

        // The icon in the corner of the tooltip.
        PlasmaCore.IconItem {
            id: iconSmall
            implicitWidth: PlasmaCore.Units.iconSizes.small;
            implicitHeight: PlasmaCore.Units.iconSizes.small;
            Layout.topMargin: PlasmaCore.Units.smallSpacing;
            Layout.leftMargin: PlasmaCore.Units.smallSpacing / 2;
            Layout.alignment: Qt.AlignVCenter

            source: icon
            animated: false
            usesPlasmaTheme: false
            roundToIconSize: false
            visible: valid && isWin
        }
        ColumnLayout {
            spacing: 0

            // Program name.
            PlasmaExtras.Heading {
                id: appNameHeading
                level: 5
                maximumLineCount: 1
                lineHeight: isWin ? iconSmall.implicitHeight * 2 : 1.0
                lineHeightMode: isWin ? Text.FixedHeight : Text.ProportionalHeight
                Layout.fillWidth: true
                Layout.topMargin: isWin ? 1 : 0;
                verticalAlignment: Text.AlignVCenter
                Layout.leftMargin: isWin ? PlasmaCore.Units.smallSpacing : 0;
                Layout.rightMargin: (!isWin ? 0 : ((!closeButton.isvisible) ? (PlasmaCore.Units.smallSpacing*2) : PlasmaCore.Units.smallSpacing));
                elide: Text.ElideRight
                text: isWin ? generateTitle() : appName;
                opacity: 1
                textFormat: Text.PlainText
            }
            // Window title.
            PlasmaComponents.Label {
                id: winTitle
                maximumLineCount: 1
                lineHeight: 1.0
                Layout.fillWidth: true
                Layout.leftMargin: isWin ? PlasmaCore.Units.smallSpacing : 0;
                Layout.rightMargin: (!isWin ? 0 : ((!closeButton.isvisible) ? (PlasmaCore.Units.smallSpacing*3) : 0));

                elide: Text.ElideRight
                text: "";
                opacity: 0.75
                visible: false
                textFormat: Text.PlainText
            }
            // Subtext.
            PlasmaComponents.Label {
                readonly property string title: generateTitle()
                id: subtext
                maximumLineCount: 1
                Layout.fillWidth: true
                Layout.leftMargin: isWin ? PlasmaCore.Units.smallSpacing : 0;
                Layout.rightMargin: (!isWin ? 0 : ((!closeButton.isvisible) ? (PlasmaCore.Units.smallSpacing*3) : 0));
                elide: Text.ElideRight
                text: title;
                //text: isWin ? generateSubText() : ""
                opacity: 0.7
                visible: !isWin && (title.length !== 0)
                textFormat: Text.PlainText
            }
        }

        // Count badge, no longer used.
        // The badge itself is inside an item to better center the text in the bubble
        /*Item {
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.preferredHeight: closeButton.height
            Layout.preferredWidth: closeButton.width
            visible: flatIndex === 0 && smartLauncherCountVisible

            Badge {
                anchors.centerIn: parent
                height: PlasmaCore.Units.iconSizes.smallMedium
                number: smartLauncherCount
            }
        }*/

        // Close button, which is no longer an icon but rather a SVG texture.
        PlasmaCore.FrameSvgItem {
            id: closeButton
            property bool isvisible: closeButton.visible
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            Layout.preferredWidth: PlasmaCore.Units.smallSpacing*3+2;
            Layout.preferredHeight: PlasmaCore.Units.smallSpacing*3+2;
            Layout.rightMargin: PlasmaCore.Units.smallSpacing / 2;
            Layout.topMargin: PlasmaCore.Units.smallSpacing*3-1;
            visible: isWin && hoverHandler.opacityHover
            imagePath: Qt.resolvedUrl("svgs/button-close.svg")
            prefix: closeButtonMA.containsPress ? "pressed" : (closeButtonMA.containsMouse ? "hover" : "normal");
            MouseArea {
                id: closeButtonMA
                anchors.fill: parent
                onClicked: {
                    backend.cancelHighlightWindows();
                    tasksModel.requestClose(submodelIndex);
                }
                onEntered: {
                    hoverHandler.opacityHover = 1;
                    tasks.windowsHovered([thumbnailSourceItem.winId], 1);
                }
                hoverEnabled: true
                z: 7
            }
            z: 6
        }
    }


    // Thumbnail container.
    Item {
        id: thumbnailSourceItem
        function determineAspect() {
            //if(isGroup) return toolTipDelegate.getMaxHeight();
            if(x11Thumbnail.visible && x11Thumbnail.paintedWidth > 0) {
                var geometry = plasmoid.nativeInterface.getWindowAspectRatio(winId);
                var ratio = geometry.height / geometry.width;
                return Math.min(thumbnailSourceItem.Layout.maximumHeight, tooltipWidth*ratio);
            }
            return thumbnailSourceItem.Layout.maximumHeight;
        }
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: tooltipWidth;
        Layout.maximumWidth: tooltipWidth;
        Layout.maximumHeight: tooltipHeight;
        Layout.preferredHeight: tooltipHeight//determineAspect()//(x11Thumbnail.visible && x11Thumbnail.paintedWidth > 0 && thumbnailSourceItem.determineAspect() ? (x11Thumbnail.paintedHeight) : tooltipHeight);
        //Layout.minimumHeight: thumbnailSourceItem.Layout.maximumHeight;
        Layout.leftMargin: PlasmaCore.Units.smallSpacing*3 - PlasmaCore.Units.smallSpacing / 2;
        Layout.rightMargin: PlasmaCore.Units.smallSpacing*3 - PlasmaCore.Units.smallSpacing / 2;
        Layout.bottomMargin: albumArtImage.visible || hasPlayer ? 0 : PlasmaCore.Units.smallSpacing*3;
        Layout.topMargin: -PlasmaCore.Units.smallSpacing;

        visible: toolTipDelegate.isWin

        readonly property bool isMinimized: isGroup ? IsMinimized == true : isMinimizedParent
        // TODO: this causes XCB error message when being visible the first time
        readonly property var winId: toolTipDelegate.isWin && toolTipDelegate.windows[flatIndex] !== undefined ? toolTipDelegate.windows[flatIndex] : 0


        PlasmaCore.WindowThumbnail {
            id: x11Thumbnail

            property alias thumbnailWidth: x11Thumbnail.paintedWidth;

            onThumbnailWidthChanged: {

                //console.log(toolTipDelegate.getMaxHeight());
            }
            anchors {
                fill: parent
            }
            width: thumbnailSourceItem.Layout.minimumWidth;
            //height: Math.min(thumbnailSourceItem.Layout.minimumHeight, x11Thumbnail.paintedHeight); //thumbnailSourceItem.Layout.minimumWidth * plasmoid.nativeInterface.getWindowAspectRatio(thumbnailSourceItem.winId);
            visible: !albumArtImage.visible && !thumbnailSourceItem.isMinimized && Number.isInteger(thumbnailSourceItem.winId)
            winId: Number.isInteger(thumbnailSourceItem.winId) ? thumbnailSourceItem.winId : 0
        }

        Rectangle {
            id: noPreviewRect
            anchors {
                fill: parent
            }
            visible: !albumArtImage.available && !x11Thumbnail.visible
            gradient: Gradient {
                GradientStop { position: 0; color: "#ffffff" }
                GradientStop { position: 1; color: "#cccccc" }
            }
            border.width: 1
            border.color: "#40000000"
            radius: 1
            PlasmaCore.IconItem {
                implicitWidth: PlasmaCore.Units.iconSizes.medium
                implicitHeight: PlasmaCore.Units.iconSizes.medium
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: thumbnailSourceItem.isMinimized && !albumArtImage.visible && Number.isInteger(thumbnailSourceItem.winId) ? icon : ""
                animated: false
                usesPlasmaTheme: false
                //visible: valid && !pipeWireLoader.active
            }
        }

        Loader {
            id: pipeWireLoader
            Layout.alignment: Qt.AlignTop
            //anchors.fill: hoverHandler
            // Indent a little bit so that neither the thumbnail nor the drop
            // shadow can cover up the highlight
            anchors.margins: PlasmaCore.Units.smallSpacing * 2

            active: !albumArtImage.visible && !Number.isInteger(thumbnailSourceItem.winId)

            //In a loader since we might not have PipeWire available yet
            source: "PipeWireThumbnail.qml"
        }

        Rectangle {
            id: thumbnailOutline
            anchors.horizontalCenter: x11Thumbnail.horizontalCenter
            anchors.verticalCenter: x11Thumbnail.verticalCenter
            visible: x11Thumbnail.visible
            border.color: "#40000000"
            border.width: 1
            radius: 1
            color: "transparent"
            width: x11Thumbnail.paintedWidth+2
            height: x11Thumbnail.paintedHeight+2
        }
        DropShadow {
            anchors.fill: pipeWireLoader.active ? pipeWireLoader : (x11Thumbnail.visible ? thumbnailOutline : noPreviewRect)
            visible: pipeWireLoader.active ? pipeWireLoader.item.visible : (x11Thumbnail.visible || noPreviewRect.visible)
            horizontalOffset: 1
            verticalOffset: 1
            radius: 1
            samples: 1
            color: "#70000000"
            source: pipeWireLoader.active ? pipeWireLoader.item : (x11Thumbnail.visible ? thumbnailOutline : noPreviewRect)
            z: 0
        }


        Image {
            id: albumArtBackground
            source: albumArt
            sourceSize: Qt.size(x11Thumbnail.width, x11Thumbnail.height)
            anchors {
                fill: parent

            }

            fillMode: Image.PreserveAspectCrop
            visible: albumArtImage.available
            asynchronous: true
            layer.enabled: true
            opacity: 0.5
            layer.effect: FastBlur {
                source: albumArtBackground
                anchors.fill: parent
                anchors.bottomMargin: -PlasmaCore.Units.smallSpacing
                radius: 30
            }

        }
        // Borders around the blurred album art for added visuals.
        PlasmaCore.FrameSvgItem {
            id: albumArtBorder
            visible: albumArtImage.available
            anchors.fill: parent
            anchors.rightMargin: -PlasmaCore.Units.smallSpacing/4
            anchors.bottomMargin: -PlasmaCore.Units.smallSpacing
            imagePath: "widgets/pager"
            prefix: "hover"
            opacity: 0.4
        }

        Image {
            id: albumArtImage
            // also Image.Loading to prevent loading thumbnails just because the album art takes a split second to load
            // don't show album art if window title doesn't include media title (eg we're in a different browser tab)
            readonly property bool available: (status === Image.Ready || status === Image.Loading) && generateTitle().includes(track)

            anchors.fill: x11Thumbnail
            // Indent by one pixel to make sure we never cover up the entire highlight
            anchors.margins: 1
            anchors.topMargin: PlasmaCore.Units.smallSpacing;
            sourceSize: Qt.size(parent.width, parent.height)

            asynchronous: true
            source: albumArt
            fillMode: Image.PreserveAspectFit
            visible: available
        }
    }

    // Player controls row
    RowLayout {
        id: playerControls
        Layout.maximumWidth: tooltipWidth + PlasmaCore.Units.smallSpacing*3;

        visible: hasPlayer
        enabled: canControl
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: PlasmaCore.Units.smallSpacing
            Layout.bottomMargin: PlasmaCore.Units.smallSpacing*2
            Layout.rightMargin: isWin ? PlasmaCore.Units.smallSpacing : PlasmaCore.Units.largeSpacing
            Layout.leftMargin: 1
            Layout.columnSpan: 2
            Layout.column: 0
            spacing: 0
            z: -1
             ScrollableTextWrapper {
                id: songTextWrapper

                Layout.fillWidth: true
                Layout.preferredHeight: songText.height
                implicitWidth: songText.implicitWidth
                Layout.leftMargin: PlasmaCore.Units.smallSpacing*2;

                PlasmaComponents3.Label {
                    id: songText
                    parent: songTextWrapper
                    width: parent.width
                    height: undefined
                    lineHeight: 1
                    maximumLineCount: artistText.visible? 1 : 2
                    wrapMode: Text.NoWrap
                    elide: parent.state ? Text.ElideNone : Text.ElideRight
                    text: track || ""
                    textFormat: Text.PlainText
                }
             }

            ScrollableTextWrapper {
                id: artistTextWrapper

                z: -1
                Layout.fillWidth: true
                Layout.preferredHeight: artistText.height
                Layout.leftMargin: PlasmaCore.Units.smallSpacing*2;
                implicitWidth: artistText.implicitWidth
                visible: artistText.text !== ""

                PlasmaComponents3.Label {
                    id: artistText
                    parent: artistTextWrapper
                    width: parent.width
                    height: undefined
                    wrapMode: Text.NoWrap
                    lineHeight: 1
                    elide: parent.state ? Text.ElideNone : Text.ElideRight
                    text: artist || ""
                    font: PlasmaCore.Theme.smallestFont
                    textFormat: Text.PlainText
                }
            }
        }
        RowLayout {

            Layout.fillWidth: true
            Layout.topMargin: (!artistTextWrapper.visible && songText.text == "" ? 1 : 0)
            Layout.bottomMargin: PlasmaCore.Units.smallSpacing * (!artistTextWrapper.visible && songText.text == "" ? 2 : 1)
            Layout.rightMargin: PlasmaCore.Units.smallSpacing / 2
            spacing: -1

        MediaButton {
            id: canGoBackMedia
            orientation: "left"
            mediaIcon: "previous"
            enableButton: canGoBack
            onClicked: {
                mpris2Source.goPrevious(mprisSourceName)
            }
        }
        MediaButton {
            id: playPauseMedia
            orientation: "center"
            mediaIcon: "pause"
            fallbackMediaIcon: "play"
            togglePlayPause: playing
            enableButton: playing ? canPause : canPlay
            onClicked: {
                if (!playing) {
                    mpris2Source.play(mprisSourceName);
                } else {
                    mpris2Source.pause(mprisSourceName);
                }
            }
        }
        MediaButton {
            id: canGoForwardMedia
            enableButton: canGoNext
            orientation: "right"
            mediaIcon: "skip"
            onClicked: mpris2Source.goNext(mprisSourceName)
        }
        }

    }
        }
    function generateTitle() {
        if (!isWin) {
            return genericName != undefined ? genericName : "";
        }

        var text;
        if (isGroup) {
            if (model.display === undefined) {
                return "";
            }
            text = model.display.toString();
        } else {
            text = displayParent;
        }

        // KWin appends increasing integers in between pointy brackets to otherwise equal window titles.
        // In this case save <#number> as counter and delete it at the end of text.
        var counter = text.match(/<\d+>\W*$/);
        text = text.replace(/\s*<\d+>\W*$/, "");

        // Remove appName from the end of text.
        var appNameRegex = new RegExp(appName + "$", "i");
        text = text.replace(appNameRegex, "");
        text = text.replace(/\s*(?:-|—)*\s*$/, "");

        // Add counter back at the end.
        if (counter !== null) {
            if (text === "") {
                text = counter;
            } else {
                text = text + " " + counter;
            }
        }

        // In case the window title had only redundant information (i.e. appName), text is now empty.
        // Add a hyphen to indicate that and avoid empty space.
        if (text === "") {
            text = appName;
        }
        return text.toString();
    }

    function generateSubText() {
        if (activitiesParent === undefined) {
            return "";
        }

        var subTextEntries = [];

        var onAllDesktops = (isGroup ? IsOnAllVirtualDesktops : isOnAllVirtualDesktopsParent) === true;
        if (!plasmoid.configuration.showOnlyCurrentDesktop && virtualDesktopInfo.numberOfDesktops > 1) {
            var virtualDesktops = isGroup ? VirtualDesktops : virtualDesktopParent;

            if (!onAllDesktops && virtualDesktops !== undefined && virtualDesktops.length > 0) {
                var virtualDesktopNameList = new Array();

                for (var i = 0; i < virtualDesktops.length; ++i) {
                    virtualDesktopNameList.push(virtualDesktopInfo.desktopNames[virtualDesktopInfo.desktopIds.indexOf(virtualDesktops[i])]);
                }

                subTextEntries.push(i18nc("Comma-separated list of desktops", "On %1",
                    virtualDesktopNameList.join(", ")));
            } else if (onAllDesktops) {
                subTextEntries.push(i18nc("Comma-separated list of desktops", "Pinned to all desktops"));
            }
        }

        var act = isGroup ? Activities : activitiesParent;
        if (act === undefined) {
            return subTextEntries.join("\n");
        }

        if (act.length === 0 && activityInfo.numberOfRunningActivities > 1) {
            subTextEntries.push(i18nc("Which virtual desktop a window is currently on",
                "Available on all activities"));
        } else if (act.length > 0) {
           var activityNames = [];

            for (var i = 0; i < act.length; i++) {
                var activity = act[i];
                var activityName = activityInfo.activityName(act[i]);
                if (activityName === "") {
                    continue;
                }
                if (plasmoid.configuration.showOnlyCurrentActivity) {
                    if (activity !== activityInfo.currentActivity) {
                        activityNames.push(activityName);
                    }
                } else if (activity !== activityInfo.currentActivity) {
                    activityNames.push(activityName);
                }
            }

            if (plasmoid.configuration.showOnlyCurrentActivity) {
                if (activityNames.length > 0) {
                    subTextEntries.push(i18nc("Activities a window is currently on (apart from the current one)",
                        "Also available on %1", activityNames.join(", ")));
                }
            } else if (activityNames.length > 0) {
                subTextEntries.push(i18nc("Which activities a window is currently on",
                    "Available on %1", activityNames.join(", ")));
            }
        }

        return subTextEntries.join("\n");
    }

}
