/*
    SPDX-FileCopyrightText: 2017, 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.2

import org.kde.plasma.private.volume 0.1

QtObject {
    id: pulseAudio

    readonly property string notificationStreamId: "sink-input-by-media-role:event"

    property QtObject notificationStream

    property QtObject instantiator: Instantiator {
        model: StreamRestoreModel {}

        delegate: QtObject {
            readonly property string name: Name
            readonly property bool muted: Muted

            function mute() {
                Muted = true
            }
            function unmute() {
                Muted = false
            }
        }

        onObjectAdded: (index, object) => {
            if (object.name === notificationStreamId) {
                notificationStream = object;
            }
        }
    }
}
