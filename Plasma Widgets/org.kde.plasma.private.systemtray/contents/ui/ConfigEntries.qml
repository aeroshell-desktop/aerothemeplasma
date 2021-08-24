/*
 *  Copyright 2013 Sebastian Kügler <sebas@kde.org>
 *  Copyright 2014 Marco Martin <mart@kde.org>
 *  Copyright 2019 Konrad Materka <materka@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.3

import org.kde.kquickcontrols 2.0 as KQC
import org.kde.kirigami 2.10 as Kirigami

ColumnLayout {
    id: iconsPage

    signal configurationChanged

    property var cfg_shownItems: []
    property var cfg_hiddenItems: []
    property var cfg_extraItems: []
    property alias cfg_showAllItems: showAllCheckBox.checked

    QQC2.CheckBox {
        id: showAllCheckBox
        text: i18n("Always show all entries")
    }

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

    QQC2.ScrollView {
        id: scrollView

        Layout.fillWidth: true
        Layout.fillHeight: true
        contentHeight: itemsList.implicitHeight

        Component.onCompleted: scrollView.background.visible = true

        property bool scrollBarVisible: QQC2.ScrollBar.vertical && QQC2.ScrollBar.vertical.visible
        property var scrollBarWidth: scrollBarVisible ? QQC2.ScrollBar.vertical.width : 0

        ListView {
            id: itemsList

            property var visibilityColumnWidth: Kirigami.Units.gridUnit
            property var keySequenceColumnWidth: Kirigami.Units.gridUnit

            clip: true

            model: plasmoid.nativeInterface.configSystemTrayModel

            header: Kirigami.AbstractListItem {

                hoverEnabled: false

                RowLayout {
                    Kirigami.Heading {
                        text: i18nc("Name of the system tray entry", "Entry")
                        level: 2
                        Layout.fillWidth: true
                    }
                    Kirigami.Heading {
                        text: i18n("Visibility")
                        level: 2
                        Layout.preferredWidth: itemsList.visibilityColumnWidth
                        Component.onCompleted: itemsList.visibilityColumnWidth = Math.max(implicitWidth, itemsList.visibilityColumnWidth)
                    }
                    Kirigami.Heading {
                        text: i18n("Keyboard Shortcut")
                        level: 2
                        Layout.preferredWidth: itemsList.keySequenceColumnWidth
                        Component.onCompleted: itemsList.keySequenceColumnWidth = Math.max(implicitWidth, itemsList.keySequenceColumnWidth)
                    }
                    QQC2.Button { // Configure button column
                        icon.name: "configure"
                        enabled: false
                        opacity: 0
                    }
                }
            }

            section {
                property: "category"
                delegate: Kirigami.ListSectionHeader {
                    label: categoryName(section)
                }
            }

            delegate: Kirigami.AbstractListItem {
                highlighted: false
                hoverEnabled: false

                property bool isPlasmoid: model.itemType === "Plasmoid"

                contentItem: RowLayout {
                    RowLayout {
                        Layout.fillWidth: true

                        Kirigami.Icon {
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            source: model.decoration
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            text: model.display
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                        }
                    }

                    QQC2.ComboBox {
                        id: visibilityComboBox

                        property var contentWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                                            implicitContentWidth + leftPadding + rightPadding)
                        implicitWidth: Math.max(contentWidth, itemsList.visibilityColumnWidth)
                        Component.onCompleted: itemsList.visibilityColumnWidth = Math.max(implicitWidth, itemsList.visibilityColumnWidth)

                        enabled: (!showAllCheckBox.checked || isPlasmoid) && itemId
                        textRole: "text"
                        model: comboBoxModel()

                        currentIndex: {
                            var value

                            if (cfg_shownItems.indexOf(itemId) !== -1) {
                                value = "shown"
                            } else if (cfg_hiddenItems.indexOf(itemId) !== -1) {
                                value = "hidden"
                            } else if (isPlasmoid && cfg_extraItems.indexOf(itemId) === -1) {
                                value = "disabled"
                            } else {
                                value = "auto"
                            }

                            for (var i = 0; i < model.length; i++) {
                                if (model[i].value === value) {
                                    return i
                                }
                            }

                            return 0
                        }

                        property var myCurrentValue: model[currentIndex].value

                        onActivated: {
                            var shownIndex = cfg_shownItems.indexOf(itemId)
                            var hiddenIndex = cfg_hiddenItems.indexOf(itemId)
                            var extraIndex = cfg_extraItems.indexOf(itemId)

                            switch (myCurrentValue) {
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
                            var autoElement = {"value": "auto", "text": i18n("Shown when relevant")}
                            var shownElement = {"value": "shown", "text": i18n("Always shown")}
                            var hiddenElement = {"value": "hidden", "text": i18n("Always hidden")}
                            var disabledElement = {"value": "disabled", "text": i18n("Disabled")}

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
                        enabled: visibilityComboBox.myCurrentValue !== "disabled"
                        keySequence: model.applet ? model.applet.globalShortcut : ""
                        onKeySequenceChanged: {
                            if (model.applet && keySequence !== model.applet.globalShortcut) {
                                model.applet.globalShortcut = keySequence

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
                        readonly property QtObject configureAction: (model.applet && model.applet.action("configure")) || null

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
}
