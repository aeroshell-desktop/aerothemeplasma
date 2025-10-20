import QtQuick 2.4
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import Qt5Compat.GraphicalEffects

import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Control {
    id: genericButton
    signal clicked

    property string text: "";
    property var iconSource: "";
    property int iconSize: Kirigami.Units.iconSizes.smallMedium;
    property alias label: btnLabel

    Keys.priority: Keys.AfterItem
    Keys.onPressed: (event) => {
        if(event.key == Qt.Key_Return) {
            genericButton.clicked();
        }
    }

    KSvg.FrameSvgItem {
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
    Kirigami.Icon {
        id: btnIcon
        z: 0
        anchors.centerIn: genericButton
        width: genericButton.iconSize
        height: width
        animated: false
        //usesPlasmaTheme: false
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
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferFullHinting
        font.kerning: false
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
