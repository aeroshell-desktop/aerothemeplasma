import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.coreaddons 1.0 as KCoreAddons
import org.kde.kcmutils as KCMUtils

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasmoid 2.0

Window {
    id: detailsWindow
    title: networkName + " Status"
    color: "#f0f0f0"
    property color borderColor: "#b4b4b4"
    property alias tabBar: tabs
    minimumWidth: 360
    maximumWidth: 360
    minimumHeight: 420
    maximumHeight: 420

    property var devicePath: null
    property var connectionModel: null
    property string networkName: ""
    property string uuid: ""
    property var connectionState: PlasmaNM.Enums.Deactivated
    property var type: PlasmaNM.Enums.Other
    property var speedVisible: connectionState === PlasmaNM.Enums.Activated &&
                               (type === PlasmaNM.Enums.Wired ||
                                type === PlasmaNM.Enums.Wireless ||
                                type === PlasmaNM.Enums.Gsm ||
                                type === PlasmaNM.Enums.Cdma)

    property var detailsHeight: detailsLoader.item.implicitHeight
    onDetailsHeightChanged: {
        if(217+detailsLoader.item.implicitHeight > 420) {
            maximumHeight = 217+detailsLoader.item.implicitHeight;
            minimumHeight = maximumHeight;
            height = maximumHeight;
        }
    }

    Component.onCompleted: {
        handler.requestScan();
        detailsLoader.setSource("NetworkDetailsPage.qml", {
            networkName: detailsWindow.networkName,
            uuid: detailsWindow.uuid,
            connectionModel: detailsWindow.connectionModel
        });
        if (detailsLoader.status === Loader.Error) {
            console.warn("Cannot create details page component");
            return;
        }

        speedLoader.setSource("SpeedGraphPage.qml", {
            networkName: detailsWindow.networkName,
            uuid: detailsWindow.uuid,
            connectionModel: detailsWindow.connectionModel
        });
        if (speedLoader.status === Loader.Error) {
            console.warn("Cannot create speed graph component");
            return;
        }
    }
    TabBar {
        id: tabs
        anchors.top: parent.top;
        anchors.left: parent.left;
        anchors.right: parent.right;
        height: 21
        anchors.leftMargin: Kirigami.Units.mediumSpacing
        anchors.rightMargin: Kirigami.Units.mediumSpacing
        z: 1
        //width: parent.width
        TabButton {
            width: contentItem.implicitWidth + Kirigami.Units.largeSpacing*2
            height: 21
            bottomPadding: 2
            topPadding: isCurrentIndex ? 0 : Kirigami.Units.smallSpacing+1
            spacing: 0
            property bool isCurrentIndex: (TabBar.index === tabs.currentIndex)
            contentItem: Text { // All this just to make the sizing correct
                text: "General"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle { // To render the bottom border when the tab is not active
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1
                height: 1
                color: detailsWindow.borderColor
                visible: !parent.isCurrentIndex
            }
        }
        TabButton {
            width: contentItem.implicitWidth + Kirigami.Units.largeSpacing*2
            height: 21
            bottomPadding: 2
            topPadding: isCurrentIndex ? 0 : Kirigami.Units.smallSpacing+1
            property bool isCurrentIndex: (TabBar.index === tabs.currentIndex)
            spacing: 0
            visible: detailsWindow.speedVisible
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1
                height: 1
                color: detailsWindow.borderColor
                visible: !parent.isCurrentIndex
            }
            contentItem: Text {
                text: "Speed"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    Rectangle {
        id: background
        anchors.top: tabs.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: closeButton.top
        anchors.leftMargin: Kirigami.Units.mediumSpacing
        anchors.rightMargin: Kirigami.Units.mediumSpacing
        anchors.bottomMargin: Kirigami.Units.mediumSpacing+1
        anchors.topMargin: Kirigami.Units.smallSpacing
        z: -1
        border.color: detailsWindow.borderColor
        border.width: 1
    }
    StackLayout {
        id: windowStack
        anchors.fill: background
        anchors.margins: 14
        currentIndex: tabs.currentIndex
        Loader {
            id: detailsLoader
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        Loader {
            id: speedLoader
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
    Button {
        id: closeButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.largeSpacing-1
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        width: 73
        height: 21
        text: "Close"
        onClicked: {
            detailsWindow.close();
        }
        Keys.onPressed: event => {
            if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                detailsWindow.close();
                event.accepted = true;
            }
        }
    }
    onClosing: {
        detailsLoader.source = "";
        speedLoader.source = "";
        mainWindow.windowManager.removeWindow(detailsWindow.networkName+detailsWindow.uuid);
    }
}
