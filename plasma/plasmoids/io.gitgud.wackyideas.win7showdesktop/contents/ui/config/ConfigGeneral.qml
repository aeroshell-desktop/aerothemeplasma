import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

import org.kde.kirigami as Kirigami

import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	property string cfg_click_action: 'showdesktop'
	property alias cfg_click_command: click_command.text

	property string cfg_mousewheel_action: 'run_commands'
	property alias cfg_mousewheel_up: mousewheel_up.text
	property alias cfg_mousewheel_down: mousewheel_down.text

	property bool showDebug: false
	property int indentWidth: 24

	AppletConfig {
		id: config
	}

	function setClickCommand(command) {
		cfg_click_action = 'run_command'
		clickGroup_runcommand.checked = true
		cfg_click_command = command
	}

	function setMouseWheelCommands(up, down) {
		cfg_mousewheel_action = 'run_commands'
		mousewheelGroup_runcommands.checked = true
		cfg_mousewheel_up = up
		cfg_mousewheel_down = down
	}

	ConfigSection {
		title: i18n("Look")

		Kirigami.FormLayout {
			Layout.fillWidth: true

			ConfigSpinBox {
				Kirigami.FormData.label: i18n("Size:")
				configKey: 'size'
				suffix: i18n("px")
			}

			ConfigColor {
				Kirigami.FormData.label: i18n("Edge Color:")
				configKey: "edgeColor"
				defaultColor: config.defaultEdgeColor
				label: ""
			}

			ConfigColor {
				Kirigami.FormData.label: i18n("Hovered Color:")
				configKey: "hoveredColor"
				defaultColor: config.defaultHoveredColor
				label: ""
			}

			ConfigColor {
				Kirigami.FormData.label: i18n("Pressed Color:")
				configKey: "pressedColor"
				defaultColor: config.defaultPressedColor
				label: ""
			}
		}
	}

	ButtonGroup { id: clickGroup }
	ConfigSection {
		title: i18n("Click")

		RadioButton {
			ButtonGroup.group: clickGroup
			checked: cfg_click_action == 'showdesktop'
			text: i18nd("plasma_applet_org.kde.plasma.showdesktop", "Show Desktop")
			onClicked: {
				cfg_click_action = 'showdesktop'
			}
		}

		RadioButton {
			ButtonGroup.group: clickGroup
			checked: cfg_click_action == 'minimizeall'
			text: i18ndc("plasma_applet_org.kde.plasma.showdesktop", "@action", "Minimize All Windows")

			onClicked: {
				cfg_click_action = 'minimizeall'
			}
		}

		RadioButton {
			id: clickGroup_runcommand
			ButtonGroup.group: clickGroup
			checked: cfg_click_action == 'run_command'
			text: i18n("Run Command")
			onClicked: {
				cfg_click_action = 'run_command'
			}
		}
		RowLayout {
			Layout.fillWidth: true
			Text { width: indentWidth } // indent
			TextField {
				Layout.fillWidth: true
				id: click_command
			}
		}
		RadioButton {
			ButtonGroup.group: clickGroup
			checked: false
			text: i18nd("kwin_effects", "Toggle Present Windows (All desktops)")
			property string command: 'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "ExposeAll"'
			onClicked: setClickCommand(command)
		}
		RadioButton {
			ButtonGroup.group: clickGroup
			checked: false
			text: i18nd("kwin_effects", "Toggle Present Windows (Current desktop)")
			property string command: 'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Expose"'
			onClicked: setClickCommand(command)
		}
		RadioButton {
			ButtonGroup.group: clickGroup
			checked: false
			text: i18nd("kwin_effects", "Toggle Present Windows (Window class)")
			property string command: 'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "ExposeClass"'
			onClicked: setClickCommand(command)
		}
	}


	ButtonGroup { id: mousewheelGroup }
	ConfigSection {
		title: i18n("Mouse Wheel")


		RadioButton {
			id: mousewheelGroup_runcommands
			ButtonGroup.group: mousewheelGroup
			checked: cfg_mousewheel_action == 'run_commands'
			text: i18n("Run Commands")
			onClicked: {
				cfg_mousewheel_action = 'run_commands'
			}
		}
		RowLayout {
			Layout.fillWidth: true
			Text { width: indentWidth } // indent
			Label {
				text: i18n("Scroll Up:")
			}
			TextField {
				Layout.fillWidth: true
				id: mousewheel_up
			}
		}
		RowLayout {
			Layout.fillWidth: true
			Text { width: indentWidth } // indent
			Label {
				text: i18n("Scroll Down:")
			}
			TextField {
				Layout.fillWidth: true
				id: mousewheel_down
			}
		}

		RadioButton {
			ButtonGroup.group: mousewheelGroup
			checked: false
			text: i18n("Volume (No UI) (amixer)")
			onClicked: setMouseWheelCommands('amixer -q sset Master 10%+', 'amixer -q sset Master 10%-')
		}

		RadioButton {
			ButtonGroup.group: mousewheelGroup
			checked: false
			text: i18n("Volume (UI) (qdbus)")
			property string upCommand:   'qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "increase_volume"'
			property string downCommand: 'qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "decrease_volume"'
			onClicked: setMouseWheelCommands(upCommand, downCommand)
		}

		RadioButton {
			ButtonGroup.group: mousewheelGroup
			checked: false
			text: i18n("Switch Desktop (qdbus)")
			property string upCommand:   'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Switch One Desktop to the Left"'
			property string downCommand: 'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Switch One Desktop to the Right"'
			onClicked: setMouseWheelCommands(upCommand, downCommand)
		}
	}

	ConfigSection {
		title: i18n("Peek")

		Kirigami.FormLayout {
			Layout.fillWidth: true

			ConfigCheckBox {
				Kirigami.FormData.label: i18n("Show desktop on hover:")
				configKey: "peekingEnabled"
				text: i18n("Enable")
			}

			ConfigSpinBox {
				Kirigami.FormData.label: i18n("Peek threshold:")
				configKey: 'peekingThreshold'
				suffix: i18n("ms")
				stepSize: 50
				from: 0
			}
		}
	}
}
