/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2

import Qt5Compat.GraphicalEffects

import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kwindowsystem 1.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg as KSvg

import QtQuick.Window 2.1
import QtQuick.Layouts 1.1

import org.kde.plasma.private.shell 2.0

PC3.Page {
    id: main

    implicitWidth: 686
    implicitHeight: 320 + details.height //header.height + footer.height + whiteBackground.height + details.height

    opacity: draggingWidget ? 0.3 : 1

    property QtObject containment

    property Window sidePanel

    //external drop events can cause a raise event causing us to lose focus and
    //therefore get deleted whilst we are still in a drag exec()
    //this is a clue to the owning dialog that hideOnWindowDeactivate should be deleted
    //See https://bugs.kde.org/show_bug.cgi?id=332733
    property bool preventWindowHide: draggingWidget || categoriesDialog.status !== PlasmaExtras.Menu.Closed
                                  || widgetsOptions.status !== PlasmaExtras.Menu.Closed

    property bool showingDetails: false

    // We might've lost focus during the widget drag and drop or whilst using
    // the "get widgets" dialog; however we prevented the sidebar to hide.
    // This might get the sidebar stuck, since we only hide when losing focus.
    // To avoid this we reclaim focus as soon as the drag and drop is done,
    // or the get widgets window is closed.
    onPreventWindowHideChanged: {
        if (!preventWindowHide && !sidePanel.active) {
            sidePanel.requestActivate()
        }
    }

    property bool outputOnly: draggingWidget

    //property Item categoryButton

    property bool draggingWidget: false

    component GlowText: Text {
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

    component GlowLink: Text {
        renderType: Text.NativeRendering
        property string link: ""
        property var action
        font.hintingPreference: Font.PreferFullHinting
        font.kerning: false
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 16
            samples: 31
            color: "#90ffffff"
            spread: 0.65
        }
        function click() {
            ma.clicked(null);
        }
        font.underline: activeFocus
        color: (ma.containsMouse) ? "#3399ff" : "#0066cc"
        Keys.onPressed: event => {
            if(event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                click();
            }
            event.accepted = false;
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if(link != "")
                    Qt.callLater(Qt.openUrlExternally, parent.link);
                else
                    parent.action();
            }
        }
    }

    component TexturedButton: KSvg.SvgItem {
        id: texturedButton

        function click() {
            if(texturedButton_ma.enabled)
                texturedButton_ma.clicked(null);
        }
        property bool debounce: true
        property bool disabled
        property string orientation
        property var action
        imagePath: Qt.resolvedUrl("../svgs/page.svg");
        opacity: disabled ? 0.5 : 1.0
        /*Layout.preferredHeight: 19
        Layout.preferredWidth: 19*/
        width: 19
        height: width
        Keys.onPressed: event => {
            if(event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                click();
            }
            event.accepted = false;
        }
        elementId: {
            if(disabled) return orientation + "-disabled";
            else if(texturedButton_ma.containsPress) return orientation + "-pressed";
            else if(texturedButton_ma.containsMouse || texturedButton.activeFocus) return orientation + "-hover";
            else return orientation + "-normal";
        }
        Timer {
            id: debouncer
            interval: 250
            onTriggered: {}
        }
        MouseArea {
            id: texturedButton_ma
            anchors.fill: parent
            enabled: !parent.disabled
            hoverEnabled: true
            onClicked: {
                if(!debouncer.running)
                    action();
                debouncer.start()
            }
        }
    }


    signal closed()

    onVisibleChanged: {
        if (!visible) {
            KWindowSystem.showingDesktop = false
        }
    }

    Component.onCompleted: {
        if (!root.widgetExplorer) {
            root.widgetExplorer = widgetExplorerComponent.createObject(root)
        }
        root.widgetExplorer.containment = main.containment
    }

    Component.onDestruction: {
        if (pendingUninstallTimer.running) {
            // we're not being destroyed so at least reset the filters
            widgetExplorer.widgetsModel.filterQuery = ""
            widgetExplorer.widgetsModel.filterType = ""
            widgetExplorer.widgetsModel.searchTerm = ""
        } else {
            root.widgetExplorer.destroy()
            root.widgetExplorer = null
        }
    }

    function addCurrentApplet() {
        var pluginName = list.currentItem ? list.currentItem.pluginName : ""
        if (pluginName) {
            widgetExplorer.addApplet(pluginName)
        }
    }

    QQC2.Action {
        shortcut: "Escape"
        onTriggered: {
            if (searchInput.length > 0) {
                searchInput.text = ""
            } else {
                main.closed()
            }
        }
    }

    Window {
        id: confirmationDialog
        modality: Qt.ApplicationModal
        title: "Desktop Gadgets"
        minimumWidth: contents.implicitWidth
        maximumWidth: minimumWidth
        minimumHeight: contents.implicitHeight
        maximumHeight: minimumHeight
        flags: Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.Dialog
        onClosing: {
            pendingUninstallTimer.applets = [];
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
                    text: "Do you want to uninstall " + widgetsOptions.visualParent.name + "?";
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
                    id: uninstall
                    text: "Uninstall"
                    Layout.preferredHeight: 21
                    KeyNavigation.right: no_uninstall
                    Keys.onPressed: event => {
                        if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                            clicked(null);
                        }
                    }
                    onClicked: {

                        var pending = pendingUninstallTimer.applets
                        if (widgetsOptions.visualParent.pendingUninstall) {
                            var index = pending.indexOf(widgetsOptions.visualParent.pluginName)
                            if (index > -1) {
                                pending.splice(index, 1)
                            }
                        } else {
                            pending.push(widgetsOptions.visualParent.pluginName)
                        }
                        pendingUninstallTimer.applets = pending;

                        pendingUninstallTimer.uninstall();
                        confirmationDialog.hide();
                    }
                }
                QQC2.Button {
                    id: no_uninstall
                    text: "Don't uninstall"
                    focus: true
                    KeyNavigation.left: uninstall
                    Keys.onPressed: event => {
                        if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                            clicked(null);
                        }
                    }
                    Layout.preferredHeight: 21
                    onClicked: {
                        pendingUninstallTimer.applets = [];
                        confirmationDialog.hide();
                    }
                }
            }
        }
    }

    Component {
        id: widgetExplorerComponent

        WidgetExplorer {
            //view: desktop
            onShouldClose: main.closed();
        }
    }

    PlasmaExtras.ModelContextMenu {
        id: categoriesDialog
        visualParent: filterWidgets
        placement: PlasmaExtras.Menu.BottomPosedRightAlignedPopup
        // model set on first invocation

        onStatusChanged: {
            if(status === PlasmaExtras.Menu.Closed) {
                 filterWidgets.forceActiveFocus();
            }
        }
        onClicked: {
            list.contentX = 0
            list.contentY = 0
            //categoryButton.text = (model.filterData ? model.display : i18nd("plasma_shell_org.kde.plasma.desktop", "All Widgets"))
            widgetExplorer.widgetsModel.filterQuery = model.filterData
            widgetExplorer.widgetsModel.filterType = model.filterType
            pageSwitcher.pageIndex = 0;
            list.positionViewAtBeginning()
            list.currentIndex = list.count ? 0 : -1

        }
    }

    PlasmaExtras.Menu {
        id: widgetsOptions
        placement: PlasmaExtras.Menu.BottomPosedRightAlignedPopup
        PlasmaExtras.MenuItem {
            text: "Add"
            onClicked: {
                if(widgetsOptions.visualParent) widgetExplorer.addApplet(widgetsOptions.visualParent.pluginName)
            }
        }
        PlasmaExtras.MenuItem {
            text: "Uninstall"
            visible: widgetsOptions.visualParent && widgetsOptions.visualParent.local

            onClicked: {
                if(widgetsOptions.visualParent) {
                    confirmationDialog.show();
                }
            }
        }
    }

    header: PlasmaExtras.PlasmoidHeading {
        height: 42
        ColumnLayout {
            id: header
            anchors.fill: parent

            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    id: pageSwitcher
                    property int itemsPerPage: 12
                    property int pageIndex: 0
                    property int currentPage: Math.floor(pageIndex / itemsPerPage) + (maxPages != 0 ? 1 : 0)
                    property int maxPages: Math.ceil(list.count / itemsPerPage)
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    spacing: 0

                    function flipBackward() {
                        var cx = list.contentX;
                        list.positionViewAtIndex(pageSwitcher.pageIndex, GridView.Beginning);
                        anim.from = cx;
                        anim.to = list.contentX;
                        anim.running = true;
                    }
                    function flipForward() {
                        var cx = list.contentX;
                        var incompletePage = list.count % pageSwitcher.itemsPerPage != 0
                        if(forwardButton.disabled && incompletePage) list.contentX = list.width * (pageSwitcher.maxPages-1);
                        else list.positionViewAtIndex(pageSwitcher.pageIndex, GridView.Beginning);
                        anim.from = cx;
                        anim.to = list.contentX;
                        anim.running = true;
                    }
                    Rectangle {
                        id: pageBackground
                        anchors.fill: parent
                        anchors.margins: -Kirigami.Units.smallSpacing/2
                        anchors.leftMargin: 0
                        anchors.rightMargin: -Kirigami.Units.smallSpacing+1
                        color: "white"
                        opacity: pageBackground.activeFocus ? 0.5 : 0.3
                        border.color: "#51000000"
                        border.width: 1
                        border.pixelAligned: true
                        radius: 19
                        KeyNavigation.tab: searchInput
                        KeyNavigation.right: pageBackground
                        KeyNavigation.down: list
                        Keys.onPressed: event => {
                            if(event.key == Qt.Key_Left) {
                                backButton.click();
                                pageBackground.forceActiveFocus();
                            } else if(event.key == Qt.Key_Right) {
                                forwardButton.click();
                            }
                        }

                    }
                    TexturedButton {
                        id: backButton
                        orientation: "back"
                        disabled: pageSwitcher.currentPage <= 1
                        action: () => {
                            pageSwitcher.pageIndex = (pageSwitcher.currentPage-2) * pageSwitcher.itemsPerPage;
                            pageSwitcher.flipBackward();
                        }
                    }

                    Text {
                        Layout.bottomMargin: 1
                        Layout.leftMargin: Kirigami.Units.gridUnit+1
                        Layout.rightMargin: Kirigami.Units.gridUnit+1
                        text: "Page " + pageSwitcher.currentPage + " of " + pageSwitcher.maxPages
                        renderType: Text.NativeRendering
                        font.hintingPreference: Font.PreferFullHinting
                        font.kerning: false
                    }

                    TexturedButton {
                        id: forwardButton
                        orientation: "forward"
                        disabled: pageSwitcher.currentPage == pageSwitcher.maxPages
                        action: () => {
                            pageSwitcher.pageIndex = (pageSwitcher.currentPage) * pageSwitcher.itemsPerPage;
                            pageSwitcher.flipForward();
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                PC3.TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.maximumWidth: 201
                    Layout.preferredHeight: 23
                    focus: false
                    leftPadding: Kirigami.Units.smallSpacing*1.5
                    bottomPadding: Kirigami.Units.smallSpacing-1
                    verticalAlignment: Qt.AlignTop
                    KeyNavigation.down: list
                    KeyNavigation.right: filterWidgets
                    KeyNavigation.tab: filterWidgets
                    KeyNavigation.backtab: pageBackground
                    KeyNavigation.left: pageBackground
                    font.italic: !searchInput.activeFocus
                    color: font.italic ? "#707070" : "black"
                    cursorDelegate: Rectangle {
                        id: cursor
                        color: "black"
                        width: 1
                        anchors.top: parent.top
                        anchors.topMargin: Kirigami.Units.smallSpacing
                        height: 14
                        visible: searchInput.cursorVisible
                        SequentialAnimation {
                            loops: Animation.Infinite
                            running: searchInput.cursorVisible
                            PropertyAction {
                                target: cursor
                                property: 'visible'
                                value: true
                            }
                            PauseAnimation { duration: 600 }
                            PropertyAction {
                                target: cursor
                                property: 'visible'
                                value: false
                            }
                            PauseAnimation { duration: 600 }
                        }
                    }
                    onTextChanged: {
                        widgetExplorer.widgetsModel.searchTerm = text
                        pageSwitcher.pageIndex = 0;
                        list.positionViewAtBeginning()
                        list.currentIndex = list.count ? 0 : -1
                    }

                    Component.onCompleted: if (!Kirigami.InputMethod.willShowOnActive) { forceActiveFocus() }
                    hoverEnabled: true
                    onPressed: event => {
                        if(dropdown_ma.containsMouse)
                            event.accepted = false;
                        else event.accepted = true;
                    }
                    onReleased: event => {
                        if(dropdown_ma.containsMouse)
                            event.accepted = false;
                        else event.accepted = true;
                    }
                    background:	KSvg.FrameSvgItem {
                        anchors.fill: parent
                        anchors.left: parent.left
                        imagePath: Qt.resolvedUrl("../svgs/lineedit.svg")
                        prefix: {
                            if(searchInput.activeFocus)
                                return "focus";
                            else if(searchInput.hovered)
                                return "hover";
                            else
                                return "base";
                        }

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: Kirigami.Units.smallSpacing
                            anchors.bottomMargin: 2
                            font.italic: true
                            color: "#707070"
                            text: i18n(" Search gadgets")
                            verticalAlignment: Text.AlignVCenter
                            visible: !searchInput.activeFocus && searchInput.text == ""
                            style: Text.Outline
                            styleColor: "transparent"
                            opacity: 0.55
                        }
                        Kirigami.Icon {
                            source: "gtk-search"
                            smooth: true
                            width: Kirigami.Units.iconSizes.small;
                            height: width
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                bottomMargin: 1
                                right: filterWidgets.left
                                rightMargin: Kirigami.Units.smallSpacing+1
                            }
                        }
                        KSvg.FrameSvgItem {
                            id: filterWidgets

                            width: 15
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: 2
                            anchors.leftMargin: 0
                            imagePath: Qt.resolvedUrl("../svgs/dropdown.svg");
                            opacity: searchInput.hovered || dropdown_ma.containsMouse || categoriesDialog.status !== PlasmaExtras.Menu.Closed || filterWidgets.activeFocus
                            onActiveFocusChanged: {
                                filterWidgets.focus = activeFocus;
                            }
                            KeyNavigation.right: list
                            KeyNavigation.left: searchInput
                            KeyNavigation.tab: list
                            KeyNavigation.backtab: searchInput
                            Keys.onPressed: event => {
                                if(event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                                    dropdown_ma.clicked(null);
                                } else if(event.key == Qt.Key_Down) {
                                    dropdown_ma.clicked(null);
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 250 }
                            }
                            prefix: {
                                if(dropdown_ma.containsPress || categoriesDialog.status !== PlasmaExtras.Menu.Closed) return "dropdown-pressed"
                                else return "dropdown-hover";

                            }

                        }
                        KSvg.SvgItem {
                            id: dropdownArrow
                            width: 7
                            height: 4
                            anchors.centerIn: filterWidgets
                            anchors.verticalCenterOffset: -1
                            imagePath: Qt.resolvedUrl("../svgs/dropdown.svg");
                            elementId: "dropdown-arrow"
                        }
                        MouseArea {
                            id: dropdown_ma
                            anchors.fill: filterWidgets
                            hoverEnabled: true
                            onClicked: {
                                categoriesDialog.model = widgetExplorer.filterModel
                                categoriesDialog.openRelative();
                            }
                        }
                    }

                }
            }
        }
    }


    footer: PlasmaExtras.PlasmoidHeading {
        height: 37

        Item {
            //spacing: Kirigami.Units.smallSpacing / 2
            anchors.fill: parent

            RowLayout {
                id: detailsButton

                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.leftMargin: Kirigami.Units.largeSpacing*2

                TexturedButton {
                    id: expandButton
                    orientation: main.showingDetails ? "expand-up" : "expand-down"
                    debounce: false
                    disabled: false
                    KeyNavigation.backtab: list
                    KeyNavigation.up: list
                    KeyNavigation.tab: installFromLocal_link
                    KeyNavigation.right: installFromLocal_link
                    KeyNavigation.priority: KeyNavigation.BeforeItem
                    action: () => {
                        details_ma.clicked(null)
                    }
                }

                GlowText {
                    id: showDetailsText
                    Layout.bottomMargin: 1
                    text: (main.showingDetails ? "Hide" : "Show") + " details"
                    MouseArea {
                        id: details_ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            main.showingDetails = !main.showingDetails;
                        }
                    }
                }

            }

            RowLayout {
                id: installFromLocal

                anchors.right: morePlasmoidsLink.left
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.smallSpacing/2
                anchors.rightMargin: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: width

                    source: "zip"
                }

                GlowLink {
                    id: installFromLocal_link
                    KeyNavigation.up: list
                    KeyNavigation.backtab: expandButton
                    KeyNavigation.tab: morePlasmoidsLink_link
                    KeyNavigation.right: morePlasmoidsLink_link
                    KeyNavigation.left: expandButton
                    KeyNavigation.priority: KeyNavigation.BeforeItem
                    text: "Install gadgets from local file"
                    action: widgetExplorer.widgetsMenuActions[2].trigger
                }
            }
            RowLayout {
                id: morePlasmoidsLink

                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.smallSpacing/2
                anchors.rightMargin: Kirigami.Units.largeSpacing*2

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: width

                    source: "emblem-web"
                }

                GlowLink {
                    id: morePlasmoidsLink_link
                    KeyNavigation.up: list
                    KeyNavigation.backtab: installFromLocal_link
                    KeyNavigation.left: installFromLocal_link
                    KeyNavigation.priority: KeyNavigation.BeforeItem
                    text: "Get more gadgets online"
                    action: widgetExplorer.widgetsMenuActions[0].trigger
                }
            }
        }
    }

    Timer {
        id: setModelTimer
        interval: 20
        running: true
        onTriggered: list.model = widgetExplorer.widgetsModel
    }

    Rectangle {
        id: whiteBackground
        anchors.fill: parent
        color: "white"
        opacity: 0.3
        z: -1

    }
    NumberAnimation { id: anim; target: list; property: "contentX"; duration: 250 }
    GridView {
        id: list
        anchors {
            top: parent.top
            topMargin: Kirigami.Units.smallSpacing*2
            left: parent.left
            leftMargin: Kirigami.Units.smallSpacing*5
        }

        width: cellWidth*6
        height: cellHeight*2

        // model set delayed by Timer above
        activeFocusOnTab: true
        //keyNavigationEnabled: true
        cellWidth: 104
        cellHeight: cellWidth

        flow: GridView.FlowTopToBottom
        clip: true

        interactive: false

        delegate: AppletDelegate {}

        highlightMoveDuration: 0
        KeyNavigation.backtab: searchInput
        KeyNavigation.tab: expandButton
        KeyNavigation.up: list
        KeyNavigation.left: list
        KeyNavigation.right: list

        Keys.onPressed: event => {
            if(event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                addCurrentApplet();
            } else if(event.key == Qt.Key_Menu) {
                if(list.currentItem) {
                    widgetsOptions.visualParent = list.currentItem;
                    widgetsOptions.openRelative();
                }
            } else if(event.key == Qt.Key_Down) {
                list.forceActiveFocus();
                if(list.currentIndex+1 != list.count && (list.currentIndex+1) % 2 != 0) {
                    list.currentIndex++;
                }
                event.accepted = true;
                return;
            } else if(event.key == Qt.Key_Up) {
                if(list.currentIndex-1 != -1 && (list.currentIndex-1) % 2 != 1) {
                    list.currentIndex--;
                }
            } else if(event.key == Qt.Key_Left) {
                if(list.currentIndex-2 > -1) {
                    var previousPage = pageSwitcher.currentPage;
                    list.currentIndex -= 2;
                    pageSwitcher.pageIndex = list.currentIndex;
                    if(pageSwitcher.currentPage !== previousPage) {
                        pageSwitcher.pageIndex = (pageSwitcher.currentPage-1) * 12;
                        pageSwitcher.flipBackward();
                    }
                }
            } else if(event.key == Qt.Key_Right) {
                if(list.currentIndex+2 < list.count) {
                    var previousPage = pageSwitcher.currentPage;
                    list.currentIndex += 2;
                    pageSwitcher.pageIndex = list.currentIndex;
                    if(pageSwitcher.currentPage !== previousPage)
                        pageSwitcher.flipForward();
                }
             }
        }


    }

    KSvg.FrameSvgItem {
        id: separatorLine
        anchors {
            left: parent.left
            right: parent.right
            top: details.top
            leftMargin: -Kirigami.Units.mediumSpacing
            rightMargin: -Kirigami.Units.mediumSpacing
        }

        imagePath: "widgets/plasmoidheading"
        prefix: "footer"
        height: 2
        opacity: main.showingDetails ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }
    }

    Item {
        id: details
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: main.showingDetails ? 145 : 0
        opacity: main.showingDetails ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }

        Behavior on height {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }
        Item {
            id: detailsContainer
            anchors.fill: parent
            anchors.rightMargin: Kirigami.Units.largeSpacing*2 + Kirigami.Units.smallSpacing
            anchors.leftMargin: Kirigami.Units.largeSpacing*2 + Kirigami.Units.smallSpacing
            anchors.topMargin: Kirigami.Units.mediumSpacing
            visible: list.currentItem ? true : false
            RowLayout {
                id: basicInfo
                anchors.fill: parent
                ColumnLayout {
                    id: basicInfoColumn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    GlowText {
                        font.pixelSize: 16
                        text: parent.visible ? list.currentItem.name + " " + list.currentItem.version : ""
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        visible: text !== ""

                    }
                    GlowText {
                        text: parent.visible ? list.currentItem.description : ""
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        wrapMode: Text.WordWrap

                    }

                    GlowText {
                        text: parent.visible ? list.currentItem.pluginName : ""
                        Layout.fillWidth: true
                        Layout.bottomMargin: Kirigami.Units.largeSpacing
                        visible: text !== ""
                        wrapMode: Text.WordWrap
                    }
                }
                Item {

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Item {
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: authorInfo.implicitWidth
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                    ColumnLayout {
                        id: authorInfo
                        anchors.fill: parent
                        GlowText {
                            font.pixelSize: 14
                            text: parent.visible ? list.currentItem.author : ""
                            visible: text !== ""
                            wrapMode: Text.WordWrap
                        }
                        GlowText {
                            text: parent.visible ? list.currentItem.license : ""
                            visible: text !== ""
                            wrapMode: Text.WordWrap
                        }
                        GlowLink {
                            text: parent.visible ? list.currentItem.website : ""
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                            link: text
                        }
                        GlowText {
                            text: parent.visible ? list.currentItem.email : ""
                            wrapMode: Text.WordWrap
                            //visible: text !== ""
                            Layout.fillHeight: true
                        }

                    }
                }
            }
        }
    }

}
