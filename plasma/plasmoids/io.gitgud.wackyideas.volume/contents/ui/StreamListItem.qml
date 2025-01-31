/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.private.volume

ListItemBase {
    id: item

    property PulseObjectFilterModel devicesModel
    isStream: true

    name: {
        if (model.Client && model.Client.name && model.Client.name != "pipewire-media-session") {
            return model.Client.name;
        }
        if (model.Name) {
            return model.Name;
        }
        return i18n("Stream name not found");
    }

    iconName: {
        if (model.IconName.length !== 0) {
            return model.IconName
        }

        if (item.type === "source-output") {
            return "audio-input-microphone"
        }

        return "audio-volume-high"
    }

    Rectangle {
        anchors.right: parent.right

        width: 1
        height: (item.height * 1.3) + (Kirigami.Units.smallSpacing / 2)

        color: "#d6e1dd"
    }
}
