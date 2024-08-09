/*
    SPDX-FileCopyrightText: 2020 Andrey Butirsky <butirsky@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import Qt.labs.platform 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.workspace.components 2.0
import org.kde.plasma.private.kcm_keyboard as KCMKeyboard
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg as KSvg
import QtQuick.Layouts

PlasmoidItem {
    id: root

    signal layoutSelected(int layoutIndex)

    preferredRepresentation: fullRepresentation
    toolTipMainText: Plasmoid.title
    toolTipSubText: fullRepresentationItem ? fullRepresentationItem.layoutNames.longName : ""

    fullRepresentation: KeyboardLayoutSwitcher {
        id: switcher

        hoverEnabled: true
        Plasmoid.status: hasMultipleKeyboardLayouts ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus

        property int widgetWidth: 24
        Layout.minimumWidth: widgetWidth
        Layout.maximumWidth: widgetWidth
        Layout.preferredWidth: widgetWidth

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainText: root.toolTipMainText
            subText: root.toolTipSubText
        }

        Instantiator {
            id: actionsInstantiator
            model: switcher.keyboardLayout.layoutsList
            delegate: PlasmaCore.Action {
                text: modelData.longName
                icon.icon: KCMKeyboard.Flags.getIcon(modelData.shortName)
                onTriggered: {
                    layoutSelected(index);
                }
            }
            onObjectAdded: (index, object) => {
                Plasmoid.contextualActions.push(object)
            }
            onObjectRemoved: (index, object) => {
                Plasmoid.contextualActions.splice(Plasmoid.contextualActions.indexOf(object), 1)
            }
        }
        Connections {
            target: switcher.keyboardLayout

            function onLayoutChanged() {
                root.Plasmoid.activated();
            }
        }

        Connections {
            target: root

            function onLayoutSelected(layoutIndex) {
               switcher.keyboardLayout.layout = layoutIndex;
            }
        }

        Kirigami.Icon {
            id: flag

            anchors.fill: parent

            visible: valid && (Plasmoid.configuration.displayStyle === 1 || Plasmoid.configuration.displayStyle === 2)

            active: containsMouse
            source: KCMKeyboard.Flags.getIcon(layoutNames.shortName)

            BadgeOverlay {
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                visible: !countryCode.visible && Plasmoid.configuration.displayStyle === 2

                text: countryCode.text
                icon: flag
            }
        }

        PlasmaComponents3.Label {
            id: countryCode
            anchors.fill: parent
            visible: Plasmoid.configuration.displayStyle === 0 || !flag.valid


            anchors.bottomMargin: Kirigami.Units.smallSpacing*2
			anchors.topMargin: Kirigami.Units.smallSpacing*2 - Kirigami.Units.smallSpacing/2

			minimumPointSize: 8
            font.pointSize: countryCode.height * 0.75
            font.capitalization: Font.AllUppercase
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: layoutNames.displayName || layoutNames.shortName

            rightPadding: Kirigami.Units.smallSpacing
            leftPadding: Kirigami.Units.smallSpacing
        }
        MouseArea {
            id: ma
            property int margin: Kirigami.Units.smallSpacing/2+((0.4*switcher.height) - 9)
            anchors.fill: parent
            anchors.topMargin: margin
            anchors.bottomMargin: margin
            hoverEnabled: true
            propagateComposedEvents: true
            onClicked: (mouse) => {
                mouse.accepted = false;
            }
        }
        KSvg.FrameSvgItem {
            id: decorationButton
            z: -1
            anchors.fill: parent
            anchors.topMargin: ma.margin
            anchors.bottomMargin: ma.margin
            imagePath: Qt.resolvedUrl("svgs/button.svg")
            visible: ma.containsMouse
            prefix: {
                var x = "keyboard-";
                if(ma.containsMouse && !ma.containsPress) return x+"hover";
                else if(ma.containsMouse && ma.containsPress) return x+"pressed";
                else return "keyboard-hover";
            }
        }
    }

    function actionTriggered(actionName) {
        const layoutIndex = parseInt(actionName);
        if (!isNaN(layoutIndex)) {
            layoutSelected(layoutIndex);
        }
    }
}
