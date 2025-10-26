/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Nicolas Fella <nicolas.fella@gmx.de>
    SPDX-FileCopyrightText: 2020 Carl Schwan <carlschwan@kde.org>
    SPDX-FileCopyrightText: 2022-2023 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15

import org.kde.kirigami as Kirigami
import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.plasma.configuration 2.0
import org.kde.plasma.plasmoid 2.0

Rectangle {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 40
    implicitHeight: Kirigami.Units.gridUnit * 30

    Layout.minimumWidth: Kirigami.Units.gridUnit * 30
    Layout.minimumHeight: Kirigami.Units.gridUnit * 21

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    color: Kirigami.Theme.backgroundColor
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    property bool isContainment: false

    property ConfigModel globalConfigModel:  globalAppletConfigModel

    property url currentSource

    function closing() {
        if (applyButton.enabled) {
            messageDialog.item = null;
            messageDialog.show();
            return false;
        }
        return true;
    }

    function saveConfig() {
        const config = Plasmoid.configuration; // type: KConfigPropertyMap

        config.keys().forEach(key => {
            const cfgKey = "cfg_" + key;
            if (cfgKey in app.pageStack.currentItem) {
                config[key] = app.pageStack.currentItem[cfgKey];
            }
        })

        plasmoid.configuration.writeConfig();

        // For ConfigurationContainmentActions.qml
        if (app.pageStack.currentItem.hasOwnProperty("saveConfig")) {
            app.pageStack.currentItem.saveConfig()
        }
    }

    Connections {
        target: configDialog
        function onClosing(event) {
            event.accepted = closing();
        }
    }

    ConfigModel {
        id: globalAppletConfigModel
        ConfigCategory {
            name: i18nd("plasma_shell_org.kde.plasma.desktop", "Keyboard Shortcuts")
            icon: "preferences-desktop-keyboard"
            source: Qt.resolvedUrl("ConfigurationShortcuts.qml")
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: configDialogFilterModel
        sourceModel: configDialog.configModel
        filterRowCallback: (row, parent) => {
            return sourceModel.data(sourceModel.index(row, 0), ConfigModel.VisibleRole);
        }
    }

    function settingValueChanged() {
        applyButton.enabled = true;
    }

    function pushReplace(item, config) {
        let page;
        if (app.pageStack.depth === 0) {
            page = app.pageStack.push(item, config);
        } else {
            page = app.pageStack.replace(item, config);
        }
        app.currentConfigPage = page;
    }
    Component {
        id: configurationKcmPageComponent
        ConfigurationKcmPage {
        }
    }

    function open(item) {
        app.isAboutPage = false;
        root.currentSource = item.source

        if (item.source) {
            app.isAboutPage = item.source === Qt.resolvedUrl("AboutPlugin.qml");

            if (isContainment) {
                pushReplace(Qt.resolvedUrl("ConfigurationAppletPage.qml"), {configItem: item});
            } else {

                const config = Plasmoid.configuration; // type: KConfigPropertyMap

                const props = {
                    "title": item.name
                };

                config.keys().forEach(key => {
                    props["cfg_" + key] = config[key];
                });

                pushReplace(item.source, props);
            }

        } else if (item.kcm) {
            pushReplace(configurationKcmPageComponent, {kcm: item.kcm, internalPage: item.kcm.mainUi});
        } else {
            app.pageStack.pop();
        }

        applyButton.enabled = false
    }

    Connections {
        target: app.currentConfigPage

        ignoreUnknownSignals: true
        function onSettingValueChanged() {
            applyButton.enabled = true;
        }
    }

    Connections {
        target: app.pageStack

        function onCurrentItemChanged() {
            if (app.pageStack.currentItem !== null && !isContainment) {
                const config = Plasmoid.configuration; // type: KConfigPropertyMap

                config.keys().forEach(key => {
                    const changedSignal = app.pageStack.currentItem["cfg_" + key + "Changed"];
                    if (changedSignal) {
                        changedSignal.connect(() => root.settingValueChanged());
                    }
                });

                const configurationChangedSignal = app.pageStack.currentItem.configurationChanged;
                if (configurationChangedSignal) {
                    configurationChangedSignal.connect(() => root.settingValueChanged());
                }
            }
        }
    }

    Component.onCompleted: {
        // if we are a containment then the first item will be ConfigurationContainmentAppearance
        // if the applet does not have own configs then the first item will be Shortcuts
        if (isContainment || !configDialog.configModel || configDialog.configModel.count === 0) {
            open(root.globalConfigModel.get(0))
        } else {
            open(configDialog.configModel.get(0))
        }
    }

    function applicationWindow() {
        return app;
    }


    QQC2.ScrollView {
        id: categoriesScroll
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: Kirigami.Units.gridUnit * 10
        contentWidth: availableWidth
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false
        activeFocusOnTab: true
        focus: true
        Accessible.role: Accessible.MenuBar
        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
        }

        Image {
            source: "rsrc/bg.png"
            anchors.fill: parent
            smooth: true
        }
        Keys.onUpPressed: event => {
            const buttons = categories.children

            let foundPrevious = false
            for (let i = buttons.length - 1; i >= 0; --i) {
                const button = buttons[i];
                if (!button.hasOwnProperty("highlighted")) {
                    // not a ConfigCategoryDelegate
                    continue;
                }

                if (foundPrevious) {
                    categories.openCategory(button.item)
                    categoriesScroll.forceActiveFocus(Qt.TabFocusReason)
                    return
                } else if (button.highlighted) {
                    foundPrevious = true
                }
            }

            event.accepted = false
        }

        Keys.onDownPressed: event => {
            const buttons = categories.children

            let foundNext = false
            for (let i = 0, length = buttons.length; i < length; ++i) {
                const button = buttons[i];
                if (!button.hasOwnProperty("highlighted")) {
                    continue;
                }
                if (foundNext) {
                    categories.openCategory(button.item)
                    categoriesScroll.forceActiveFocus(Qt.TabFocusReason)
                    return
                } else if (button.highlighted) {
                    foundNext = true
                }
            }

            event.accepted = false
        }

        ColumnLayout {
            id: categories

            spacing: Kirigami.Units.largeSpacing
            width: categoriesScroll.contentWidth
            focus: true

            function openCategory(item) {
                if (applyButton.enabled) {
                    messageDialog.item = item;
                    messageDialog.show();
                    return;
                }
                open(item)
            }

            Item {
                id: paddingItem
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }
            Component {
                id: categoryDelegate

                RowLayout {
                    id: delegate

                    required property var model
                    property var item: model

                    Accessible.role: Accessible.MenuItem
                    Accessible.name: model.name
                    Accessible.description: i18nd("plasma_shell_org.kde.plasma.desktop", "Open configuration page")
                    Accessible.onPressAction: ma.clicked(null)

                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.maximumWidth: categoriesScroll.width
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.largeSpacing
                    property bool highlighted: {
                        if (app.pageStack.currentItem) {
                            if (model.kcm && app.pageStack.currentItem.kcm) {
                                return model.kcm == app.pageStack.currentItem.kcm
                            } else {
                                return root.currentSource == model.source
                            }
                        }
                        return false
                    }
                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignTop
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        source: delegate.model.icon
                    }
                    Text {
                        color: ma.containsMouse ? "#074ae5" : "#151c55"
                        font.underline: ma.containsMouse
                        font.bold: parent.highlighted || delegate.focus
                        text: parent.model.name
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        rightPadding: Kirigami.Units.largeSpacing

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            enabled: !highlighted
                            hoverEnabled: true
                            onClicked: categories.openCategory(model);
                            cursorShape: delegate.highlighted ? Qt.ArrowCursor : Qt.PointingHandCursor

                        }
                    }
                }

            }

            Repeater {
                Layout.fillWidth: true
                model: root.isContainment ? globalConfigModel : undefined
                delegate: categoryDelegate
            }
            Repeater {
                Layout.fillWidth: true
                model: configDialogFilterModel
                delegate: categoryDelegate
            }
            Repeater {
                Layout.fillWidth: true
                model: !root.isContainment ? globalConfigModel : undefined
                delegate: categoryDelegate
            }
            Repeater {
                Layout.fillWidth: true
                model: ConfigModel {
                    ConfigCategory{
                        name: i18nd("plasma_shell_org.kde.plasma.desktop", "About")
                        icon: "help-about"
                        source: Qt.resolvedUrl("AboutPlugin.qml")
                    }
                }
                delegate: categoryDelegate
            }
        }
    }

    Kirigami.Separator {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        z: 1
    }
    Kirigami.Separator {
        id: verticalSeparator
        anchors {
            top: parent.top
            left: categoriesScroll.right
            bottom: parent.bottom
        }
        z: 1
    }

    Kirigami.ApplicationItem {
        id: app
        anchors {
            top: parent.top
            left: verticalSeparator.right
            right: parent.right
            bottom: parent.bottom
            topMargin: Kirigami.Units.largeSpacing
        }

        pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
        wideScreen: true
        //pageStack.globalToolBar.separatorVisible: false
        //pageStack.globalToolBar.colorSet: Kirigami.Theme.View
        property var currentConfigPage: null
        onCurrentConfigPageChanged: {
            if(currentConfigPage) {
                currentConfigPage.Kirigami.Theme.colorSet =  Kirigami.Theme.View
            }
        }
        property bool isAboutPage: false


        Window {
            id: messageDialog
            property var item
            modality: Qt.WindowModal
            title: i18nd("plasma_shell_org.kde.plasma.desktop", "Confirm changes")
            minimumWidth: contents.implicitWidth
            maximumWidth: minimumWidth
            minimumHeight: contents.implicitHeight
            maximumHeight: minimumHeight
            flags: Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.Dialog
            onClosing: {

            }
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: dialogButtons.implicitHeight + dialogButtons.Layout.bottomMargin + dialogButtons.Layout.topMargin
                color: "#f0f0f0"
                Rectangle {
                    height: 1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: anchors.top
                    color: "#dfdfdf"
                }
            }
            signal discarded();
            onDiscarded: {
                if (item) {
                    root.open(item);
                    messageDialog.close();
                } else {
                    applyButton.enabled = false;
                    configDialog.close();
                }
            }

            ColumnLayout {
                id: contents
                anchors.fill: parent
                spacing: Kirigami.Units.largeSpacing
                RowLayout {
                    Layout.leftMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    Layout.bottomMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.largeSpacing
                    Kirigami.Icon {
                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                        Layout.preferredHeight: width
                        source: "dialog-warning"
                    }
                    Text {
                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                        text: i18nd("plasma_shell_org.kde.plasma.desktop", "The settings of the current module have changed. Do you want to apply the changes or discard them?")
                        Layout.maximumWidth: Kirigami.Units.gridUnit*20
                        wrapMode: Text.WordWrap
                        color: "#0033bc"
                        font.pixelSize: 16
                        renderType: Text.NativeRendering
                        font.hintingPreference: Font.PreferFullHinting
                        font.kerning: false
                        layer.enabled: true
                    }
                }
                RowLayout {
                    id: dialogButtons
                    spacing: Kirigami.Units.mediumSpacing
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    Layout.bottomMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    Layout.topMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    QQC2.Button {
                        id: apply
                        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Apply")
                        Layout.preferredHeight: 21
                        KeyNavigation.right: discard
                        Keys.onPressed: event => {
                            if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                                clicked(null);
                            }
                        }
                        onClicked: {
                            applyAction.trigger();
                            messageDialog.discarded();
                        }
                    }
                    QQC2.Button {
                        id: discard
                        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Discard")
                        KeyNavigation.left: apply
                        KeyNavigation.right: cancel
                        Keys.onPressed: event => {
                            if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                                clicked(null);
                            }
                        }
                        Layout.preferredHeight: 21
                        onClicked: {
                            messageDialog.discarded();
                        }
                    }
                    QQC2.Button {
                        id: cancel
                        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Cancel")
                        focus: true
                        KeyNavigation.left: discard
                        Keys.onPressed: event => {
                            if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                                clicked(null);
                            }
                        }
                        Layout.preferredHeight: 21
                        onClicked: {
                            messageDialog.close();
                        }
                    }
                }
            }
        }

        footer: QQC2.Pane {

            padding: Kirigami.Units.largeSpacing

            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
                Kirigami.Theme.colorSet:  Kirigami.Theme.Window
                Kirigami.Theme.inherit: false
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#bababe"
                }

            }
            contentItem: RowLayout {
                id: buttonsRow
                spacing: Kirigami.Units.smallSpacing

                Item {
                    Layout.fillWidth: true
                }

                QQC2.Button {
                    icon.name: "dialog-ok"
                    text: i18nd("plasma_shell_org.kde.plasma.desktop", "OK")
                    onClicked: acceptAction.trigger()
                    KeyNavigation.tab: categories
                }
                QQC2.Button {
                    id: applyButton
                    enabled: false
                    icon.name: "dialog-ok-apply"
                    text: i18nd("plasma_shell_org.kde.plasma.desktop", "Apply")
                    visible: !app.isAboutPage && app.pageStack.currentItem && (!app.pageStack.currentItem.kcm || app.pageStack.currentItem.kcm.buttons & 4) // 4 = Apply button
                    onClicked: applyAction.trigger()
                }
                QQC2.Button {
                    icon.name: "dialog-cancel"
                    text: i18nd("plasma_shell_org.kde.plasma.desktop", "Cancel")
                    onClicked: cancelAction.trigger()
                    visible: !app.isAboutPage
                }
            }
        }

        QQC2.Action {
            id: acceptAction
            onTriggered: {
                applyAction.trigger();
                configDialog.close();
            }
        }

        QQC2.Action {
            id: applyAction
            onTriggered: {
                if (isContainment) {
                    app.pageStack.get(0).saveConfig()
                } else {
                    root.saveConfig()
                }

                applyButton.enabled = false;
            }
        }

        QQC2.Action {
            id: cancelAction
            onTriggered: {
                if (root.closing()) {
                    configDialog.close();
                }
            }
        }

        Keys.onReturnPressed: acceptAction.trigger();
        Keys.onEscapePressed: cancelAction.trigger();
    }
}
