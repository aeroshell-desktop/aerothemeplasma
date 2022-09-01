/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.5 as Kirigami

T.Menu {
    id: control

    palette: Kirigami.Theme.palette
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : 0)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem ? contentItem.implicitHeight : 0) + topPadding + bottomPadding

    delegate: MenuItem { width: parent.width; onImplicitWidthChanged: control.contentItem.contentItem.childrenChanged() }

    margins: 0
    leftPadding: background.margins.left
    topPadding: background.margins.top
    rightPadding: background.margins.right
    bottomPadding: background.margins.bottom

    contentItem: ListView {
        implicitHeight: contentHeight
        property bool hasCheckables: false
        property bool hasIcons: false
        model: control.contentModel

        implicitWidth: {
            var maxWidth = 0;
            for (var i = 0; i < contentItem.children.length; ++i) {
                maxWidth = Math.max(maxWidth, contentItem.children[i].implicitWidth);
            }
            return maxWidth;
        }

        interactive: ApplicationWindow.window ? contentHeight > ApplicationWindow.window.height : false
        clip: true
        currentIndex: control.currentIndex || 0
        keyNavigationEnabled: true
        keyNavigationWraps: true

        T.ScrollBar.vertical: ScrollBar {}
    }

    Connections {
        target: control.contentItem.contentItem

        function onChildrenChanged() {
            for (var i in control.contentItem.contentItem.children) {
                var child = control.contentItem.contentItem.children[i];
                if (child.checkable) {
                    control.contentItem.hasCheckables = true;
                }
                if (child.icon && child.icon.hasOwnProperty("name") && (child.icon.name.length > 0 || child.icon.source.length > 0)) {
                    control.contentItem.hasIcons = true;
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            easing.type: Easing.InOutQuad
            duration: PlasmaCore.Units.shortDuration
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            easing.type: Easing.InOutQuad
            duration: PlasmaCore.Units.shortDuration
        }
    }

    background: PlasmaCore.FrameSvgItem {
        imagePath: "widgets/background"
        implicitWidth: PlasmaCore.Units.gridUnit * 8
        implicitHeight: PlasmaCore.Units.gridUnit * 2
    }
}
