/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0


PlasmaCore.ToolTipArea {
    id: appletRoot
    objectName: "org.kde.desktop-CompactApplet"
    anchors.fill: parent

    mainText: plasmoid.toolTipMainText
    subText: plasmoid.toolTipSubText
    location: if (plasmoid.parent && plasmoid.parent.inHiddenLayout && plasmoid.location !== PlasmaCore.Types.LeftEdge) {
                return PlasmaCore.Types.RightEdge;
              } else {
                return plasmoid.location;
              }
    active: !plasmoid.expanded
    textFormat: plasmoid.toolTipTextFormat
    mainItem: plasmoid.toolTipItem ? plasmoid.toolTipItem : null

    property Item fullRepresentation
    property Item compactRepresentation

    Connections {
        target: plasmoid
        function onContextualActionsAboutToShow() {
            appletRoot.hideToolTip()
        }
    }

    Layout.minimumWidth: {
        switch (plasmoid.formFactor) {
        case PlasmaCore.Types.Vertical:
            return 0;
        case PlasmaCore.Types.Horizontal:
            return height;
        default:
            return PlasmaCore.Units.gridUnit * 3;
        }
    }

    Layout.minimumHeight: {
        switch (plasmoid.formFactor) {
        case PlasmaCore.Types.Vertical:
            return width;
        case PlasmaCore.Types.Horizontal:
            return 0;
        default:
            return PlasmaCore.Units.gridUnit * 3;
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

