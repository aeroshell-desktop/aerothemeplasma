
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.plasma.private.kicker as Kicker
import org.kde.coreaddons as KCoreAddons // kuser
import org.kde.plasma.private.shell 2.0

import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0

import org.kde.kirigami 2.13 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

import org.kde.kirigami as Kirigami

Item {
    id: floatingOrb
    width: buttonIconSizes.width
    height: buttonIconSizes.height / 3
    property alias buttonIconSizes: buttonIconSizes
    property alias buttonIcon: buttonIcon
    property alias buttonIconPressed: buttonIconPressed
    property alias buttonIconHovered: buttonIconHovered
    property alias mouseArea: mouseArea

    property string orbTexture: getResolvedUrl(Plasmoid.configuration.customButtonImage, "orbs/orb" + (stickOutOrb ? "_small" : "") + ".png")
    property int opacityDuration: 300

    Image {
        id: buttonIconSizes
        smooth: true
        source: orbTexture
        opacity: 0;
    }
    clip: false
    Image {
        id: buttonIcon
        smooth: true
        source: orbTexture
        sourceClipRect: Qt.rect(0, 0, buttonIconSizes.width, buttonIconSizes.height / 3);
    }
    Image {
        id: buttonIconPressed
        visible: dashWindow.visible
        smooth: true
        source: orbTexture
        verticalAlignment: Image.AlignBottom
        sourceClipRect: Qt.rect(0, 2*buttonIconSizes.height / 3, buttonIconSizes.width, buttonIconSizes.height / 3);
    }
    Image {
        id: buttonIconHovered
        source: orbTexture
        opacity: mouseArea.containsMouse || mouseAreaCompositingOff.containsMouse
        visible:  !dashWindow.visible
        Behavior on opacity {
            NumberAnimation { properties: "opacity"; easing.type: Easing.Linear; duration: opacityDuration  }
        }
        verticalAlignment: Image.AlignVCenter
        sourceClipRect: Qt.rect(0, buttonIconSizes.height / 3, buttonIconSizes.width, buttonIconSizes.height / 3);
    }

    MouseArea
    {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton// | Qt.RightButton
        //propagateComposedEvents: true
        onPressed: mouse => {
            //if(mouse.button === Qt.LeftButton)
                root.showMenu();
        }

    }
}
