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
import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaCore.Dialog {
    id: calendar
    objectName: "popupWindow"
    flags: Qt.WindowStaysOnTopHint
    location: PlasmaCore.Types.Floating //To make the dialog float in the corner of the screen
    hideOnWindowDeactivate: !plasmoid.configuration.pin
	
	//Used for reading margin values 
    PlasmaCore.FrameSvgItem {
        id : panelSvg
        visible: false
        imagePath: "widgets/panel-background"
    }

    onVisibleChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
        
        holidaysList.model = null;
        holidaysList.model = monthView.daysModel.eventsForDate(monthView.currentDate);
    }
    onHeightChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }

    onWidthChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }
        
    function popupPosition(i, j) {
        var screenAvail = plasmoid.availableScreenRect;
        var screen = plasmoid.screenGeometry;

        var offset = PlasmaCore.Units.smallSpacing;
        // Fall back to bottom-left of screen area when the applet is on the desktop or floating.
        var x = offset;
        var y = screen.height - j - offset;

        var horizMidPoint = screen.x + (screen.width / 2);
        var vertMidPoint = screen.y + (screen.height / 2);
        var appletTopLeft = parent.mapToGlobal(0, 0);
        var appletBottomLeft = parent.mapToGlobal(0, parent.height);

        x = (appletTopLeft.x < horizMidPoint) ? screen.x : (screen.x + screen.width) - i;
          
        if (appletTopLeft.x < horizMidPoint) {
        	x += offset
        } else if (appletTopLeft.x + i > horizMidPoint){
        	x -= offset
        }

        if (plasmoid.location == PlasmaCore.Types.TopEdge) {
        	/*this is floatingAvatar.width*/
        	offset = PlasmaCore.Units.smallSpacing*2;
            y = screen.y + parent.height + panelSvg.margins.bottom + offset;
        } else {
        	offset = PlasmaCore.Units.smallSpacing*2;
            y = screen.y + screen.height - (parent.height) - j - panelSvg.margins.top - offset;
        }

        return Qt.point(x, y);
    }

    readonly property bool showAgenda: PlasmaCalendar.EventPluginsManager.enabledPlugins.length > 0

    property int _minimumWidth: (showAgenda ? agendaViewWidth : units.largeSpacing) + monthViewWidth
    property int _minimumHeight: PlasmaCore.Units.gridUnit * 12

    readonly property int agendaViewWidth: _minimumHeight
    readonly property int monthViewWidth: monthView.showWeekNumbers ? Math.round(_minimumHeight * 1.25) : Math.round(_minimumHeight * 1.125)

    property int boxWidth: (agendaViewWidth + monthViewWidth - ((showAgenda ? 3 : 4) * spacing)) / 2

    property int spacing: units.largeSpacing
    property alias borderWidth: monthView.borderWidth
    property alias monthView: monthView

    property bool debug: false

    property bool isExpanded: plasmoid.expanded

    onIsExpandedChanged: {
        // clear all the selections when the plasmoid is showing/hiding
        monthView.resetToToday();
    }

    FocusScope {
        Layout.minimumWidth: _minimumWidth * 0.8
        Layout.minimumHeight: _minimumHeight * 1.2
        Layout.maximumWidth: _minimumWidth * 0.8
        Layout.maximumHeight: _minimumHeight  * 1.2
        Layout.preferredWidth: _minimumWidth * 0.8
        Layout.preferredHeight: _minimumHeight  * 1.2

		//This is the long date that appears on top of the dialog, pressing on it will set the calendar to the current day.
		PlasmaExtras.Heading {
			id: longDateLabel
			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
				topMargin: PlasmaCore.Units.smallSpacing*2
			}
			width: paintedWidth
			horizontalAlignment: Text.AlignHCenter
			text: agenda.dateString("dddd") + ", " + Qt.locale().standaloneMonthName(monthView.currentDate.getMonth()) + agenda.dateString(" dd") + ", " + agenda.dateString("yyyy")
			color: heading_ma.containsPress ? "#90e7ff" : (heading_ma.containsMouse ? "#b6ffff" : "white")
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
		
		//This is the side panel that appears on the right of the calendar view, showing holidays, events, reminders, etc. in a list.
		//Replaces the large graphical clock on the right on Windows 7's equivalent panel.
		Item {
		    id: agenda
		    visible: calendar.showAgenda
		    width: boxWidth * 0.75
		
		    anchors {
		        top: parent.top
		        right: parent.right
		        bottom: parent.bottom
		        topMargin: spacing
		        bottomMargin: spacing
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
		        target: plasmoid.configuration
		
		        function onEnabledCalendarPluginsChanged() {
		            PlasmaCalendar.EventPluginsManager.enabledPlugins = plasmoid.configuration.enabledCalendarPlugins;
		        }
		    }
		
		    Binding {
		        target: plasmoid
		        property: "hideOnWindowDeactivate"
		        value: !plasmoid.configuration.pin
		    }
		
		    TextMetrics {
		        id: dateLabelMetrics
		
		        // Date/time are arbitrary values with all parts being two-digit
		        readonly property string timeString: Qt.formatTime(new Date(2000, 12, 12, 12, 12, 12, 12))
		        readonly property string dateString: agenda.formatDateWithoutYear(new Date(2000, 12, 12, 12, 12, 12))
		
		        font: theme.defaultFont
		        text: timeString.length > dateString.length ? timeString : dateString
		    }
		
		    PlasmaExtras.ScrollArea {
		        id: holidaysView
		        anchors {
		            top: parent.top
		            topMargin: PlasmaCore.Units.largeSpacing
		            left: parent.left
		            right: parent.right
		            bottom: parent.bottom
		        }
		        flickableItem.boundsBehavior: Flickable.StopAtBounds
		
		        ListView {
		            id: holidaysList
		
		            delegate: PlasmaComponents.ListItem {
		                id: eventItem
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
		                    width: parent.width
		                    height: eventGrid.height
		                    active: eventTitle.truncated || eventDescription.truncated
		                    mainText: active ? eventTitle.text : ""
		                    subText: active ? eventDescription.text : ""
		
		                    GridLayout {
		                        id: eventGrid
		                        columns: 3
		                        rows: 2
		                        rowSpacing: 0
		                        columnSpacing: 2 * units.smallSpacing
		
		                        width: parent.width
		
		                        Rectangle {
		                            id: eventColor
		
		                            Layout.row: 0
		                            Layout.column: 0
		                            Layout.rowSpan: 2
		                            Layout.fillHeight: true
		
		                            color: modelData.eventColor
		                            width: 5 * units.devicePixelRatio
		                            visible: modelData.eventColor !== ""
		                        }
		
		                        PlasmaComponents.Label {
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
		
		                        PlasmaComponents.Label {
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
		
		                        PlasmaComponents.Label {
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
		
		                        PlasmaComponents.Label {
		                            id: eventDescription
		
		                            Layout.row: 1
		                            Layout.column: 2
		                            Layout.fillWidth: true
		
		                            elide: Text.ElideRight
		                            text: modelData.description
		                            verticalAlignment: Text.AlignVCenter
		                            enabled: false
		
		                            visible: text !== ""
		                        }
		                    }
		                }
		            }
		
		            section.property: "modelData.eventType"
		            section.delegate: PlasmaExtras.Heading {
		                level: 5
		                elide: Text.ElideRight
		                text: section
		                font.weight: Font.Bold
		            }
		        }
		    }
		
		    PlasmaExtras.Heading {
		        anchors.fill: holidaysView
		        anchors.rightMargin: units.largeSpacing
		        text: monthView.isToday(monthView.currentDate) ? i18n("No events for today") + "\n" 
		                                                       : i18n("No events for this day") + "\n";
		        level: 5
		        opacity: 0.8
		        visible: holidaysList.count == 0
		    }
		
		}

		//The calendar itself, on the left side of the dialog
		Item {
		    id: cal
		    width: boxWidth
		    anchors {
		        top: parent.top
		        left: parent.left
		        bottom: parent.bottom
		        leftMargin: PlasmaCore.Units.smallSpacing * 2
		        topMargin: PlasmaCore.Units.largeSpacing * 2
		        rightMargin: spacing
		        bottomMargin: 0
		    }
		
		    CustomMonthView {
		        id: monthView
		        today: root.tzDate
		        showWeekNumbers: plasmoid.configuration.showWeekNumbers
		        firstDayOfWeek: Locale.Monday
		        anchors.fill: parent
		    }
		}
		
		// Allows the user to keep the calendar open for reference
		PlasmaComponents.ToolButton {
		    anchors.right: parent.right
		    width: Math.round(units.gridUnit * 1.25)
		    height: width
		    checkable: true
		    iconSource: "window-pin"
		    checked: plasmoid.configuration.pin
		    onCheckedChanged: plasmoid.configuration.pin = checked
		}
		}
		Component.onCompleted: {
		    calendar.backgroundHints = 2; //Sets the background type to 'Solid' in order to make use of the alternative dialog style.
										  //The same is done to the system tray, giving the two plasmoids a consistent look and feel.
		    var pos = popupPosition(width, height);
		    x = pos.x;
		    y = pos.y;
		}
}
