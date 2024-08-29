/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Konrad Materka <materka@gmail.com>
    SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls as QQC2
import QtQuick.Layouts 1.3

import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrols 2.0 as KQC
import org.kde.kirigami 2.10 as Kirigami
import org.kde.kitemmodels 1.0
import org.kde.kcmutils as KCM

KCM.ScrollViewKCM {
    id: iconsPage

    signal configurationChanged

    property var cfg_shownItems: []
    property var cfg_hiddenItems: []
    property var cfg_extraItems: []
    property alias cfg_showAllItems: showAllCheckBox.checked

    function categoryName(category) {
        switch (category) {
        case "ApplicationStatus":
            return i18n("Application Status")
        case "Communications":
            return i18n("Communications")
        case "SystemServices":
            return i18n("System Services")
        case "Hardware":
            return i18n("Hardware Control")
        case "UnknownCategory":
        default:
            return i18n("Miscellaneous")
        }
    }

    header: Kirigami.SearchField {
        id: filterField
    }

    view: ListView {
        id: itemsList

        property real visibilityColumnWidth: Kirigami.Units.iconSizes.small
        property real keySequenceColumnWidth: Kirigami.Units.iconSizes.small
        readonly property int iconSize: Kirigami.Units.iconSizes.smallMedium

        clip: true

        model: KSortFilterProxyModel {
            sourceModel: Plasmoid.configSystemTrayModel
            filterString: filterField.text
            filterCaseSensitivity: Qt.CaseInsensitive
        }
        reuseItems: true

        header: RowLayout {
            width: itemsList.width
            spacing: Kirigami.Units.smallSpacing

            Item {
                implicitWidth: Kirigami.Units.smallSpacing
            }
            Kirigami.Heading {
                text: i18nc("Name of the system tray entry", "Entry")
                level: 5
                elide: Text.ElideRight
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                type: Kirigami.Heading.Type.Primary
            }
            Kirigami.Heading {
                text: "  " + i18n("Visibility")
                level: 5
                Layout.preferredWidth: itemsList.visibilityColumnWidth
                Component.onCompleted: itemsList.visibilityColumnWidth = Math.max(implicitWidth, itemsList.visibilityColumnWidth)
                type: Kirigami.Heading.Type.Primary
            }
            Kirigami.Heading {
                text: "  " + i18n("Keyboard Shortcut")
                level: 5
                Layout.preferredWidth: itemsList.keySequenceColumnWidth
                Component.onCompleted: itemsList.keySequenceColumnWidth = Math.max(implicitWidth, itemsList.keySequenceColumnWidth)
                type: Kirigami.Heading.Type.Primary
            }
            QQC2.Button { // Configure button column
                icon.name: "configure"
                enabled: false
                opacity: 0
                Layout.rightMargin: 2 * Kirigami.Units.smallSpacing
            }
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#cccccc"
            }
        }

        section {
            property: "category"
            delegate: Kirigami.ListSectionHeader {
                label: categoryName(section)
                width: itemsList.width
            }
        }

        delegate: QQC2.ItemDelegate {
            id: listItem

            width: itemsList.width

            // Don't need highlight, hover, or pressed effects
            highlighted: false
            hoverEnabled: false
            down: false

            readonly property bool isPlasmoid: model.itemType === "Plasmoid"

            contentItem: FocusScope {
                implicitHeight: childrenRect.height

                onActiveFocusChanged: if (activeFocus) {
                    listItem.ListView.view.positionViewAtIndex(index, ListView.Contain);
                }

                RowLayout {
                    width: parent.width
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        implicitWidth: itemsList.iconSize
                        implicitHeight: itemsList.iconSize
                        source: model.decoration
                        animated: false
                    }

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: model.display
                        elide: Text.ElideRight

                        QQC2.ToolTip {
                            visible: listItem.hovered && parent.truncated
                            text: parent.text
                        }
                    }

                    QQC2.ComboBox {
                        id: visibilityComboBox

                        property real contentWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                                            implicitContentWidth + leftPadding + rightPadding)
                        implicitWidth: Math.max(contentWidth, itemsList.visibilityColumnWidth)
                        Component.onCompleted: itemsList.visibilityColumnWidth = Math.max(implicitWidth, itemsList.visibilityColumnWidth)

                        enabled: (!showAllCheckBox.checked || isPlasmoid) && itemId
                        textRole: "text"
                        valueRole: "value"
                        model: comboBoxModel()

                        currentIndex: {
                            let value

                            if (cfg_shownItems.indexOf(itemId) !== -1) {
                                value = "shown"
                            } else if (cfg_hiddenItems.indexOf(itemId) !== -1) {
                                value = "hidden"
                            } else if (isPlasmoid && cfg_extraItems.indexOf(itemId) === -1) {
                                value = "disabled"
                            } else {
                                value = "auto"
                            }

                            for (let i = 0; i < model.length; i++) {
                                if (model[i].value === value) {
                                    return i
                                }
                            }

                            return 0
                        }

                        onActivated: {
                            const shownIndex = cfg_shownItems.indexOf(itemId)
                            const hiddenIndex = cfg_hiddenItems.indexOf(itemId)
                            const extraIndex = cfg_extraItems.indexOf(itemId)

                            switch (currentValue) {
                            case "auto":
                                if (shownIndex > -1) {
                                    cfg_shownItems.splice(shownIndex, 1)
                                }
                                if (hiddenIndex > -1) {
                                    cfg_hiddenItems.splice(hiddenIndex, 1)
                                }
                                if (extraIndex === -1) {
                                    cfg_extraItems.push(itemId)
                                }
                                break
                            case "shown":
                                if (shownIndex === -1) {
                                    cfg_shownItems.push(itemId)
                                }
                                if (hiddenIndex > -1) {
                                    cfg_hiddenItems.splice(hiddenIndex, 1)
                                }
                                if (extraIndex === -1) {
                                    cfg_extraItems.push(itemId)
                                }
                                break
                            case "hidden":
                                if (shownIndex > -1) {
                                    cfg_shownItems.splice(shownIndex, 1)
                                }
                                if (hiddenIndex === -1) {
                                    cfg_hiddenItems.push(itemId)
                                }
                                if (extraIndex === -1) {
                                    cfg_extraItems.push(itemId)
                                }
                                break
                            case "disabled":
                                if (shownIndex > -1) {
                                    cfg_shownItems.splice(shownIndex, 1)
                                }
                                if (hiddenIndex > -1) {
                                    cfg_hiddenItems.splice(hiddenIndex, 1)
                                }
                                if (extraIndex > -1) {
                                    cfg_extraItems.splice(extraIndex, 1)
                                }
                                break
                            }
                            iconsPage.configurationChanged()
                        }

                        function comboBoxModel() {
                            const autoElement = {"value": "auto", "text": i18n("Shown when relevant")}
                            const shownElement = {"value": "shown", "text": i18n("Always shown")}
                            const hiddenElement = {"value": "hidden", "text": i18n("Always hidden")}
                            const disabledElement = {"value": "disabled", "text": i18n("Disabled")}

                            if (showAllCheckBox.checked) {
                                if (isPlasmoid) {
                                    return [autoElement, disabledElement]
                                } else {
                                    return [shownElement]
                                }
                            } else {
                                if (isPlasmoid) {
                                    return [autoElement, shownElement, hiddenElement, disabledElement]
                                } else {
                                    return [autoElement, shownElement, hiddenElement]
                                }
                            }
                        }
                    }
                    KQC.KeySequenceItem {
                        id: keySequenceItem
                        Layout.minimumWidth: itemsList.keySequenceColumnWidth
                        Layout.preferredWidth: itemsList.keySequenceColumnWidth
                        Component.onCompleted: itemsList.keySequenceColumnWidth = Math.max(implicitWidth, itemsList.keySequenceColumnWidth)

                        visible: isPlasmoid
                        enabled: visibilityComboBox.currentValue !== "disabled"
                        keySequence: model.applet ? model.applet.plasmoid.globalShortcut : ""
                        onCaptureFinished: {
                            if (model.applet && keySequence !== model.applet.plasmoid.globalShortcut) {
                                model.applet.plasmoid.globalShortcut = keySequence

                                itemsList.keySequenceColumnWidth = Math.max(implicitWidth, itemsList.keySequenceColumnWidth)
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
                        readonly property QtObject configureAction: (model.applet && model.applet.plasmoid.internalAction("configure")) || null

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

    footer: QQC2.CheckBox {
        id: showAllCheckBox
        text: i18n("Always show all entries")
        Layout.alignment: Qt.AlignVCenter
    }
}
