/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.12 as QQC2

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kirigami 2.20 as Kirigami

import org.kde.breeze.components
import "timer.js" as AutoTriggerTimer

import org.kde.plasma.private.sessions 2.0

Item {
    id: root
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    height: screenGeometry.height
    width: screenGeometry.width

    signal logoutRequested()
    signal haltRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal cancelRequested()
    signal lockScreenRequested()
    signal cancelSoftwareUpdateRequested()

    property alias backgroundColor: backgroundRect.color

    function sleepRequested() {
        root.suspendRequested(2);
    }

    function hibernateRequested() {
        root.suspendRequested(4);
    }

    property real timeout: 30
    property real remainingTime: root.timeout

    property var currentAction: {
        switch (sdtype) {
        case ShutdownType.ShutdownTypeReboot:
            return () => root.rebootRequested();
        case ShutdownType.ShutdownTypeHalt:
            return () => root.haltRequested();
        default:
            return () => root.logoutRequested();
        }
    }

    readonly property bool showAllOptions: sdtype === ShutdownType.ShutdownTypeDefault

    KCoreAddons.KUser {
        id: kuser
    }

    // For showing a "other users are logged in" hint
    SessionsModel {
        id: sessionsModel
        includeUnusedSessions: false
    }

    QQC2.Action {
        onTriggered: root.cancelRequested()
        shortcut: "Escape"
    }

    onRemainingTimeChanged: {
        if (remainingTime <= 0) {
            (root.currentAction)();
        }
    }

    Timer {
        id: countDownTimer
        running: !root.showAllOptions
        repeat: true
        interval: 1000
        onTriggered: remainingTime--
        Component.onCompleted: {
            AutoTriggerTimer.addCancelAutoTriggerCallback(function() {
                countDownTimer.running = false;
            });
        }
    }

    function isLightColor(color) {
        return Math.max(color.r, color.g, color.b) > 0.5
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        //use "black" because this is intended to look like a general darkening of the scene. a dark gray as normal background would just look too "washed out"
        color: root.isLightColor(Kirigami.Theme.backgroundColor) ? Kirigami.Theme.backgroundColor : "black"
        opacity: 0.5
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelRequested()
    }
    UserDelegate {
        width: Kirigami.Units.gridUnit * 8
        height: Kirigami.Units.gridUnit * 9
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.verticalCenter
        }
        constrainText: false
        avatarPath: kuser.faceIconUrl
        iconSource: "user-identity"
        isCurrent: true
        name: kuser.fullName
    }
    ColumnLayout {
        id: column

        anchors {
            top: parent.verticalCenter
            topMargin: Kirigami.Units.gridUnit * 2
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Kirigami.Units.largeSpacing

        height: Math.max(implicitHeight, Kirigami.Units.gridUnit * 10)
        width: Math.max(implicitWidth, Kirigami.Units.gridUnit * 16)

        PlasmaComponents.Label {
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
            Layout.alignment: Qt.AlignHCenter
            //opacity, as visible would re-layout
            opacity: countDownTimer.running ? 1 : 0
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            text: {
                switch (sdtype) {
                    case ShutdownType.ShutdownTypeReboot:
                        return softwareUpdatePending ? i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Installing software updates and restarting in 1 second", "Installing software updates and restarting in %1 seconds", root.remainingTime)
                        : i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Restarting in 1 second", "Restarting in %1 seconds", root.remainingTime);
                    case ShutdownType.ShutdownTypeNone:
                        return i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Logging out in 1 second", "Logging out in %1 seconds", root.remainingTime);
                    case ShutdownType.ShutdownTypeHalt:
                    default:
                        return i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Shutting down in 1 second", "Shutting down in %1 seconds", root.remainingTime);
                }
            }
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
            Layout.maximumWidth: Math.max(Kirigami.Units.gridUnit * 16, logoutButtonsRow.implicitWidth)
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
            text: i18ndp("plasma_lookandfeel_org.kde.lookandfeel",
                         "One other user is currently logged in. If the computer is shut down or restarted, that user may lose work.",
                         "%1 other users are currently logged in. If the computer is shut down or restarted, those users may lose work.",
                         sessionsModel.count - 1)
            textFormat: Text.PlainText
            visible: sessionsModel.count > 1
        }

        PlasmaComponents.Label {
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
            Layout.maximumWidth: Math.max(Kirigami.Units.gridUnit * 16, logoutButtonsRow.implicitWidth)
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "When restarted, the computer will enter the firmware setup screen.")
            textFormat: Text.PlainText
            visible: rebootToFirmwareSetup
        }

        RowLayout {
            id: logoutButtonsRow
            spacing: Kirigami.Units.gridUnit * 2
            Layout.topMargin: Kirigami.Units.gridUnit * 2 - column.spacing
            Layout.alignment: Qt.AlignHCenter
            LogoutButton {
                id: suspendButton
                iconSource: "system-suspend"
                text: root.showAllOptions ? i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Suspend to RAM", "Sleep")
                                          : i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Suspend to RAM", "Sleep Now")
                onClicked: root.sleepRequested()
                KeyNavigation.left: cancelButton
                KeyNavigation.right: hibernateButton.visible ? hibernateButton : (rebootButton.visible ? rebootButton : (shutdownButton.visible ? shutdownButton : (logoutButton.visible ? logoutButton : cancelButton)))
                visible: spdMethods.SuspendState && root.showAllOptions
            }
            LogoutButton {
                id: hibernateButton
                iconSource: "system-suspend-hibernate"
                text: root.showAllOptions ? i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Hibernate")
                                          : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Hibernate Now")
                onClicked: root.hibernateRequested()
                KeyNavigation.left: suspendButton.visible ? suspendButton : cancelButton
                KeyNavigation.right: rebootButton.visible ? rebootButton : (shutdownButton.visible ? shutdownButton : (logoutButton.visible ? logoutButton : cancelButton))
                visible: spdMethods.HibernateState && root.showAllOptions
            }
            LogoutButton {
                id: rebootButton
                iconSource: softwareUpdatePending ? "update-none" : "system-reboot"
                text: {
                    if (softwareUpdatePending) {
                        return root.showAllOptions ? i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "@action:button Keep short", "Install Updates & Restart")
                                                   : i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "@action:button Keep short", "Install Updates & Restart Now")
                    } else {
                        return root.showAllOptions ? i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                                                   : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart Now")
                    }
                }
                onClicked: root.rebootRequested()
                KeyNavigation.left: hibernateButton.visible ? hibernateButton : (suspendButton.visible ? suspendButton : cancelButton)
                KeyNavigation.right: rebootWithoutUpdatesButton.visible ? rebootWithoutUpdatesButton : (shutdownButton.visible ? shutdownButton : (logoutButton.visible ? logoutButton : cancelButton))
                focus: sdtype === ShutdownType.ShutdownTypeReboot
                visible: maysd && (sdtype === ShutdownType.ShutdownTypeReboot || root.showAllOptions)
            }
            LogoutButton {
                id: rebootWithoutUpdatesButton
                iconSource: "system-reboot"
                text: root.showAllOptions ? i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                                          : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart Now")
                onClicked: {
                    root.cancelSoftwareUpdateRequested()
                    root.rebootRequested()
                }
                KeyNavigation.left: rebootButton
                KeyNavigation.right: shutdownButton.visible ? shutdownButton : (logoutButton.visible ? logoutButton : cancelButton)
                visible: maysd && softwareUpdatePending && (sdtype === ShutdownType.ShutdownTypeReboot || root.showAllOptions)
            }
            LogoutButton {
                id: shutdownButton
                iconSource: "system-shutdown"
                text: root.showAllOptions ? i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                                          : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down Now")
                onClicked: root.haltRequested()
                KeyNavigation.left: rebootWithoutUpdatesButton.visible ? rebootWithoutUpdatesButton : (rebootButton.visible ? rebootButton : (hibernateButton.visible ? hibernateButton : (suspendButton.visible ? suspendButton : cancelButton)))
                KeyNavigation.right: logoutButton.visible ? logoutButton : cancelButton
                focus: sdtype === ShutdownType.ShutdownTypeHalt || root.showAllOptions
                visible: maysd && (sdtype === ShutdownType.ShutdownTypeHalt || root.showAllOptions)
            }
            LogoutButton {
                id: logoutButton
                iconSource: "system-log-out"
                text: root.showAllOptions ? i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log Out")
                                          : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log Out Now")
                onClicked: root.logoutRequested()
                KeyNavigation.left: shutdownButton.visible ? shutdownButton : (rebootWithoutUpdatesButton.visible ? rebootWithoutUpdatesButton : (rebootButton.visible ? rebootButton : (hibernateButton.visible ? hibernateButton : (suspendButton.visible ? suspendButton : cancelButton))))
                KeyNavigation.right: cancelButton
                focus: sdtype === ShutdownType.ShutdownTypeNone
                visible: canLogout && (sdtype === ShutdownType.ShutdownTypeNone || root.showAllOptions)
            }
            LogoutButton {
                id: cancelButton
                iconSource: "dialog-cancel"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Cancel")
                onClicked: root.cancelRequested()
                KeyNavigation.left: logoutButton.visible ? logoutButton : (shutdownButton.visible ? shutdownButton : (rebootWithoutUpdatesButton.visible ? rebootWithoutUpdatesButton : (rebootButton.visible ? rebootButton : (hibernateButton.visible ? hibernateButton : suspendButton))))
                KeyNavigation.right: suspendButton.visible ? suspendButton : (hibernateButton.visible ? hibernateButton : rebootButton)
            }
        }
    }
}
