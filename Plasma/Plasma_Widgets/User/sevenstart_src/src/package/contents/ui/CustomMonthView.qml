/*
     SPDX-FileCopyrightText: 2013 Heena Mahour <heena393@gmail.com>
     SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>
     SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
     SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>
  
     SPDX-License-Identifier: GPL-2.0-or-later
 */
 import QtQuick 2.0
 import QtQuick.Layouts 1.1
  
 import org.kde.plasma.calendar 2.0
 import org.kde.plasma.core 2.0 as PlasmaCore
 import org.kde.plasma.components 3.0 as PlasmaComponents3
 import org.kde.plasma.extras 2.0 as PlasmaExtras
  
 PinchArea { // TODO KF6 switch to Item
     id: root
  
     anchors.fill: parent // TODO KF6 don't use anchors
  
     enabled: false
  
     /**
      * Currently selected month name.
      * \property string MonthView::selectedMonth
      */
     property alias selectedMonth: calendarBackend.monthName
     /**
      * Currently selected month year.
      * \property int MonthView::selectedYear
      */
     property alias selectedYear: calendarBackend.year
     /**
      * The start day of a week.
      * \property int MonthView::firstDayOfWeek
      * \sa Calendar::firstDayOfWeek
      */
     property alias firstDayOfWeek: calendarBackend.firstDayOfWeek
  
     property QtObject date
     property date currentDate
  
     property date showDate: new Date()
  
     property int borderWidth: 1
     property real borderOpacity: 0.4
  
     property int columns: calendarBackend.days
     property int rows: calendarBackend.weeks
  
     property Item selectedItem
     property int week;
     property int firstDay: new Date(showDate.getFullYear(), showDate.getMonth(), 1).getDay()
     property alias today: calendarBackend.today
     property bool showWeekNumbers: false
     property bool showCustomHeader: false
  
     /**
      * SwipeView currentIndex needed for binding a TabBar to the MonthView.
      */
     property int currentIndex: swipeView.currentIndex
  
     property alias cellHeight: mainDaysCalendar.cellHeight
     property QtObject daysModel: calendarBackend.daysModel
  
     function isToday(date) {
         return date.toDateString() === new Date().toDateString();
     }
  
     function eventDate(yearNumber,monthNumber,dayNumber) {
         const d = new Date(yearNumber, monthNumber-1, dayNumber);
         return Qt.formatDate(d, "dddd dd MMM yyyy");
     }
  
     /**
      * Move calendar to month view showing today's date.
      */
     function resetToToday() {
         calendarBackend.resetToToday();
         root.currentDate = root.today;
         swipeView.currentIndex = 0;
     }
  
     function updateYearOverview() {
         const date = calendarBackend.displayedDate;
         const day = date.getDate();
         const year = date.getFullYear();
  
         for (let i = 0, j = monthModel.count; i < j; ++i) {
             monthModel.setProperty(i, "yearNumber", year);
         }
     }
  
     function updateDecadeOverview() {
         const date = calendarBackend.displayedDate;
         const day = date.getDate();
         const month = date.getMonth() + 1;
         const year = date.getFullYear();
         const decade = year - year % 10;
  
         for (let i = 0, j = yearModel.count; i < j; ++i) {
             const label = decade - 1 + i;
             yearModel.setProperty(i, "yearNumber", label);
             yearModel.setProperty(i, "label", label);
         }
     }
  
     /**
      * Possible calendar views
      */
     enum CalendarView {
         DayView,
         MonthView,
         YearView
     }
  
     /**
      * Go to the next month/year/decade depending on the current
      * calendar view displayed.
      */
     function nextView() {
         if (swipeView.currentIndex === 0) {
             calendarBackend.nextMonth();
         } else if (swipeView.currentIndex === 1) {
             calendarBackend.nextYear();
         } else if (swipeView.currentIndex === 2) {
             calendarBackend.nextDecade();
         }
     }
  
     /**
      * Go to the previous month/year/decade depending on the current
      * calendar view displayed.
      */
     function previousView() {
         if (swipeView.currentIndex === 0) {
             calendarBackend.previousMonth();
         } else if (swipeView.currentIndex === 1) {
             calendarBackend.previousYear();
         } else if (swipeView.currentIndex === 2) {
             calendarBackend.previousDecade();
         }
     }
  
     /**
      * \return CalendarView
      */
     readonly property var calendarViewDisplayed: {
         if (swipeView.currentIndex === 0) {
             return MonthView.CalendarView.DayView;
         } else if (swipeView.currentIndex === 1) {
             return MonthView.CalendarView.MonthView;
         } else if (swipeView.currentIndex === 2) {
             return MonthView.CalendarView.YearView;
         }
     }
  
     /**
      * Show month view.
      */
     function showMonthView() {
         swipeView.currentIndex = 0;
     }
  
     /**
      * Show year view.
      */
     function showYearView() {
         swipeView.currentIndex = 1;
     }
  
     /**
      * Show month view.
      */
     function showDecadeView() {
         swipeView.currentIndex = 2;
     }
  
     Calendar {
         id: calendarBackend
  
         days: 7
         weeks: 6
         firstDayOfWeek: Qt.locale().firstDayOfWeek
         today: root.today
  
         Component.onCompleted: {
             daysModel.setPluginsManager(EventPluginsManager);
         }
  
         onYearChanged: {
             updateYearOverview()
             updateDecadeOverview()
         }
     }
  
     ListModel {
         id: monthModel
  
         Component.onCompleted: {
             for (let i = 0; i < 12; ++i) {
                 append({
                     label: Qt.locale(Qt.locale().uiLanguages[0]).standaloneMonthName(i, Locale.LongFormat),
                     monthNumber: i + 1,
                     yearNumber: 2050,
                     isCurrent: true
                 })
             }
             updateYearOverview()
         }
     }
  
     ListModel {
         id: yearModel
  
         Component.onCompleted: {
             for (let i = 0; i < 12; ++i) {
                 append({
                     label: 2050, // this value will be overwritten, but it set the type of the property to int
                     yearNumber: 2050,
                     isCurrent: (i > 0 && i < 11) // first and last year are outside the decade
                 })
             }
             updateDecadeOverview()
         }
     }
  
     ColumnLayout {
         id: viewHeader
         visible: !showCustomHeader
         // Make sure the height of the invisible item is zero, otherwise anchoring to the item will
         // include the height even if it is invisible.
         height: !visible ? 0 : implicitHeight
         width: parent.width
         anchors {
             top: parent.top
         }
  
         RowLayout {
             spacing: 0
             
             
             PlasmaComponents3.ToolButton {
                 id: previousButton
                 property string tooltip: {
                     switch(root.calendarViewDisplayed) {
                         case MonthView.CalendarView.DayView:
                             return i18nd("libplasma5", "Previous Month")
                         case MonthView.CalendarView.MonthView:
                             return i18nd("libplasma5", "Previous Year")
                         case MonthView.CalendarView.YearView:
                             return i18nd("libplasma5", "Previous Decade")
                         default:
                             return "";
                     }
                 }
                 implicitWidth: PlasmaCore.Units.iconSizes.smallMedium
                 implicitHeight: PlasmaCore.Units.iconSizes.smallMedium
                 Layout.preferredWidth: PlasmaCore.Units.iconSizes.smallMedium
                 Layout.preferredHeight: PlasmaCore.Units.iconSizes.smallMedium
                 icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "gtk-go-forward" : "gtk-go-back"
                 onClicked: root.previousView()
                 Accessible.name: tooltip
                 PlasmaComponents3.ToolTip { text: parent.tooltip }
             }
             PlasmaExtras.Heading {
                 id: heading
                 text: i18ndc("libplasma5", "Format: month year", "%1, %2", root.selectedMonth, root.selectedYear.toString())
                 level: 5
                 font.capitalization: Font.Capitalize
                 horizontalAlignment: Text.AlignHCenter
                 Layout.fillWidth: true
             }
  
             PlasmaComponents3.ToolButton {
                 id: nextButton
                 property string tooltip: {
                     switch(root.calendarViewDisplayed) {
                         case MonthView.CalendarView.DayView:
                             return i18nd("libplasma5", "Next Month")
                         case MonthView.CalendarView.MonthView:
                             return i18nd("libplasma5", "Next Year")
                         case MonthView.CalendarView.YearView:
                             return i18nd("libplasma5", "Next Decade")
                         default:
                             return "";
                     }
                 }
                 implicitWidth: PlasmaCore.Units.iconSizes.smallMedium
                 implicitHeight: PlasmaCore.Units.iconSizes.smallMedium
                 Layout.preferredWidth: PlasmaCore.Units.iconSizes.smallMedium
                 Layout.preferredHeight: PlasmaCore.Units.iconSizes.smallMedium
                 icon.name: Qt.application.layoutDirection === Qt.RightToLeft ? "gtk-go-back" : "gtk-go-back-rtl"
                 PlasmaComponents3.ToolTip { text: parent.tooltip }
                 onClicked: root.nextView();
                 Accessible.name: tooltip
             }
         }
  
         PlasmaComponents3.TabBar {
             id: tabBar
             currentIndex: swipeView.currentIndex
             Layout.fillWidth: true
             Layout.bottomMargin: PlasmaCore.Units.smallSpacing
  
             PlasmaComponents3.TabButton {
                 text: i18nd("libplasma5", "Days");
                 onClicked: root.showMonthView();
                 display: PlasmaComponents3.AbstractButton.TextOnly
             }
             PlasmaComponents3.TabButton {
                 text: i18nd("libplasma5", "Months");
                 onClicked: root.showYearView();
                 display: PlasmaComponents3.AbstractButton.TextOnly
             }
             PlasmaComponents3.TabButton {
                 text: i18nd("libplasma5", "Years");
                 onClicked: root.showDecadeView();
                 display: PlasmaComponents3.AbstractButton.TextOnly
             }
         }
     }
  
     PlasmaComponents3.SwipeView {
         id: swipeView
         anchors {
             top: viewHeader.bottom
             left: parent.left
             right: parent.right
             bottom: parent.bottom
         }
         clip: true
  
         onCurrentIndexChanged: if (currentIndex > 1) {
             updateDecadeOverview();
         }
  
         // MonthView
         DaysCalendar {
             id: mainDaysCalendar
  
             columns: calendarBackend.days
             rows: calendarBackend.weeks
  
             showWeekNumbers: root.showWeekNumbers
  
             headerModel: calendarBackend.days
             gridModel: calendarBackend.daysModel
  
             dateMatchingPrecision: Calendar.MatchYearMonthAndDay
  
             onActivated: {
                 const rowNumber = Math.floor(index / columns);
                 week = 1 + calendarBackend.weeksModel[rowNumber];
                 root.currentDate = new Date(date.yearNumber, date.monthNumber - 1, date.dayNumber)
             }
  
             onScrollUp: root.nextView()
             onScrollDown: root.previousView()
         }
  
         // YearView
         DaysCalendar {
             columns: 3
             rows: 4
  
             dateMatchingPrecision: Calendar.MatchYearAndMonth
  
             gridModel: monthModel
             onActivated: {
                 calendarBackend.goToMonth(date.monthNumber);
                 swipeView.currentIndex = 0;
             }
  
             onScrollUp: calendarBackend.nextYear()
             onScrollDown: calendarBackend.previousYear()
         }
  
         // DecadeView
         DaysCalendar {
             readonly property int decade: {
                 const year = calendarBackend.displayedDate.getFullYear()
                 return year - year % 10
             }
  
             columns: 3
             rows: 4
  
             dateMatchingPrecision: Calendar.MatchYear
  
             gridModel: yearModel
             onActivated: {
                 calendarBackend.goToYear(date.yearNumber);
                 swipeView.currentIndex = 1;
             }
  
             onScrollUp: calendarBackend.nextDecade()
             onScrollDown: calendarBackend.previousDecade()
         }
     }
  
     Component.onCompleted: {
         root.currentDate = calendarBackend.today
     }
 } 
