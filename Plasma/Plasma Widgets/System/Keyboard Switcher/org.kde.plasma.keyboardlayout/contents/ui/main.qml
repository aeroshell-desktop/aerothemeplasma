/*
    SPDX-FileCopyrightText: 2020 Andrey Butirsky <butirsky@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import Qt.labs.platform 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.workspace.components 2.0

Item {
    id: root

    function iconURL(name) {
        return StandardPaths.locate(StandardPaths.GenericDataLocation,
                        "kf5/locale/countries/" + name + "/flag.png")
    }

    signal layoutSelected(int layout)

    function actionTriggered(selectedLayout) {
        layoutSelected(selectedLayout)
    }

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.compactRepresentation: KeyboardLayoutSwitcher {
        Plasmoid.toolTipSubText: layoutNames.longName
        Plasmoid.status: hasMultipleKeyboardLayouts ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus

        Connections {
            target: keyboardLayout

            function onLayoutsListChanged() {
                plasmoid.clearActions()

                keyboardLayout.layoutsList.forEach(
                            function(layout, index) {
                                plasmoid.setAction(
                                            index,
                                            layout.longName,
                                            iconURL(layout.shortName).toString().substring(7) // remove file:// scheme
                                            )
                            }
                            )
            }

            function onLayoutChanged() {
                root.Plasmoid.activated()
            }
        }

        Connections {
            target: root

            function onLayoutSelected(layout) {
               keyboardLayout.layout = layout
            }
        }

        hoverEnabled: true

        PlasmaCore.IconItem {
            id: icon

            source: iconURL(layoutNames.shortName)
            visible: plasmoid.configuration.showFlag && source
            anchors.fill: parent
            active: containsMouse
        }

        PlasmaComponents3.Label {
            text: layoutNames.displayName || layoutNames.shortName
            visible: !icon.visible
            anchors.fill: parent
            anchors.margins: PlasmaCore.Units.smallSpacing*2
            //anchors.bottomMargin: PlasmaCore.Units.smallSpacing
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            minimumPointSize: 9;
            rightPadding: PlasmaCore.Units.smallSpacing
            leftPadding: PlasmaCore.Units.smallSpacing
            font.pointSize: height
            font.capitalization: Font.AllUppercase
            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onClicked: {
                    mouse.accepted = false;
                }
            }
            PlasmaCore.FrameSvgItem {
                id: decorationButton
                z: -1
                anchors.fill: parent
                imagePath: "widgets/button"
                visible: ma.containsMouse
                prefix: {
                    var x = "keyboard-";
                    if(ma.containsMouse && !ma.containsPress) return x+"hover";
                    else if(ma.containsMouse && ma.containsPress) return x+"pressed";
                    else return "keyboard-hover";
                }
            }
        }
        
    }
}
