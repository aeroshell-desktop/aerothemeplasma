/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

import org.kde.kcmutils as KCM

import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.3 as Kirigami

KCM.SimpleKCM {
    id: configSidepanel

    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_showHomeSidepanel: showHomeSidepanel.checked
    property alias cfg_showDocumentsSidepanel: showDocumentsSidepanel.checked
    property alias cfg_showPicturesSidepanel: showPicturesSidepanel.checked
    property alias cfg_showMusicSidepanel: showMusicSidepanel.checked
    property alias cfg_showVideosSidepanel: showVideosSidepanel.checked
    property alias cfg_showDownloadsSidepanel: showDownloadsSidepanel.checked
    property alias cfg_showGamesSidepanel: showGamesSidepanel.checked
    property alias cfg_showRecentItemsSidepanel: showRecentItemsSidepanel.checked
    property alias cfg_showRootSidepanel: showRootSidepanel.checked
    property alias cfg_showNetworkSidepanel: showNetworkSidepanel.checked
    property alias cfg_showSettingsSidepanel: showSettingsSidepanel.checked
    property alias cfg_showDevicesSidepanel: showDevicesSidepanel.checked
    property alias cfg_showDefaultsSidepanel: showDefaultsSidepanel.checked
    property alias cfg_showHelpSidepanel: showHelpSidepanel.checked
    property alias cfg_showRunSidepanel: showRunSidepanel.checked

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Kirigami.Units.gridUnit*4
        anchors.rightMargin: Kirigami.Units.gridUnit*4
        GroupBox {
			id: gbox
            Layout.fillWidth: true

            background: Rectangle {
				color: "white"
				border.color: "#bababe"
				y: gbox.topPadding - gbox.bottomPadding
				height: parent.height - gbox.topPadding + gbox.bottomPadding

			}
			label: Label {
				x: gbox.leftPadding
				width: gbox.availableWidth
				text: gbox.title
				elide: Text.ElideRight
			}

            title: i18n("Show side panel items")

			ColumnLayout {
           		CheckBox {
           		    id: showHomeSidepanel
           		    text: i18n("Home directory")
           		}
           		CheckBox {
           		    id: showDocumentsSidepanel
           		    text: i18n("Documents")
           		}
           		CheckBox {
           		    id: showPicturesSidepanel
           		    text: i18n("Pictures")
           		}
           		CheckBox {
           		    id: showMusicSidepanel
           		    text: i18n("Music")
           		}
           		CheckBox {
           		    id: showVideosSidepanel
           		    text: i18n("Videos")
           		}
           		CheckBox {
           		    id: showDownloadsSidepanel
           		    text: i18n("Downloads")
           		}
           		CheckBox {
           		    id: showGamesSidepanel
           		    text: i18n("Games")
           		}
           		CheckBox {
           		    id: showRecentItemsSidepanel
           		    text: i18n("Recent Items")
           		}
           		CheckBox {
           		    id: showRootSidepanel
           		    text: i18n("Computer")
           		}
           		CheckBox {
           		    id: showNetworkSidepanel
           		    text: i18n("Network")
           		}
           		CheckBox {
           		    id: showSettingsSidepanel
           		    text: i18n("Control Panel")
           		}
           		CheckBox {
           		    id: showDevicesSidepanel
           		    text: i18n("Devices and Printers")
           		}
           		CheckBox {
           		    id: showDefaultsSidepanel
           		    text: i18n("Default Programs")
           		}
           		CheckBox {
           		    id: showHelpSidepanel
           		    text: i18n("Help and Support")
           		}
           		CheckBox {
					id: showRunSidepanel
					text: i18n("Run...")
				}
			}
        }
    }
    Component.onCompleted: {
		if(Plasmoid.configuration.stickOutOrb) Plasmoid.setTransparentWindow();
    }
	Component.onDestruction: {
		if(Plasmoid.configuration.stickOutOrb) Plasmoid.setTransparentWindow();
    }
}
