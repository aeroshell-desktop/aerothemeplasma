import QtQuick 2.8
import SddmComponents 2.0
import QtGraphicalEffects 1.0

Rectangle
{
    color: "black"

    Background
    {
        id: background
        anchors.fill: parent
        fillMode: Image.Stretch
        source: "nonredist/crop/background-resized.png"
    }

    Text
    {
        text: "Shutting down..."
        color: "white"
        font.pixelSize: 24

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 12
        anchors.verticalCenterOffset: -49

        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferFullHinting
        font.kerning: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        layer.enabled: true
        layer.effect: DropShadow
        {
            verticalOffset: 1
            color: "#444"
            radius: 7
            samples: 20
        }
    }
}
