import QtQuick 2.15
import org.kde.plasma.configuration 2.0
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.1
import QtQml 2.15

import org.kde.newstuff 1.62 as NewStuff
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.configuration 2.0
import org.kde.plasma.plasma5support as Plasma5Support


ColumnLayout {
    id: column
    property int bottomMargin
    property string iconSource
    property string text
    property string command

    property var execHelper

    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Math.max(icon.width, textLabel.implicitWidth)
        Layout.preferredHeight: icon.height + textLabel.implicitHeight
        Layout.bottomMargin: column.bottomMargin //pluginComboBox.height + parent.spacing
        Kirigami.Icon {
            id: icon
            width: Kirigami.Units.iconSizes.large
            height: width
            anchors.centerIn: parent
            source: column.iconSource
            Text {
                id: textLabel
                anchors.top: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: Kirigami.Theme.linkColor
                font.underline: ma.containsMouse
                text: column.text
            }
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            anchors.margins: -Kirigami.Units.smallSpacing
            onClicked: column.execHelper.exec(column.command);
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
