/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.8

import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15

import Qt5Compat.GraphicalEffects

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kscreenlocker 1.0 as ScreenLocker
import "../components"

ColumnLayout {
    //id: sessionManager
    property Item mainPasswordBox: passwordBox
    property alias echoMode: passwordBox.echoMode
    property alias notificationMessage: notificationsLabel.text

    /*
     * Login has been requested with the following username and password
     * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
     */
    signal passwordResult(string password)


    /*onUserSelected: {

    }*/
    Component.onCompleted: {
        const nextControl = (passwordBox.visible ? passwordBox : loginButton);
        // Don't startLogin() here, because the signal is connected to the
        // Escape key as well, for which it wouldn't make sense to trigger
        // login. Using TabFocusReason, so that the loginButton gets the
        // visual highlight.
        nextControl.forceActiveFocus(Qt.TabFocusReason);
    }

    function startLogin() {
        const password = passwordBox.text

        // This is partly because it looks nicer, but more importantly it
        // works round a Qt bug that can trigger if the app is closed with a
        // TextField focused.
        //
        // See https://bugreports.qt.io/browse/QTBUG-55460
        loginButton.forceActiveFocus();
        passwordResult(password);
    }


    id: contents
    anchors.centerIn: parent
    spacing: 0
    PFPContainer {
        avatarPath: kscreenlocker_userImage
        Layout.alignment: Qt.AlignHCenter
    }

    Label {
        id: usernameDelegate
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: 18

        width: parent.width
        text: kscreenlocker_userName
        color: "white"
        horizontalAlignment: Text.AlignCenter
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferFullHinting
        font.kerning: false
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

    Label {
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: 9

        width: implicitWidth
        text: "Locked"
        color: "white"
        horizontalAlignment: Text.AlignCenter
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferFullHinting
        font.kerning: false
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

    Item {
        height: 6
    }

    RowLayout {
        Item {
            height: loginButton.height
            width: loginButton.width
        }

        /*AuthuiTextbox {
            id: passwordBox
            font.pointSize: 9
            implicitWidth: 225

            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: true
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            enabled: !authenticator.graceLocked
            revealPasswordButtonShown: true

            // In Qt this is implicitly active based on focus rather than visibility
            // in any other application having a focussed invisible object would be weird
            // but here we are using to wake out of screensaver mode
            // We need to explicitly disable cursor flashing to avoid unnecessary renders
            cursorVisible: visible

            onAccepted: {
                startLogin()
            }

            //if empty and left or right is pressed change selection in user switch
            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
            Keys.onPressed: {
                if (event.key == Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key == Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true
                }
            }

            Connections {
                target: root
                function onClearPassword() {
                    passwordBox.forceActiveFocus()
                    passwordBox.text = "";
                }
            }
        }*/
        AuthuiTextbox {
            id: passwordBox
            font.pointSize: 9
            implicitWidth: 225

            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: true
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            //enabled: !authenticator.graceLocked
            //revealPasswordButtonShown: true

            // In Qt this is implicitly active based on focus rather than visibility
            // in any other application having a focussed invisible object would be weird
            // but here we are using to wake out of screensaver mode
            // We need to explicitly disable cursor flashing to avoid unnecessary renders
            cursorVisible: visible

            onClicked: {
                loginButton.clicked()
            }

            Connections {
                target: root
                function onClearPassword() {
                    passwordBox.forceActiveFocus()
                    passwordBox.text = "";
                }
            }
        }

        GoButton {
            id: loginButton

            onClicked: startLogin()
            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()
        }
    }
    RowLayout {
        spacing: 2
        Layout.alignment: Qt.AlignHCenter
        visible: notificationsLabel.text != ""
        Kirigami.Icon {
            source: "dialog-warning"
            implicitHeight: 16
            implicitWidth: 16
        }
        Label {
            id: notificationsLabel
            font.pointSize: 9

            width: implicitWidth
            color: "white"
        }
    }
    Item {
        height: Math.max(16, notificationsLabel.height)
        visible: notificationsLabel.text == ""
    }
    component FailableLabel : PlasmaComponents3.Label {
        id: _failableLabel
        required property int kind
        required property string label

        visible: authenticator.authenticatorTypes & kind
        text: label
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true

        /*RejectPasswordAnimation {
            id: _rejectAnimation
            target: _failableLabel
            onFinished: _timer.restart()
        }*/

        Connections {
            target: authenticator
            function onNoninteractiveError(kind, authenticator) {
                if (kind & _failableLabel.kind) {
                    _failableLabel.text = Qt.binding(() => authenticator.errorMessage)
                    _timer.restart()
                }
            }
        }
        Timer {
            id: _timer
            interval: Kirigami.Units.humanMoment
            onTriggered: {
                _failableLabel.text = Qt.binding(() => _failableLabel.label)
            }
        }
    }

    FailableLabel {
        kind: ScreenLocker.Authenticator.Fingerprint
        label: i18nd("plasma_shell_org.kde.plasma.desktop", "(or scan your fingerprint on the reader)")
    }
    FailableLabel {
        kind: ScreenLocker.Authenticator.Smartcard
        label: i18nd("plasma_shell_org.kde.plasma.desktop", "(or scan your smartcard)")
    }
}
