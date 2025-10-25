/*
    SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
    SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Natalie Clarius <natalie.clarius@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls

import org.kde.notification
import org.kde.kwindowsystem as KWindowSystem
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.dbus as DBus

QtControls.ItemDelegate {
    id: root

    property bool pluggedIn

    signal inhibitionChangeRequested(bool inhibit)

    property var requestedInhibitions: []
    readonly property bool hasActiveIdleInhibitions: root.requestedInhibitions.some((inh) => inh.active && inh.what.includes("idle"))
    readonly property bool hasActiveSleepInhibitions: root.requestedInhibitions.some((inh) => inh.active && inh.what.includes("sleep"))
    readonly property bool hasActiveInhibitions: root.hasActiveIdleInhibitions || root.hasActiveSleepInhibitions
    property bool isManuallyInhibited
    property bool isManuallyInhibitedError
    // List of active power management inhibitions (applications that are
    // blocking sleep and screen locking).
    //
    // type: [{
    //  Name: string,
    //  PrettyName: string,
    //  Icon: string,
    //  Reason: string,
    // }]
    property bool inhibitsLidAction

    function baseName(name) {
        if(name[0] != "/") return name;
        var res = name.split("/");
        return res[res.length-1];
    }


    background.visible: false
    //  highlighted: activeFocus
    hoverEnabled: false
    text: i18nc("@title:group", "Sleep and Screen Locking after Inactivity")

    Notification {
        id: inhibitionError
        componentName: "plasma_workspace"
        eventId: "warning"
        iconName: "system-suspend-uninhibited"
        title: i18n("Power Management")
    }

    Accessible.description: isManuallyInhibited ? i18n("Sleep and Screen Locking is manually blocked") : i18n("Sleep and Screen Locking is unblocked")
    Accessible.role: Accessible.CheckBox
    onFocusChanged: {
        if(focus) {
            manualInhibitionButton.focus = true;
        }
    }

    contentItem: RowLayout {
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: Kirigami.Units.smallSpacing


            // UI to manually inhibit sleep and screen locking
            QtControls.CheckBox {
                id: manualInhibitionButton
                Layout.fillWidth: true
                Layout.leftMargin: 1

                text: i18nc("Minimize the length of this string as much as possible", "Manually block sleep and screen locking")
                Keys.onPressed: (event) => {
                    if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                        click();
                    }
                }

                onClicked: {
                    inhibitionChangeRequested(!root.isManuallyInhibited);
                }
                Connections {
                    target: root
                    function onIsManuallyInhibitedChanged() {
                        DBus.SessionBus.asyncCall({service: "org.kde.plasmashell", path: "/org/kde/osdService", iface: "org.kde.osdService", member: "showText",
                            arguments: [new DBus.string("system-hibernate"), new DBus.string(root.isManuallyInhibited ? i18n("Sleep and Screen Locking Blocked") : i18n("Sleep and Screen Locking Unblocked"))], signature: "(ss)"});
                        manualInhibitionButton.checked = root.isManuallyInhibited;
                    }
                    function onIsManuallyInhibitedErrorChanged() {
                        if (root.isManuallyInhibitedError) {
                            root.isManuallyInhibitedError = false;
                            if (!root.isManuallyInhibited) {
                                inhibitionError.text = i18n("Failed to unblock automatic sleep and screen locking");
                                inhibitionError.sendEvent();
                            } else {
                                inhibitionError.text = i18n("Failed to block automatic sleep and screen locking");
                                inhibitionError.sendEvent();
                            }
                        }
                    }
                }

            }

            Separator {
                visible: (inhibitionRepeater.count > 0) ||  root.inhibitsLidAction
                Layout.fillWidth: true
                Layout.leftMargin: -Kirigami.Units.largeSpacing
                Layout.rightMargin: -Kirigami.Units.largeSpacing
            }
            // list of inhibitions
            ColumnLayout {
                id: inhibitionReasonsLayout

                Layout.fillWidth: true
                spacing: 0
                visible: (inhibitionRepeater.count > 0) ||  root.inhibitsLidAction

                InhibitionHint {
                    readonly property var pmControl: root.pmControl

                    Layout.fillWidth: true
                    visible: root.inhibitsLidAction
                    iconSource: "computer-laptop"
                    text: i18nc("Minimize the length of this string as much as possible", "Your laptop is configured not to sleep when closing the lid while an external monitor is connected.")
                }

                Repeater {
                    id: inhibitionRepeater
                    model: root.requestedInhibitions

                    InhibitionHint {
                        id: inhibitionDelegate

                        required property string icon
                        required property string appName
                        required property string prettyName
                        required property string reason
                        required property bool active
                        required property bool allowed
                        Layout.fillWidth: true
                        iconSource: icon || (KWindowSystem.KWindowSystem.isPlatformWayland ? "wayland" : "xorg")
                        text: {
                            if (!allowed) {
                                return i18nc("Application name; reason", "%1 has been prevented from blocking sleep and screen locking for %2", root.baseName(prettyName), reason)
                            } else if (root.requestedInhibitions.length === 1) {
                                if (reason && prettyName) {
                                    return i18n("%1 is currently blocking sleep and screen locking (%2)", root.baseName(prettyName), reason)
                                } else if (prettyName) {
                                    return i18n("%1 is currently blocking sleep and screen locking (unknown reason)", root.baseName(prettyName))
                                } else if (reason) {
                                    return i18n("An application is currently blocking sleep and screen locking (%1)", reason)
                                } else {
                                    return i18n("An application is currently blocking sleep and screen locking (unknown reason)")
                                }
                            } else {
                                if (reason && prettyName) {
                                    return i18nc("Application name: reason for preventing sleep and screen locking", "%1: %2", root.baseName(prettyName), reason)
                                } else if (prettyName) {
                                    return i18nc("Application name: reason for preventing sleep and screen locking", "%1: unknown reason", root.baseName(prettyName))
                                } else if (reason) {
                                    return i18nc("Application name: reason for preventing sleep and screen locking", "Unknown application: %1", reason)
                                } else {
                                    return i18nc("Application name: reason for preventing sleep and screen locking", "Unknown application: unknown reason")
                                }
                            }
                        }

                        Item {
                            //visible: !permanentlyBlocked
                            width: blockMenuButton.width
                            height: blockMenuButton.height
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            Layout.leftMargin: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
                            Layout.topMargin: -Kirigami.Units.smallSpacing

                            QtControls.Button {
                                id: blockMenuButton
                                text: inhibitionDelegate.allowed ? i18nc("@action:button Prevent an app from blocking automatic sleep and screen locking after inactivity", "Unblock") : i18nc("@action:button Undo preventing an app from blocking automatic sleep and screen locking after inactivity", "Block Again")
                                hoverEnabled: true
                                flat: true
                                background: null
                                padding: 0
                                contentItem: QtControls.Label {
                                    text: "<a style=\"color: #0066cc; text-decoration: " + ((blockMenuButton.hovered || blockMenuButton.focus) ? "underline" : "none") + "; \" href=\"hi\">" + blockMenuButton.text + "</a>"
                                    textFormat: Text.RichText
                                    verticalAlignment: Text.AlignTop
                                }
                                //height: Kirigami.Theme.defaultFont.pointSize + Kirigami.Units.mediumSpacing * 2
                                onClicked: {
                                    pmControl.setInhibitionAllowed(inhibitionDelegate.appName, inhibitionDelegate.reason, !inhibitionDelegate.allowed);
                                }
                            }
                        }
                    }
                }

                Repeater {
                    model: root.blockedInhibitions

                    InhibitionHint {
                        property string icon: modelData.Icon
                            || (KWindowSystem.isPlatformWayland ? "wayland" : "xorg")
                        property string app: modelData.Name
                        property string name: modelData.PrettyName
                        property string reason: modelData.Reason
                        property bool permanently: modelData.Permanently
                        property bool temporarilyUnblocked: {
                            return root.inhibitions.some(function (inhibition) {
                                return inhibition.Name === app && inhibition.Reason === reason;
                            });
                        }
                        visible: !temporarilyUnblocked

                        Layout.fillWidth: true
                        iconSource: icon
                        text: {
                            if (root.blockedInhibitions.length === 1) {
                                return i18nc("Application name; reason", "%1 has been prevented from blocking sleep and screen locking for %2", root.baseName(name), reason)
                            } else {
                                return i18nc("Application name: reason for preventing sleep and screen locking", "%1: %2", root.baseName(name), reason)
                            }
                        }

                        Item {
                            //visible: permanently
                            width: unblockMenuButton.width
                            height: unblockMenuButton.height
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            Layout.leftMargin: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
                            Layout.topMargin: -Kirigami.Units.smallSpacing

                            QtControls.Button {
                                id: unblockMenuButton
                                text: i18nc("@action:button Undo preventing an app from blocking automatic sleep and screen locking after inactivity", "Block Again")
                                Accessible.role: permanently ? Accessible.ButtonMenu : Accessible.Button
                                hoverEnabled: true
                                flat: true
                                background: null
                                padding: 0
                                contentItem: QtControls.Label {
                                    text: "<a style=\"color: #0066cc; text-decoration: " + ((unblockMenuButton.hovered || unblockMenuButton.focus) ? "underline" : "none") + "; \" href=\"hi\">" + unblockMenuButton.text + (permanently ? " 🞃" : "") + "</a>"
                                    textFormat: Text.RichText
                                    verticalAlignment: Text.AlignTop
                                }
                                onClicked: {

                                    if(permanently)
                                        unblockButtonMenu.open();
                                    else
                                        pmControl.unblockInhibition(app, reason, false);
                                }
                            }

                            PlasmaExtras.Menu {
                                id: unblockButtonMenu

                                PlasmaExtras.MenuItem {
                                    text: i18nc("@action:button Prevent an app from blocking automatic sleep and screen locking after inactivity", "Only this time")
                                    onClicked: pmControl.unblockInhibition(app, reason, false)
                                }

                                PlasmaExtras.MenuItem {
                                    text: i18nc("@action:button Prevent an app from blocking automatic sleep and screen locking after inactivity", "Every time for this app and reason")
                                    onClicked: pmControl.unblockInhibition(app, reason, true)
                                }
                            }
                        }

                    }
                }
            }
        }
    }
}
