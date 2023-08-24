
import QtQuick 2.4
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons // kuser
import org.kde.plasma.private.shell 2.0

import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.quicklaunch 1.0

import org.kde.kirigami 2.13 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import org.kde.kwindowsystem 1.0


Item {
		id: iconContainer
		//The frame displayed on top of the user icon
        height: units.iconSizes.huge
        width: height
        anchors.horizontalCenter: parent.horizontalCenter

        property alias iconSource: imgAuthorIcon.source
        Image {
            source: "../pics/user.png"
            smooth: true
            z: 1
			opacity: imgAuthorIcon.source === ""
			Behavior on opacity {
				NumberAnimation { duration: 350 }
			}
			anchors {
           		left: parent.left
           		right: parent.right
           		bottom: parent.bottom
           		top: parent.top
			}
        }
        PlasmaCore.IconItem {
            id: imgAuthorIcon
            source: ""
			height: parent.height
			width: height
			smooth: true
            visible: true
            usesPlasmaTheme: false
            z: 99
            CrossFadeBehavior on source {
				fadeDuration: 350
			}
        }
        Image {
            id: imgAuthor
			anchors {
            	top: parent.top
            	left: parent.left
            	right: parent.right
            	bottom: parent.bottom

            	topMargin: units.smallSpacing*2
            	leftMargin: units.smallSpacing*2
            	rightMargin: units.smallSpacing*2
            	bottomMargin: units.smallSpacing*2
			}
			opacity: imgAuthorIcon.source === ""
			Behavior on opacity {
				NumberAnimation { duration: 350 }
			}
            source: kuser.faceIconUrl.toString()
            smooth: true
            mipmap: true
            visible: true
        }
        /*OpacityMask {
            anchors.fill: imgAuthor
            source: (kuser.faceIconUrl.toString() === "") ? imgAuthorIcon : imgAuthor;
            maskSource: Rectangle {
                width: imgAuthorIcon.source === "" ? imgAuthor.width : 0
                height: imgAuthor.height
                visible: false
            }
        }*/
        MouseArea{
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onPressed: {
                root.visible = false;
                KCMShell.open("kcm_users")
            }
            cursorShape: Qt.PointingHandCursor
        }
}
