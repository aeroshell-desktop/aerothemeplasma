/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick

import org.kde.plasma.extras as PlasmaExtras

import org.kde.kquickcontrolsaddons as KQCAddons

PlasmaExtras.Menu {
    id: contextMenu

    signal closed

    property QtObject __clipboard: KQCAddons.Clipboard { }

    // can be a Text or TextEdit
    property Item target

    property string link

    onStatusChanged: {
        if (status === PlasmaExtras.Menu.Closed) {
            closed();
        }
    }

    PlasmaExtras.MenuItem {
        text: i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "@action:inmenu", "Copy Link Address")
        icon: "edit-copy-symbolic"
        onClicked: __clipboard.content = contextMenu.link
        visible: contextMenu.link !== ""
    }

    PlasmaExtras.MenuItem {
        separator: true
        visible: contextMenu.link !== ""
    }

    PlasmaExtras.MenuItem {
        text: i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "@action:inmenu", "Copy")
        icon: "edit-copy-symbolic"
        enabled: typeof contextMenu.target.selectionStart !== "undefined"
        ? contextMenu.target.selectionStart !== contextMenu.target.selectionEnd
        : (contextMenu.target.text || "").length > 0
        onClicked: {
            if (typeof contextMenu.target.copy === "function") {
                contextMenu.target.copy();
            } else {
                contextMenu.__clipboard.content = contextMenu.target.text;
            }
        }
    }

    PlasmaExtras.MenuItem {
        id: selectAllAction
        icon: "edit-select-all-symbolic"
        text: i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "@action:inmenu", "Select All")
        onClicked: contextMenu.target.selectAll()
        visible: typeof contextMenu.target.selectAll === "function"
    }
}
