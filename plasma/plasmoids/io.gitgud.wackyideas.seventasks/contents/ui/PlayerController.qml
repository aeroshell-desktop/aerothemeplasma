/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2017 Roman Gilg <subdiff@gmail.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mpris as Mpris

RowLayout {
    property QtObject root

    readonly property bool isPlaying: root.playerData.playbackStatus === Mpris.PlaybackStatus.Playing

    spacing: -1

    Item {
        Layout.fillWidth: true
    }

    KSvg.FrameSvgItem {
        id: previousBtn

        property string state: backMa.containsMouse ? (backMa.containsPress ? "-pressed" : "-hover") : ""

        Layout.preferredWidth: 26
        Layout.preferredHeight: 24

        imagePath: Qt.resolvedUrl("svgs/toolbuttons.svg")
        prefix: "left" + state

        KSvg.SvgItem {
            anchors.centerIn: parent

            width: 13
            height: 11

            imagePath: Qt.resolvedUrl("svgs/media-icons.svg")
            elementId: root.playerData.canGoPrevious ? "previous" : "previous-disabled"

            opacity: root.playerData.canGoPrevious ? 1.0 : 0.5
        }

        MouseArea {
            id: backMa

            anchors.fill: parent

            hoverEnabled: true
            propagateComposedEvents: true

            onClicked: root.playerData.Previous();

            visible: root.playerData.canGoPrevious
        }
    }
    KSvg.FrameSvgItem {
        id: playbackBtn

        property string state: playbackMa.containsMouse ? (playbackMa.containsPress ? "-pressed" : "-hover") : ""

        Layout.preferredWidth: 27
        Layout.preferredHeight: 24

        imagePath: Qt.resolvedUrl("svgs/toolbuttons.svg")
        prefix: "center" + state

        KSvg.SvgItem {
            anchors.centerIn: parent

            width: isPlaying ? 10 : 12
            height: isPlaying ? 11 : 13

            imagePath: Qt.resolvedUrl("svgs/media-icons.svg")
            elementId: isPlaying ? (root.playerData.canPause ? "pause" : "pause-disabled") : (root.playerData.canPlay ? "play" : "play-disabled")

            opacity: root.playerData.canPause || root.playerData.canPlay ? 1.0 : 0.5
        }

        MouseArea {
            id: playbackMa

            anchors.fill: parent

            hoverEnabled: true
            propagateComposedEvents: true

            visible: root.playerData.canPause || root.playerData.canPlay

            onClicked: {
                if(isPlaying) root.playerData.Pause();
                else root.playerData.Play();
            }
        }
    }
    KSvg.FrameSvgItem {
        id: skipBtn

        property string state: skipMa.containsMouse ? (skipMa.containsPress ? "-pressed" : "-hover") : ""

        Layout.preferredWidth: 25
        Layout.preferredHeight: 24

        imagePath: Qt.resolvedUrl("svgs/toolbuttons.svg")
        prefix: Plasmoid.configuration.showMuteBtn ? ("center" + state) : ("right" + state)

        KSvg.SvgItem {
            anchors.centerIn: parent

            width: 13
            height: 11

            imagePath: Qt.resolvedUrl("svgs/media-icons.svg")
            elementId: root.playerData.canGoNext ? "skip" : "skip-disabled"

            opacity: root.playerData.canGoNext ? 1.0 : 0.5
        }

        MouseArea {
            id: skipMa

            anchors.fill: parent

            hoverEnabled: true
            propagateComposedEvents: true

            onClicked: root.playerData.Next();

            visible: root.playerData.canGoNext
        }
    }

    KSvg.FrameSvgItem {
        id: muteBtn

        property string state: muteMa.containsMouse ? (muteMa.containsPress ? "-pressed" : "-hover") : ""

        Layout.preferredWidth: 26
        Layout.preferredHeight: 24

        imagePath: Qt.resolvedUrl("svgs/toolbuttons.svg")
        prefix: "right" + state

        KSvg.SvgItem {
            anchors.centerIn: parent

            width: root.parentTask.muted ? 16 : 17
            height: 14

            imagePath: Qt.resolvedUrl("svgs/media-icons.svg")
            elementId: root.parentTask.muted ? "unmute" : "mute"
        }

        MouseArea {
            id: muteMa

            anchors.fill: parent

            hoverEnabled: true
            propagateComposedEvents: true

            onClicked: root.parentTask.toggleMuted();
        }

        visible: Plasmoid.configuration.showMuteBtn
    }

    Item {
        Layout.fillWidth: true
    }
}
