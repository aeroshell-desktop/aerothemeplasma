/*import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQml.Models 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
// for Highlight
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
*/
import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2.5 as Kirigami // For Settings.tabletMode

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

