import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import org.kde.plasma.plasmoid

import ".."

CheckBox {
	id: configCheckBox

	property string configKey: ''
	checked: Plasmoid.configuration[configKey]
	onClicked: Plasmoid.configuration[configKey] = !Plasmoid.configuration[configKey]
}
