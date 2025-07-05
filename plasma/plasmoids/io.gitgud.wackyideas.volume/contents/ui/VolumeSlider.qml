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
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.volume
import Qt5Compat.GraphicalEffects
import org.kde.plasma.core as PlasmaCore

// Audio volume slider. Value represents desired volume level in
// device-specific units, while volume property reports current volume level
// normalized to 0..1 range.
PC3.Slider {
    id: control

    property VolumeObject volumeObject

    // When muted, the whole slider will appear slightly faded, but remain
    // functional and interactive.
    property bool muted: false

    // Current (monitored) volume. To be animated. Do not update too fast
    // (i.e. faster or close to screen refresh rate), otherwise it won't
    // animate smoothly.
    property real volume: meter.volume

    property string type

    VolumeMonitor {
        id: meter
        target: control.visible ? control.volumeObject : null
    }

    opacity: muted ? 0.5 : 1
    // Prevents the groove from showing through the handle

    wheelEnabled: false
    orientation: Qt.Vertical
    // `wheelEnabled: true` doesn't work we can't both respect stepsize
    // on scroll and allow fine-tuning on drag.
    // So we have to implement the scroll handling ourselves. See
    // https://bugreports.qt.io/browse/QTBUG-93081
    WheelHandler {
        orientation: Qt.Vertical | Qt.Horizontal
        property int wheelDelta: 0
        acceptedButtons: Qt.NoButton
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: wheel => {
            const lastValue = control.value
            // We want a positive delta to increase the slider for up/right scrolling,
            // independently of the scrolling inversion setting
            // The x-axis is also inverted (scrolling right produce negative values)
            const delta = (wheel.angleDelta.y || -wheel.angleDelta.x) * (wheel.inverted ? -1 : 1)
            wheelDelta += delta;
            // magic number 120 for common "one click"
            // See: https://doc.qt.io/qt-6/qml-qtquick-wheelevent.html#angleDelta-prop
            while (wheelDelta >= 120) {
                wheelDelta -= 120;
                control.increase();
            }
            while (wheelDelta <= -120) {
                wheelDelta += 120;
                control.decrease();
            }
            if (lastValue !== control.value) {
                control.moved();
            }
        }     
    }
    ToolTip {
        x: Math.max(-25, Math.floor(-implicitWidth-2))
        y: Math.floor(-parent.height / 2)
        parent: control.handle
        visible: control.pressed
        text: Math.round(control.value / PulseAudio.NormalVolume * 100.0)
        delay: 0
    }
    handle: KSvg.SvgItem {
        id: volumeHandle
        implicitWidth: 18
        implicitHeight: 10
        x: Math.round(1 + control.leftPadding + (horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2))
        y: Math.round(control.topPadding + (horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height)))

        imagePath: Qt.resolvedUrl("svgs/control.svg")
        elementId: {
            if(control.pressed) return "scursor-pressed";
            if(control.hovered) return "scursor-focused";
            return "scursor-normal";
        }
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 1
            verticalOffset: 1
            color: "#30000000"
            radius: 0
            cached: true
            samples: 3
        }


    }
    background: Item {
        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        width: 22

        KSvg.FrameSvgItem {
            id: bg

            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            width: 6 //isStream ? 4 : 6

            imagePath: "widgets/slider"
            prefix: "groove"

            x: 3

            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                }

                height: 40

                color: "orange"

                opacity: 0.5

                visible: (type == "sink-output" || type == "sink-input") && config.raiseMaximumVolume
            }

            Rectangle {
                id: grayBar

                anchors {
                    left: parent.left
                    leftMargin: 1
                    bottom: parent.bottom
                }

                width: greenBar.width
                implicitHeight: greenBar.height
                Behavior on implicitHeight {
                    NumberAnimation { duration: grayBar.height > greenBar.height ? (Kirigami.Units.shortDuration / 2) : 1 }
                }

                color: "gray"
                radius: 1

                opacity: 0.5

                visible: greenBar.visible
            }

            Rectangle {
                id: greenBar

                anchors {
                    left: parent.left
                    leftMargin: 1
                    bottom: parent.bottom
                }

                height: Math.round(control.volume * control.position * control.availableHeight) - 3 // remove 3 pixels to avoid overflow
                width: parent.width - 1

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#33ca33" }
                    GradientStop { position: 1.0; color: "#339a33" }
                }
                radius: 1

                visible: meter.available && control.volume > 0
            }
        }
        Item {
            anchors {
                left: bg.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                bottomMargin: 1
            }

            Rectangle {
                anchors {
                    right: parent.right
                    left: parent.left
                    top: parent.top
                }

                height: 1

                color: "#cfcfcf"
            }

            Rectangle {
                anchors {
                    right: parent.right
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                height: 1

                color: "#cfcfcf"
            }

            Rectangle {
                anchors {
                    right: parent.right
                    left: parent.left
                    bottom: parent.bottom
                }

                height: 1

                color: "#cfcfcf"
            }

            KSvg.SvgItem {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                width: 10

                imagePath: Qt.resolvedUrl("svgs/control.svg")
                elementId: "bgthing"
            }
        }
    }
}
