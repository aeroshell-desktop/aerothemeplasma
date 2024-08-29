import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.3 as Kirigami

GroupBox {
    id: gbox
    label: Label {
        id: lbl
        x: gbox.leftPadding + 2
        y: lbl.implicitHeight/2-gbox.bottomPadding-1
        width: lbl.implicitWidth
        text: gbox.title
        elide: Text.ElideRight
        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -2
            anchors.rightMargin: -2
            color: Kirigami.Theme.backgroundColor
            z: -1
        }
    }
    background: Rectangle {
        y: gbox.topPadding - gbox.bottomPadding*2
        width: parent.width
        height: parent.height - gbox.topPadding + gbox.bottomPadding*2
        color: "transparent"
        border.color: "#d5dfe5"
        radius: 3
    }
}
