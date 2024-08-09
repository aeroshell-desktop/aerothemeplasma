import QtQuick 2.15
import org.kde.plasma.configuration

ConfigModel {
	ConfigCategory {
		name: i18n("General")
		icon: "preferences-desktop-color"
		source: "config/ConfigGeneral.qml"
	}
}
