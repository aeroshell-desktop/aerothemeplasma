import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami // For Settings.tabletMode
import org.kde.plasma.clock as PlasmaClock
import org.kde.plasma.private.digitalclock

Item {
    id: clockItem

	PlasmaClock.Clock {
		id: plasmaClock
		timeZone: Plasmoid.configuration.lastSelectedTimezone
		trackSeconds: true
	}
    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

    KSvg.SvgItem {
        id: clockface
        svg: clockSvg
        elementId: "clockface"
        anchors.fill: parent
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
            angle: 360 * (plasmaClock.dateTime.getSeconds() / 60) + 180
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
        anchors.horizontalCenterOffset: plasmaClock.dateTime.getMinutes() > 45 || plasmaClock.dateTime.getMinutes() <= 15 ? 2 : 0
        antialiasing: true
        transform: Rotation {
            origin.x: 0
            origin.y: 0
            angle: 360 * (plasmaClock.dateTime.getMinutes() / 60) + 180
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
            angle: 360 * ((plasmaClock.dateTime.getHours() % 12) / 12 + plasmaClock.dateTime.getMinutes() / (12*60)) + 180
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
