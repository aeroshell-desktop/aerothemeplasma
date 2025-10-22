/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import "../components" as Components


BaseDelegate {
    id: delegateRoot

    body: bodyLabel
    icon: icon
    footer: footerLoader.item
    columns: 3

    Item {
        Layout.fillHeight: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.rowSpan: 3
        implicitWidth: Kirigami.Units.iconSizes.small

        // Not using the Plasma theme's vertical line SVG because we want something thicker
        // than a hairline, and thickening a thin line SVG does not necessarily look good
        // with all Plasma themes.
        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: 3
            // TODO: use separator color here, once that color role is implemented
            color: Kirigami.Theme.textColor
            opacity: 0.2
        }
    }

    RowLayout {
        id: summaryRow

        Layout.fillWidth: true
        Layout.columnSpan: 2

        Components.Summary {
            id: summaryLabel

            Layout.topMargin: lineCount > 1 ? Math.max(0, (headingElement.implicitHeight - metrics.height) / 2) : 0

            modelInterface: delegateRoot.modelInterface
        }

        Item {Layout.fillWidth: true}

        Components.HeadingButtons {
            id: headingElement
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            modelInterface: delegateRoot.modelInterface
        }
    }

    Components.Body {
        id: bodyLabel
        Layout.fillWidth: true
        visible: delegateRoot.hasBodyText
        modelInterface: delegateRoot.modelInterface
    }

    Components.Icon {
        id: icon
        Layout.row: 1
        Layout.column: 2
        modelInterface: delegateRoot.modelInterface
    }

    Components.FooterLoader {
        id: footerLoader
        Layout.fillWidth: true
        Layout.columnSpan: 2
        modelInterface: delegateRoot.modelInterface
        iconContainerItem: icon
    }
}

