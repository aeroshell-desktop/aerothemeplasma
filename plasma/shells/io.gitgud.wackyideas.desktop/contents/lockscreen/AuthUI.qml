/*
 * SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2023 Nate Graham <nate@kde.org>
 * SPDX-FileCopyrightText: 2026 catpswin56 <catpswin5@proton.me>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Effects

import QtMultimedia

import org.kde.kirigami as Kirigami
import org.kde.kscreenlocker as ScreenLocker
import org.kde.kirigamiaddons.sounds

import org.kde.plasma.workspace.components as PW
import org.kde.plasma.plasma5support as Plasma5Support

import aeroshell.utils as AeroShellUtils

import "../components" as Components

Item {
    id: root

    signal switchUserClicked()

    property string notification
    property string notificationIcon

    property alias switchUserVisible: switchUser.visible
    property bool  capsLockOn: false

    function resetFocus(clear: bool) {
        if(clear) password.clear();
        password.forceActiveFocus();
    }

    function beginAuth() {
        if(!authenticator.graceLocked && password.enabled) {
            authenticator.startAuthenticating();
            pageView.replaceCurrentItem(welcomePage);
        }
    }

    function showMessage(message: string, icon: string) {
        if(!statusPage.visible) {
            pageView.replaceCurrentItem(statusPage);
            k.forceActiveFocus();
        }
        root.notification = message;
        root.notificationIcon = icon;
    }

    component CorrectedLabel: Text {
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferFullHinting

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "black"
            shadowOpacity: 1.0
            shadowBlur: 0.35
            shadowVerticalOffset: 1
        }
    }

    component InfoLabel: RowLayout {
        property alias icon: icon
        property alias text: lbl.text

        spacing: 2

        visible: root.capsLockOn

        Item { Layout.fillWidth: true }

        Kirigami.Icon {
            id: icon
            implicitHeight: 16
            implicitWidth: 16
        }

        CorrectedLabel {
            id: lbl
            font.pointSize: 9
            color: "white"
        }

        Item { Layout.fillWidth: true }
    }

    Connections {
        target: authenticator

        function onFailed() {
            showMessage(i18nd("kscreenlocker_greet", "The user name or password is incorrect."), "dialog-error");
        }
        function onBusyChanged() {
            if(!authenticator.busy) {
                root.notification = "";
                root.notificationIcon = "";
            }
        }
        function onInfoMessageChanged() {
            showMessage(authenticator.infoMessage, "dialog-information");
        }
        function onErrorMessageChanged() {
            showMessage(authenticator.errorMessage, "dialog-error");
        }
        function onPromptForSecretChanged() {
            authenticator.respond(password.text);
        }
        function onSucceeded() {
            lockSuccess.play();
            fadeExitDelay.start();
        }
    }

    // BEGIN LOGIN SOUND HACK
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
            exited(stdout, sourceName)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd) {
            if (cmd) {
                connectSource(cmd)
            }
        }
        signal exited(string stdout, string cmd)
    }
    Connections {
        target: executable
        function onExited(stdout, cmd) {
            soundsModel.theme = stdout.trim() ? stdout.trim() : "ocean";
            for(var i = 0; i < soundsModel.rowCount(); i++) {
                var str = soundsModel.initialSourceUrl(i);
                if(str.includes("desktop-login") && !str.endsWith(".license")) {
                    lockSuccess.source = str;
                    break;
                }
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
    // END LOGIN SOUND HACK

    Component.onCompleted: {
        executable.exec("kreadconfig6 --file ~/.config/kdeglobals --group Sounds --key Theme");
        root.resetFocus();
    }

    Timer {
        id: fadeExitDelay
        interval: 400
        onTriggered: fadeExit.start();
    }

    Timer {
        id: quitDelay
        interval: 100
        onTriggered: Qt.quit();
    }

    SequentialAnimation {
        id: fadeExit

        NumberAnimation { target: fadeRect; property: "opacity"; from: 0; to: 1; duration: 600 }
        ScriptAction { script: quitDelay.start(); }
    }

    AeroShellUtils.SDDM { id: sddm }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: sddm.currentBackground
    }

    Item {
        id: uiRoot

        width: parent.width
        height: parent.height

        Timer {
            id: authTimeout
            interval: 3000
            onTriggered: {
                password.enabled = true;
            }
        }
        QQC2.StackView {
            id: pageView

            anchors.fill: parent

            initialItem: mainPage
            replaceEnter: Transition {}
            replaceExit: Transition {}

            property bool firstTime: false
            onCurrentItemChanged: {
                if(currentItem == mainPage && firstTime) {
                    password.enabled = false;
                    authTimeout.start();
                } else {
                    firstTime = true;
                }
            }

            Item {
                id: mainPage

                visible: pageView.currentItem == mainPage

                ColumnLayout {
                    id: loginColumn

                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: Math.round(bigSpaceForNoReason.height / 2)

                    spacing: 0

                    PFPContainer {
                        Layout.alignment: Qt.AlignHCenter
                        avatarPath: kscreenlocker_userImage
                    }

                    CorrectedLabel {
                        id: usernameDelegate

                        Layout.alignment: Qt.AlignHCenter

                        font.pointSize: 18
                        text: kscreenlocker_userName
                        color: "white"
                    }

                    CorrectedLabel {
                        Layout.alignment: Qt.AlignHCenter
                        color: "white"
                        text: i18nd("kscreenlocker_greet", "Locked")
                    }

                    Item { implicitHeight: Kirigami.Units.smallSpacing - 1 }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter

                        spacing: Kirigami.Units.smallSpacing

                        Item { implicitWidth: login.width }

                        QQC2.TextField {
                            id: password

                            Layout.alignment: Qt.AlignHCenter

                            implicitWidth: 225

                            enabled: loginMa.enabled
                            font.pointSize: 9
                            text: PasswordSync.password
                            leftPadding: 8
                            rightPadding: 8
                            topPadding: 4
                            bottomPadding: 4
                            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
                            echoMode: TextInput.Password
                            inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                            background: BorderImage {
                                anchors.fill: parent

                                border {
                                    left: 4
                                    right: 4
                                    top: 4
                                    bottom: 4
                                }
                                source: {
                                    if(password.focus && password.enabled) return "../images/textbox/focus.png";
                                    else if(password.hovered && password.enabled) return "../images/textbox/hover.png";
                                    else if(password.enabled) return "../images/textbox/normal.png";
                                    else return "../images/textbox/disabled.png";
                                }
                            }

                            Keys.onEnterPressed: root.beginAuth();
                            Keys.onReturnPressed: root.beginAuth();
                            Keys.onEscapePressed: {
                                password.text = ""
                                password.text = Qt.binding(() => PasswordSync.password)
                            }

                            Binding {
                                target: PasswordSync
                                property: "password"
                                value: password.text
                            }
                        }

                        Image {
                            id: login

                            activeFocusOnTab: true

                            source: {
                                if(loginMa.pressed && loginMa.enabled) return "../images/login-pressed.png";
                                else if(loginMa.containsMouse && loginMa.enabled) return "../images/login-hover.png";
                                else return "../images/login-normal.png";
                            }

                            opacity: loginMa.enabled ? 1.0 : 0.5

                            MouseArea {
                                id: loginMa

                                anchors.fill: parent

                                hoverEnabled: true
                                enabled: !authenticator.busy
                                onClicked: root.beginAuth();
                            }
                        }
                    }

                    ColumnLayout {
                        id: bigSpaceForNoReason

                        Layout.fillWidth: true
                        Layout.preferredHeight: 61

                        InfoLabel {
                            Layout.fillWidth: true

                            text: i18nd("kscreenlocker_greet", "Caps Lock is on");
                            icon.source: "dialog-warning"
                        }

                        InfoLabel {
                            Layout.fillWidth: true

                            text: i18nd("kscreenlocker_greet", "(or place your fingerprint on the reader)")
                            icon.source: "dialog-information"

                            visible: authenticator.authenticatorTypes & ScreenLocker.Authenticator.Fingerprint
                        }
                        InfoLabel {
                            Layout.fillWidth: true

                            text: i18nd("kscreenlocker_greet", "(or use your smartcard)")
                            icon.source: "dialog-information"

                            visible: authenticator.authenticatorTypes & ScreenLocker.Authenticator.Smartcard
                        }

                        Item { Layout.fillHeight: true }
                    }

                    Components.GenericButton {
                        id: switchUser

                        Layout.alignment: Qt.AlignHCenter

                        implicitWidth: 108
                        implicitHeight: 30

                        focusPolicy: Qt.TabFocus
                        text: i18nd("kscreenlocker_greet", "Switch User")
                        label.font.pointSize: 11

                        onClicked: root.switchUserClicked()
                    }
                }
            }

            Item {
                id: welcomePage

                visible: pageView.currentItem == welcomePage

                Components.Status {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -36

                    statusText: i18nd("okular", "Welcome")
                    speen: welcomePage.visible
                }
            }

            Item {
                id: statusPage

                visible: pageView.currentItem == statusPage
                onVisibleChanged: k.forceActiveFocus();

                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: Math.round(loginColumn.height / 2)

                    spacing: 40

                    RowLayout {
                        Kirigami.Icon {
                            implicitHeight: 32
                            implicitWidth: 32

                            source: root.notificationIcon
                        }

                        CorrectedLabel {
                            Layout.alignment: Qt.AlignVCenter
                            color: "white"
                            text: root.notification
                        }
                    }

                    Components.GenericButton {
                        id: k

                        signal accepted()
                        onAccepted: {
                            pageView.replaceCurrentItem(mainPage);
                            root.resetFocus(true);
                        }

                        Layout.alignment: Qt.AlignHCenter

                        implicitWidth: 93
                        implicitHeight: 28

                        font.pointSize: 11
                        focusPolicy: Qt.TabFocus
                        Accessible.name: "OK"
                        text: "OK"
                        onClicked: accepted()

                        Keys.onReturnPressed: accepted()
                        Keys.onEnterPressed: accepted()
                    }
                }
            }
        }

        Components.GenericButton {
            id: switchLayoutButton

            anchors {
                top: parent.top
                left: parent.left

                leftMargin: 7
                topMargin: 5
            }

            implicitHeight: 28

            label.font.pointSize: 9
            label.font.capitalization: Font.AllUppercase
            focusPolicy: Qt.TabFocus
            Accessible.description: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to change keyboard layout", "Switch layout")
            text: keyboardLayoutSwitcher.layoutNames.shortName
            onClicked: keyboardLayoutSwitcher.keyboardLayout.switchToNextLayout()

            visible: keyboardLayoutSwitcher.hasMultipleKeyboardLayouts

            PW.KeyboardLayoutSwitcher {
                id: keyboardLayoutSwitcher

                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }
        }

        RowLayout {
            anchors {
                left: parent.left
                bottom: parent.bottom

                margins: 34
            }

            spacing: Kirigami.Units.largeSpacing

            Components.GenericButton {
                id: easeOfAccess
                iconSource: "access"
                opacity: pageView.currentItem == mainPage
            }

            Components.GenericButton {
                implicitHeight: easeOfAccess.height

                iconImage: "../images/osk.png"
                checked: inputPanel.keyboardActive
                onClicked: inputPanel.showHide();

                opacity: pageView.currentItem == mainPage
            }
        }
    }

    Image {
        anchors {
            horizontalCenter: parent.horizontalCenter

            bottom: parent.bottom
            bottomMargin: 23
        }

        source: "../images/branding.png"

        visible: opacity > 0
        opacity: !inputPanel.keyboardActive
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Loader {
        id: inputPanel

        readonly property bool keyboardActive: item ? item.active : false

        anchors {
            left: parent.left
            right: parent.right
            bottom: root.bottom

            leftMargin: Kirigami.Units.gridUnit*12
            rightMargin: Kirigami.Units.gridUnit*12
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

        state: "hidden"
        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: uiRoot
                    height: root.height - inputPanel.height;
                }
                PropertyChanges {
                    target: inputPanel
                    y: uiRoot.height - inputPanel.height
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: uiRoot
                    height: root.height;
                }
                PropertyChanges {
                    target: inputPanel
                    y: uiRoot.height - uiRoot.height/4
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
                            target: uiRoot
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
                            target: uiRoot
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

    Loader {
        anchors {
            horizontalCenter: parent.horizontalCenter

            top: parent.top
            topMargin: Kirigami.Units.largeSpacing
        }

        active: true
        source: "LockOsd.qml"
    }

    Rectangle {
        id: fadeRect
        anchors.fill: parent
        color: "black"
        opacity: 0
    }
}
