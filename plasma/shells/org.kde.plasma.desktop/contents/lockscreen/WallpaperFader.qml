/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: wallpaperFader
    property alias source: wallpaperBlur.source
    property real factor: 1

    FastBlur { /* Forced by KDE for some reason to be able to show the background */
        id: wallpaperBlur
        anchors.fill: parent
        radius: 0
    }
    ShaderEffect {
        id: wallpaperShader
        anchors.fill: parent
        supportsAtlasTextures: true
        property var source: ShaderEffectSource {
            sourceItem: wallpaperBlur
            live: true
            hideSource: true
            textureMirroring: ShaderEffectSource.NoMirroring
        }
    }
}
