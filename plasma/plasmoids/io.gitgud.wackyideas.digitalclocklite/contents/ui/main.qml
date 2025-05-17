/*
 * Copyright 2013  Heena Mahour <heena393@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
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
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.private.digitalclock 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.workspace.calendar 2.0 as PlasmaCalendar
import org.kde.ksvg 1.0 as KSvg

import org.kde.kcmutils // KCMLauncher
import org.kde.config // KAuthorized

//import org.kde.plasma.components 2.0 as PlasmaComponents
//import org.kde.plasma.extras 2.0 as PlasmaExtras


//import org.kde.plasma.calendar 2.0 as PlasmaCalendar

PlasmoidItem {
    id: root
    anchors.fill: parent

    width: Kirigami.Units.iconSizes.small * 10
    height: Kirigami.Units.iconSizes.small * 4
    property string dateFormatString: setDateFormatString()
    property date tzDate: {
        const data = dataSource.data[Plasmoid.configuration.lastSelectedTimezone];
        if (data === undefined) {
            return new Date();
        }
        // get the time for the given timezone from the dataengine
        const now = data["DateTime"];
        // get current UTC time
        const msUTC = now.getTime() + (now.getTimezoneOffset() * 60000);
        // add the dataengine TZ offset to it
        return new Date(msUTC + (data["Offset"] * 1000));
    }

    function initTimezones() {
        const tz = []

        if (Plasmoid.configuration.selectedTimeZones.indexOf("Local") === -1) {
            tz.push("Local");
        }
        root.allTimezones = tz.concat(Plasmoid.configuration.selectedTimeZones);
        dataSource.connectedSources = root.allTimezones;
    }

    preferredRepresentation: fullRepresentation
    compactRepresentation: null
    fullRepresentation: smallRepresentation

    KSvg.Svg {
        id: buttonIcons
        imagePath: Qt.resolvedUrl("svgs/icons.svg");
    }
    KSvg.Svg {
        id: clockSvg
        imagePath: Qt.resolvedUrl("svgs/clock.svg");
    }

    //We need Local to be *always* present, even if not disaplayed as
    //it's used for formatting in ToolTip.dateTimeChanged()
    property var allTimezones
    Connections {
        target: Plasmoid.configuration
        function onSelectedTimeZonesChanged() { root.initTimezones(); }
    }
    Component {
        id: mainRepresentation
        CalendarView {
            
        }
    }
    Component {
        id: smallRepresentation
        DigitalClock
        {}
    }

    hideOnWindowDeactivate: !Plasmoid.configuration.pin


    P5Support.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: allTimezones
        interval: 1000 //Plasmoid.configuration.showSeconds ? 1000 : 60000
        intervalAlignment: P5Support.Types.NoAlignment //Plasmoid.configuration.showSeconds ? P5Support.Types.NoAlignment : P5Support.Types.AlignToMinute
    }

    function setDateFormatString() {
        // remove "dddd" from the locale format string
        // /all/ locales in LongFormat have "dddd" either
        // at the beginning or at the end. so we just
        // remove it + the delimiter and space
        var format = Qt.locale().dateFormat(Locale.LongFormat);
        format = format.replace(/(^dddd.?\s)|(,?\sdddd$)/, "");
        return format;
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Adjust Date and Time…")
            icon.name: "clock"
            visible: KAuthorized.authorize("kcm_clock")
            onTriggered: KCMLauncher.openSystemSettings("kcm_clock")
        },
        PlasmaCore.Action {
            text: i18n("Set Time Format…")
            icon.name: "gnumeric-format-thousand-separator"
            visible: KAuthorized.authorizeControlModule("kcm_regionandlang")
            onTriggered: KCMLauncher.openSystemSettings("kcm_regionandlang")
        }
    ]
    
    PlasmaCalendar.EventPluginsManager {
        id: eventPluginsManager
        enabledPlugins: Plasmoid.configuration.enabledCalendarPlugins
    }

    Component.onCompleted: {
        root.initTimezones();
        
        // Set the list of enabled plugins from config
        // to the manager
        eventPluginsManager.enabledPlugins = Plasmoid.configuration.enabledCalendarPlugins;
        

    }
}
