/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import plasma.applet.io.gitgud.wackyideas.notifications as Notifications

RowLayout {
    id: replyRow

    // implicitWidth will keep being rewritten by the Layout itself
    Layout.maximumWidth: Notifications.Globals.popupWidth
    required property ModelInterface modelInterface

    signal beginReplyRequested

    spacing: Kirigami.Units.smallSpacing

    function activate() {
        replyTextField.forceActiveFocus(Qt.ActiveWindowFocusReason);
    }

    Binding {
        target: replyRow.modelInterface
        property: "hasPendingReply"
        value: replyTextField.text !== ""
    }
    PlasmaComponents3.TextField {
        id: replyTextField
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Theme.defaultFont.pointSize + Kirigami.Units.mediumSpacing*2
        placeholderText: replyRow.modelInterface.replyPlaceholderText
                         || i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Text field placeholder", "Type a reply…")
        Accessible.name: placeholderText
        onAccepted: {
            if (replyButton.enabled) {
                replyRow.modelInterface.replied(text);
            }
        }

        // Catches mouse click when reply field is already shown to start a reply
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            visible: !replyRow.modelInterface.replying
            Accessible.name: "begin reply"
            Accessible.role: Accessible.Button
            Accessible.onPressAction: replyRow.beginReplyRequested()
            onClicked: mouse => {
                mouse.accepted = true
                replyRow.beginReplyRequested()
            }
        }
    }

    PlasmaComponents3.Button {
        id: replyButton
        Layout.preferredHeight: Kirigami.Theme.defaultFont.pointSize + Kirigami.Units.mediumSpacing*2
        icon.name: replyRow.modelInterface.replySubmitButtonIconName || "document-send"
        text: replyRow.modelInterface.replySubmitButtonText
              || i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "@action:button", "Send")
        enabled: replyTextField.length > 0
        onClicked: replyRow.modelInterface.replied(replyTextField.text)
    }
}
