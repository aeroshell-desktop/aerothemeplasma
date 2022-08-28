/*
	Copyright (C) 2019 Chris Holland <zrenfire@gmail.com>
	Copyright (C) 2014 Ashish Madeti <ashishmadeti@gmail.com>

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import QtQuick 2.7
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
// import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.showdesktop 0.1

import org.kde.draganddrop 2.0 as DragAndDrop
import org.kde.taskmanager 0.1 as TaskManager

Item {
	id: widget

	Layout.minimumWidth: Layout.maximumWidth
	Layout.minimumHeight: Layout.maximumHeight

	// In Latte, widgets are always Mutable.
	property bool isInLatte: false // Latte v8
	// Latte will set inEditMode=true when editing the dock.
	// https://techbase.kde.org/LatteDock#latteBridge
	property QtObject latteBridge: null // Latte v9
	readonly property bool inLatte: latteBridge !== null

	readonly property bool isWidgetUnlocked: {
		if (isInLatte) { // Latte v8
			return false
		} else if (inLatte) { // Latte v9
			return latteBridge.inEditMode
		} else if (plasmoid.immutability != PlasmaCore.Types.Mutable) { // Plasma 5.17 and below
			return false
		} else { // Plasma 5.18
			return widget.editMode
		}
	}

	//--- containment.editMode detector
	property var containmentInterface: null
	readonly property bool editMode: containmentInterface ? containmentInterface.editMode : false
	onParentChanged: {
		if (parent) {
			for (var obj = widget, depth = 0; !!obj; obj = obj.parent, depth++) {
				// console.log('depth', depth, 'obj', obj)
				if (obj.toString().startsWith('ContainmentInterface')) {
					// desktop containment / plasmoidviewer
					// Note: This doesn't always work. FolderViewDropArea may not yet have
					//       ContainmentInterface as a parent when this loop runs.
					if (typeof obj['editMode'] === 'boolean') {
						// console.log('\t', 'obj.editMode', obj.editMode, typeof obj['editMode'])
						widget.containmentInterface = obj
						break
					}
				} else if (obj.toString().startsWith('DeclarativeDropArea')) {
					// panel containment
					if (typeof obj['Plasmoid'] !== 'undefined' && obj['Plasmoid'].toString().startsWith('ContainmentInterface')) {
						if (typeof obj['Plasmoid']['editMode'] === 'boolean') {
							// console.log('\t', 'obj.Plasmoid', obj.Plasmoid, typeof obj['Plasmoid']) // ContainmentInterface
							// console.log('\t', 'obj.Plasmoid.editMode', obj.Plasmoid.editMode, typeof obj['Plasmoid']['editMode'])
							widget.containmentInterface = obj.Plasmoid
							break
						}
					}
				}
			}
		}
	}

	//---
	property int iconSize: units.iconSizes.smallMedium
	property int size: {
		if (isWidgetUnlocked) {
			return iconSize
		} else {
			return Math.max(1, plasmoid.configuration.size) * units.devicePixelRatio
		}
	}

	AppletConfig {
		id: config
	}

	//---
	state: {
		if (plasmoid.formFactor == PlasmaCore.Types.Vertical) return "vertical"
		if (plasmoid.formFactor == PlasmaCore.Types.Horizontal) return "horizontal"
		return "square"
	}

	states: [
		State { name: "square"
			PropertyChanges {
				target: widget
				Layout.minimumWidth: units.iconSizeHints.desktop
				Layout.minimumHeight: units.iconSizeHints.desktop
				Layout.maximumWidth: -1
				Layout.maximumHeight: -1
				iconSize: units.iconSizeHints.desktop
			}
			PropertyChanges {
				target: buttonRect
				y: 0
				x: 0
				width: plasmoid.width
				height: plasmoid.height
			}
			/*PropertyChanges {
				target: edgeLine
				color: "transparent"
				anchors.fill: edgeLine.parent
				border.color: config.edgeColor
			}*/
		},
		State { name: "vertical" // ...panel (fat short button)
			// Assume it's on the bottom. Breeze has margins of top=4 right=5 bottom=1 left=N/A
			PropertyChanges {
				target: widget
				Layout.maximumWidth: plasmoid.width
				Layout.maximumHeight: widget.size // size + bottomMargin = totalHeight
				iconSize: Math.min(plasmoid.width, units.iconSizes.smallMedium)
			}
			PropertyChanges {
				target: buttonRect
				rightMargin: 5
				bottomMargin: 5
			}
			/*PropertyChanges {
				target: edgeLine
				height: 1 * units.devicePixelRatio
			}
			AnchorChanges {
				target: edgeLine
				anchors.left: edgeLine.parent.left
				anchors.top: edgeLine.parent.top
				anchors.right: edgeLine.parent.right
			}*/
		},
		State { name: "horizontal" // ...panel (thin tall button)
			// Assume it's on the right. Breeze has margins of top=4 right=5 bottom=1 left=N/A
			PropertyChanges {
				target: widget
				Layout.maximumWidth: widget.size // size + rightMargin = totalWidth
				Layout.maximumHeight: plasmoid.height
				iconSize: Math.min(plasmoid.height, units.iconSizes.smallMedium)
			}
			PropertyChanges {
				target: buttonRect
				topMargin: 4
				rightMargin: 5
				bottomMargin: 3
			}
			/*PropertyChanges {
				target: edgeLine
				width: 1 * units.devicePixelRatio
			}
			AnchorChanges {
				target: edgeLine
				anchors.left: edgeLine.parent.left
				anchors.top: edgeLine.parent.top
				anchors.bottom: edgeLine.parent.bottom
			}*/
		}
	]

	Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
	Plasmoid.onActivated: widget.performClick()

	function performClick() {
		if (plasmoid.configuration.click_action == 'minimizeall') {
			minimizeAll.toggleActive()
		} else if (plasmoid.configuration.click_action == 'run_command') {
			widget.exec(plasmoid.configuration.click_command)
		} else { // Default: showdesktop
			showdesktop.showingDesktop = !showdesktop.showingDesktop
		}
	}

	function performMouseWheelUp() {
		widget.exec(plasmoid.configuration.mousewheel_up)
	}

	function performMouseWheelDown() {
		widget.exec(plasmoid.configuration.mousewheel_down)
	}

	//--- ShowDesktop
	// https://github.com/KDE/plasma-desktop/blob/master/applets/showdesktop/package/contents/ui/main.qml
	ShowDesktop {
		id: showdesktop
		property bool isPeeking: false
		onIsPeekingChanged: {
			if (isPeeking) {
				showingDesktop = true
			}
		}

		function initPeeking() {
			// console.log('initPeeking')
			// console.log('showingDesktop', showingDesktop)
			// console.log('peekTimer.running', peekTimer.running)
			if (!showingDesktop) {
				if (plasmoid.configuration.peekingEnabled) {
					peekTimer.restart()
				}
			}
		}

		function cancelPeek() {
			// console.log('cancelPeek')
			// console.log('peekTimer.running', peekTimer.running)
			peekTimer.stop()
			if (isPeeking) {
				isPeeking = false
				showingDesktop = false
			}
		}
	}

	//--- MinimizeAll
	// https://github.com/KDE/plasma-desktop/blob/master/applets/minimizeall/package/contents/ui/main.qml
	QtObject {
		id: minimizeAll
		property bool active: false
		property var minimizedClients: [] //list of persistentmodelindexes from task manager model of clients minimised by us

		property var taskModel: TaskManager.TasksModel {
			id: tasksModel
			sortMode: TaskManager.TasksModel.SortDisabled
			groupMode: TaskManager.TasksModel.GroupDisabled
		}
		property var taskModelConnection: Connections {
			target: tasksModel
			enabled: minimizeAll.active

			onActiveTaskChanged: {
				if (tasksModel.activeTask.valid) { //to suppress changing focus to non windows, such as the desktop
					minimizeAll.active = false
					minimizeAll.minimizedClients = []
				}
			}
			onVirtualDesktopChanged: minimizeAll.deactivate()
			onActivityChanged: minimizeAll.deactivate()
		}

		function activate() {
			var clients = []
			for (var i = 0; i < tasksModel.count; i++) {
				var idx = tasksModel.makeModelIndex(i)
				if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
					tasksModel.requestToggleMinimized(idx)
					clients.push(tasksModel.makePersistentModelIndex(i))
				}
			}
			minimizedClients = clients
			active = true
		}

		function deactivate() {
			active = false;
			for (var i = 0; i < minimizedClients.length; i++) {
				var idx = minimizedClients[i]
				//client deleted, do nothing
				if (!idx.valid) {
					continue
				}
				//if the user has restored it already, do nothing
				if (!tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)) {
					continue
				}
				tasksModel.requestToggleMinimized(idx)
			}
			minimizedClients = []
		}

		function toggleActive() {
			if (active) {
				deactivate()
			} else {
				activate()
			}
		}
	}
	//---

	Timer {
		id: peekTimer
		interval: plasmoid.configuration.peekingThreshold
		onTriggered: {
			showdesktop.isPeeking = true
		}
	}

	Rectangle {
		id: buttonRect
		color: "transparent"

		property int topMargin: 0
		property int rightMargin: 0
		property int bottomMargin: 0
		property int leftMargin: 0

		y: -topMargin
		x: -leftMargin
		width: leftMargin + plasmoid.width + rightMargin
		height: topMargin + plasmoid.height + bottomMargin

		PlasmaCore.FrameSvgItem {
            id: buttonImg
			anchors.fill: parent
            anchors.topMargin: 2;
            anchors.rightMargin: 3;
            anchors.bottomMargin: 1;
            
            imagePath: "widgets/showdesktop"
            prefix: {
                if(control.containsPress) return "selected";
                if(control.containsMouse) return "hover";
                return "normal";
            }
            
			MouseArea {
				id: control
				anchors.fill: parent
				hoverEnabled: true
				onClicked: {
					if (showdesktop.isPeeking && showdesktop.showingDesktop) {
						showdesktop.isPeeking = false
					} else {
						peekTimer.stop()

						if (true) {
							widget.performClick()
						} else {
							showdesktop.showingDesktop = false
							minimizeAll.toggleActive()
						}
					}
				}
				onEntered: {
					// console.log('onEntered')
					showdesktop.initPeeking()
				}
				onExited: {
					// console.log('onExited')
					showdesktop.cancelPeek()
				}


				// org.kde.plasma.volume
				property int wheelDelta: 0
				onWheel: {
					var delta = wheel.angleDelta.y || wheel.angleDelta.x
					wheelDelta += delta
					// Magic number 120 for common "one click"
					// See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
					while (wheelDelta >= 120) {
						wheelDelta -= 120
						widget.performMouseWheelUp()
					}
					while (wheelDelta <= -120) {
						wheelDelta += 120
						widget.performMouseWheelDown()
					}
					wheel.accepted = true
				}
			}

			DragAndDrop.DropArea {
				anchors.fill: parent
				onDragEnter: {
					// console.log('showDesktopDropArea.onDragEnter')
					// showdesktop.initPeeking()
					showdesktop.showingDesktop = true
				}
			}
		}

		// PlasmaComponents.Button {
		// 	anchors.fill: parent
		// 	// anchors.left: parent.left
		// 	// anchors.top: parent.top + 3
		// 	// anchors.right: parent.right + 5
		// 	// anchors.bottom: parent.bottom + 5
		// 	// width: parent.width
		// 	// height: parent.height
		// 	onClicked: showdesktop.showDesktop()
		// }
	}

	PlasmaCore.IconItem {
		anchors.centerIn: parent
		visible: widget.isWidgetUnlocked
		source: "transform-move"
		width: units.iconSizes.smallMedium
		height: units.iconSizes.smallMedium
	}

	// org.kde.plasma.mediacontrollercompact
	PlasmaCore.DataSource {
		id: executeSource
		engine: "executable"
		connectedSources: []
		onNewData: {
			//we get new data when the process finished, so we can remove it
			disconnectSource(sourceName)
		}
	}
	function exec(cmd) {
		//Note: we assume that 'cmd' is executed quickly so that a previous call
		//with the same 'cmd' has already finished (otherwise no new cmd will be
		//added because it is already in the list)
		executeSource.connectSource(cmd)
	}


	Component.onCompleted: {
		plasmoid.setAction("toggleLockWidgets", i18n("Toggle Lock Widgets (Plasma 5.18)"), "object-locked")
		plasmoid.setAction("showdesktop", i18nd("plasma_applet_org.kde.plasma.showdesktop", "Show Desktop"), "user-desktop")
		plasmoid.setAction("minimizeall", i18ndc("plasma_applet_org.kde.plasma.showdesktop", "@action", "Minimize All Windows"), "user-desktop")
	}

	//---
	function action_toggleLockWidgets() {
		var cmd = 'qdbus org.kde.plasmashell /PlasmaShell evaluateScript "lockCorona(!locked)"'
		widget.exec(cmd)
	}

	function action_showdesktop() {
		showdesktop.showingDesktop = true
	}

	function action_minimizeall() {
		minimizeAll.toggleActive()
	}
}
