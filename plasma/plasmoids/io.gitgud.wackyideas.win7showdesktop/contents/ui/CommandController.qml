/*
	SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

	SPDX-License-Identifier: GPL-2.0-or-later
*/

import org.kde.plasma.plasmoid 2.0


Controller {
	id: controller

	titleInactive: i18nc("@action:button", "Run custom command")
	titleActive: titleInactive

	descriptionActive: i18nc("@info:tooltip", "Run user-defined command when pressed")
	descriptionInactive: descriptionActive

	active: false

	// override
	function toggle() {
		root.exec(Plasmoid.configuration.click_command);
	}
}
