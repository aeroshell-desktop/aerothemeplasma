/*
    SPDX-FileCopyrightText: 2012-2013 Daniel Nicoletti <dantti12@gmail.com>
    SPDX-FileCopyrightText: 2013, 2015 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls

import org.kde.kwindowsystem
import org.kde.plasma.components as PlasmaComponents3
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root

    property alias pmCheckBox: pmCheckBox
    property alias disabled: pmCheckBox.checked
    property bool pluggedIn

    signal inhibitionChangeRequested(bool inhibit)

    // List of active power management inhibitions (applications that are
    // blocking sleep and screen locking).
    //
    // type: [{
    //  Icon: string,
    //  Name: string,
    //  Reason: string,
    // }]
    property var inhibitions: []
    property bool manuallyInhibited
    property bool inhibitsLidAction

    // UI to manually inhibit sleep and screen locking
    QtControls.CheckBox {
        id: pmCheckBox
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.largeSpacing
        text: i18nc("Minimize the length of this string as much as possible", "Manually block sleep and screen locking")
        checked: root.manuallyInhibited
        focus: true

        KeyNavigation.up: dialog.KeyNavigation.up
        KeyNavigation.down: batteryList.children[0]
        KeyNavigation.backtab: dialog.KeyNavigation.backtab
        KeyNavigation.tab: KeyNavigation.down

        onToggled: {
            inhibitionChangeRequested(checked)
        }
    }

    // Separator line
    Separator {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.leftMargin: -Kirigami.Units.largeSpacing - Kirigami.Units.smallSpacing
        Layout.rightMargin: -Kirigami.Units.largeSpacing
        visible: inhibitionReasonsLayout.visible
    }
    /*KSvg.SvgItem {
        Layout.fillWidth: true

        visible: inhibitionReasonsLayout.visible

        imagePath: "widgets/line"
        elementId: "horizontal-line"
    }*/

    // list of automatic inhibitions
    ColumnLayout {
        id: inhibitionReasonsLayout

        Layout.fillWidth: true
        visible: root.inhibitsLidAction || (root.inhibitions.length > 0)
        Layout.leftMargin: Kirigami.Units.iconSizes.small
        Layout.rightMargin: Kirigami.Units.iconSizes.small

        InhibitionHint {
            Layout.fillWidth: true
            visible: root.inhibitsLidAction
            iconSource: "computer-laptop"
            text: i18nc("Minimize the length of this string as much as possible", "Your laptop is configured not to sleep when closing the lid while an external monitor is connected.")
        }

        PlasmaComponents3.Label {
            id: inhibitionExplanation
            Layout.fillWidth: true
            visible: root.inhibitions.length > 1
            //font: Kirigami.Theme.smallFont
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 3
            text: i18np("%1 application is currently blocking sleep and screen locking:",
                        "%1 applications are currently blocking sleep and screen locking:",
                        root.inhibitions.length)
        }

        Repeater {
            model: root.inhibitions

            InhibitionHint {
                property string icon: modelData.Icon
                    || (KWindowSystem.isPlatformWayland ? "wayland" : "xorg")
                property string name: modelData.Name
                property string reason: modelData.Reason

                Layout.fillWidth: true
                iconSource: icon
                text: {
                    if (root.inhibitions.length === 1) {
                        if (reason && name) {
                            return i18n("%1 is currently blocking sleep and screen locking (%2)", name, reason)
                        } else if (name) {
                            return i18n("%1 is currently blocking sleep and screen locking (unknown reason)", name)
                        } else if (reason) {
                            return i18n("An application is currently blocking sleep and screen locking (%1)", reason)
                        } else {
                            return i18n("An application is currently blocking sleep and screen locking (unknown reason)")
                        }
                    } else {
                        if (reason && name) {
                            return i18nc("Application name: reason for preventing sleep and screen locking", "%1: %2", name, reason)
                        } else if (name) {
                            return i18nc("Application name: reason for preventing sleep and screen locking", "%1: unknown reason", name)
                        } else if (reason) {
                            return i18nc("Application name: reason for preventing sleep and screen locking", "Unknown application: %1", reason)
                        } else {
                            return i18nc("Application name: reason for preventing sleep and screen locking", "Unknown application: unknown reason")
                        }
                    }
                }
            }
        }
    }
}
