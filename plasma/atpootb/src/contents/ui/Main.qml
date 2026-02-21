// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2025 WackyIdeas <wackyideas@disroot.org>

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg

import io.gitgud.wackyideas.atpootb

Window {
    id: mainWindow
    objectName: "MainWindow";
    visible: true
    property string __title: i18n("AeroThemePlasma Out of the Box Experience")
    title: __title

    color: "transparent"
    width: 600
    height: 400
    minimumHeight: height
    minimumWidth: width
    maximumHeight: height
    maximumWidth: width

    property bool lnfApplied: false

    readonly property color backgroundColor: Kirigami.Theme.backgroundColor
    readonly property color autoTextColor: {
        var yiq_y = ((backgroundColor.r * 0.299) + (backgroundColor.g * 0.587) + (backgroundColor.b * 0.114));
        return yiq_y >= 0.5 ? "#0033bc" : Kirigami.Theme.activeTextColor
    }

    component BasicPage : ColumnLayout {
        property string pageTitle
        QQC2.Label {
            text: pageTitle
            color: autoTextColor //Kirigami.Theme.activeTextColor //  "#0033bc"
            font.pointSize: 12
            font.family: "Segoe UI"
            Layout.fillWidth: true
            renderType: Text.NativeRendering
            Layout.bottomMargin: Kirigami.Units.largeSpacing
        }
        signal next()
        property string buttonText: i18n("Next")
    }

    Image {
        id: backButton
        width: btnWidth
        height: btnHeight
        source: (Screen.devicePixelRatio === 1.0) ? "qrc:/assets/img/back.png" : "qrc:/assets/img/back_125.png"
        property int btnWidth: (Screen.devicePixelRatio === 1.0) ? 29 : 38
        property int btnHeight: (Screen.devicePixelRatio === 1.0) ? 27 : 38
        sourceClipRect: {
            if(!backButtonMA.enabled) return Qt.rect(0, 3*btnHeight, btnWidth, btnHeight);
            if(backButtonMA.containsPress) return Qt.rect(0, 2*btnHeight, btnWidth, btnHeight);
            if(backButtonMA.containsMouse) return Qt.rect(0, 1*btnHeight, btnWidth, btnHeight);
            return Qt.rect(0, 0, btnWidth, btnHeight)
        }

        anchors {
            top: parent.top
            left: parent.left
            leftMargin: Kirigami.Units.smallSpacing / 2
            topMargin: Kirigami.Units.smallSpacing / 2
        }
        MouseArea {
            id: backButtonMA
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            enabled: pages.currentIndex > 0
            onClicked: {
                if(pages.currentIndex > 0) pages.currentIndex--;
            }
        }
    }

    Text {
        id: windowTitle
        anchors {
            top: parent.top
            left: backButton.right
            right: parent.right
            leftMargin: Kirigami.Units.mediumSpacing
            topMargin: Kirigami.Units.mediumSpacing
        }

        //color: Kirigami.Theme.textColor
        font.family: "Segoe UI"
        text: mainWindow.__title
        elide: Text.ElideMiddle
        renderType: Text.NativeRendering
        layer.enabled: true
        layer.effect: Glow {
            x: windowTitle.x
            y: windowTitle.y
            width: windowTitle.width
            height: windowTitle.height
            radius: 15
            samples: 31
            color: "#77ffffff"
            spread: 0.60
            source: windowTitle
            cached: true
        }

        DragHandler {
            grabPermissions:  PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverByAnything
            onActiveChanged: if (mainWindow.active) mainWindow.startSystemMove()
        }
    }
    BorderImage {
        id: activeBorders
        source: "qrc:/assets/img/inner_borders_active.png";
        anchors {
            top: backButton.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Kirigami.Units.smallSpacing
        }

        border {
            bottom: 2
            top: 2
            left: 2
            right: 2
        }

        smooth: false
        opacity: Window.active ? 1.0 : 0.0
    }
    BorderImage {
        id: inactiveBorders
        source: "qrc:/assets/img/inner_borders_inactive.png";
        anchors {
            top: backButton.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Kirigami.Units.smallSpacing
        }

        border {
            bottom: 2
            top: 2
            left: 2
            right: 2
        }

        smooth: false
        opacity: !Window.active ? 1.0 : 0.0
    }
    Rectangle {
        id: contentBackground
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        anchors {
            top: activeBorders.top
            left: activeBorders.left
            right: activeBorders.right
            bottom: footer.top
            leftMargin: 2
            rightMargin: 2
            topMargin: 2
        }

    }

    StackLayout {
        id: pages
        anchors.fill: contentBackground
        anchors.margins: Kirigami.Units.gridUnit*2
        anchors.topMargin: Kirigami.Units.gridUnit
        BasicPage {
            pageTitle: i18n("AeroThemePlasma Setup Wizard")
            QQC2.Label {
                text: i18n("Welcome to the AeroThemePlasma first time setup wizard.")
                font.family: "Segoe UI"
            }
            Item {
                Layout.fillHeight: true
            }
            QQC2.Label {
                text: i18n("Microsoft® Windows™ is a registered trademark of Microsoft® Corporation. This name is used for referential use only, and does not aim to usurp copyrights from Microsoft. Microsoft Ⓒ 2025 All rights reserved. All respective resources and assets belong to Microsoft Corporation.")
                font.family: "Segoe UI"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                opacity: 0.75
            }
        }
        BasicPage {
            pageTitle: i18n("Look and Feel")
            buttonText: i18n("Apply")
            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                textFormat: Text.MarkdownText
                font.family: "Segoe UI"
                text: i18n("AeroThemePlasma will change the look and feel of the following parts of your system:\n" +
                           "- Plasma Style\n- Application Style\n- Color Scheme\n- Icon and Sound Theme\n- Window Effects and Animations\n\n" +
                           "To review these changes in detail, see the [install guide](https://gitgud.io/wackyideas/aerothemeplasma/-/blob/master/INSTALL.md?ref_type=heads). These settings can be changed later at any time.")
            }
            Item {
                Layout.fillHeight: true
            }
            QQC2.Label {
                opacity: 0.75
                text: i18n("These configurations will also be applied to the regular Plasma session.")
                font.family: "Segoe UI"
            }
            onNext: {
                App.applyLookAndFeel();
            }
        }
        BasicPage {
            pageTitle: i18n("SDDM Theme")
            buttonText: i18n("Apply")
            QQC2.Label {
                Layout.fillWidth: true
                font.family: "Segoe UI"
                wrapMode: Text.WordWrap
                textFormat: Text.MarkdownText
                text: i18n("AeroThemePlasma will change the look and feel of the login screen (SDDM), as well as synchronize settings between Plasma and SDDM.\n")
            }
            Item {
                Layout.fillHeight: true
            }
            RowLayout {
                Kirigami.Icon {
                    source: "security-medium-symbolic"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                }
                QQC2.Label {
                    opacity: 0.75
                    font.family: "Segoe UI"
                    text: i18n("These operations require administrator privileges.")
                }

            }
            onNext: {
                App.syncPlasmaWithSDDM();
            }
        }
        BasicPage {
            pageTitle: i18n("Cursor Theme")
            buttonText: i18n("Apply")
            QQC2.Label {
                Layout.fillWidth: true
                font.family: "Segoe UI"
                wrapMode: Text.WordWrap
                textFormat: Text.MarkdownText
                text: i18n("AeroThemePlasma will change the default cursor theme globally in order for SDDM to recognize it.\n")
            }
            Item {
                Layout.fillHeight: true
            }
            RowLayout {
                Kirigami.Icon {
                    source: "security-medium-symbolic"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                }
                QQC2.Label {
                    opacity: 0.75
                    font.family: "Segoe UI"
                    text: i18n("This operation requires administrator privileges.")
                }

            }
            onNext: {
                App.setCursorThemeSDDM();
            }
        }
        /*BasicPage {
            pageTitle: i18n("Additional Options")
            QQC2.Label {
                text: i18n("Select additional customization options for AeroThemePlasma.")
                font.family: "Segoe UI"
            }
            QQC2.Frame {
                id: checkBoxFrame
                property Item currentCheckbox: null
                Layout.fillWidth: true
                function setCurrentCheckBox(self) {
                    if(self.focus || self.hovered) {
                        checkBoxFrame.currentCheckbox = self;
                    } else if(!self.hovered && checkBoxFrame.currentCheckbox === self) {
                        checkBoxFrame.currentCheckbox = null;
                    }
                }
                ColumnLayout {
                    spacing: 2

                    QQC2.CheckBox {
                        id: mimetypeCheckBox
                        hoverEnabled: true
                        font.family: "Segoe UI"
                        property string description: i18n("This setting will locally override mimetype file associations for Windows™ executables (.exe, .dll, etc.) with file associations that have appropriate icon representations for each respective type.\n\nThis setting is recommended, especially if icon previews are disabled for these types.")
                        text: i18n("Fix file associatons for Windows™ executables and libraries")
                        onHoveredChanged: {
                            checkBoxFrame.setCurrentCheckBox(mimetypeCheckBox)
                        }
                        onFocusChanged: {
                            checkBoxFrame.setCurrentCheckBox(mimetypeCheckBox)
                        }
                    }
                    QQC2.CheckBox {
                        id: brandingCheckBox
                        hoverEnabled: true
                        font.family: "Segoe UI"
                        property string description: i18n("This setting will locally override the branding found in the system settings (KInfoCenter), replacing the distribution name and logo with AeroThemePlasma's branding.\n\nFor more authentic branding, see [Linver](https://gitgud.io/wackyideas/linver).")
                        text: i18n("Use AeroThemePlasma branding for Info Center")
                        onHoveredChanged: {
                            checkBoxFrame.setCurrentCheckBox(brandingCheckBox)
                        }
                        onFocusChanged: {
                            checkBoxFrame.setCurrentCheckBox(brandingCheckBox)
                        }
                    }
                }
            }
            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                textFormat: Text.MarkdownText
                text: checkBoxFrame.currentCheckbox?.description || ""
                font.family: "Segoe UI"
            }
        }*/
        BasicPage {
            pageTitle: i18n("Completing the AeroThemePlasma Setup Wizard")
            buttonText: i18n("Finish")
            QQC2.Label {
                text: i18n("Thank you for trying out AeroThemePlasma!")
                font.family: "Segoe UI"
            }
            QQC2.Label {
                text: i18n("Click Finish to exit the AeroThemePlasma wizard.")
                font.family: "Segoe UI"
            }
            onNext: {
                App.saveOotbConfig(true);
                Qt.quit();
            }
        }
    }
    Rectangle {
        id: footer
        anchors {
            left: activeBorders.left
            right: activeBorders.right
            bottom: activeBorders.bottom
            leftMargin: 2
            rightMargin: 2
            bottomMargin: 2
        }

        height: footerButtons.implicitHeight + footerButtons.anchors.bottomMargin + footerButtons.anchors.topMargin
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false
        color: Kirigami.Theme.backgroundColor
        Rectangle {
            height: 1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: anchors.top
            color: Kirigami.Theme.alternateBackgroundColor
        }
    }
    RowLayout {
        id: footerButtons
        anchors {
            left: activeBorders.left
            right: activeBorders.right
            bottom: activeBorders.bottom
            leftMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing + 2
            rightMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing + 2
            bottomMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing + 2
            topMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing + 2
        }

        Item {
            Layout.fillWidth: true
        }

        QQC2.Button {
            property bool isFinished: pages.currentIndex === pages.count-1
            text: pages.children[pages.currentIndex].buttonText
            onClicked: {
                pages.children[pages.currentIndex].next();
                if(!isFinished) pages.currentIndex++;
            }
        }
    }

    Component.onCompleted: {
        App.setWindowProps(mainWindow);
    }
}
