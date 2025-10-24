/*
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.0

Loader {
    id: itemLoader

    property real minLabelHeight: 0

    z: x+1 // always be above what it's on top of, even for x==0
    property var itemModel: model
    property string itemId: model.itemId

    Binding {
        target: item
        property: "minLabelHeight"
        value: itemLoader.minLabelHeight
    }
    source: {
        if (model.itemType === "Plasmoid" && model.hasApplet) {
            return Qt.resolvedUrl("PlasmoidItem.qml")
        } else if (model.itemType === "StatusNotifier") {
            return Qt.resolvedUrl("StatusNotifierItem.qml")
        }
        console.warn("SystemTray ItemLoader: Invalid state, cannot determine source!")
        return ""
    }
}
