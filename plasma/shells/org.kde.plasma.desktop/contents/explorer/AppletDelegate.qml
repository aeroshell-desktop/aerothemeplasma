/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1

import Qt5Compat.GraphicalEffects

import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kwindowsystem
import org.kde.kirigami 2.20 as Kirigami
import org.kde.graphicaleffects as KGraphicalEffects
import org.kde.ksvg as KSvg

Item {
    id: delegate

    readonly property string pluginName: model.pluginName
    readonly property bool pendingUninstall: pendingUninstallTimer.applets.indexOf(pluginName) > -1
    readonly property bool pressed: tapHandler.pressed

    readonly property string name: model.name
    readonly property string website: model.website
    readonly property string email: model.email
    readonly property string author: model.author

    readonly property string version: model.version
    readonly property string description: model.description
    readonly property string category: model.category
    readonly property string license: model.license

    readonly property bool local: model.local

    width: 104
    height: width

    KSvg.FrameSvgItem {
        id: highlight
        anchors.fill: parent
        imagePath: "widgets/viewitem"
        prefix: {
            var isSelected = delegate.GridView.view.currentIndex == index;
            if(isSelected && hoverHandler.hovered) return "selected+hover";
            if(isSelected) return "selected";
            if(hoverHandler.hovered) return "hover";
            return "";
        }
    }
    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        id: tapHandler
        enabled: !delegate.pendingUninstall && model.isSupported
        onDoubleTapped: widgetExplorer.addApplet(delegate.pluginName)
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onTapped: (eventPoint, button) => {
            if(button == Qt.LeftButton)
                delegate.GridView.view.currentIndex = index;
            else if(button == Qt.RightButton) {
                widgetsOptions.visualParent = delegate;
                widgetsOptions.openRelative();
            }
        }
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        visible: model.running
        mainText: model.running + " added"
    }
    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        visible: !model.isSupported
        mainText: i18n("Unsupported Widget")
        subText: model.unsupportedMessage
    }

    // Avoid repositioning delegate item after dragFinished
    Item {
        anchors.fill: parent
        enabled: model.isSupported

        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.MoveAction | Qt.LinkAction
        Drag.mimeData: {
            "text/x-plasmoidservicename" : delegate.pluginName,
        }
        Drag.onDragStarted: {
            KWindowSystem.showingDesktop = true;
            main.draggingWidget = true;
        }
        Drag.onDragFinished: {
            KWindowSystem.showingDesktop = false;
            main.draggingWidget = false;
        }

        DragHandler {
            id: dragHandler
            enabled: !delegate.pendingUninstall && model.isSupported

            onActiveChanged: if (active) {
                iconContainer.grabToImage(function(result) {
                    if (!dragHandler.active) {
                        return;
                    }
                    parent.Drag.imageSource = result.url;
                    parent.Drag.active = dragHandler.active;
                }, Qt.size(Kirigami.Units.iconSizes.huge, Kirigami.Units.iconSizes.huge));
            } else {
                parent.Drag.active = false;
                parent.Drag.imageSource = "";
            }
        }
    }

    ColumnLayout {
        id: mainLayout

        readonly property color textColor: tapHandler.pressed ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

        spacing: Kirigami.Units.smallSpacing
        anchors {
            left: parent.left
            right: parent.right
            //bottom: parent.bottom
            margins: Kirigami.Units.smallSpacing * 2
            rightMargin: Kirigami.Units.smallSpacing * 2 // don't cram the text to the border too much
            top: parent.top
        }

        Item {
            id: iconContainer
            width: Kirigami.Units.iconSizes.huge
            height: width
            Layout.alignment: Qt.AlignHCenter
            opacity: delegate.pendingUninstall ? 0.6 : 1
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            Item {
                id: iconWidget
                anchors.fill: parent
                Kirigami.Icon {
                    anchors.fill: parent
                    source: model.decoration
                    enabled: model.isSupported
                }
                Image {
                    width: Kirigami.Units.iconSizes.enormous
                    height: width
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: model.screenshot
                }
            }


        }
        PlasmaComponents.Label {
            id: heading
            Layout.fillWidth: true
            text: model.name
            textFormat: Text.PlainText
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            maximumLineCount: 1
            horizontalAlignment: Text.AlignHCenter
            color: "black"
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferFullHinting
            font.kerning: false
            layer.enabled: true
            layer.effect: DropShadow {
                radius: 16
                samples: 31
                color: "#90ffffff"
                spread: 0.65
            }
        }
    }
}
