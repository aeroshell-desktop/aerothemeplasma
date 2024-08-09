import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

import org.kde.plasma.plasmoid

RowLayout {
	id: configSpinBox

	property string configKey: ''
	property alias to: spinBox.to
	property alias from: spinBox.from
	property alias prefix: spinBox.prefix
	property alias stepSize: spinBox.stepSize
	property alias suffix: spinBox.suffix
	property alias value: spinBox.value

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	Label {
		id: labelBefore
		text: ""
		visible: text
	}

	SpinBox {
		id: spinBox

		property string prefix
		property string suffix

		value: Plasmoid.configuration[configKey]
		// onValueChanged: Plasmoid.configuration[configKey] = value
		onValueChanged: serializeTimer.start()
		to: 2147483647

		textFromValue: function(value) {
			return prefix + value + suffix;
		}
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: Plasmoid.configuration[configKey] = value
	}
}
