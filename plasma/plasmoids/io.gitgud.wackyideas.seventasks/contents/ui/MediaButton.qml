import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrolsaddons
import org.kde.ksvg as KSvg


MouseArea {
    id: mediaButton

    Layout.preferredWidth: 26;
    Layout.preferredHeight: 24;
    hoverEnabled: true

    property int iconWidth
    property int iconHeight

    //signal clicked
    property string orientation: ""
    property string mediaIcon: ""
    property string fallbackMediaIcon: ""
    property bool togglePlayPause: true

    property bool enableButton: false
    enabled: enableButton

    KSvg.FrameSvgItem {
        id: normalButton
        imagePath: Qt.resolvedUrl("svgs/toolbuttons.svg")
        anchors.fill: parent
        prefix: mediaButton.orientation + (!mediaButton.enableButton ? "-disabled" : "")
        opacity: mediaButton.enableButton ? !parent.containsMouse : 1
        Behavior on opacity {
            NumberAnimation { duration: mediaButton.enableButton ? 250 : 1 }
        }
    }
    KSvg.FrameSvgItem {
        id: internalButtons
        imagePath: Qt.resolvedUrl("svgs/toolbuttons.svg")
        anchors.fill: parent
        visible: mediaButton.enableButton
        prefix: mediaButton.orientation + (parent.containsPress ? "-pressed" : "-hover");
        opacity: mediaButton.enableButton ? parent.containsMouse : 0
        Behavior on opacity {
            NumberAnimation { duration: mediaButton.enableButton ? 250 : 1}
        }
    }

    KSvg.SvgItem {
        id: mediaIconSvg
        imagePath: Qt.resolvedUrl("svgs/media-icons.svg")
        elementId: mediaButton.mediaIcon
        width: mediaButton.iconWidth;
        height:  mediaButton.iconHeight;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: parent.containsPress ? 1 : 0
        anchors.verticalCenterOffset: parent.containsPress ? 1 : 0
        opacity: !mediaButton.enableButton ? 0.5 : mediaButton.togglePlayPause
        Behavior on opacity {
            NumberAnimation { duration: mediaButton.enableButton ? 250 : 1}
        }
    }
    KSvg.SvgItem {
        id: mediaIconSvgSecond
        imagePath: Qt.resolvedUrl("svgs/media-icons.svg")
        elementId: mediaButton.fallbackMediaIcon
        width: mediaButton.iconWidth;
        height:  mediaButton.iconHeight;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: parent.containsPress ? 1 : 0
        anchors.verticalCenterOffset: parent.containsPress ? 1 : 0
        opacity: !mediaButton.togglePlayPause && mediaButton.enableButton
        visible: mediaButton.enableButton
        Behavior on opacity {
            NumberAnimation { duration: mediaButton.enableButton ? 250 : 1}
        }
    }

}

