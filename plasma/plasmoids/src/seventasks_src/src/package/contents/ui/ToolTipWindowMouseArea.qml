/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.0

import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    property var modelIndex
    property var closeBtn
    // winId won't be available on wayland, only on X11.
    property var winId // FIXME Legacy
    property Item rootTask
    property double opacityHover: 0;
    property ScrollableTextWrapper title1;
    property ScrollableTextWrapper title2;
    property bool firstHover: false
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    hoverEnabled: true
    enabled: winId !== 0
    y: 0

    onClicked: {
        if (mouse.button == Qt.LeftButton) {
            tasksModel.requestActivate(modelIndex);
            rootTask.hideToolTipTemporarily();
            backend.cancelHighlightWindows();
        } else if (mouse.button == Qt.MiddleButton) {
            backend.cancelHighlightWindows();
            tasksModel.requestClose(modelIndex);
        } else /* right button */ {
            // Creates a context menu for the task pointed to by the tooltip.
            rootTask.toolTipAreaItem.hideImmediately();
            rootTask.tasksMenu = tasks.createTasksMenu(rootTask, modelIndex);
            rootTask.tasksMenu.menuDecoration = icon;
            rootTask.tasksMenu.show();
            plasmoid.nativeInterface.setMouseGrab(true, rootTask.tasksMenu);
        }
    }
    
    
    onEntered: {
        tasks.windowsHovered([winId], 1);
        opacityHover = 1;
    }
    onExited: {
        tasks.windowsHovered([winId], 0);
        opacityHover = 0;
    }
    
    Component.onCompleted: {
        tasks.windowsHovered([winId], 0);
        opacityHover = 0;
    }
}
