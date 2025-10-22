/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

import org.kde.coreaddons as KCoreAddons


GridLayout {
    id: detailsGrid

    property ModelInterface modelInterface

    columns: 2
    rowSpacing: Math.round(Kirigami.Units.smallSpacing / 2)
    columnSpacing: Kirigami.Units.smallSpacing

    // once you use Layout.column/Layout.row *all* of the items in the Layout have to use them
    Repeater {
        model: [1, 2]

        PlasmaExtras.DescriptiveLabel {
            Layout.column: 0
            Layout.row: index
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            text: modelInterface.jobDetails["descriptionLabel" + modelData] && modelInterface.jobDetails["descriptionValue" + modelData]
                ? i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Row description, e.g. Source", "%1:", modelInterface.jobDetails["descriptionLabel" + modelData]) : ""
            font.pointSize: 8
            //font.: Kirigami.Theme.defaultFont
            textFormat: Text.PlainText
            visible: text !== ""
        }
    }

    Repeater {
        model: [1, 2]

        PlasmaExtras.DescriptiveLabel {
            id: descriptionValueLabel
            Layout.column: 1
            Layout.row: index
            Layout.fillWidth: true
            //font: Kirigami.Theme.defaultFont
            font.pointSize: 8
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
                    return modelInterface.jobDetails["descriptionValue" + modelData] || "";
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

        PlasmaExtras.DescriptiveLabel {
            Layout.column: 1
            Layout.row: 2 + index
            Layout.fillWidth: true
            text: {
                let processed = modelInterface.jobDetails["processed" + modelData];
                let total = modelInterface.jobDetails["total" + modelData];

                if (processed > 0 || total > 1) {
                    // Format numbers to not display as exponential
                    const processedAsString = processed.toLocaleString(Qt.locale(), 'f', 0);
                    const totalAsString = total.toLocaleString(Qt.locale(), 'f', 0);

                    if (processed > 0 && total > 0 && processed <= total) {
                        switch(modelData) {
                        case "Bytes":
                            return i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "How many bytes have been copied", "%2 of %1",
                                KCoreAddons.Format.formatByteSize(total),
                                KCoreAddons.Format.formatByteSize(processed))
                        case "Files":
                            return i18ndcp("plasma_applet_io.gitgud.wackyideas.notifications", "How many files have been copied", "%2 of %1 file", "%2 of %1 files",
                                          totalAsString, processedAsString);
                        case "Directories":
                            return i18ndcp("plasma_applet_io.gitgud.wackyideas.notifications", "How many dirs have been copied", "%2 of %1 folder", "%2 of %1 folders",
                                         totalAsString, processedAsString);
                        case "Items":
                            return i18ndcp("plasma_applet_io.gitgud.wackyideas.notifications", "How many items (that includes files and dirs) have been copied", "%2 of %1 item", "%2 of %1 items",
                                         totalAsString, processedAsString);
                        }
                    } else {
                        switch(modelData) {
                        case "Bytes":
                            return KCoreAddons.Format.formatByteSize(processed || total)
                        case "Files":
                            return i18ndp("plasma_applet_io.gitgud.wackyideas.notifications", "%1 file", "%1 files", (processedAsString || totalAsString));
                        case "Directories":
                            return i18ndp("plasma_applet_io.gitgud.wackyideas.notifications", "%1 folder", "%1 folders", (processedAsString || totalAsString));
                        case "Items":
                            return i18ndp("plasma_applet_io.gitgud.wackyideas.notifications", "%1 item", "%1 items", (processedAsString || totalAsString));
                        }
                    }
                }

                return "";
            }
            //font: Kirigami.Theme.defaultFont
            font.pointSize: 8
            textFormat: Text.PlainText
            visible: text !== ""
        }
    }

    PlasmaExtras.DescriptiveLabel {
        Layout.column: 1
        Layout.row: 2 + 4
        Layout.fillWidth: true
        text: modelInterface.jobDetails.speed > 0 ? i18ndc("plasma_applet_io.gitgud.wackyideas.notifications", "Bytes per second", "%1/s",
                                           KCoreAddons.Format.formatByteSize(modelInterface.jobDetails.speed)) : ""
        //font: Kirigami.Theme.defaultFont
        font.pointSize: 8
        textFormat: Text.PlainText
        visible: text !== ""
    }
}
