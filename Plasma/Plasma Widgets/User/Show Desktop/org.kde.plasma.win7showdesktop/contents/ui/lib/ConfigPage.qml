// Version 4

import QtQuick 2.0
import QtQuick.Layouts 1.0

Item {
	id: page
	Layout.fillWidth: true
	default property alias _contentChildren: content.data
	implicitHeight: content.implicitHeight

	ColumnLayout {
		id: content
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top

		// Workaround for crash when using default on a Layout.
		// https://bugreports.qt.io/browse/QTBUG-52490
		// Still affecting Qt 5.7.0
		Component.onDestruction: {
			while (children.length > 0) {
				children[children.length - 1].parent = page
			}
		}
	}

	property alias showAppletVersion: appletVersionLoader.active
	Loader {
		id: appletVersionLoader
		active: false
		visible: active
		source: "AppletVersion.qml"
		anchors.right: parent.right
		anchors.bottom: parent.top
	}
}
