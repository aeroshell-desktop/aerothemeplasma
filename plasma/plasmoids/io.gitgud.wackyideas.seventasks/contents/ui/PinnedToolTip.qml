import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore

MouseArea {
    id: tooltipRoot

    property QtObject root

    readonly property alias bg: bg

    implicitWidth: name.implicitWidth + Kirigami.Units.smallSpacing*2
    implicitHeight: name.implicitHeight + Kirigami.Units.smallSpacing

    hoverEnabled: true
    propagateComposedEvents: true

    KSvg.FrameSvgItem {
        id: bg

        anchors.fill: parent

        imagePath: "solid/widgets/tooltip"
    }

    Timer {
        interval: 200
        running: (!root.taskHovered && !tooltipRoot.containsMouse)
        onTriggered: root.destroy();
    }

    Text {
        id: name

        anchors.fill: parent

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.display
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferFullHinting
        font.kerning: false

        opacity: 0.75
    }
}
