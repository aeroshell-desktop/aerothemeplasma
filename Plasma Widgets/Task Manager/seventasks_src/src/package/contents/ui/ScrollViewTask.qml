/*
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2017 The Qt Company Ltd.

    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/


import QtQuick 2.9
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.9 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

T.ScrollView {
    id: controlRoot
    
    //property alias scrollbarVertical: verticalScrollBar
    //property alias scrollbarHorizontal: horizontalScrollBar
    clip: true

    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentHeight + topPadding + bottomPadding)

    leftPadding: mirrored && T.ScrollBar.vertical && T.ScrollBar.vertical.visible && !Kirigami.Settings.isMobile ? T.ScrollBar.vertical.width : 0
    rightPadding: !mirrored && T.ScrollBar.vertical && T.ScrollBar.vertical.visible && !Kirigami.Settings.isMobile ? T.ScrollBar.vertical.width : 0
    bottomPadding: T.ScrollBar.horizontal && T.ScrollBar.horizontal.visible && !Kirigami.Settings.isMobile ? T.ScrollBar.horizontal.height : 0

    data: [
        Kirigami.WheelHandler {
            target: controlRoot.contentItem
        }
    ]

    /*PlasmaComponents3.ScrollBar.vertical: PlasmaComponents3.ScrollBar {
        id: verticalScrollBar
        readonly property Flickable flickableItem: controlRoot.contentItem
        onFlickableItemChanged: {
            flickableItem.clip = true;
        }
        parent: controlRoot
        x: controlRoot.mirrored ? 0 : controlRoot.width - width
        y: controlRoot.topPadding
        height: 0//controlRoot.availableHeight
        active: false//controlRoot.ScrollBar.vertical || controlRoot.ScrollBar.vertical.active
        
    }

    PlasmaComponents3.ScrollBar.horizontal: PlasmaComponents3.ScrollBar {
        id: horizontalScrollBar
        parent: controlRoot
        x: controlRoot.leftPadding
        y: controlRoot.height - height
        width: 0//controlRoot.availableWidth
        active: false//controlRoot.ScrollBar.horizontal || controlRoot.ScrollBar.horizontal.active
    }*/
}
