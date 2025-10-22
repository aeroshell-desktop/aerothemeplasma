/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

PlasmaComponents3.StackView {
    id: actionContainer

    property ModelInterface modelInterface

    implicitWidth: currentItem.Layout.maximumWidth < Infinity ? currentItem.Layout.maximumWidth : currentItem.implicitWidth
    implicitHeight: currentItem.implicitHeight

    function beginReply() {
        modelInterface.replying = true;
        modelInterface.forceActiveFocusRequested();
        if (currentItem === actionRow) {
            push(replyFieldComponent);
        }
        currentItem.activate()
    }

    pushEnter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: Kirigami.Units.longDuration
            easing.type: Easing.Linear
        }
    }
    pushExit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.Linear
        }
    }

    // Notification actions
    initialItem: (actionContainer.modelInterface.hasReplyAction && (actionContainer.modelInterface.actionNames || []).length === 0) ? replyFieldComponent : actionRow
    RowLayout {
        id: actionRow
        visible: actionContainer.currentItem === actionRow
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Repeater {
            id: actionRepeater

            model: {
                const buttons = [];
                const actionNames = (actionContainer.modelInterface.actionNames || []);
                const actionLabels = (actionContainer.modelInterface.actionLabels || []);

                for (let i = 0; i < actionNames.length; ++i) {
                    buttons.push({
                        actionName: actionNames[i],
                        label: actionLabels[i]
                    });
                }

                if (actionContainer.modelInterface.hasReplyAction) {
                    buttons.unshift({
                        actionName: "inline-reply",
                        label: actionContainer.modelInterface.replyActionLabel || i18nc("Reply to message", "Reply")
                    });
                }

                if (actionContainer.modelInterface.inHistory && actionContainer.modelInterface.addDefaultAction) {
                    buttons.unshift({
                        actionName: "default",
                        label: actionContainer.modelInterface.defaultActionLabel
                    });
                }

                return buttons;
            }

            PlasmaComponents3.ToolButton {
                Layout.fillWidth: true
                Layout.maximumWidth: implicitWidth
                Layout.leftMargin: index > 0 ? Kirigami.Units.smallSpacing : 0
                Layout.preferredHeight: Kirigami.Theme.defaultFont.pointSize + Kirigami.Units.mediumSpacing*2
                bottomInset: 0
                padding: 0

                flat: false
                // why does it spit "cannot assign undefined to string" when a notification becomes expired?
                text: modelData.label || ""

                onClicked: {
                    if (modelData.actionName === "inline-reply") {
                        actionContainer.beginReply();
                        return;
                    }

                    actionContainer.modelInterface.actionInvoked(modelData.actionName);
                }
            }
        }
    }

    Component {
        id: replyFieldComponent
        NotificationReplyField {
            modelInterface: actionContainer.modelInterface
            onBeginReplyRequested: actionContainer.beginReply()
        }
    }
}
