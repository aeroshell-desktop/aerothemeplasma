/*
    SPDX-FileCopyrightText: 2013 Aurélien Gâteau <agateau@kde.org>
    SPDX-FileCopyrightText: 2014-2015 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15

import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: root

    property variant actionList
    property QtObject menu
    property bool opened: menu ? (menu.status !== PlasmaExtras.Menu.Closed) : false
    property Item visualParent

    signal actionClicked(string actionId, variant actionArgument)
    signal closed

    function fillMenu(menu, items) {
        items.forEach(function (actionItem) {
            if (actionItem.subActions) {
                // This is a menu
                var submenuItem = contextSubmenuItemComponent.createObject(menu, {
                    "actionItem": actionItem
                });
                fillMenu(submenuItem.submenu, actionItem.subActions);
            } else {
                var item = contextMenuItemComponent.createObject(menu, {
                    "actionItem": actionItem
                });
            }
        });
    }
    function open(x, y) {
        if (!actionList) {
            return;
        }
        if (x && y) {
            menu.open(x, y);
        } else {
            menu.open();
        }
    }
    function refreshMenu() {
        if (menu) {
            menu.destroy();
        }
        if (!actionList) {
            return;
        }
        menu = contextMenuComponent.createObject(root);
        fillMenu(menu, actionList);
    }

    onActionListChanged: refreshMenu()
    onOpenedChanged: {
        if (!opened) {
            closed();
        }
    }

    Component {
        id: contextMenuComponent

        PlasmaExtras.Menu {
            visualParent: root.visualParent
        }
    }
    Component {
        id: contextSubmenuItemComponent

        PlasmaExtras.MenuItem {
            id: submenuItem

            property variant actionItem
            property PlasmaExtras.Menu submenu: PlasmaExtras.Menu {
                visualParent: submenuItem.action
            }

            icon: actionItem.icon ? actionItem.icon : null
            text: actionItem.text ? actionItem.text : ""
        }
    }
    Component {
        id: contextMenuItemComponent

        PlasmaExtras.MenuItem {
            property variant actionItem

            checkable: actionItem.checkable ? actionItem.checkable : false
            checked: actionItem.checked ? actionItem.checked : false
            enabled: actionItem.type !== "title" && ("enabled" in actionItem ? actionItem.enabled : true)
            icon: actionItem.icon ? actionItem.icon : null
            section: actionItem.type === "title"
            separator: actionItem.type === "separator"
            text: actionItem.text ? actionItem.text : ""

            onClicked: {
                root.actionClicked(actionItem.actionId, actionItem.actionArgument);
            }
        }
    }
}
