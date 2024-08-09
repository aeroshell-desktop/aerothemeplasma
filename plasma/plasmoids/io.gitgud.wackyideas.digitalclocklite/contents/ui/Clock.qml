import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.1
import QtQuick.Window 2.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2.5 as Kirigami // For Settings.tabletMode

Item {
    id: clockItem

    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

    property date currentDate: {
        // get the time for the given timezone from the dataengine
        var now = dataSource.data[Plasmoid.configuration.lastSelectedTimezone]["DateTime"];
        // get current UTC time
        var msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
        // add the dataengine TZ offset to it
        var currentTime = new Date(msUTC + (dataSource.data[Plasmoid.configuration.lastSelectedTimezone]["Offset"] * 1000));
        return currentTime
    }
    KSvg.SvgItem {
        id: clockface
        svg: clockSvg
        elementId: "clockface"
        anchors.fill: parent
        /*anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter*/
    }



    // Rects
    Rectangle {
        id: secondHand
        color: "#bf546770"
        width: 1
        height: 65
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 15
        anchors.horizontalCenterOffset: 1
        antialiasing: true
        transform: Rotation {
            origin.x: 0
            origin.y: 18
            angle: 360 * (currentDate.getSeconds() / 60) + 180
        }
    }

    Rectangle {
        id: minuteHand
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "#df5c6c74" }
            GradientStop { position: 0.5; color: "#ef5c6c74" }
            GradientStop { position: 1; color: "#df5c6c74" }
        }
        radius: 1
        //color: "#bf546770"
        width: 2
        height: 47
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: minuteHand.height/2
        anchors.horizontalCenterOffset: currentDate.getMinutes() > 45 || currentDate.getMinutes() <= 15 ? 2 : 0
        antialiasing: true
        transform: Rotation {
            origin.x: 0
            origin.y: 0
            angle: 360 * (currentDate.getMinutes() / 60) + 180
        }
    }

    Rectangle {
        id: hourHand
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "#df5c6c74" }
            GradientStop { position: 0.5; color: "#ef5c6c74" }
            GradientStop { position: 1; color: "#df5c6c74" }
        }
        radius: 1
        //color: "#bf546770"
        width: 2
        height: 36
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: hourHand.height/2
        anchors.horizontalCenterOffset: 1
        antialiasing: true
        transform: Rotation {
            origin.x: 0
            origin.y: 0
            angle: 360 * ((currentDate.getHours() % 12) / 12 + currentDate.getMinutes() / (12*60)) + 180
        }
    }
    KSvg.SvgItem {
        id: clockdot
        svg: clockSvg
        elementId: "clockdot"
        width: 5
        height: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    KSvg.SvgItem {
        id: clockshine
        svg: clockSvg
        elementId: "clockshine"
        anchors.fill: parent
    }

}
