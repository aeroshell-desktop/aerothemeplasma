/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Konrad Materka <materka@gmail.com>
    SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>
    SPDX-FileCopyrightText: 2025 Kristen McWilliam <kristen@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.kquickcontrols as KQC
import org.kde.plasma.plasmoid

KCMUtils.ScrollViewKCM {
    id: iconsPage

    signal configurationChanged
    property bool unsavedChanges: !(changedVisibility.size === 0 && changedShortcuts.size === 0)
    onUnsavedChangesChanged: {
        if(changedVisibility.size > 0) {
            for (const [key, value] of changedVisibility.entries()) {
                updateVisibility(key, value);
            }
            configurationChanged();
        }
    }

    property var cfg_shownItems: []
    property var cfg_hiddenItems: []
    property var cfg_extraItems: []
    property var cfg_disabledStatusNotifiers: []
    property alias cfg_showAllItems: showAllCheckBox.checked

    // We can share one combobox model across all delegates, they all have the same options
    readonly property var comboBoxModel: {
        const autoElement = {
            "value": "auto",
            "text": i18n("Shown when relevant") // qmllint disable unqualified
        };
        const shownElement = {
            "value": "shown",
            "text": i18n("Always shown") // qmllint disable unqualified
        };
        const hiddenElement = {
            "value": "hidden",
            "text": i18n("Always hidden") // qmllint disable unqualified
        };
        const disabledElement = {
            "value": "disabled",
            "text": i18n("Disabled") // qmllint disable unqualified
        };

        return cfg_showAllItems ? [autoElement, disabledElement] : [autoElement, shownElement, hiddenElement, disabledElement];
    }

    readonly property var changedShortcuts: new Map()
    readonly property var changedVisibility: new Map()


    function saveConfig() {
        for (const [key, value] of changedVisibility.entries()) {
            updateVisibility(key, value);
        }
        for (const [key, value] of changedShortcuts.entries()) {
            key.globalShortcut = value;
        }
        changedShortcuts.clear();
        changedVisibility.clear();
        cfg_shownItemsChanged();
        cfg_hiddenItemsChanged();
        cfg_extraItemsChanged();
        cfg_disabledStatusNotifiersChanged();
        changedShortcutsChanged();
        changedVisibilityChanged();
    }

    function updateVisibility(itemId: string, visibility: string): void {
        const shownIndex = cfg_shownItems.indexOf(itemId);
        const hiddenIndex = cfg_hiddenItems.indexOf(itemId);
        const extraIndex = cfg_extraItems.indexOf(itemId);
        const disabledSniIndex = cfg_disabledStatusNotifiers.indexOf(itemId);

        if (shownIndex > -1) {
            cfg_shownItems.splice(shownIndex, 1);
        }
        if (hiddenIndex > -1) {
            cfg_hiddenItems.splice(hiddenIndex, 1);
        }
        if (extraIndex > -1) {
            cfg_extraItems.splice(extraIndex, 1);
        }
        if (disabledSniIndex > -1) {
            cfg_disabledStatusNotifiers.splice(disabledSniIndex, 1);
        }

        switch (visibility) {
        case "auto":
        case "auto-sni":
            cfg_extraItems.push(itemId);
            break;
        case "shown":
            cfg_extraItems.push(itemId);
        /* fallthrough*/
        case "shown-sni":
            cfg_shownItems.push(itemId);
            break;
        case "hidden":
            cfg_extraItems.push(itemId);
        /* fallthrough */
        case "hidden-sni":
            cfg_hiddenItems.push(itemId);
            break;
        case "disabled-sni":
            cfg_disabledStatusNotifiers.push(itemId);
            break;
        }
    }

    function categoryName(category) {
        switch (category) {
        case "ApplicationStatus":
            return i18n("Application Status"); // qmllint disable unqualified
        case "Communications":
            return i18n("Communications"); // qmllint disable unqualified
        case "SystemServices":
            return i18n("System Services"); // qmllint disable unqualified
        case "Hardware":
            return i18n("Hardware Control"); // qmllint disable unqualified
        case "UnknownCategory":
        default:
            return i18n("Miscellaneous"); // qmllint disable unqualified
        }
    }

    Connections {
        target: plasmoid.configSystemTrayModel
        function onRowsRemoved() {
            // if the user closes an app with a SNI that has a visibility change queued, we need to remove it
            // from the queue as the change is no longer visible in the UI.
            let idsToRemove = [...iconsPage.changedVisibility.keys()];
            for (let i = 0; i < plasmoid.configSystemTrayModel.rowCount() && idsToRemove.length > 0; ++i) {
                let itemId = plasmoid.configSystemTrayModel.index(i, 0).data(Qt.UserRole + 2);
                idsToRemove = idsToRemove.filter(id => id !== itemId);
            }
            idsToRemove.forEach(id => {
                changedVisibility.delete(id);
            });
            if (idsToRemove.length > 0) {
                iconsPage.changedVisibilityChanged();
            }
        }
    }

    // Frameless style for the InlineMessage is not visually compatible here
    header: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        Kirigami.SearchField {
            id: filterField
            Layout.fillWidth: true
        }

        Kirigami.InlineMessage {
            id: disablingSniMessage
            property string appName

            function showWithAppName(appName: string) {
                disablingSniMessage.appName = appName;
                visible = true;
            }

            Layout.fillWidth: true
            type: Kirigami.MessageType.Warning
            text: xi18nc("@info:usagetip", "Look for a setting in <application>%1</application> to disable its tray icon before doing it here. Some apps’ tray icons were not designed to be disabled, and using this setting may cause them to behave unexpectedly.<nl/><nl/>Use this setting at your own risk, and do not report issues to KDE or the app’s author.", appName) // qmllint disable unqualified
            actions: [
                Kirigami.Action {
                    text: i18nc("@action:button", "I understand the risks") // qmllint disable unqualified
                    onTriggered: disablingSniMessage.visible = false
                }
            ]
        }

        Kirigami.InlineMessage {
            id: disablingKlipperMessage

            visible: iconsPage.changedVisibility.get("org.kde.plasma.clipboard") === "disabled"
            Layout.fillWidth: true
            type: Kirigami.MessageType.Warning
            text: xi18nc("@info:usagetip", "Disabling the clipboard is not recommended, as it will cause copied data to be lost when the application it was copied from is closed.<nl/><nl/>Instead consider configuring the clipboard to disable its history, or only remember one item at a time.") // qmllint disable unqualified
        }
    }

    view: ListView {
        id: itemsList

        property real visibilityColumnWidth: Kirigami.Units.gridUnit
        property real keySequenceColumnWidth: Kirigami.Units.gridUnit
        readonly property int iconSize: Kirigami.Units.iconSizes.smallMedium

        clip: true

        model: KItemModels.KSortFilterProxyModel {
            filterString: filterField.text
            filterCaseSensitivity: Qt.CaseInsensitive
            Component.onCompleted: sourceModel = Plasmoid.configSystemTrayModel // avoid unnecessary binding, it causes loops
        }
        reuseItems: true

        section {
            property: "category"
            delegate: Kirigami.ListSectionHeader {
                required property string section

                text: iconsPage.categoryName(section)
                width: itemsList.width
            }
        }

        delegate: TrayItemDelegate {}
    }

    // Re-add separator line between footer and list view
    //extraFooterTopPadding: true
    footer: QQC2.CheckBox {
        id: showAllCheckBox
        text: i18n("Always show all entries") // qmllint disable unqualified
        Layout.alignment: Qt.AlignVCenter
    }

    /*!
    * Delegate representing each system tray item.
    */
    component TrayItemDelegate: QQC2.ItemDelegate {
        id: listItem

        required property var applet
        required property var decoration
        required property string displayText
        required property int index
        required property string itemId
        required property string itemType

        width: itemsList.width

        Kirigami.Theme.useAlternateBackgroundColor: true

        // Don't need highlight, hover, or pressed effects
        highlighted: false
        hoverEnabled: false
        down: false

        readonly property bool isPlasmoid: itemType === "Plasmoid"

        contentItem: FocusScope {
            implicitHeight: childrenRect.height

            onActiveFocusChanged: if (activeFocus) {
                listItem.ListView.view.positionViewAtIndex(listItem.index, ListView.Contain);
            }

            RowLayout {
                width: parent.width
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    implicitWidth: itemsList.iconSize
                    implicitHeight: itemsList.iconSize
                    source: listItem.decoration
                    animated: false
                }

                QQC2.Label {
                    id: nameLabel
                    Layout.fillWidth: true
                    text: listItem.displayText
                    textFormat: Text.PlainText
                    elide: Text.ElideRight

                    QQC2.ToolTip {
                        visible: listItem.hovered && parent.truncated
                        text: parent.text
                    }
                }

                QQC2.ComboBox {
                    id: visibilityComboBox

                    property real contentWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)

                    readonly property string currentVisibility: iconsPage.changedVisibility.has(listItem.itemId) ? iconsPage.changedVisibility.get(listItem.itemId).replace("-sni", "") : originalVisibility
                    readonly property string originalVisibility: {
                        if (iconsPage.cfg_showAllItems || iconsPage.cfg_shownItems.indexOf(listItem.itemId) !== -1) {
                            return "shown";
                        } else if (iconsPage.cfg_hiddenItems.indexOf(listItem.itemId) !== -1) {
                            return "hidden";
                        } else if ((listItem.isPlasmoid && iconsPage.cfg_extraItems.indexOf(listItem.itemId) === -1) || (!listItem.isPlasmoid && iconsPage.cfg_disabledStatusNotifiers.indexOf(listItem.itemId) > -1)) {
                            return "disabled";
                        } else {
                            return "auto";
                        }
                    }

                    implicitWidth: Math.max(contentWidth, itemsList.visibilityColumnWidth)
                    Component.onCompleted: itemsList.visibilityColumnWidth = Math.max(implicitWidth, itemsList.visibilityColumnWidth)

                    enabled: !iconsPage.cfg_showAllItems && listItem.itemId
                    textRole: "text"
                    valueRole: "value"

                    currentIndex: {
                        for (let i = 0; i < model.length; i++) {
                            if (model[i].value === currentVisibility) {
                                return i;
                            }
                        }

                        return 0;
                    }
                    model: iconsPage.comboBoxModel

                    onActivated: index => {
                        if (currentValue !== originalVisibility) {
                            if (currentValue === "disabled" && !listItem.isPlasmoid) {
                                disablingSniMessage.showWithAppName(nameLabel.text);
                            }
                            iconsPage.changedVisibility.set(listItem.itemId, currentValue + (listItem.isPlasmoid ? "" : "-sni"));
                        } else {
                            iconsPage.changedVisibility.delete(listItem.itemId);
                        }
                        iconsPage.changedVisibilityChanged();
                    }
                }
                KQC.KeySequenceItem {
                    id: keySequenceItem
                    Layout.minimumWidth: itemsList.keySequenceColumnWidth
                    Layout.preferredWidth: itemsList.keySequenceColumnWidth
                    Component.onCompleted: itemsList.keySequenceColumnWidth = Math.max(implicitWidth, itemsList.keySequenceColumnWidth)

                    visible: listItem.isPlasmoid
                    enabled: visibilityComboBox.currentValue !== "disabled"
                    readonly property string originalKeySequence: listItem.applet ? listItem.applet.plasmoid.globalShortcut : ""
                    keySequence: iconsPage.changedShortcuts.has(listItem.applet?.plasmoid) ? iconsPage.changedShortcuts.get(listItem.applet?.plasmoid) : originalKeySequence
                    onCaptureFinished: {
                        if (listItem.applet) {
                            if (keySequence !== listItem.applet.plasmoid.globalShortcut) {
                                iconsPage.changedShortcuts.set(listItem.applet.plasmoid, keySequence.toString());
                            } else {
                                iconsPage.changedShortcuts.delete(listItem.applet.plasmoid);
                            }

                            itemsList.keySequenceColumnWidth = Math.max(implicitWidth, itemsList.keySequenceColumnWidth);
                            iconsPage.changedShortcutsChanged();
                        }
                    }
                }
                // Placeholder for when KeySequenceItem is not visible
                Item {
                    Layout.minimumWidth: itemsList.keySequenceColumnWidth
                    Layout.maximumWidth: itemsList.keySequenceColumnWidth
                    visible: !keySequenceItem.visible
                }

                QQC2.Button {
                    readonly property QtObject configureAction: (listItem.applet && listItem.applet.plasmoid.internalAction("configure")) || null

                    Accessible.name: configureAction ? configureAction.text : ""
                    icon.name: "configure"
                    enabled: configureAction && configureAction.visible && configureAction.enabled
                    // Still reserve layout space, so not setting visible to false
                    opacity: enabled ? 1 : 0
                    onClicked: configureAction.trigger()

                    QQC2.ToolTip {
                        // Strip out ampersands right before non-whitespace characters, i.e.
                        // those used to determine the alt key shortcut
                        text: parent.Accessible.name.replace(/&(?=\S)/g, "")
                    }
                }
            }
        }
    }
}
