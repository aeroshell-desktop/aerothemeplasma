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

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
    id: configSidepanel

    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_showHomeSidepanel: showHomeSidepanel.checked
    property alias cfg_showDocumentsSidepanel: showDocumentsSidepanel.checked
    property alias cfg_showPicturesSidepanel: showPicturesSidepanel.checked
    property alias cfg_showMusicSidepanel: showMusicSidepanel.checked
    property alias cfg_showVideosSidepanel: showVideosSidepanel.checked
    property alias cfg_showDownloadsSidepanel: showDownloadsSidepanel.checked
    property alias cfg_showRootSidepanel: showRootSidepanel.checked
    property alias cfg_showNetworkSidepanel: showNetworkSidepanel.checked
    property alias cfg_showSettingsSidepanel: showSettingsSidepanel.checked
    property alias cfg_showDefaultsSidepanel: showDefaultsSidepanel.checked

    ColumnLayout {
        anchors.left: parent.left
		anchors.right: parent.right
        GroupBox {
            Layout.fillWidth: true

            title: i18n("Show sidebar items")

            flat: false
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
           		    id: showRootSidepanel
           		    text: i18n("Computer")
           		}
           		CheckBox {
           		    id: showNetworkSidepanel
           		    text: i18n("Network")
           		}
           		CheckBox {
           		    id: showSettingsSidepanel
           		    text: i18n("System Settings")
           		}
           		CheckBox {
           		    id: showDefaultsSidepanel
           		    text: i18n("Default Programs")
           		}
			}
        }
    }
}
