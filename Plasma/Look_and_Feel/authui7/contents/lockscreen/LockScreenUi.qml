/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQml 2.15
import QtQuick 2.8
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.workspace.components 2.0 as PW
import org.kde.kirigami 2.13 as Kirigami

import org.kde.plasma.private.sessions 2.0
import "../components"

PlasmaCore.ColorScope {

    id: lockScreenUi
    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    property bool hadPrompt: false;
    property int currentPage: 0;

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    function setWrongPasswordScreen(msg) {
        root.clearPassword();
        currentMessage.text = msg;
        currentMessageIcon.source = "dialog-error";
        currentPage = 2;
        dismissButton.focus = true;
    }
    Connections {
        target: authenticator
        function onFailed() {
            if (root.notification) {
                root.notification += "\n"
            }
            setWrongPasswordScreen("The user name or password is incorrect.");
            lockScreenUi.hadPrompt = false;
        }

        function onSucceeded() {
            if (lockScreenUi.hadPrompt) {
                Qt.quit();
            } else {
                currentPage = 4;
                noPasswordArea.forceActiveFocus();
            }
        }

        function onInfoMessage(msg) {
            root.clearPassword();
            currentMessage.text = msg;
            currentMessageIcon.source = "dialog-info";
            currentPage = 2;
            dismissButton.focus = true;
        }

        function onErrorMessage(msg) {

        }

        function onPrompt(msg) {
            root.notification = msg;
            passwordArea.mainPasswordBox.forceActiveFocus();
            lockScreenUi.hadPrompt = true;
        }
        function onPromptForSecret(msg) {
            passwordArea.mainPasswordBox.forceActiveFocus();
            lockScreenUi.hadPrompt = true;
        }
    }

    SessionManagement {
        id: sessionManagement
    }

    Connections {
        target: sessionManagement
        function onAboutToSuspend() {
            root.clearPassword();
        }
    }

    SessionsModel {
        id: sessionsModel
        showNewSessionEntry: false
    }

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Loader {
        id: changeSessionComponent
        active: false
        source: "ChangeSession.qml"
        visible: false
    }

    WallpaperFader {
        anchors.fill: parent
        source: wallpaper
    }

    Loader {
            id: inputPanel
            state: "hidden"
            readonly property bool keyboardActive: item ? item.active : false
            anchors {
                left: parent.left
                right: parent.right
                bottom: lockScreenUi.bottom
            }
            function showHide() {
                state = state == "hidden" ? "visible" : "hidden";
            }
            Component.onCompleted: {
                inputPanel.source = Qt.platform.pluginName.includes("wayland") ? "../components/VirtualKeyboard_wayland.qml" : "../components/VirtualKeyboard.qml"
            }

            onKeyboardActiveChanged: {
                if (keyboardActive) {
                    inputPanel.z = 99;
                    state = "visible";
                } else {
                    state = "hidden";
                }
            }

            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: lockScreenRoot
                        height: lockScreenUi.height - inputPanel.height;
                        //y: 0 - inputPanel.height + passwordArea.height - (switchuserButton.height + switchuserButton.anchors.topMargin);
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: lockScreenRoot.height - inputPanel.height
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: lockScreenRoot
                        height: lockScreenUi.height;
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: lockScreenRoot.height - lockScreenRoot.height/4
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: lockScreenRoot
                                property: "height"
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: lockScreenRoot
                                property: "height"
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = false;
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }

    MouseArea {
        id: lockScreenRoot

        property bool calledUnlock: false

        Component.onCompleted: {
            if (!calledUnlock) {
                calledUnlock = true
                authenticator.tryUnlock();
            }
        }

        x: parent.x
        y: parent.y
        width: parent.width
        height: parent.height
        hoverEnabled: true
        drag.filterChildren: true
        Keys.onEscapePressed: {
            if (inputPanel.keyboardActive) {
                inputPanel.showHide();
            }
        }
        Keys.onPressed: {
            event.accepted = false;
        }
        GenericButton {
            id: switchLayoutButton
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                leftMargin: 7
            }
            implicitWidth: 35
            implicitHeight: 28
            label.font.pointSize: 9
            label.font.capitalization: Font.AllUppercase
            focusPolicy: Qt.TabFocus
            Accessible.description: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to change keyboard layout", "Switch layout")

            PW.KeyboardLayoutSwitcher {
                id: keyboardLayoutSwitcher

                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }

            text: keyboardLayoutSwitcher.layoutNames.shortName
            onClicked: keyboardLayoutSwitcher.keyboardLayout.switchToNextLayout()

            visible: keyboardLayoutSwitcher.hasMultipleKeyboardLayouts
        }

        ListModel {
            id: users

            Component.onCompleted: {
                users.append({
                    name: kscreenlocker_userName,
                    realName: kscreenlocker_userName,
                    icon: kscreenlocker_userImage,
                })
            }
        }


        MainBlock {
            id: passwordArea
            anchors.centerIn: parent
            visible: currentPage == 0
            focus: true

            onPasswordResult: {
                // Switch to the 'Welcome' screen
                currentPage = 1;

                authenticator.respond(password)
            }

            notificationMessage: {
                if (keystateSource.data["Caps Lock"]["Locked"]) {
                    return i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Caps Lock is on");
                } else {
                    return "";
                }
            }
        }
        NoPasswordUnlock {
            id: noPasswordArea
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: switchuserButton.top
            anchors.bottomMargin: 52
            visible: currentPage == 4
            onClicked: {
                Qt.quit();
            }
        }
        GenericButton {
            id: switchuserButton
            visible: currentPage == 0 || currentPage == 4
            label.font.pointSize: 11
            implicitWidth: 108
            implicitHeight: 28
            focusPolicy: Qt.TabFocus

            Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Switch User")
            PlasmaComponents3.Label {
                font.pointSize: 11
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Switch User")
                anchors.fill: parent
                anchors.bottomMargin: PlasmaCore.Units.smallSpacing / 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                layer.enabled: true
                layer.effect: DropShadow {
                    //visible: !softwareRendering
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 6
                    samples: 14
                    spread: 0.0001
                    color: "#bf000000"
                }
            }
            onClicked: {
                sessionsModel.startNewSession(true /* lock the screen too */)
                lockScreenRoot.state = ''
                passwordArea.mainPasswordBox.forceActiveFocus();
            }
            anchors {
                top: passwordArea.bottom
                topMargin: (currentPage == 4 ? 36 : 40) / (inputPanel.keyboardActive ? 4 : 1) // for some reason, Microsoft offset Windows 7's Switch User button a bit when in no password lock
                horizontalCenter: parent.horizontalCenter
            }
        }
        RowLayout {
            visible: currentPage == 0 || currentPage == 4
            id: footer
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 34
            }

            EoAButton {
            }

            OSKButton {
                onClicked: {
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    passwordArea.mainPasswordBox.forceActiveFocus();
                    inputPanel.showHide()
                }

                visible: inputPanel.status == Loader.Ready
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Item {
            id: welcomePage
            visible: currentPage == 1
            anchors.fill: parent
            Status {
                id: statusText
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -36
                statusText: i18nd("okular", "Welcome")
                speen: welcomePage.visible
            }
        }

        ColumnLayout {
            id: messagePage
            visible: currentPage == 2
            anchors {
                bottom: switchuserButton.bottom
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 0
            RowLayout {
                spacing: 10
                Kirigami.Icon {
                    id: currentMessageIcon
                    implicitHeight: 32
                    implicitWidth: 32
                }
                Label {
                    id: currentMessage
                    Layout.alignment: Qt.AlignHCenter
                    font.pointSize: 9

                    width: implicitWidth
                    color: "white"
                    horizontalAlignment: Text.AlignCenter
                    layer.enabled: true
                    layer.effect: DropShadow {
                        //visible: !softwareRendering
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 6
                        samples: 14
                        spread: 0.0001
                        color: "#bf000000"
                    }
                }
            }
            Item {
                height: 40
            }
            GenericButton {
                id: dismissButton
                Layout.alignment: Qt.AlignHCenter
                font.pointSize: 11
                implicitWidth: 93
                implicitHeight: 28
                focusPolicy: Qt.TabFocus

                Accessible.name: "OK"
                text: "OK"
                onClicked: {
                    authenticator.tryUnlock();
                    currentPage = 0;
                    passwordArea.mainPasswordBox.forceActiveFocus();
                }
            }
        }


        RowLayout {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: 96
            Rectangle { Layout.fillWidth: true }
            Image {
                id: watermark
                source: "../images/watermark.png"
                opacity: !inputPanel.keyboardActive
            }
            Rectangle { Layout.fillWidth: true }
        }

        Loader {
            active: true
            source: "LockOsd.qml"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: PlasmaCore.Units.largeSpacing
            }
        }
    }
}
