/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kquickcontrolsaddons as KQuickAddons
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

import org.kde.notificationmanager as NotificationManager
import plasma.applet.io.gitgud.wackyideas.notifications as NotificationsApplet
import org.kde.kwindowsystem

import "delegates" as Delegates

NotificationsApplet.NotificationWindow {
    id: notificationPopup

    property int popupWidth

    // Maximum width the popup can take to not break out of the screen geometry.
    readonly property int availableWidth: NotificationsApplet.Globals.screenRect.width - NotificationsApplet.Globals.popupEdgeDistance * 2 - leftPadding - rightPadding

    readonly property int minimumContentWidth: popupWidth
    readonly property int maximumContentWidth: Math.min((availableWidth > 0 ? availableWidth : Number.MAX_VALUE), popupWidth * 3)

    property alias modelInterface: notificationItem.modelInterface

    // Fixes the notification windows being shown at (0, 0) randomly
    property int intendedX
    property int intendedY

    onVisibleChanged: {
        if(visible && KWindowSystem.isPlatformX11) {
            if(x != intendedX) {
                x = intendedX;
            }
            if(y != intendedY) {
                y = intendedY;
            }
        }
    }
    onXChanged: {
        if(x != intendedX && KWindowSystem.isPlatformX11) {
            x = intendedX;
        }
    }
    onYChanged: {
        if(y != intendedY && KWindowSystem.isPlatformX11) {
            y = intendedY;
        }
    }

    property int modelTimeout
    property int dismissTimeout

    property var defaultActionFallbackWindowIdx

    signal expired
    signal hoverEntered
    signal hoverExited

    property int defaultTimeout: 5000
    readonly property int effectiveTimeout: {
        if (modelTimeout === -1) {
            return defaultTimeout;
        }
        if (dismissTimeout) {
            return dismissTimeout;
        }
        return modelTimeout;
    }

    // On wayland we need focus to copy to the clipboard, we change on mouse interaction until the cursor leaves
    takeFocus: notificationItem.modelInterface.replying || focusListener.wantsFocus

    visible: false

    height: mainItem.implicitHeight + topPadding + bottomPadding
    onHeightChanged: {
        // Fixes the annoying bug where the heights don't actually match
        if(height !== mainItem.implicitHeight + topPadding + bottomPadding)
            height = Qt.binding(() => { return mainItem.implicitHeight + topPadding + bottomPadding });
    }
    width: mainItem.implicitWidth + leftPadding + rightPadding

    mainItem: KQuickAddons.MouseEventListener {
        id: focusListener
        property bool wantsFocus: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false

        implicitWidth: Math.min(Math.max(notificationPopup.minimumContentWidth, notificationItem.Layout.preferredWidth), Math.max(notificationPopup.minimumContentWidth, notificationPopup.maximumContentWidth))
        implicitHeight: notificationItem.implicitHeight

        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        onPressed: wantsFocus = true
        onContainsMouseChanged: {
            wantsFocus = wantsFocus && containsMouse
            if (containsMouse) {
                onEntered: notificationPopup.hoverEntered()
            } else {
                onExited: notificationPopup.hoverExited()
            }
        }

        KSvg.FrameSvgItem {
            id: solidBackground
            visible: false
            imagePath: "solid/dialogs/background"
        }


        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffffff" }
                GradientStop { position: 1.0; color: "#d3d1d2" }
            }
        }
        DropArea {
            anchors.fill: parent
            onEntered: (drag) => {
                if (notificationItem.modelInterface.hasDefaultAction && !notificationItem.dragging) {
                    dragActivationTimer.start();
                } else {
                    drag.accepted = false;
                }
            }
        }

        Timer {
            id: dragActivationTimer
            interval: 250 // same as Task Manager
            repeat: false
            onTriggered: notificationItem.modelInterface.defaultActionInvoked()
        }
        DraggableDelegate {
            anchors {
                fill: parent
                leftMargin: solidBackground.margins.left
                rightMargin: solidBackground.margins.right
                bottomMargin: solidBackground.margins.bottom
                topMargin: solidBackground.margins.top + (notificationPopup.modelInterface.closable || notificationPopup.modelInterface.dismissable || notificationPopup.modelInterface.configurable ? -notificationPopup.topPadding : 0)
            }
            leftPadding: 0
            rightPadding: 0
            hoverEnabled: true
            draggable: notificationItem.modelInterface.notificationType != NotificationManager.Notifications.JobType
            onDismissRequested: NotificationsApplet.Globals.popupNotificationsModel.close(NotificationsApplet.Globals.popupNotificationsModel.index(notificationItem.modelInterface.index, 0))

            opacity: {
                if(focusListener.containsMouse) return 1;
                if(notificationItem.modelInterface.remainingTime < effectiveTimeout / 4) {
                    return (4 * notificationItem.modelInterface.remainingTime / effectiveTimeout);
                }
                return 1;
            }
            TapHandler {
                id: tapHandler
                acceptedButtons: {
                    let buttons = Qt.MiddleButton;
                    if (notificationPopup.modelInterface.hasDefaultAction) {
                        buttons |= Qt.LeftButton;
                    }
                    return buttons;
                }
                onTapped: (_eventPoint, button) => {
                    if (button === Qt.MiddleButton) {
                        if (notificationItem.modelInterface.closable) {
                            notificationItem.modelInterface.closeClicked();
                        }
                    } else if (notificationPopup.modelInterface.hasDefaultAction) {
                        notificationItem.modelInterface.defaultActionInvoked();
                    }
                }
            }

            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
            LayoutMirroring.childrenInherit: true

            Timer {
                id: timer
                interval: notificationPopup.effectiveTimeout
                running: {
                    if (!notificationPopup.visible) {
                        return false;
                    }
                    if (focusListener.containsMouse) {
                        return false;
                    }
                    if (interval <= 0) {
                        return false;
                    }
                    if (notificationItem.dragging || notificationItem.menuOpen) {
                        return false;
                    }
                    if (notificationItem.modelInterface.replying
                            && (notificationPopup.active || notificationItem.modelInterface.hasPendingReply)) {
                        return false;
                    }
                    return true;
                }
                onTriggered: {
                    if (notificationPopup.dismissTimeout) {
                        notificationPopup.modelInterface.dismissClicked();
                    } else {
                        notificationPopup.expired();
                    }
                }
            }

            NumberAnimation {
                target: notificationItem.modelInterface
                property: "remainingTime"
                from: timer.interval
                to: 0
                duration: timer.interval
                running: timer.running && Kirigami.Units.longDuration > 1
            }

            contentItem: Delegates.DelegatePopup {
                id: notificationItem

                Layout.preferredHeight: implicitHeight // Why is this necessary?

                modelInterface {
                    maximumLineCount: 8
                    bodyCursorShape: modelInterface.hasDefaultAction ? Qt.PointingHandCursor : 0

                    popupLeftPadding: notificationPopup.leftPadding
                    popupTopPadding: notificationPopup.topPadding
                    popupRightPadding: notificationPopup.rightPadding
                    popupBottomPadding: notificationPopup.bottomPadding

                    // When notification is updated, restart hide timer
                    onTimeChanged: {
                        if (timer.running) {
                            timer.restart();
                        }
                    }
                    timeout: timer.running ? timer.interval : 0

                    closable: true

                    onBodyClicked: {
                        if (modelInterface.hasDefaultAction) {
                            notificationItem.modelInterface.defaultActionInvoked();
                        }
                    }
                }
            }
        }
    }
}
