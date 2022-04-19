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
    // winId won't be an int wayland
    property var winId // FIXME Legacy
    property Item rootTask
    property double opacityHover: 0;
    property ScrollableTextWrapper title1;
    property ScrollableTextWrapper title2;
    property bool firstHover: false
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    hoverEnabled: true
    enabled: winId !== 0

    onClicked: {
        if (mouse.button == Qt.LeftButton) {
            tasksModel.requestActivate(modelIndex);
            rootTask.hideToolTipTemporarily();
            backend.cancelHighlightWindows();
        } else if (mouse.button == Qt.MiddleButton) {
            backend.cancelHighlightWindows();
            tasksModel.requestClose(modelIndex);
        } else /* right button */ {
            tasks.createContextMenu(rootTask, modelIndex).show();
        }
    }
    
    
    onEntered: {
            tasks.windowsHovered([winId], 1);
            opacityHover = 1;//containsMouse 
            //mouse.accepted = false;
    }
    onExited: {
        tasks.windowsHovered([winId], 0);
        opacityHover = 0;
        //mouse.accepted = false;
    }
    
    Component.onCompleted: {
        tasks.windowsHovered([winId], 0);
        opacityHover = 0;
        
    }
    /*onContainsMouseChanged: {
        tasks.windowsHovered([winId], containsMouse);
        opacityHover = containsMouse ? 1 : 0;
    }*/
}
