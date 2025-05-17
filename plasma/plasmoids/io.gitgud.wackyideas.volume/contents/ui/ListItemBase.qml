/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>
    SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.private.volume
import org.kde.plasma.plasmoid

import org.kde.kirigami as Kirigami
import org.kde.kquickcontrolsaddons
import org.kde.ksvg as KSvg

Item {
    id: item

    required property var model
    property string type
    property bool isStream: false
    property bool isInWindow: false

    property string name: "unknown"
    property string iconName: model.IconName

    property bool isMixer: {
        let item = this;
        while (item.parent) {
            item = item.parent;
            if (item.mixer !== undefined) {
                return item.mixer
            }
        }
    }

    opacity: (main.draggedStream && main.draggedStream.deviceIndex === item.model.Index) ? 0.3 : 1.0

    Keys.forwardTo: [slider]

    ColumnLayout {
        id: controlsRow

        anchors.fill: parent
        anchors.topMargin: 1

        spacing: 17

        Kirigami.Icon {
            property bool showDropdown: {
                if(type == "sink-output") return paSinkFilterModel.count > 1
                if(type == "sink-input") return paSourceFilterModel.count > 1
                else return false
            }

            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: (iconMa.containsPress ? 1 : 0) - 2
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            Layout.topMargin: item.isInWindow ? 0 : -3

            source: type == "sink-output" ? "audio-speakers" : (type == "sink-input" ? "audio-input-microphone" : item.iconName)

            Timer {
                id: deviceTooltipTimer
                interval: Kirigami.Units.longDuration*2
                onTriggered: {
                    if(iconMa.containsMouse) {
                        deviceTooltip.showToolTip();
                    } else {
                        deviceTooltip.hideToolTip();
                    }
                }
            }
            MouseArea {
                id: iconMa

                anchors.fill: parent
                anchors.margins: -Kirigami.Units.smallSpacing
                anchors.leftMargin: -Kirigami.Units.smallSpacing - (containsPress ? 1 : 0)
                anchors.rightMargin: -Kirigami.Units.smallSpacing + (containsPress ? 1 : 0)

                hoverEnabled: true
                onClicked: {
                    deviceListMenu.openRelative();
                    deviceTooltip.hideImmediately();
                }
                onContainsMouseChanged: {
                    deviceTooltipTimer.start();
                }

                visible: (type == "sink-output" || type == "sink-input") && showDropdown
            }


            KSvg.FrameSvgItem {
                anchors.fill: iconMa

                imagePath: "widgets/button"
                prefix: iconMa.containsPress || deviceListMenu.state == 1 ? "toolbutton-pressed" : "toolbutton-hover"

                visible: opacity

                opacity: iconMa.containsMouse || deviceListMenu.state == 1

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }

                PlasmaCore.ToolTipArea {
                    id: deviceTooltip

                    anchors.fill: parent
                    interactive: false
                    mainText: model.Description
                }

                z: -1
            }
        }

        Text {
            id: label

            property bool showDropdown: {
                if(type == "sink-output") return contextMenu.hasContent
                if(type == "sink-input") return contextMenu.hasContent
                else return false
            }

            Layout.topMargin: -parent.spacing / 2
            Layout.preferredHeight: 32
            Layout.fillWidth: true
            Layout.maximumWidth: !isMixer ? 48 : undefined

            text: Plasmoid.configuration.showDeviceName ? name
                  : (type == "sink-output" ? "Speakers" : (type == "sink-input" ? "Microphone" : item.name))
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            rightPadding: showDropdown ? (dropdownArrow.width + Kirigami.Units.smallSpacing) : 0

            visible: isMixer || Plasmoid.configuration.showLabels

            TextMetrics {
                id: textMetrics
                text: label.showDropdown ? label.text : ""
            }

            MouseArea {
                id: labelMa

                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                height: textMetrics.height + Kirigami.Units.smallSpacing
                width: {
                    if(textMetrics.advanceWidth < 48 || isMixer) return textMetrics.advanceWidth + dropdownArrow.width + Kirigami.Units.smallSpacing * 2
                    else return 48
                }

                hoverEnabled: true
                onClicked: contextMenu.openRelative();

                visible: label.showDropdown
            }

            KSvg.FrameSvgItem {
                anchors.fill: labelMa

                imagePath: "widgets/button"
                prefix: labelMa.containsPress || contextMenu.visible ? "toolbutton-pressed" : "toolbutton-hover"

                visible: labelMa.containsMouse || contextMenu.visible

                z: -1
            }

            KSvg.SvgItem {
                id: dropdownArrow

                anchors {
                    verticalCenter: labelMa.verticalCenter
                    verticalCenterOffset: 0
                    right: labelMa.right
                    rightMargin: 3
                }

                width: 6
                height: 4

                imagePath: Qt.resolvedUrl("svgs/control.svg")
                elementId: "dropdown"

                visible: label.showDropdown
            }
        }

        VolumeSlider {
            id: slider

            property real myStepSize: PulseAudio.NormalVolume / 100.0 * config.volumeStep

            readonly property bool forceRaiseMaxVolume: (config.raiseMaximumVolume && (item.type === "sink-output" || item.type === "sink-input"))
            onForceRaiseMaxVolumeChanged: {
                if (forceRaiseMaxVolume) {
                    toAnimation.from = PulseAudio.NormalVolume;
                    toAnimation.to = PulseAudio.MaximalVolume;
                } else {
                    toAnimation.from = PulseAudio.MaximalVolume;
                    toAnimation.to = PulseAudio.NormalVolume;
                }
                seqAnimation.restart();
            }

            function increase() { value = value + myStepSize }
            function decrease() { value = value - myStepSize }

            function updateVolume() {
                if (!forceRaiseMaxVolume && item.model.Volume > PulseAudio.NormalVolume) {
                    item.model.Volume = PulseAudio.NormalVolume;
                }
            }

            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: -Kirigami.Units.smallSpacing
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.preferredHeight: 121
            Layout.rightMargin: Kirigami.Units.largeSpacing+2

            from: PulseAudio.MinimalVolume
            to: forceRaiseMaxVolume || item.model.Volume >= PulseAudio.NormalVolume * 1.01 ? PulseAudio.MaximalVolume : PulseAudio.NormalVolume
            stepSize: PulseAudio.NormalVolume / 100.0
            enabled: item.model.VolumeWritable
            muted: item.model.Muted// || value === PulseAudio.MinimalVolume
            volumeObject: item.model.PulseObject
            value: to, item.model.Volume

            onMoved: {
                item.model.Volume = value;
                item.model.Muted = false //value === PulseAudio.MinimalVolume;
            }
            onPressedChanged: {
                if (!pressed) {
                    // Make sure to sync the volume once the button was
                    // released.
                    // Otherwise it might be that the slider is at v10
                    // whereas PA rejected the volume change and is
                    // still at v15 (e.g.).
                    value = Qt.binding(() => item.model.Volume);
                    if (type === "sink-output") { // It used to be "sink" but that never happens so this code never happens
                        playFeedback(item.model.Index);
                    }
                }
            }

            type: item.type

            visible: item.model.HasVolume !== false // Devices always have volume but Streams don't necessarily

            SequentialAnimation {
                id: seqAnimation
                NumberAnimation {
                    id: toAnimation
                    target: slider
                    property: "to"
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
                ScriptAction {
                    script: slider.updateVolume()
                }
            }
        }
        MouseArea {
            id: muteButton

            Layout.preferredWidth: 32
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 3

            property bool isMuted: item.model.Muted //|| slider.value === PulseAudio.MinimalVolume

            hoverEnabled: true
            onClicked: {
                item.model.Muted = !item.model.Muted
                muteTooltip.hideImmediately();
            }
            onContainsMouseChanged: {
                muteTooltipTimer.start();
            }

            Timer {
                id: muteTooltipTimer
                interval: Kirigami.Units.longDuration*2
                onTriggered: {
                    if(muteButton.containsMouse) {
                        muteTooltip.showToolTip();
                    } else {
                        muteTooltip.hideToolTip();
                    }
                }
            }
            KSvg.FrameSvgItem {
                anchors.fill: parent

                imagePath: "widgets/button"
                prefix: parent.containsPress ? "toolbutton-pressed" : "toolbutton-hover"

                visible: opacity

                opacity: parent.containsMouse

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }
                PlasmaCore.ToolTipArea {
                    id: muteTooltip

                    anchors.fill: parent
                    interactive: false
                    mainText: (muteButton.isMuted ? "Unmute" : "Mute") + " " + (item.type == "sink-output" ? "Speakers" : (item.type == "sink-input" ? "Microphone" : item.name))
                }
            }
            KSvg.SvgItem {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: parent.containsPress ? 1 : 0

                width: Kirigami.Units.iconSizes.small - (elementId == "unmute" ? 2 : 0)
                height: Kirigami.Units.iconSizes.small

                imagePath: Qt.resolvedUrl("svgs/control.svg")
                elementId: muteButton.isMuted ? "unmute" : "mute"
            }

        }
    }

    Instantiator {
        model: {
            if(type === "sink-output") return paSinkFilterModel;
            if(type === "sink-input") return paSourceFilterModel;
        }
        delegate: PlasmaExtras.MenuItem {
            required property int index
            required property var model

            text: model.Description + "      "
            checkable: true
            checked: model.PulseObject.default
            onClicked: {
                if (type === "sink-output" || type === "sink-input") {
                    model.PulseObject.default = true;
                }
            }
        }
        onObjectAdded: (index, object) => deviceListMenu.addMenuItem(object);
        onObjectRemoved: (index, object) => deviceListMenu.removeMenuItem(object)
    }

    PlasmaExtras.Menu {
        id: deviceListMenu
        visualParent: iconMa
        placement: PlasmaExtras.Menu.BottomPosedLeftAlignedPopup;
    }

    ListItemMenu {
        id: contextMenu
        pulseObject: item.model.PulseObject
        cardModel: main.paCardModel
        itemType: {
            switch (item.type) {
            case "sink-output":
                return ListItemMenu.Sink;
            case "sink-input":
                return ListItemMenu.SinkInput;
            case "source":
                return ListItemMenu.Source;
            case "source-output":
                return ListItemMenu.SourceOutput;
            }
        }
        sourceModel: {
            if (item.type == "sink-output") return main.paSinkFilterModel
            else if (item.type == "sink-input") return main.paSourceFilterModel
        }
        visualParent: labelMa
    }

    function setVolumeByPercent(targetPercent) {
        item.model.PulseObject.volume = Math.round(PulseAudio.NormalVolume * (targetPercent/100));
    }

    function setAsDefault(): void {
        if (type === "sink" || type === "source") {
            model.PulseObject.default = true;
        }
    }

    Keys.onPressed: event => {
        const k = event.key;

        if (k === Qt.Key_M) {
            muteButton.clicked();
        } else if (k >= Qt.Key_0 && k <= Qt.Key_9) {
            setVolumeByPercent((k - Qt.Key_0) * 10);
        } else if (k === Qt.Key_Return) {
            setAsDefault();
        } else if (k === Qt.Key_Menu && contextMenu.hasContent) {
            contextMenu.visualParent = contextMenuButton;
            contextMenu.openRelative();
        } else {
            return; // don't accept the key press
        }
        event.accepted = true;
    }
}
