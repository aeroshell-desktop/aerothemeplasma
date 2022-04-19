import QtQuick 2.0

QtObject {
	id: config

	// Colors
	function alpha(c, newAlpha) {
		return Qt.rgba(c.r, c.g, c.b, newAlpha)
	}
	property color defaultEdgeColor: alpha(theme.textColor, 0.4)
	property color defaultHoveredColor: theme.buttonBackgroundColor
	property color defaultPressedColor: theme.buttonHoverColor
	property color edgeColor: plasmoid.configuration.edgeColor || defaultEdgeColor
	property color hoveredColor: plasmoid.configuration.hoveredColor || defaultHoveredColor
	property color pressedColor: plasmoid.configuration.pressedColor || defaultPressedColor
}
