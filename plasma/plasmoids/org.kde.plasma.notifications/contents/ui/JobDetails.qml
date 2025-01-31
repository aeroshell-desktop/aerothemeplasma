/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1

import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

import org.kde.coreaddons 1.0 as KCoreAddons


GridLayout {
    id: detailsGrid

    property QtObject jobDetails

    columns: 2
    rowSpacing: Math.round(Kirigami.Units.smallSpacing / 2)
    columnSpacing: Kirigami.Units.smallSpacing

    // once you use Layout.column/Layout.row *all* of the items in the Layout have to use them
    Repeater {
        model: [1, 2]

        PlasmaComponents3.Label {
            Layout.column: 0
            Layout.row: index
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            text: jobDetails["descriptionLabel" + modelData] && jobDetails["descriptionValue" + modelData]
                ? i18ndc("plasma_applet_org.kde.plasma.notifications", "Row description, e.g. Source", "%1:", jobDetails["descriptionLabel" + modelData]) : ""
            font: Kirigami.Theme.smallFont
            textFormat: Text.PlainText
            visible: text !== ""
        }
    }

    Repeater {
        model: [1, 2]

        PlasmaComponents3.Label {
            id: descriptionValueLabel
            Layout.column: 1
            Layout.row: index
            Layout.fillWidth: true
            font: Kirigami.Theme.smallFont
            elide: Text.ElideMiddle
            textFormat: Text.PlainText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            verticalAlignment: Text.AlignTop
            maximumLineCount: 5
            visible: text !== ""

            // Only let the label grow, never shrink, to avoid repeatedly resizing the dialog when copying many files
            onImplicitHeightChanged: {
                if (implicitHeight > Layout.preferredHeight) {
                    Layout.preferredHeight = implicitHeight;
                }
            }

            Component.onCompleted: bindText()
            function bindText() {
                text = Qt.binding(function() {
                    return jobDetails["descriptionValue" + modelData] || "";
                });
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onPressed: mouse => {
                    // break binding so it doesn't update while the menu is opened
                    descriptionValueLabel.text = descriptionValueLabel.text;
                    descriptionValueMenu.open(mouse.x, mouse.y)
                }
            }

            EditContextMenu {
                id: descriptionValueMenu
                target: descriptionValueLabel
                // defer re-binding until after the "Copy" action in the menu has triggered
                onClosed: Qt.callLater(descriptionValueLabel.bindText)
            }
        }
    }

    Repeater {
        model: ["Bytes", "Files", "Directories", "Items"]

        PlasmaComponents3.Label {
            Layout.column: 1
            Layout.row: 2 + index
            Layout.fillWidth: true
            text: {
                var processed = jobDetails["processed" + modelData];
                var total = jobDetails["total" + modelData];

                if (processed > 0 || total > 1) {
                    if (processed > 0 && total > 0 && processed <= total) {
                        switch(modelData) {
                        case "Bytes":
                            return i18ndc("plasma_applet_org.kde.plasma.notifications", "How many bytes have been copied", "%2 of %1",
                                KCoreAddons.Format.formatByteSize(total),
                                KCoreAddons.Format.formatByteSize(processed))
                        case "Files":
                            return i18ndcp("plasma_applet_org.kde.plasma.notifications", "How many files have been copied", "%2 of %1 file", "%2 of %1 files",
                                          total, processed);
                        case "Directories":
                            return i18ndcp("plasma_applet_org.kde.plasma.notifications", "How many dirs have been copied", "%2 of %1 folder", "%2 of %1 folders",
                                         total, processed);
                        case "Items":
                            return i18ndcp("plasma_applet_org.kde.plasma.notifications", "How many items (that includes files and dirs) have been copied", "%2 of %1 item", "%2 of %1 items",
                                         total, processed);
                        }
                    } else {
                        switch(modelData) {
                        case "Bytes":
                            return KCoreAddons.Format.formatByteSize(processed || total)
                        case "Files":
                            return i18ndp("plasma_applet_org.kde.plasma.notifications", "%1 file", "%1 files", (processed || total));
                        case "Directories":
                            return i18ndp("plasma_applet_org.kde.plasma.notifications", "%1 folder", "%1 folders", (processed || total));
                        case "Items":
                            return i18ndp("plasma_applet_org.kde.plasma.notifications", "%1 item", "%1 items", (processed || total));
                        }
                    }
                }

                return "";
            }
            font: Kirigami.Theme.smallFont
            textFormat: Text.PlainText
            visible: text !== ""
        }
    }

    PlasmaComponents3.Label {
        Layout.column: 1
        Layout.row: 2 + 4
        Layout.fillWidth: true
        text: jobDetails.speed > 0 ? i18ndc("plasma_applet_org.kde.plasma.notifications", "Bytes per second", "%1/s",
                                           KCoreAddons.Format.formatByteSize(jobDetails.speed)) : ""
        font: Kirigami.Theme.smallFont
        textFormat: Text.PlainText
        visible: text !== ""
    }
}
