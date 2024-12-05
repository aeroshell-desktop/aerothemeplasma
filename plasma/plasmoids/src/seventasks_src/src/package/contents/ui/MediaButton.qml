import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQml.Models 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
// for Highlight
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons


MouseArea {
    id: mediaButton

    Layout.maximumWidth: PlasmaCore.Units.gridUnit*1.5;
    Layout.maximumHeight: PlasmaCore.Units.gridUnit*1.5 - PlasmaCore.Units.smallSpacing;
    Layout.preferredWidth: PlasmaCore.Units.gridUnit*1.5;
    Layout.preferredHeight: PlasmaCore.Units.gridUnit*1.5 - PlasmaCore.Units.smallSpacing;

    //signal clicked
    property string orientation: ""
    property string mediaIcon: ""
    property bool enableButton: false
    enabled: enableButton
    property bool togglePlayPause: true
    property string fallbackMediaIcon: ""


    hoverEnabled: true
    PlasmaCore.FrameSvgItem {
        id: normalButton
        imagePath: Qt.resolvedUrl("svgs/button-media.svg")
        anchors.fill: parent
        prefix: orientation + "-normal"
        opacity: !(parent.containsMouse && enableButton)
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }
    PlasmaCore.FrameSvgItem {
        id: internalButtons
        imagePath: Qt.resolvedUrl("svgs/button-media.svg")
        anchors.fill: parent
        prefix: parent.containsPress ? orientation + "-pressed" : orientation + "-hover";
        opacity: parent.containsMouse && enableButton
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    PlasmaCore.SvgItem {
        id: mediaIconSvg
        svg: mediaIcons
        elementId: mediaIcon
        width: PlasmaCore.Units.iconSizes.small;
        height:  PlasmaCore.Units.iconSizes.small;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: parent.containsPress ? 1 : 0
        anchors.verticalCenterOffset: parent.containsPress ? 1 : 0
        opacity: (enableButton ? 1.0 : 0.35) * togglePlayPause
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }
    PlasmaCore.SvgItem {
        id: mediaIconSvgSecond
        svg: mediaIcons
        elementId: fallbackMediaIcon
        width: PlasmaCore.Units.iconSizes.small;
        height:  PlasmaCore.Units.iconSizes.small;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: parent.containsPress ? 1 : 0
        anchors.verticalCenterOffset: parent.containsPress ? 1 : 0
        opacity: (enableButton ? 1.0 : 0.35) * !togglePlayPause
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

}

