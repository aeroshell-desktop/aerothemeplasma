/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg as KSvg

PlasmaCore.ToolTipArea {
    id: tooltip

    readonly property int arrowAnimationDuration: Kirigami.Units.shortDuration
    property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property int iconSize: Kirigami.Units.smallMedium
    property int expanderSize: Kirigami.Units.iconSizes.smallMedium - Kirigami.Units.smallSpacing / 2
    implicitWidth: expanderSize+1
    implicitHeight: expanderSize
    activeFocusOnTab: true

    Accessible.name: subText
    Accessible.description: i18n("Show all the items in the system tray in a popup")
    Accessible.role: Accessible.Button
    Accessible.onPressAction: systemTrayState.expanded = !systemTrayState.expanded

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Select:
            systemTrayState.expanded = !systemTrayState.expanded;
        }
    }

    subText: systemTrayState.expanded ? i18n("Close popup") : i18n("Show hidden icons")

    property bool wasExpanded

    property bool flyoutExpanded: systemTrayState.expanded
    onFlyoutExpandedChanged: {
        if(flyoutExpanded) {
            tooltip.hideImmediately();
        }
    }

    TapHandler {
        onTapped: {
            systemTrayState.expanded = !systemTrayState.expanded;
            //systemTrayState.expanded = !tooltip.wasExpanded;
            expandedRepresentation.hiddenLayout.currentIndex = -1;
        }
    }

    KSvg.SvgItem {
        id: arrow
        z: -1
        anchors.centerIn: parent
        width: expanderSize +1
        height: expanderSize

        // This is the Aero styled button texture used for the system tray expander.
        KSvg.FrameSvgItem {
            id: hoverButton
            z: -1 // To prevent layout issues with the MouseArea.
            anchors.fill: parent
            imagePath: Qt.resolvedUrl("svgs/systray.svg")
            prefix: {
                if(tooltip.containsPress || (systemTrayState.expanded && expandedRepresentation.hiddenLayout.visible)) return "pressed";
                if(tooltip.containsMouse) return "hover";
                return "normal"; // The normal state actually just makes the button invisible.
            }
        }
        imagePath: "widgets/arrows"
        //svg: arrowSvg
        elementId: {
            // Depending on the taskbar orientation, choose different arrow orientation from the SVG.
            if (Plasmoid.location === PlasmaCore.Types.TopEdge) {
                return "down-arrow";
            } else if (Plasmoid.location === PlasmaCore.Types.LeftEdge) {
                return "right-arrow";
            } else if (Plasmoid.location === PlasmaCore.Types.RightEdge) {
                return "left-arrow";
            } else {
                return "up-arrow";
            }
        }
    }
}
