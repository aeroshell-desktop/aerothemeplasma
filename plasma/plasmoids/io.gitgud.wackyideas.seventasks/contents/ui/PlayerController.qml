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
    readonly property bool isPlaying: root.playerData.playbackStatus === Mpris.PlaybackStatus.Playing

    spacing: 0

    Item {
        Layout.fillWidth: true
    }

    MediaButton {
        id: previousBtn
        orientation: "left"
        mediaIcon: "previous"
        onClicked: root.playerData.Previous();
        enableButton: root.playerData.canGoPrevious
        iconWidth: 13
        iconHeight: 11
    }
    MediaButton {
        id: playbackBtn
        orientation: "center"
        mediaIcon: isPlaying ? "pause" : "play"
        onClicked: {
            if(isPlaying) root.playerData.Pause();
            else root.playerData.Play();
        }
        enableButton: root.playerData.canPause || root.playerData.canPlay
        iconWidth: isPlaying ? 10 : 12
        iconHeight: isPlaying ? 11 : 13
    }
    MediaButton {
        id: skipBtn
        orientation: Plasmoid.configuration.showMuteBtn ? "center" : "right"
        mediaIcon: "skip"
        onClicked: root.playerData.Next();
        enableButton: root.playerData.canGoNext
        iconWidth: 13
        iconHeight: 11
    }
    MediaButton {
        id: muteBtn
        orientation: "right"
        mediaIcon: root.parentTask.muted ? "unmute" : "mute"
        onClicked: root.parentTask.toggleMuted();
        enableButton: visible
        visible: Plasmoid.configuration.showMuteBtn
        iconWidth: root.parentTask.muted ? 16 : 17
        iconHeight: 14
    }
    Item {
        Layout.fillWidth: true
    }
}
