import QtQuick 2.15
import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid

QtObject {
	id: config

	// Colors
	function alpha(c, newAlpha) {
		return Qt.rgba(c.r, c.g, c.b, newAlpha)
	}
	property color defaultEdgeColor: alpha(Kirigami.Theme.textColor, 0.4)
	property color defaultHoveredColor: Kirigami.Theme.backgroundColor
	property color defaultPressedColor: Kirigami.Theme.hoverColor
	property color edgeColor: Plasmoid.configuration.edgeColor || defaultEdgeColor
	property color hoveredColor: Plasmoid.configuration.hoveredColor || defaultHoveredColor
	property color pressedColor: Plasmoid.configuration.pressedColor || defaultPressedColor
}
