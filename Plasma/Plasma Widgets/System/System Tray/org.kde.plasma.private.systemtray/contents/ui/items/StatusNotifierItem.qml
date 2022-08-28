/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore

AbstractItem {
    id: taskIcon

    itemId: model.Id
    text: model.Title || model.ToolTipTitle
    mainText: model.ToolTipTitle !== "" ? model.ToolTipTitle : model.Title
    subText: model.ToolTipSubTitle
    textFormat: Text.AutoText

    PlasmaCore.IconItem {
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
            return model.Icon ? model.Icon : model.IconName
        }
        active: taskIcon.containsMouse
    }

    onContextMenu: {
        openContextMenu(plasmoid.nativeInterface.popupPosition(taskIcon, mouse.x, mouse.y))
    }

    onClicked: {
        var pos = plasmoid.nativeInterface.popupPosition(taskIcon, mouse.x, mouse.y);
        var service = model.Service;

        switch (mouse.button) {
        case Qt.LeftButton:
            var operation = service.operationDescription("Activate");
            operation.x = pos.x;
            operation.y = pos.y;
            var job = service.startOperationCall(operation);
            job.finished.connect(function () {
                if (!job.result) {
                    // On error try to invoke the context menu.
                    // Workaround primarily for apps using libappindicator.
                    openContextMenu(pos);
                }
            });
            taskIcon.activated()
            break;
        case Qt.RightButton:
            openContextMenu(pos);
            break;

        case Qt.MiddleButton:
            var operation = service.operationDescription("SecondaryActivate");
            operation.x = pos.x;

            operation.y = pos.y;
            service.startOperationCall(operation);
            taskIcon.activated()
            break;
        }
    }

    function openContextMenu(pos) {
        var service = model.Service;
        var operation = service.operationDescription("ContextMenu");
        operation.x = pos.x;
        operation.y = pos.y;

        var job = service.startOperationCall(operation);
        job.finished.connect(function () {
            plasmoid.nativeInterface.showStatusNotifierContextMenu(job, taskIcon);
        });
    }

    onWheel: {
        //don't send activateVertScroll with a delta of 0, some clients seem to break (kmix)
        if (wheel.angleDelta.y !== 0) {
            var service = model.Service;
            var operation = service.operationDescription("Scroll");
            operation.delta =wheel.angleDelta.y;
            operation.direction = "Vertical";
            service.startOperationCall(operation);
        }
        if (wheel.angleDelta.x !== 0) {
            var service = model.Service;
            var operation = service.operationDescription("Scroll");
            operation.delta =wheel.angleDelta.x;
            operation.direction = "Horizontal";
            service.startOperationCall(operation);
        }
    }
}
