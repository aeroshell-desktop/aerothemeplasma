import QtQuick 2.4
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0


import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Control {
    id: genericButton
    signal clicked

    property string text: "";
    property var iconSource: "";
    property int iconSize: PlasmaCore.Units.iconSizes.smallMedium;
    property alias label: btnLabel

    Keys.priority: Keys.AfterItem
    Keys.onPressed: {
        if(event.key == Qt.Key_Return) {
            genericButton.clicked();
        }
    }

    PlasmaCore.FrameSvgItem {
        id: texture
        z: -1
        anchors.fill: parent
        imagePath: Qt.resolvedUrl("../images/button.svg");
        prefix: {
            var result = "";
            if(genericButton.focus) result = "focus-";
            if(buttonMA.containsPress) result = "pressed";
            else if(buttonMA.containsMouse) result += "hover";
            else result += "normal";
            return result;
        }
    }
    MouseArea {
        id: buttonMA
        z: 99
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton;
        onClicked: {
            genericButton.clicked();
        }
    }
    PlasmaCore.IconItem {
        id: btnIcon
        z: 0
        anchors.centerIn: genericButton
        width: genericButton.iconSize
        height: width
        animated: false
        usesPlasmaTheme: false
        source: genericButton.iconSource
        visible: genericButton.iconSource !== ""
    }
    PlasmaComponents.Label {
        id: btnLabel
        z: 0
        anchors.fill: parent
        text: genericButton.text
        visible: genericButton.text !== ""
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        layer.enabled: genericButton.text !== ""
        layer.effect: DropShadow {
            //visible: !softwareRendering
            horizontalOffset: 0
            verticalOffset: 1
            radius: 6
            samples: 14
            spread: 0.0001
            color: "#bf000000"
        }
    }
}
