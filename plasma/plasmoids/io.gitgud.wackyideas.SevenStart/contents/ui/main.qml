/***************************************************************************
 *   Copyright (C) 2014-2015 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import org.kde.kwindowsystem
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: kicker

    signal reset

    anchors.fill: parent
    property bool isDash: false
    property Item dragSource: null

    switchWidth: isDash || !fullRepresentationItem ? 0 :fullRepresentationItem.Layout.minimumWidth
    switchHeight: isDash || !fullRepresentationItem ? 0 :fullRepresentationItem.Layout.minimumHeight

    property QtObject globalFavorites: rootModel.favoritesModel
    property QtObject systemFavorites: rootModel.systemFavoritesModel
    // I see what you did here
    //property bool compositingEnabled: kwindowsystem.compositingActive
    property bool compositingEnabled: KWindowSystem.isPlatformX11 ? KX11Extras.compositingActive : true

    preferredRepresentation: isDash ? menuRepresentation : null

    compactRepresentation: isDash ? null : compactRepresentation
    fullRepresentation: isDash ? compactRepresentation : menuRepresentation
    Plasmoid.constraintHints: Plasmoid.CanFillArea


    // Runs KMenuEdit.
    function action_menuedit() {
        processRunner.runMenuEditor();
    }

    function action_taskman() {
        menu_executable.exec("ksysguard");
    }

    Component {
        id: compactRepresentation
        CompactRepresentation {}
    }

    Component {
        id: menuRepresentation
        MenuRepresentation { }
    }

    // Used to run separate programs through this plasmoid.
    Plasma5Support.DataSource {
    	id: menu_executable
    	engine: "executable"
    	connectedSources: []
    	onNewData: {
    	    var exitCode = data["exit code"]
    	    var exitStatus = data["exit status"]
    	    var stdout = data["stdout"]
    	    var stderr = data["stderr"]
    	    exited(sourceName, exitCode, exitStatus, stdout, stderr)
    	    disconnectSource(sourceName)
    	}
    	function exec(cmd) {
    	    if (cmd) {
    	        connectSource(cmd)
    	    }
    	}
    	signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }
    Kicker.WindowSystem {
        id: windowSystem
    }

    Kicker.RecentUsageModel {
        id: recentUsageModel
        favoritesModel: globalFavorites
        ordering: 0
        shownItems: Kicker.RecentUsageModel.OnlyApps
    }

    Kicker.RunnerModel {
        id: runnerModel

        appletInterface: kicker

        //query: kickoff.searchField ? kickoff.searchField.text : ""
        //deleteWhenEmpty: false
        favoritesModel: rootModel.favoritesModel
        //runners: ["Dictionary","services","calculator","shell","org.kde.windowedwidgets","org.kde.datetime","baloosearch","locations","unitconverter","bookmarks", "krunner_services", "krunner_systemsettings", "krunner_sessions", "krunner_powerdevil"]
        /*runners: {
                const results = ["Dictionary","services","calculator","shell","org.kde.windowedwidgets","org.kde.datetime","baloosearch","locations","unitconverter","bookmarks", "krunner_services", "krunner_systemsettings", "krunner_sessions", "krunner_powerdevil"];

                if (Plasmoid.configuration.useExtraRunners) {
                    results.push(...Plasmoid.configuration.extraRunners);
                }
                return results;
            }*/
        mergeResults: true
    }
    //KWindowSystem { id: kwindowsystem } // Used for detecting compositing changes.
    Kicker.RootModel {
        id: rootModel

        autoPopulate: false

        appNameFormat: Plasmoid.configuration.appNameFormat
        flat: true
        sorted: true
        showSeparators: false
        appletInterface: kicker

        paginate: false
        pageSize: Plasmoid.configuration.numberColumns *  Plasmoid.configuration.numberRows

        showAllApps: false
        showAllAppsCategorized: false
        showRecentApps: true
        showRecentDocs: false
        //showRecentContacts: false
        showPowerSession: false

        onFavoritesModelChanged: {
            if ("initForClient" in favoritesModel) {
                favoritesModel.initForClient("org.kde.plasma.kicker.favorites.instance-" + plasmoid.id)

                if (!Plasmoid.configuration.favoritesPortedToKAstats) {
                    favoritesModel.portOldFavorites(Plasmoid.configuration.favoriteApps);
                    Plasmoid.configuration.favoritesPortedToKAstats = true;
                }
            } else {
                favoritesModel.favorites = Plasmoid.configuration.favoriteApps;
            }
            favoritesModel.maxFavorites = pageSize;
        }

        onSystemFavoritesModelChanged: {
            systemFavoritesModel.enabled = false;
            systemFavoritesModel.favorites = Plasmoid.configuration.favoriteSystemActions;
            systemFavoritesModel.maxFavorites = 8;
        }

        Component.onCompleted: {
            if ("initForClient" in favoritesModel) {
                favoritesModel.initForClient("org.kde.plasma.kicker.favorites.instance-" + plasmoid.id)

                if (!Plasmoid.configuration.favoritesPortedToKAstats) {
                    favoritesModel.portOldFavorites(Plasmoid.configuration.favoriteApps);
                    Plasmoid.configuration.favoritesPortedToKAstats = true;
                }
            } else {
                favoritesModel.favorites = Plasmoid.configuration.favoriteApps;
            }

            favoritesModel.maxFavorites = pageSize;
            rootModel.refresh();
        }
    }

    Connections {
        target: globalFavorites

        function onFavoritesChanged() {
            Plasmoid.configuration.favoriteApps = target.favorites;
        }
    }

    Connections {
        target: systemFavorites

        function onFavoritesChanged() {
            Plasmoid.configuration.favoriteSystemActions = target.favorites;
        }
    }

    Connections {
        target: Plasmoid.configuration

        function onFavoriteAppsChanged() {
            globalFavorites.favorites = Plasmoid.configuration.favoriteApps;
        }

        function onFavoriteSystemActionsChanged() {
            systemFavorites.favorites = Plasmoid.configuration.favoriteSystemActions;
        }
    }

    Kicker.DragHelper {
        id: dragHelper
    }

    Kicker.ProcessRunner {
        id: processRunner
    }

	// SVGs
    KSvg.FrameSvgItem {
        id : highlightItemSvg
        visible: false
        imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
        prefix: "hover"
    }
    KSvg.FrameSvgItem {
        id : panelSvg
        visible: false
        imagePath: "widgets/panel-background"
    }
    KSvg.Svg {
        id: arrowsSvg
        imagePath: Qt.resolvedUrl("svgs/arrows.svgz")
        size: "16x16"
    }
    KSvg.Svg {
        id: separatorSvg
        imagePath: Qt.resolvedUrl("svgs/sidebarseparator.svg")
    }
    KSvg.Svg {
        id: lockScreenSvg
        imagePath: Qt.resolvedUrl("svgs/system-lock-screen.svg")
    }

    PlasmaComponents.Label {
        id: toolTipDelegate

        width: contentWidth
        height: contentHeight

        property Item toolTip

        text: (toolTip != null) ? toolTip.text : ""
    }

    function resetDragSource() {
        dragSource = null;
    }
    function enableHideOnWindowDeactivate() {
        kicker.hideOnWindowDeactivate = true;
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Edit Applications...")
            icon.name: "application-menu"
            onTriggered:  menu_executable.exec("kmenuedit");
        },
        PlasmaCore.Action {
            text: i18n("Task Manager")
            icon.name: "ksysguardd"
            onTriggered: menu_executable.exec("ksysguard");
        }
    ]

    Component.onCompleted: {
        if (Plasmoid.hasOwnProperty("activationTogglesExpanded")) {
            Plasmoid.activationTogglesExpanded = !kicker.isDash
        }

        windowSystem.focusIn.connect(enableHideOnWindowDeactivate);
        kicker.hideOnWindowDeactivate = true;

        rootModel.refreshed.connect(reset);

        dragHelper.dropped.connect(resetDragSource);
    }

}
