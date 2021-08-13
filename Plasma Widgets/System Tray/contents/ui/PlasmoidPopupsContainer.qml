/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
//needed for units
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

StackView {
    id: mainStack
    focus: true

    Layout.minimumWidth: PlasmaCore.Units.gridUnit * 12
    Layout.minimumHeight: PlasmaCore.Units.gridUnit * 12

    readonly property Item activeApplet: systemTrayState.activeApplet

    /* Heading */
    property bool appletHasHeading: false
    property bool mergeHeadings: appletHasHeading && activeApplet.fullRepresentationItem.header.visible
    property int headingHeight: mergeHeadings ? activeApplet.fullRepresentationItem.header.height : 0
    /* Footer */
    property bool appletHasFooter: false
    property bool mergeFooters: appletHasFooter && activeApplet.fullRepresentationItem.footer.visible
    property int footerHeight: mergeFooters ? activeApplet.fullRepresentationItem.footer.height : 0

    onActiveAppletChanged: {
        mainStack.appletHasHeading = false
        mainStack.appletHasFooter = false
        if (activeApplet != null) {
            //reset any potential anchor
            activeApplet.fullRepresentationItem.anchors.left = undefined;
            activeApplet.fullRepresentationItem.anchors.top = undefined;
            activeApplet.fullRepresentationItem.anchors.right = undefined;
            activeApplet.fullRepresentationItem.anchors.bottom = undefined;
            activeApplet.fullRepresentationItem.anchors.centerIn = undefined;
            activeApplet.fullRepresentationItem.anchors.fill = undefined;

            if (activeApplet.fullRepresentationItem instanceof PlasmaComponents3.Page) {
                if (activeApplet.fullRepresentationItem.header && activeApplet.fullRepresentationItem.header instanceof PlasmaExtras.PlasmoidHeading) {
                    mainStack.appletHasHeading = true
                    activeApplet.fullRepresentationItem.header.background.visible = false
                }
                if (activeApplet.fullRepresentationItem.footer && activeApplet.fullRepresentationItem.footer instanceof PlasmaExtras.PlasmoidHeading) {
                    mainStack.appletHasFooter = true
                    activeApplet.fullRepresentationItem.footer.background.visible = false
                }
            }

            mainStack.replace({item: activeApplet.fullRepresentationItem, immediate: !systemTrayState.expanded, properties: {focus: true}});
        } else {
            mainStack.replace(emptyPage);
        }
    }

    onCurrentItemChanged: {
        if (currentItem !== null && plasmoid.expanded) {
            currentItem.forceActiveFocus();
        }
    }

    Connections {
        target: plasmoid
        function onAppletRemoved(applet) {
            if (applet === systemTrayState.activeApplet) {
                mainStack.clear()
            }
        }
    }
    //used to animate away to nothing
    Item {
        id: emptyPage
    }

    delegate: StackViewDelegate {
        id: transitioner
        function transitionFinished(properties) {
            properties.exitItem.opacity = 1
        }
        property bool goingLeft: {
            const unFlipped = systemTrayState.oldVisualIndex < systemTrayState.newVisualIndex

            if (Qt.application.layoutDirection == Qt.LeftToRight) {
                return unFlipped
            } else {
                return !unFlipped
            }
        }
        replaceTransition: StackViewTransition {
            ParallelAnimation {
                PropertyAnimation {
                    target: enterItem
                    property: "x"
                    from: root.vertical ? 0 : (transitioner.goingLeft ? enterItem.width : -enterItem.width)
                    to: 0
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.shortDuration
                }
                SequentialAnimation {
                    PropertyAction {
                        target: enterItem
                        property: "opacity"
                        value: 0
                    }
                    PauseAnimation {
                        duration: root.vertical ? (PlasmaCore.Units.shortDuration/2) : 0
                    }
                    PropertyAnimation {
                        target: enterItem
                        property: "opacity"
                        from: 0
                        to: 1
                        easing.type: Easing.InOutQuad
                        duration: (PlasmaCore.Units.shortDuration/2)
                    }
                }
            }
            ParallelAnimation {
                PropertyAnimation {
                    target: exitItem
                    property: "x"
                    from: 0
                    to: root.vertical ? 0 : (transitioner.goingLeft ? -exitItem.width : exitItem.width)
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.shortDuration
                }
                PropertyAnimation {
                    target: exitItem
                    property: "opacity"
                    from: 1
                    to: 0
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.shortDuration/2
                }
            }
        }
    }
}
