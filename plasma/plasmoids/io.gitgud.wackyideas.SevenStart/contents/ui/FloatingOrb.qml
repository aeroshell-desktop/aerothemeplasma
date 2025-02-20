
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

import org.kde.kquickcontrolsaddons 2.0
import org.kde.kwindowsystem 1.0
import org.kde.kirigami as Kirigami

Item {
    id: floatingOrb
    width: scaledWidth //buttonIconSizes.width
    height: scaledHeight / 3 //buttonIconSizes.height / 3
    property alias buttonIconSizes: buttonIconSizes
    property alias buttonIcon: buttonIcon
    property alias buttonIconPressed: buttonIconPressed
    property alias buttonIconHovered: buttonIconHovered

    property string orbTexture: getResolvedUrl(Plasmoid.configuration.customButtonImage, "orbs/orb" + (stickOutOrb ? "_small" : "") + ".png")
    property int opacityDuration: 300

    Image {
        id: buttonIconSizes
        smooth: true
        source: orbTexture
        opacity: 0;
    }
    clip: false

    property real aspectRatio: buttonIconSizes.height === 0 ? 1 : (buttonIconSizes.width / buttonIconSizes.height)
    property int scaledWidth: Plasmoid.configuration.orbWidth === 0 ? buttonIconSizes.width : Plasmoid.configuration.orbWidth
    property int scaledHeight: scaledWidth / aspectRatio

    Image {
        id: buttonIcon
        anchors.centerIn: parent
        smooth: true
        source: floatingOrb.orbTexture
        sourceClipRect: Qt.rect(0, 0, buttonIconSizes.width, buttonIconSizes.height / 3);
        fillMode: Image.PreserveAspectFit
        width: floatingOrb.scaledWidth
        height: floatingOrb.scaledHeight
    }
    Image {
        id: buttonIconPressed
        anchors.centerIn: parent
        visible: dashWindow.visible
        smooth: true
        source: floatingOrb.orbTexture
        sourceClipRect: Qt.rect(0, 2*buttonIconSizes.height / 3, buttonIconSizes.width, buttonIconSizes.height / 3);
        fillMode: Image.PreserveAspectFit
        width: floatingOrb.scaledWidth
        height: floatingOrb.scaledHeight
    }
    Image {
        id: buttonIconHovered
        anchors.centerIn: parent
        source: floatingOrb.orbTexture
        smooth: true
        opacity: mouseAreaCompositingOff.containsMouse
        visible:  !dashWindow.visible
        Behavior on opacity {
            NumberAnimation { properties: "opacity"; easing.type: Easing.Linear; duration: floatingOrb.opacityDuration  }
        }
        sourceClipRect: Qt.rect(0, buttonIconSizes.height / 3, buttonIconSizes.width, buttonIconSizes.height / 3);
        fillMode: Image.PreserveAspectFit
        width: floatingOrb.scaledWidth
        height: floatingOrb.scaledHeight
    }
}
