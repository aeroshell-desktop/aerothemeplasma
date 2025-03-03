/*
    SPDX-FileCopyrightText: 2011 Marco Martin <notmart@gmail.com>
    SPDX-FileCopyrightText: 2014, 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts 1.1
import QtQuick.Controls as QQC2

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami
import Qt5Compat.GraphicalEffects

import org.kde.plasma.private.notifications as Notifications

QQC2.ScrollView {
    id: bodyTextContainer

    property alias text: bodyText.text

    property int cursorShape

    property QtObject contextMenu: null
    property ListView listViewParent: null
    hoverEnabled: true

    signal clicked(var mouse)
    signal linkActivated(string link)

    property bool scrollbarVisible: QQC2.ScrollBar.vertical.visible
    property double scrollBarPosition: QQC2.ScrollBar.vertical.position
    onScrollBarPositionChanged: {
        console.log("Start: " + bodyTextContainer.scrollBarPosition);
        console.log("Middle: " + (bodyTextContainer.scrollBarPosition + bodyTextContainer.scrollBarSize) / 2.0);
        console.log("End: " + (bodyTextContainer.scrollBarPosition + bodyTextContainer.scrollBarSize));
        console.log(1.0 - bodyTextContainer.scrollBarSize)

    }
    property real scrollBarSize: QQC2.ScrollBar.vertical.size
    QQC2.ScrollBar.vertical.opacity: scrollMA.scrollOpacity
    leftPadding: mirrored && !Kirigami.Settings.isMobile ? QQC2.ScrollBar.vertical.width+(QQC2.ScrollBar.vertical.width > 0 ? Kirigami.Units.smallSpacing : 0) : 0
    rightPadding: !mirrored && !Kirigami.Settings.isMobile ? QQC2.ScrollBar.vertical.width+(QQC2.ScrollBar.vertical.width > 0 ? Kirigami.Units.smallSpacing : 0) : 0

    PlasmaComponents3.TextArea {
        id: bodyText
        enabled: !Kirigami.Settings.isMobile
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        //visible: false
        opacity: (bodyText.hovered || bodyTextContainer.hovered || !bodyTextContainer.scrollbarVisible) ? 1 : 0.01

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        background: null
        color: Kirigami.Theme.textColor
        selectionColor: "#3399ff"

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
            hoverEnabled: true
            property double scrollOpacity: (bodyText.hovered || bodyTextContainer.hovered) ? 1 : 0
            Behavior on scrollOpacity {
                NumberAnimation { duration: 250 }
            }
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

    LinearGradient {
        id: mask
        anchors.fill: parent
        property double startPos: bodyTextContainer.scrollBarPosition
        property double endPos: bodyTextContainer.scrollBarPosition + bodyTextContainer.scrollBarSize
        property double middlePos: (startPos + endPos) / 2.0
        property bool atEnd: endPos == 1.0

        gradient: Gradient {
            GradientStop { position: mask.startPos; color: (bodyTextContainer.scrollBarPosition == 0.0) ? "white" : "#20000000" }
            GradientStop { position: mask.middlePos-0.1; color: "white" }
            GradientStop { position: mask.middlePos; color: "white" }
            GradientStop { position: mask.middlePos+0.1; color: "white" }
            GradientStop { position: mask.endPos; color: (mask.atEnd) ? "white" : "#20000000" }
        }
        visible: false
    }

    OpacityMask {
        anchors.fill: bodyText
        source: bodyText
        maskSource: mask
        opacity: (bodyText.hovered || bodyTextContainer.hovered || !bodyTextContainer.scrollbarVisible) ? 0 : 1
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Component {
        id: contextMenuComponent

        EditContextMenu {
            target: bodyText
        }
    }
}
