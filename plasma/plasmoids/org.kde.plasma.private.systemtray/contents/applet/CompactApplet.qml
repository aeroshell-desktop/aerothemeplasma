/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

PlasmaCore.ToolTipArea {
    id: appletRoot
    objectName: "org.kde.desktop-CompactApplet"
    anchors.fill: parent

    mainText: plasmoidItem ? plasmoidItem.toolTipMainText : ""
    subText: plasmoidItem ? plasmoidItem.toolTipSubText : ""
    location: if (plasmoidItem && plasmoidItem.parent && plasmoidItem.parent.inHiddenLayout && Plasmoid.location !== PlasmaCore.Types.LeftEdge) {
        return PlasmaCore.Types.RightEdge;
    } else {
        return Plasmoid.location;
    }
    active: plasmoidItem ? !plasmoidItem.expanded : 0
    textFormat: plasmoidItem ? plasmoidItem.toolTipTextFormat : 0
    mainItem: plasmoidItem && plasmoidItem.toolTipItem ? plasmoidItem.toolTipItem : null

    property Item fullRepresentation
    property Item compactRepresentation
    property PlasmoidItem plasmoidItem

    Connections {
        target: Plasmoid
        function onContextualActionsAboutToShow() {
            appletRoot.hideImmediately()
        }
    }

    Layout.minimumWidth: {
        switch (Plasmoid.formFactor) {
        case PlasmaCore.Types.Vertical:
            return 0;
        case PlasmaCore.Types.Horizontal:
            return height;
        default:
            return Kirigami.Units.gridUnit * 3;
        }
    }

    Layout.minimumHeight: {
        switch (Plasmoid.formFactor) {
        case PlasmaCore.Types.Vertical:
            return width;
        case PlasmaCore.Types.Horizontal:
            return 0;
        default:
            return Kirigami.Units.gridUnit * 3;
        }
    }

    onCompactRepresentationChanged: {
        if (compactRepresentation) {
            compactRepresentation.parent = appletRoot;
            compactRepresentation.anchors.fill = appletRoot;
            compactRepresentation.visible = true;
        }
        appletRoot.visible = true;
    }
}

