/*
    SPDX-FileCopyrightText: 2011 Marco Martin <notmart@gmail.com>
    SPDX-FileCopyrightText: 2014, 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.notifications as Notifications

PlasmaComponents3.ScrollView {
    id: bodyTextContainer

    property alias text: bodyText.text

    property int cursorShape

    property QtObject contextMenu: null
    property ListView listViewParent: null

    signal clicked(var mouse)
    signal linkActivated(string link)

    leftPadding: mirrored && !Kirigami.Settings.isMobile ? PlasmaComponents3.ScrollBar.vertical.width : 0
    rightPadding: !mirrored && !Kirigami.Settings.isMobile ? PlasmaComponents3.ScrollBar.vertical.width : 0

    PlasmaComponents3.TextArea {
        id: bodyText
        enabled: !Kirigami.Settings.isMobile
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        background: null
        color: Kirigami.Theme.textColor

        // Selectable only when we are in desktop mode
        selectByMouse: !Kirigami.Settings.tabletMode

        readOnly: true
        wrapMode: TextEdit.Wrap
        textFormat: TextEdit.RichText

        onLinkActivated: bodyTextContainer.linkActivated(link)

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: bodyTextContainer.clicked(null)
        }

        TapHandler {
            acceptedButtons: Qt.RightButton
            cursorShape: {
                if (bodyText.hoveredLink) {
                    return Qt.PointingHandCursor;
                } else if (bodyText.selectionStart !== bodyText.selectionEnd) {
                    return Qt.IBeamCursor;
                } else {
                    return bodyTextContainer.cursorShape || Qt.IBeamCursor;
                }
            }
            onTapped: eventPoint => {
                contextMenu = contextMenuComponent.createObject(bodyText);
                contextMenu.link = bodyText.linkAt(eventPoint.position.x, eventPoint.position.y);

                contextMenu.closed.connect(function() {
                    contextMenu.destroy();
                    contextMenu = null;
                });
                contextMenu.open(eventPoint.position.x, eventPoint.position.y);
            }
        }
        MouseArea {
            id: scrollMA
            anchors.fill: parent
            visible: bodyTextContainer.listViewParent !== null
            propagateComposedEvents: true
            onPressed: mouse => {
                mouse.accepted = false
            }
            onReleased: mouse => {
                mouse.accepted = false
            }
            onWheel: wheel => {

                var listView = bodyTextContainer.listViewParent;

                if (wheel.angleDelta.y < 0) {
                    //make sure not to scroll too far
                    if (!listView.atYEnd)
                        listView.contentY -= wheel.angleDelta.y / 2
                }
                else {
                    //make sure not to scroll too far
                    if (!listView.atYBeginning)
                        listView.contentY -= wheel.angleDelta.y / 2

                }
                if(listView.verticalOvershoot != 0.0) {
                    listView.contentY += -listView.verticalOvershoot
                }
            }

        }
    }

    Component {
        id: contextMenuComponent

        EditContextMenu {
            target: bodyText
        }
    }
}
