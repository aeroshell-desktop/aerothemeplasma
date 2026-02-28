/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

AbstractItem {
    id: taskIcon

    itemId: model.Id
    text: model.Title || model.ToolTipTitle
    mainText: model.ToolTipTitle !== "" ? model.ToolTipTitle : model.Title
    subText: model.ToolTipSubTitle
    textFormat: Text.AutoText

    Kirigami.Icon {
        id: iconItem
        parent: taskIcon.iconContainer
        anchors.fill: iconItem.parent

        source: {
            if (model.status === PlasmaCore.Types.NeedsAttentionStatus) {
                if (model.AttentionIcon) {
                    return model.AttentionIcon
                }
                if (model.AttentionIconName) {
                    return model.AttentionIconName
                }
            }
            return model.Icon || model.IconName
        }
        active: false//taskIcon.containsMouse
    }

    onActivated: pos => {
        if (model.ItemIsMenu) {
            Plasmoid.openContextMenu(model.DataEngineSource, pos, taskIcon);
            return;
        }

        Plasmoid.activate(model.DataEngineSource, pos, taskIcon)
    }

    onContextMenu: mouse => {
        if (mouse === null) {
            Plasmoid.openContextMenu(model.DataEngineSource, Plasmoid.popupPosition(taskIcon, taskIcon.width / 2, taskIcon.height / 2), taskIcon);
        } else {
            Plasmoid.openContextMenu(model.DataEngineSource, Plasmoid.popupPosition(taskIcon, mouse.x, mouse.y), taskIcon);
        }
    }

    onClicked: mouse => {
        var pos = Plasmoid.popupPosition(taskIcon, mouse.x, mouse.y);

        switch (mouse.button) {
        case Qt.LeftButton:
            taskIcon.activated(pos)
            break;
        case Qt.RightButton:
            Plasmoid.openContextMenu(model.DataEngineSource, pos, taskIcon);
            break;
        case Qt.MiddleButton:
            Plasmoid.secondaryActivate(model.DataEngineSource, pos)
            break;
        }
    }

    onWheel: wheel => {
        //don't send activateVertScroll with a delta of 0, some clients seem to break (kmix)
        if (wheel.angleDelta.y !== 0) {
            Plasmoid.scroll(model.DataEngineSource, wheel.angleDelta.y, "Vertical")
        }
        if (wheel.angleDelta.x !== 0) {
            Plasmoid.scroll(model.DataEngineSource, wheel.angleDelta.x, "Horizontal")
        }
    }
}
