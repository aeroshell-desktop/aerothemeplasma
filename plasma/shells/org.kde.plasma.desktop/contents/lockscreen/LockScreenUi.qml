/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQml 2.15
import QtQuick 2.8
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import Qt5Compat.GraphicalEffects
import QtCore

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.workspace.components 2.0 as PW
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kscreenlocker 1.0 as ScreenLocker
import org.kde.kirigamiaddons.sounds
import QtMultimedia
import org.kde.plasma.plasma5support as Plasma5Support
//import org.kde.breeze.components

import org.kde.plasma.private.sessions 2.0
import "../components"

Item {

    id: lockScreenUi
    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    property bool hadPrompt: false;
    property int currentPage: 0;

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false
    //colorGroup: PlasmaCore.Theme.ComplementaryColorGroup


    Rectangle {
        id: blackRect
        anchors.fill: parent
        color: "black"
        z: 99
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 600 }
        }
    }
    Timer {
        id: graceLockTimer
        interval: 3000
        onTriggered: {
            root.clearPassword();
            authenticator.startAuthenticating();
        }
    }
    Timer {
        id: successTimer
        interval: 800
        onTriggered: {
            Qt.quit();
        }
    }
    function setWrongPasswordScreen(msg) {
        root.clearPassword();
        currentMessage.text = msg;
        currentMessageIcon.source = "dialog-error";
        currentPage = 2;
        dismissButton.focus = true;
        //graceLockTimer.restart();
    }

    // This is probably the worst code I've ever written, just so that I can play a themed sound file slightly earlier, on time, instead of letting Plasma decide,
    // because Plasma plays the sounds too early/too late for this to be accurate, the biggest offender being the sound that plays when the user successfully logs
    // back into the session. Plasma plays it right as kscreenlocker closes, which is too late and sounds jarring as a result.
    // It literally executes a kreadconfig to read kdeglobals to extract the sound theme because I cannot for the life of me find the appropriate API calls
    // and then it manually *searches* for the appropriate sound file, because the SoundsModel component provided by kirigamiaddons (the only thing I could)
    // actually find at all, does not have a standard way of representing these sounds at all.
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"]
            exited(stdout)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd) {
            if (cmd) {
                connectSource(cmd)
            }
        }
        signal exited(string stdout)
    }
    Connections {
        target: executable
        function onExited(stdout) {
            soundsModel.theme = stdout.trim() ? stdout.trim() : "ocean";
            for(var i = 0; i < soundsModel.rowCount(); i++) {
                var str = soundsModel.initialSourceUrl(i);
                if(str.includes("desktop-login") && !str.endsWith(".license")) {
                    lockSuccess.source = str;
                    break;
                }
                /*if(str.includes("desktop-logout") && !str.endsWith(".license")) {
                    lockSound.source = str;
                    lockSound.play();
                }*/
            }

        }
    }
    SoundsModel {
        id: soundsModel
    }
    MediaPlayer {
        id: lockSuccess
        audioOutput: AudioOutput {}
    }
    /*MediaPlayer {
        id: lockSound
        audioOutput: AudioOutput {}
    }*/

    Connections {
        target: authenticator
        function onFailed(kind) {
            if (kind != 0) { // if this is coming from the noninteractive authenticators
                return;
            }
            if (root.notification) {
                root.notification += "\n"
            }
            setWrongPasswordScreen("The user name or password is incorrect.");
            lockScreenUi.hadPrompt = false;
        }
        function onSucceeded() {
            if (lockScreenUi.hadPrompt) {
                blackRect.opacity = 1;
                lockSuccess.play();
                successTimer.start();
            } else {
                currentPage = 4;
                noPasswordArea.forceActiveFocus();
            }
        }

        function onInfoMessageChanged() {
            root.clearPassword();
            currentMessage.text = authenticator.infoMessage;
            currentMessageIcon.source = "dialog-info";
            currentPage = 2;
            dismissButton.focus = true;
        }

        function onErrorMessageChanged() {
            console.log("ERROR " + authenticator.errorMessage);
        }

        function onPromptChanged() {
            root.notification = authenticator.prompt;
            passwordArea.mainPasswordBox.forceActiveFocus();
            lockScreenUi.hadPrompt = true;
        }
        function onPromptForSecretChanged() {
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

    KeyboardIndicator.KeyState {
        id: capsLockState
        key: Qt.Key_CapsLock
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
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: Kirigami.Units.longDuration
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
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: Kirigami.Units.longDuration
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
            executable.exec("kreadconfig6 --file ~/.config/kdeglobals --group Sounds --key Theme");
            if (!calledUnlock) {
                calledUnlock = true;
                authenticator.startAuthenticating();
                graceLockTimer.restart();
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
        Keys.onPressed: (event) => {
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

            //enabled: !authenticator.busy
            enabled: !graceLockTimer.running
            onPasswordResult: (password) => {
                // Switch to the 'Welcome' screen
                currentPage = 1;
                authenticator.startAuthenticating();
                authenticator.respond(password);
            }

            notificationMessage: {
                if (capsLockState.locked) {
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
                anchors.bottomMargin: Kirigami.Units.smallSpacing / 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferFullHinting
                font.kerning: false
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
                sessionManagement.switchUser();
                //sessionsModel.startNewSession(true /* lock the screen too */)
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
                    authenticator.startAuthenticating();
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
                topMargin: Kirigami.Units.largeSpacing
            }
        }
    }
}
