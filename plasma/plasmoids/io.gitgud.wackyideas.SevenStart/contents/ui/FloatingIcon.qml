
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras  as PlasmaExtras

import org.kde.plasma.private.kicker as Kicker
import org.kde.coreaddons as KCoreAddons // kuser
import org.kde.plasma.private.shell 2.0

import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0
//import org.kde.plasma.private.quicklaunch 1.0

import org.kde.kirigami 2.13 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.kcmutils as KCM
import org.kde.kwindowsystem 1.0


Item {
		id: iconContainer
		//The frame displayed on top of the user icon
        height: Kirigami.Units.iconSizes.huge
            //Kirigami.Units.iconSizes.huge
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
        Kirigami.Icon {
            id: imgAuthorIcon
            source: ""
			height: parent.height
			width: height
			smooth: true
            visible: true
            //usesPlasmaTheme: false
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

            	topMargin: Kirigami.Units.smallSpacing*2
            	leftMargin: Kirigami.Units.smallSpacing*2
            	rightMargin: Kirigami.Units.smallSpacing*2
            	bottomMargin: Kirigami.Units.smallSpacing*2
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
                KCM.KCMLauncher.openSystemSettings("kcm_users")
            }
            cursorShape: Qt.PointingHandCursor
        }
}
