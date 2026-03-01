import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami // For Settings.tabletMode

MouseArea {
    id: toolButton

    Layout.maximumWidth: Kirigami.Units.iconSizes.small+1;
    Layout.maximumHeight: Kirigami.Units.iconSizes.small;
    Layout.preferredWidth: Kirigami.Units.iconSizes.small+1;
    Layout.preferredHeight: Kirigami.Units.iconSizes.small;

    //signal clicked
    property string buttonIcon: ""
    property bool checkable: false
    property bool checked: false
    property bool flat: false

    hoverEnabled: true
    KSvg.FrameSvgItem {
        id: normalButton
        imagePath: Qt.resolvedUrl("svgs/button.svgz")
        anchors.fill: parent
        prefix: {
            if(parent.containsPress || (checkable && checked)) return "toolbutton-pressed";
            else return "toolbutton-hover";
        }
        visible: (parent.containsMouse || (checkable && checked)) && !flat
    }

    KSvg.SvgItem {
        id: buttonIconSvg
        svg: buttonIcons
        elementId: buttonIcon
        width: 10;
        height:  10;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

}

