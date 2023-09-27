
import QtQuick 2.4
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons // kuser
import org.kde.plasma.private.shell 2.0

import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.quicklaunch 1.0

import org.kde.kirigami 2.13 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons


Item {
    id: floatingOrb
    width: buttonIcon.implicitWidth
    height: buttonIcon.implicitHeight
    property alias buttonIcon: buttonIcon
    property alias buttonIconPressed: buttonIconPressed
    property alias buttonIconHovered: buttonIconHovered
    property alias mouseArea: mouseArea

    PlasmaCore.IconItem {
        id: buttonIcon
        anchors.fill: parent
        opacity: 1
        readonly property double aspectRatio: (vertical ? implicitHeight / implicitWidth
            : implicitWidth / implicitHeight)

        source: getResolvedUrl(plasmoid.configuration.customButtonImage, "orbs/normal.png")
        smooth: true
        roundToIconSize: !useCustomButtonImage || aspectRatio === 1
        onSourceChanged: updateSizeHints()
    }
    PlasmaCore.IconItem {
        id: buttonIconPressed
        anchors.fill: parent
        opacity: 1
        visible: dashWindow.visible
        readonly property double aspectRatio: (vertical ? implicitHeight / implicitWidth
            : implicitWidth / implicitHeight)

        source: getResolvedUrl(plasmoid.configuration.customButtonImageActive, "orbs/selected.png") //

        smooth: true
        roundToIconSize: !useCustomButtonImage || aspectRatio === 1
        onSourceChanged: updateSizeHints()
    }
    PlasmaCore.IconItem {
        id: buttonIconHovered
        z: 1
        source: getResolvedUrl(plasmoid.configuration.customButtonImageHover, "orbs/hovered.png");
        opacity: mouseArea.containsMouse || mouseAreaCompositingOff.containsMouse
        visible:  !dashWindow.visible
        anchors.fill: parent
        readonly property double aspectRatio: (vertical ? implicitHeight / implicitWidth
            : implicitWidth / implicitHeight)
        smooth: true
        Behavior on opacity {
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: opacityDuration  }
        }
        // A custom icon could also be rectangular. However, if a square, custom, icon is given, assume it
        // to be an icon and round it to the nearest icon size again to avoid scaling artifacts.
        roundToIconSize: !useCustomButtonImage || aspectRatio === 1

        onSourceChanged: updateSizeHints()
    }

    MouseArea
    {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: {
            root.showMenu();
        }
    }
}
