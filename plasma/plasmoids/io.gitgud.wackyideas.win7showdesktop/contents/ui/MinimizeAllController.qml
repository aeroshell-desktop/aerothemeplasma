/*
	SPDX-FileCopyrightText: 2015 Sebastian Kügler <sebas@kde.org>
	SPDX-FileCopyrightText: 2016 Anthony Fieroni <bvbfan@abv.bg>
	SPDX-FileCopyrightText: 2018 David Edmundson <davidedmundson@kde.org>
	SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

	SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQml 2.15

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.workspace.dbus as DBus

Controller {
	id: controller

	titleActive: i18nc("@action:button", "Restore All Minimized Windows")
	titleInactive: i18nc("@action:button", "Minimize All Windows")

	descriptionActive: i18nc("@info:tooltip", "Restores the previously minimized windows")
	descriptionInactive: i18nc("@info:tooltip", "Shows the Desktop by minimizing all windows")

	// override
	function toggle() {
		const promise = new Promise((resolve, reject) => {
		DBus.SessionBus.asyncCall({
			service: "org.kde.kglobalaccel",
			path: "/component/kwin",
			iface: "org.kde.kglobalaccel.Component",
			member: "invokeShortcut",
			arguments: [new DBus.string("MinimizeAll")],
			signature: "(s)"},
			resolve, reject);
		}).then((reply) => {
			console.log(reply.value);
		}).catch((reply) => {
			console.log(reply.value);
		});
	}
}
