/*
    SPDX-FileCopyrightText: 2012-2016 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.taskmanager 0.1 as TaskManager

import "code/layout.js" as LayoutManager
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.5 as Kirigami

PlasmaComponents.MenuItem {
    id: tasksWrapper

    property bool selected: false
    objectName: "menuitemwrapper"

    Kirigami.MnemonicData.enabled: renderItem.enabled && renderItem.visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.MenuItem
    Kirigami.MnemonicData.label: text
    Shortcut {
         //in case of explicit & the button manages it by itself
         id: itemShortcut
         enabled: !(RegExp(/\&[^\&]/).test(text))
         sequence: tasksWrapper.Kirigami.MnemonicData.sequence
         onActivated: {
            renderItem.clicked();
         }
     }

    TasksMenuItem {
        id: renderItem
        anchors.fill: parent
        visible: parent.visible
        enabled: parent.enabled
        iconSource: parent.icon
        menuText: parent.Kirigami.MnemonicData.richTextLabel
        selected: parent.selected
        onClicked: parent.clicked()
    }
}
