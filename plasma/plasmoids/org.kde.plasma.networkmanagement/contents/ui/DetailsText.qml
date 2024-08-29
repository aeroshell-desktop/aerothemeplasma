/*
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.15

import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents3

MouseArea {
    height: detailsGrid.implicitHeight

    property string connectionTitle: ""
    property var details: []

    acceptedButtons: Qt.RightButton

    onPressed: mouse => {
        const item = detailsGrid.childAt(mouse.x, mouse.y);
        if (!item || !item.isContent) {
            return;
        }
        contextMenu.show(this, item.text, mouse.x, mouse.y);
    }

    KQuickControlsAddons.Clipboard {
        id: clipboard
    }

    PlasmaExtras.Menu {
        id: contextMenu
        property string text

        function show(item, text, x, y) {
            contextMenu.text = text
            visualParent = item
            open(x, y)
        }

        PlasmaExtras.MenuItem {
            text: i18n("Copy")
            icon: "edit-copy"
            enabled: contextMenu.text !== ""
            onClicked: clipboard.content = contextMenu.text
        }
    }

    PlasmaComponents3.Label {
        id: titleLabel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        //anchors.rightMargin: Kirigami.Units.smallSpacing / 2
        //anchors.leftMargin: Kirigami.Units.smallSpacing / 2
        anchors.topMargin: -Kirigami.Units.smallSpacing*2
        //horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        text: connectionTitle + " " + i18n("Details")
    }
    GridLayout {
        id: detailsGrid
        width: parent.width
        columns: 2
        rowSpacing: 1
        anchors.top: titleLabel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        //anchors.rightMargin: Kirigami.Units.smallSpacing / 2
        //anchors.leftMargin: Kirigami.Units.smallSpacing / 2
        anchors.topMargin: Kirigami.Units.smallSpacing

        Repeater {
            id: repeater

            model: details.length

            PlasmaComponents3.Label {
                Layout.fillWidth: true

                readonly property bool isContent: index % 2

                //elide: isContent ? Text.ElideRight : Text.ElideNone
                font: Kirigami.Theme.smallFont
                horizontalAlignment: isContent ? Text.AlignRight : Text.AlignLeft
                text: isContent ? details[index] : `${details[index]}:`
                textFormat: Text.PlainText
                opacity: isContent ? 1 : 0.6
            }
        }
    }
}
