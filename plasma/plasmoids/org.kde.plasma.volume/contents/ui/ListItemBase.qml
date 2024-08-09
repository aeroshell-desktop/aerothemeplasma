/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>
    SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kquickcontrolsaddons
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.volume

PC3.ItemDelegate {
    id: item

    required property var model
    property alias label: defaultButton.text
    property alias draggable: dragMouseArea.enabled
    property alias iconSource: clientIcon.source
    // TODO: convert to a proper enum?
    property string /* "sink" | "sink-input" | "source" | "source-output" */ type
    property string fullNameToShowOnHover: ""

    highlighted: dropArea.containsDrag || activeFocus
    background.visible: highlighted
    opacity: (main.draggedStream && main.draggedStream.deviceIndex === item.model.Index) ? 0.3 : 1.0

    ListView.delayRemove: clientIcon.Drag.active

    Keys.forwardTo: [slider]

    contentItem: RowLayout {
        id: controlsRow
        spacing: item.spacing

        Kirigami.Icon {
            id: clientIcon
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            implicitHeight: Kirigami.Units.iconSizes.medium
            implicitWidth: implicitHeight
            source: "unknown"
            visible: item.type === "sink-input" || item.type === "source-output"

            onSourceChanged: {
                if (!valid && source !== "unknown") {
                    source = "unknown";
                }
            }

            Kirigami.Icon {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                implicitHeight: Kirigami.Units.iconSizes.small
                implicitWidth: implicitHeight
                source: item.type === "sink-input" || item.type === "source-output" ? "emblem-pause" : ""
                visible: valid && item.model.Corked

                PC3.ToolTip.visible: visible && dragMouseArea.containsMouse
                PC3.ToolTip.text: item.type === "source-output"
                    ? i18n("Currently not recording")
                    : i18n("Currently not playing")
                PC3.ToolTip.delay: 700
            }

            MouseArea {
                id: dragMouseArea
                anchors.fill: parent
                cursorShape: enabled ? (pressed && pressedButtons === Qt.LeftButton ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : undefined
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                hoverEnabled: true
                drag.target: clientIcon
                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton) {
                        item.model.Muted = !item.model.Muted;
                    }
                }
                onPressed: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        clientIcon.grabToImage(result => clientIcon.Drag.imageSource = result.url);
                    }
                }
            }
            Drag.active: dragMouseArea.drag.active
            Drag.dragType: Drag.Automatic
            Drag.onDragStarted: {
                main.draggedStream = item.model.PulseObject;
                beginMoveStream(item.type === "sink-input" ? "sink" : "source");
            }
            Drag.onDragFinished: {
                main.draggedStream = null;
                endMoveStream();
            }
        }

        ColumnLayout {
            id: column
            spacing: 0

            RowLayout {
                Layout.minimumHeight: contextMenuButton.implicitHeight
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    spacing: 0
                    Layout.maximumWidth: Infinity // Ignore maximum width of children
                    visible: (item.type === "sink" || item.type === "source") && item.ListView.view.count > 1

                    PC3.RadioButton {
                        id: defaultButton
                        // Maximum width of the button need to match the text. Empty area must not change the default device.
                        Layout.maximumWidth: item.availableWidth - Layout.leftMargin - Layout.rightMargin
                            - (contextMenuButton.visible ? contextMenuButton.implicitWidth + Kirigami.Units.smallSpacing * 2 : 0)
                        Layout.leftMargin: !mirrored ? Math.round((muteButton.width - defaultButton.indicator.width) / 2) : 0
                        Layout.rightMargin: mirrored ? Math.round((muteButton.width - defaultButton.indicator.width) / 2) : 0
                        spacing: Kirigami.Units.smallSpacing + Math.round((muteButton.width - defaultButton.indicator.width) / 2)
                        checked: item.model.PulseObject?.default ?? false
                        onToggled: {
                            if (checked) {
                                item.setAsDefault();
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    visible: !defaultButton.visible
                    implicitHeight: Math.max(friendlyDescriptionLabel.implicitHeight, longDescriptionLabel.implicitHeight)

                    // User-friendly name
                    PC3.Label {
                        id: friendlyDescriptionLabel

                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        width: Math.min(implicitWidth, parent.width)

                        text: defaultButton.text
                        elide: Text.ElideRight

                        HoverHandler {
                            id: labelHoverHandler
                            enabled: item.fullNameToShowOnHover !== ""
                        }
                    }

                    // Possibly not user-friendly description; only show on hover
                    PC3.Label {
                        id: longDescriptionLabel

                        anchors {
                            left: friendlyDescriptionLabel.right
                            leftMargin: Kirigami.Units.smallSpacing
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }

                        visible: width > 0 && opacity > 0
                        opacity: labelHoverHandler.hovered ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Kirigami.Units.shortDuration
                                easing.type: Easing.InOutQuad
                            }
                        }

                        // Not a word puzzle because this is not a translated string
                        text: "(" + item.fullNameToShowOnHover + ")"
                        elide: Text.ElideRight
                    }
                }

                SmallToolButton {
                    id: contextMenuButton
                    icon.name: "application-menu"
                    checked: contextMenu.visible && contextMenu.visualParent === this
                    onPressed: {
                        contextMenu.visualParent = this;
                        contextMenu.openRelative();
                    }
                    visible: contextMenu.hasContent

                    text: i18nc("@action:button", "Additional Options")

                    Accessible.description: i18n("Show additional options for %1", defaultButton.text)
                    Accessible.role: Accessible.ButtonMenu

                    PC3.ToolTip {
                        text: parent.Accessible.description
                    }
                }
            }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                SmallToolButton {
                    id: muteButton
                    readonly property bool isPlayback: item.type.startsWith("sink")
                    icon.name: AudioIcon.forVolume(volumePercent(item.model.Volume), item.model.Muted, isPlayback ? "audio-volume" : "microphone-sensitivity")
                    onClicked: item.model.Muted = !item.model.Muted
                    checked: item.model.Muted

                    text: item.model.Muted ? i18nc("@action:button", "Unmute") : i18nc("@action:button", "Mute")

                    Accessible.description: item.model.Muted ? i18n("Unmute %1", defaultButton.text) : i18n("Mute %1", defaultButton.text)

                    PC3.ToolTip {
                        text: parent.Accessible.description
                    }
                }

                VolumeSlider {
                    id: slider

                    readonly property bool forceRaiseMaxVolume: (raiseMaximumVolumeCheckbox.checked && (item.type === "sink" || item.type === "source"))

                    Layout.fillWidth: true
                    from: PulseAudio.MinimalVolume
                    to: forceRaiseMaxVolume || item.model.Volume >= PulseAudio.NormalVolume * 1.01 ? PulseAudio.MaximalVolume : PulseAudio.NormalVolume
                    stepSize: PulseAudio.NormalVolume / 100.0
                    property real myStepSize: PulseAudio.NormalVolume / 100.0 * config.volumeStep
                    visible: item.model.HasVolume !== false // Devices always have volume but Streams don't necessarily
                    enabled: item.model.VolumeWritable
                    muted: item.model.Muted
                    volumeObject: item.model.PulseObject
                    Accessible.name: i18nc("Accessibility data on volume slider", "Adjust volume for %1", defaultButton.text)
                    Accessible.onPressAction: moved()

                    value: to, item.model.Volume
                    function increase() { value = value + myStepSize }
                    function decrease() { value = value - myStepSize }
                    onMoved: {
                        item.model.Volume = value;
                        item.model.Muted = value === 0;
                    }
                    onPressedChanged: {
                        if (!pressed) {
                            // Make sure to sync the volume once the button was
                            // released.
                            // Otherwise it might be that the slider is at v10
                            // whereas PA rejected the volume change and is
                            // still at v15 (e.g.).
                            value = Qt.binding(() => item.model.Volume);
                            if (type === "sink") {
                                playFeedback(item.model.Index);
                            }
                        }
                    }
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

                    function updateVolume() {
                        if (!forceRaiseMaxVolume && item.model.Volume > PulseAudio.NormalVolume) {
                            item.model.Volume = PulseAudio.NormalVolume;
                        }
                    }

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
                PC3.Label {
                    id: percentText
                    readonly property real value: item.model.PulseObject.volume > slider.to ? item.model.PulseObject.volume : slider.value
                    readonly property real displayValue: Math.round(value / PulseAudio.NormalVolume * 100.0)
                    Layout.alignment: Qt.AlignHCenter
                    Layout.minimumWidth: percentMetrics.advanceWidth
                    horizontalAlignment: Qt.AlignRight
                    text: i18nc("volume percentage", "%1%", displayValue)
                    // Display a subtle visual indication that the volume
                    // might be dangerously high
                    // ------------------------------------------------
                    // Keep this in sync with the copies in VolumeSlider.qml
                    // and plasma-workspace:OSDItem.qml
                    color: {
                        if (displayValue <= AudioIcon.HIGH_UPPER_BOUND) {
                            return Kirigami.Theme.textColor
                        } else if (displayValue > AudioIcon.HIGH_UPPER_BOUND && displayValue <= AudioIcon.VERY_HIGH_UPPER_BOUND) {
                            return Kirigami.Theme.neutralTextColor
                        } else {
                            return Kirigami.Theme.negativeTextColor
                        }
                    }
                }

                TextMetrics {
                    id: percentMetrics
                    font: percentText.font
                    text: i18nc("only used for sizing, should be widest possible string", "100%")
                }
            }
        }
    }

    MouseArea {
        z: -1
        parent: item
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton | Qt.RightButton
        onPressed: mouse => {
            if (mouse.button === Qt.RightButton && contextMenu.hasContent) {
                contextMenu.visualParent = this;
                contextMenu.open(mouse.x, mouse.y);
            }
        }
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                item.model.Muted = !item.model.Muted;
            }
        }
    }

    DropArea {
        id: dropArea
        z: -1
        parent: item
        anchors.fill: parent
        enabled: main.draggedStream && main.draggedStream.deviceIndex !== item.model.Index
        onDropped: drop => {
            main.draggedStream.deviceIndex = item.model.Index;
        }
    }

    ListItemMenu {
        id: contextMenu
        pulseObject: item.model.PulseObject
        cardModel: main.paCardModel
        itemType: {
            switch (item.type) {
            case "sink":
                return ListItemMenu.Sink;
            case "sink-input":
                return ListItemMenu.SinkInput;
            case "source":
                return ListItemMenu.Source;
            case "source-output":
                return ListItemMenu.SourceOutput;
            }
        }
        sourceModel: if (item.type.startsWith("sink")) {
            return main.paSinkFilterModel
        }  else if (item.type.startsWith("source")) {
            return main.paSourceFilterModel
        }
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
