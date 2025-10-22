import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami // For Settings.tabletMode

MouseArea {
    id: toolButton

    Layout.maximumWidth: largeSize ? Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing : Kirigami.Units.iconSizes.small+1;
    Layout.maximumHeight: largeSize ? Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing : Kirigami.Units.iconSizes.small;
    Layout.preferredWidth: largeSize ? Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing : Kirigami.Units.iconSizes.small+1;
    Layout.preferredHeight: largeSize ? Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing : Kirigami.Units.iconSizes.small;
    width: largeSize ? Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing : Kirigami.Units.iconSizes.small+1;
    height: largeSize ? Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing : Kirigami.Units.iconSizes.small

    //signal clicked
    property string buttonIcon: ""
    property bool checkable: false
    property bool checked: false
    property bool largeSize: false

    hoverEnabled: true
    KSvg.FrameSvgItem {
        id: normalButton
        imagePath: Qt.resolvedUrl("../svgs/button.svgz")
        anchors.fill: parent
        prefix: {
            if(parent.containsPress || (toolButton.checkable && toolButton.checked)) return "toolbutton-pressed";
            else return "toolbutton-hover";
        }
        visible: parent.containsMouse || (toolButton.checkable && toolButton.checked)
    }

    KSvg.SvgItem {
        id: buttonIconSvg
        imagePath: Qt.resolvedUrl("../svgs/icons.svg");
        elementId: toolButton.buttonIcon
        width: toolButton.largeSize ? Kirigami.Units.iconSizes.small : 10;
        height: toolButton.largeSize ? Kirigami.Units.iconSizes.small : 10;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

}

