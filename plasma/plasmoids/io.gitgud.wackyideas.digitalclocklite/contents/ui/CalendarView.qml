/*
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 * Copyright 2015 Martin Klapetek <mklapetek@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.workspace.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2.20 as Kirigami
import Qt5Compat.GraphicalEffects

PlasmaCore.Dialog {
    id: calendar
    objectName: "popupWindow"
    flags: Qt.WindowStaysOnTopHint
    location: PlasmaCore.Types.Floating //To make the dialog float in the corner of the screen
    hideOnWindowDeactivate: !plasmoid.configuration.pin
	
	//Used for reading margin values 
    KSvg.FrameSvgItem {
        id : panelSvg
        visible: false
        imagePath: "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
		id : dialogSvg
		visible: false
		imagePath: "solid/dialogs/background"
	}

    onVisibleChanged: {
        popupPosition();
        monthView.resetToToday();
		holidaysList.model = null;
        holidaysList.model = monthView.daysModel.eventsForDate(monthView.currentDate);
    }
    onHeightChanged: {
        popupPosition();
    }
    property int flyoutMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing/2

    onWidthChanged: {
        popupPosition();
    }
        
	function popupPosition() {
		var pos = root.mapToGlobal(root.x, root.y);
		var availScreen = Plasmoid.containment.availableScreenRect;
		var screen = root.screenGeometry;

		x = pos.x - calendar.width / 2 + root.width / 2
		y = pos.y - calendar.height;

		if(x <= 0) x += flyoutMargin;
		if(x + calendar.width - screen.x >= availScreen.width) {
			x = screen.x + availScreen.width - calendar.width - flyoutMargin;

		}
		if(y <= 0) y += flyoutMargin;
		if(y + calendar.height - screen.y >= availScreen.height) {
			y = screen.y + availScreen.height - calendar.height - flyoutMargin;
		}


	}


    readonly property bool showAgenda: Plasmoid.configuration.enabledCalendarPlugins.length > 0

    property int _minimumWidth: 336//(showAgenda ? agendaViewWidth : Kirigami.Units.largeSpacing) + monthViewWidth
    property int _minimumHeight: 247

    readonly property int agendaViewWidth: _minimumHeight
    readonly property int monthViewWidth: monthView.showWeekNumbers ? Math.round(_minimumHeight * 1.25) : Math.round(_minimumHeight * 1.125)

    property int boxWidth: (agendaViewWidth + monthViewWidth - ((showAgenda ? 3 : 4) * spacing)) / 2

    property int spacing: Kirigami.Units.largeSpacing
    property alias borderWidth: monthView.borderWidth
    property alias monthView: monthView

    property bool debug: false

    property bool isExpanded: Plasmoid.expanded

    onIsExpandedChanged: {
        // clear all the selections when the plasmoid is showing/hiding
        monthView.resetToToday();
    }

    FocusScope {


		Kirigami.Theme.colorSet: Kirigami.Theme.View
		Kirigami.Theme.inherit: false
        Layout.minimumWidth: _minimumWidth
        Layout.minimumHeight: _minimumHeight
        Layout.maximumWidth: _minimumWidth
        Layout.maximumHeight: _minimumHeight
        Layout.preferredWidth: _minimumWidth
        Layout.preferredHeight: _minimumHeight

		//colorGroup: PlasmaCore.Theme.ToolTipColorGroup
		anchors.fill: parent
		//This is the long date that appears on top of the dialog, pressing on it will set the calendar to the current day.

		ColumnLayout {

			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
				bottom: plasmoidFooter.top
				topMargin: dialogSvg.margins.top + Kirigami.Units.mediumSpacing*2
				leftMargin: dialogSvg.margins.left + Kirigami.Units.mediumSpacing*2
				bottomMargin: Kirigami.Units.mediumSpacing*2
				rightMargin: dialogSvg.margins.right + Kirigami.Units.mediumSpacing*2
			}
			PlasmaExtras.Heading {
				id: longDateLabel

				Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
				/*anchors {
					left: parent.left
					right: parent.right
					top: parent.top
					topMargin: Kirigami.Units.smallSpacing*2
				}*/
				width: paintedWidth
				horizontalAlignment: Text.AlignHCenter

				text: agenda.todayDateString("dddd") + ", " + Qt.locale().standaloneMonthName(monthView.today.getMonth()) + agenda.todayDateString(" dd") + ", " + agenda.todayDateString("yyyy")

				color: "#0066cc" //heading_ma.containsPress ? "#90e7ff" : (heading_ma.containsMouse ? "#b6ffff" : Kirigami.Theme.textColor)
				font.underline: heading_ma.containsMouse
				level: 5
				MouseArea {
					id: heading_ma
					anchors.fill: parent
					hoverEnabled: true
					onClicked: monthView.resetToToday()
					cursorShape: Qt.PointingHandCursor
					z: 5
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				spacing: 0
				//The calendar itself, on the left side of the dialog
				Item {
					id: cal
					Layout.preferredWidth: 168
					Layout.preferredHeight: 150
					Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
					Layout.topMargin: Kirigami.Units.largeSpacing + Kirigami.Units.mediumSpacing

					CustomMonthView {
						id: monthView
						today: root.tzDate
						showWeekNumbers: Plasmoid.configuration.showWeekNumbers
						firstDayOfWeek: Plasmoid.configuration.firstDayOfWeek
						anchors.fill: parent
					}
				}


				Item {
					id: testRect
					visible: !calendar.showAgenda
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.bottomMargin: Kirigami.Units.mediumSpacing
					Clock {
						id: clockWidget
						//anchors.fill: parent
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						anchors.horizontalCenterOffset: Kirigami.Units.largeSpacing
						anchors.verticalCenterOffset: -Kirigami.Units.largeSpacing
						width: 128
						height: 128

						//Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
						//Layout.leftMargin: Kirigami.Units.largeSpacing
					}

					DropShadow {
						anchors.fill: clockWidget
						horizontalOffset: 2
						verticalOffset: 2
						radius: 3.0
						color: "#16000000"
						source: clockWidget

					}
					Text {
						id: clockTime
						anchors.bottom: parent.bottom
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.leftMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing*2
						//anchors.bottomMargin: Kirigami.Units.mediumSpacing
						horizontalAlignment: Text.AlignHCenter
						text: Qt.formatTime(clockWidget.currentDate, main.use24hFormat ? "hh:mm:ss" : "h:mm:ss AP")
					}
				}


				//This is the side panel that appears on the right of the calendar view, showing holidays, events, reminders, etc. in a list.
				//Replaces the large graphical clock on the right on Windows 7's equivalent panel.
				Item {
					id: agenda
					visible: calendar.showAgenda
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.leftMargin: Kirigami.Units.largeSpacing

					function todayDateString(format) {
						return Qt.formatDate(monthView.today, format);
					}
					function dateString(format) {
						return Qt.formatDate(monthView.currentDate, format);
					}

					function formatDateWithoutYear(date) {
						// Unfortunatelly Qt overrides ECMA's Date.toLocaleDateString(),
						// which is able to return locale-specific date-and-month-only date
						// formats, with its dumb version that only supports Qt::DateFormat
						// enum subset. So to get a day-and-month-only date format string we
						// must resort to this magic and hope there are no locales that use
						// other separators...
						var format = Qt.locale().dateFormat(Locale.ShortFormat).replace(/[./ ]*Y{2,4}[./ ]*/i, '');
						return Qt.formatDate(date, format);
					}

					Connections {
						target: monthView

						function onCurrentDateChanged() {
							// Apparently this is needed because this is a simple QList being
							// returned and if the list for the current day has 1 event and the
							// user clicks some other date which also has 1 event, QML sees the
							// sizes match and does not update the labels with the content.
							// Resetting the model to null first clears it and then correct data
							// are displayed.
							holidaysList.model = null;
							holidaysList.model = monthView.daysModel.eventsForDate(monthView.currentDate);
						}
					}

					Connections {
						target: monthView.daysModel

						function onAgendaUpdated(updatedDate) {
							// Checks if the dates are the same, comparing the date objects
							// directly won't work and this does a simple integer subtracting
							// so should be fastest. One of the JS weirdness.
							if (updatedDate - monthView.currentDate === 0) {
								holidaysList.model = null;
								holidaysList.model = monthView.daysModel.eventsForDate(monthView.currentDate);
							}
						}
					}

					Connections {
						target: Plasmoid.configuration

						function onEnabledCalendarPluginsChanged() {
							PlasmaCalendar.EventPluginsManager.enabledPlugins = Plasmoid.configuration.enabledCalendarPlugins;
							eventPluginsManager.enabledPlugins = Plasmoid.configuration.enabledCalendarPlugins;
							//console.log(PlasmaCalendar.EventPluginsManager.enabledPlugins);
							//console.log(eventPluginsManager.enabledPlugins);
						}
					}

					/*Binding {
						target: Plasmoid
						property: "hideOnWindowDeactivate"
						value: !Plasmoid.configuration.pin
					}*/

					TextMetrics {
						id: dateLabelMetrics

						// Date/time are arbitrary values with all parts being two-digit
						readonly property string timeString: Qt.formatTime(new Date(2000, 12, 12, 12, 12, 12, 12))
						readonly property string dateString: agenda.formatDateWithoutYear(new Date(2000, 12, 12, 12, 12, 12))

						font: Kirigami.Theme.defaultFont
						text: timeString.length > dateString.length ? timeString : dateString
					}

					PlasmaComponents3.ScrollView {
						id: holidaysView
						anchors {
							fill: parent
							topMargin: Kirigami.Units.largeSpacing
						}

						ListView {
							id: holidaysList

							spacing: Kirigami.Units.smallSpacing
							highlightFollowsCurrentItem: false
							highlight: Item {
								opacity: 0
							}

							delegate: PlasmaComponents3.ItemDelegate {
								id: eventItem
								width: parent.width
								height: eventGrid.height

								property bool hasTime: {
									// Explicitly all-day event

									if (modelData.isAllDay) {
										return false;
									}
									// Multi-day event which does not start or end today (so
									// is all-day from today's point of view)
									if (modelData.startDateTime - monthView.currentDate < 0 &&
										modelData.endDateTime - monthView.currentDate > 86400000) { // 24hrs in ms
											return false;
										}

										// Non-explicit all-day event
										var startIsMidnight = modelData.startDateTime.getHours() == 0
										&& modelData.startDateTime.getMinutes() == 0;

									var endIsMidnight = modelData.endDateTime.getHours() == 0
									&& modelData.endDateTime.getMinutes() == 0;

									var sameDay = modelData.startDateTime.getDate() == modelData.endDateTime.getDate()
									&& modelData.startDateTime.getDay() == modelData.endDateTime.getDay()

									if (startIsMidnight && endIsMidnight && sameDay) {
										return false
									}

									return true;
								}

								PlasmaCore.ToolTipArea {

									//anchors.fill: parent
									width: parent.width
									height: eventGrid.height
									active: eventTitle.truncated || eventDescription.truncated
									mainText: active ? eventTitle.text : ""
									subText: active ? eventDescription.text : ""
									textFormat: Text.RichText

									GridLayout {
										id: eventGrid
										columns: 3
										rows: 2
										rowSpacing: 0
										columnSpacing: Kirigami.Units.smallSpacing

										width: parent.width

										Rectangle {
											id: eventColor

											Layout.row: 0
											Layout.column: 0
											Layout.rowSpan: 2
											Layout.fillHeight: true

											color: modelData.eventColor
											width: 3
											visible: modelData.eventColor !== ""
										}

										PlasmaComponents3.Label {
											id: startTimeLabel

											readonly property bool startsToday: modelData.startDateTime - monthView.currentDate >= 0
											readonly property bool startedYesterdayLessThan12HoursAgo: modelData.startDateTime - monthView.currentDate >= -43200000 //12hrs in ms

											Layout.row: 0
											Layout.column: 1
											Layout.minimumWidth: dateLabelMetrics.width

											text: startsToday || startedYesterdayLessThan12HoursAgo
											? Qt.formatTime(modelData.startDateTime)
											: agenda.formatDateWithoutYear(modelData.startDateTime)
											horizontalAlignment: Qt.AlignRight
											visible: eventItem.hasTime
										}

										PlasmaComponents3.Label {
											id: endTimeLabel

											readonly property bool endsToday: modelData.endDateTime - monthView.currentDate <= 86400000 // 24hrs in ms
											readonly property bool endsTomorrowInLessThan12Hours: modelData.endDateTime - monthView.currentDate <= 86400000 + 43200000 // 36hrs in ms

											Layout.row: 1
											Layout.column: 1
											Layout.minimumWidth: dateLabelMetrics.width

											text: endsToday || endsTomorrowInLessThan12Hours
											? Qt.formatTime(modelData.endDateTime)
											: agenda.formatDateWithoutYear(modelData.endDateTime)
											horizontalAlignment: Qt.AlignRight
											enabled: false

											visible: eventItem.hasTime
										}

										PlasmaComponents3.Label {
											id: eventTitle

											readonly property bool wrap: eventDescription.text === ""

											Layout.row: 0
											Layout.rowSpan: wrap ? 2 : 1
											Layout.column: 2
											Layout.fillWidth: true


											elide: Text.ElideRight
											text: modelData.title
											verticalAlignment: Text.AlignVCenter
											maximumLineCount: 2
											wrapMode: wrap ? Text.Wrap : Text.NoWrap
										}
										TextEdit {
											id: descriptionHelper
											visible: false
											text: modelData.description
											textFormat: Text.RichText
										}
										PlasmaComponents3.Label {
											id: eventDescription

											Layout.row: 1
											Layout.column: 2
											Layout.fillWidth: true

											elide: Text.ElideRight
											text: descriptionHelper.getText(0, descriptionHelper.length)
											verticalAlignment: Text.AlignVCenter
											enabled: false
											textFormat: Text.PlainText
											maximumLineCount: 1

											visible: text !== ""
										}
									}
								}
							}

							section.property: "eventType"
							section.delegate:
							PlasmaExtras.Heading {
								width: holidaysList.width
								bottomPadding: Kirigami.Units.smallSpacing
								level: 5
								elide: Text.ElideRight
								text: section
								font.weight: Font.Bold

							}
						}
					}

					PlasmaExtras.Heading {
						anchors.fill: holidaysView
						horizontalAlignment: Text.AlignHCenter
						//anchors.rightMargin: Kirigami.Units.largeSpacing
						text: monthView.isToday(monthView.currentDate) ? i18n("No events for today") + "\n"
						: i18n("No events for this day") + "\n";
						level: 5
						opacity: 0.8
						visible: holidaysList.count == 0
					}

				}
			}
		}
		

		Rectangle {
			id: plasmoidFooter
			anchors {
				bottom: parent.bottom
				left: parent.left
				right: parent.right
				leftMargin: dialogSvg.margins.left
				rightMargin: dialogSvg.margins.right
				bottomMargin: dialogSvg.margins.bottom

			}
			//visible: container.appletHasFooter
			height: 40 + Kirigami.Units.smallSpacing / 2 //+ container.footerHeight + Kirigami.Units.smallSpacing
			//height: trayHeading.height + container.headingHeight + (container.headingHeight === 0 ? 0 : Kirigami.Units.smallSpacing/2)
			color: "#f1f5fb"
			Rectangle {
				id: plasmoidFooterBorder
				anchors {
					top: parent.top
					left: parent.left
					right: parent.right
				}
				gradient: Gradient {
					GradientStop { position: 0.0; color: "#ccd9ea" }
					GradientStop { position: 1.0; color: "#f1f5fb" }
				}
				height: Kirigami.Units.smallSpacing
			}

			PlasmaExtras.Heading {
				id: settingsLink

				anchors {
					horizontalCenter: parent.horizontalCenter
					verticalCenter: parent.verticalCenter
				}

				horizontalAlignment: Text.AlignHCenter
				text: "Change date and time settings..."
				color: "#0066cc" //heading_ma.containsPress ? "#90e7ff" : (heading_ma.containsMouse ? "#b6ffff" : Kirigami.Theme.textColor)
				font.underline: link_ma.containsMouse
				level: 5
				MouseArea {
					id: link_ma
					anchors.fill: parent
					hoverEnabled: true
					onClicked: Plasmoid.internalAction("configure").trigger()
					cursorShape: Qt.PointingHandCursor
					z: 5
				}
			}
			z: -9999
		}
		ToolButton {
			id: pinButton

			anchors.bottom: parent.bottom
			anchors.right: parent.right
			anchors.rightMargin: dialogSvg.margins.right + Kirigami.Units.mediumSpacing + 2
			anchors.bottomMargin: dialogSvg.margins.bottom + Kirigami.Units.mediumSpacing + 2
			width: Kirigami.Units.iconSizes.small+1;
			height: Kirigami.Units.iconSizes.small;
			checkable: true
			checked: Plasmoid.configuration.pin

			onClicked: (mouse) => {
				Plasmoid.configuration.pin = !Plasmoid.configuration.pin;
			}
			buttonIcon: "pin"

			z: 9999

		}
	}
		Component.onCompleted: {
		    calendar.backgroundHints = 2; //Sets the background type to 'Solid' in order to make use of the alternative dialog style.
										  //The same is done to the system tray, giving the two plasmoids a consistent look and feel.
		    popupPosition();
		    //x = pos.x;
		    //y = pos.y;
		}
}
