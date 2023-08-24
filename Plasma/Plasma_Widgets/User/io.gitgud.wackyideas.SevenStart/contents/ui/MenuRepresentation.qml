/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
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

import QtQuick 2.4
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons // kuser
import org.kde.plasma.private.shell 2.0

import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.quicklaunch 1.0

import org.kde.kirigami 2.13 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import org.kde.kwindowsystem 1.0


PlasmaCore.Dialog {
    id: root
    objectName: "popupWindow"
    location: "Floating" // To make the panel display all 4 borders, the panel will be positioned at a corner.
    flags: Qt.WindowStaysOnTopHint | Qt.Popup // Set to popup so that it is still considered a plasmoid popup, despite being a floating dialog window.
    hideOnWindowDeactivate: true
    
    property int iconSize: units.iconSizes.medium
    property int iconSizeSide: units.iconSizes.smallMedium
    property int cellWidth: units.gridUnit * 14 // Width for all standard menu items.
    property int cellWidthSide: units.gridUnit * 8 // Width for sidebar menu items.
    property int cellHeight: iconSize + units.smallSpacing + (Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                                    				   highlightItemSvg.margins.left + highlightItemSvg.margins.right)) - units.smallSpacing/2
    property bool searching: (searchField.text != "")
    property bool showingAllPrograms: false
    property bool firstTimePopup: false // To make sure the user icon is displayed properly.
    property bool compositingEnabled: kwindowsystem.compositingActive
    
    property int slideAnimationDuration: 105

	property color leftPanelBackgroundColor: "white"
	property color leftPanelBorderColor: "#44000000"
	property color leftPanelSeparatorColor: "#d6e5f5"
	property color searchPanelSeparatorColor: "#cddbea"
	property color searchPanelBackgroundColor: "#f3f7fb"

	property color searchFieldBackgroundColor: "white"
	property color searchFieldTextColor: "black"
	property color searchFieldPlaceholderColor: "#707070"

	property color shutdownTextColor: "#202020"

	// A bunch of references for easier access by child QML elements.
	property alias m_recents: recents
	property alias m_faves: faves
	property alias m_showAllButton: allButtonsArea
	property alias m_shutDownButton: shutdown
	property alias m_lockButton: lockma
	property alias m_searchField: searchField
	property alias m_delayTimer: delayTimer

    onVisibleChanged: {
        var pos = popupPosition(width, height); // Calculates the position of the floating dialog window.
        x = pos.x;
        y = pos.y;
        if (!visible) {
            reset();
        } else {
            requestActivate();
			searchField.forceActiveFocus();
        }
		resetRecents(); // Resets the recents model to prevent errors and crashes.
    }

    onHeightChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
		// It's at this point where everything actually gets properly initialized and we don't have to worry about
		// random unpredictable values, so we can safely allow the popup icon to show up.
		iconUser.x = sidePanel.x+sidePanel.width/2-units.iconSizes.huge/2+units.smallSpacing
		iconUser.y = root.y-units.iconSizes.huge/2
		firstTimePopup = true;
    }

    onWidthChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }

    onSearchingChanged: {
        if (!searching) {
			reset();
        }
    }
    
    function selectItem(itemIndex) {
		//Stub
    }

    function resetRecents() {
        recents.model = rootModel.modelForRow(0);
        recents.model.refresh();
        recents.currentIndex = -1;
    }
    function reset() {
        searchField.text = "";
		compositingIcon.iconSource = "";
		nonCompositingIcon.iconSource = "";
    }
	
	//The position calculated is always at a corner.
    function popupPosition(width, height) {
        var screenAvail = plasmoid.availableScreenRect;
        var screen = plasmoid.screenGeometry;

        var offset = 0;
        // Fall back to bottom-left of screen area when the applet is on the desktop or floating.
        var x = offset;
        var y = screen.height - height - offset;
        var horizMidPoint = screen.x + (screen.width / 2);
        var vertMidPoint = screen.y + (screen.height / 2);
        var appletTopLeft = kicker.mapToGlobal(0, 0);
        var appletBottomLeft = kicker.mapToGlobal(0, kicker.height);

        x = (appletTopLeft.x < horizMidPoint) ? screen.x : (screen.x + screen.width) - width;
        
        if (appletTopLeft.x < horizMidPoint) {
        	x += offset
        } else if (appletTopLeft.x + width > horizMidPoint){
        	x -= offset
        }

        if (plasmoid.location == PlasmaCore.Types.TopEdge) {
        	/*this is floatingAvatar.width*/
        	offset = 2;
        	y = screen.y + parent.height + panelSvg.margins.bottom + offset;
        } else {
          	y = screen.y + screen.height - parent.height - height - panelSvg.margins.top - offset;
        }

        return Qt.point(x, y);
    }

    FocusScope {
		id: mainFocusScope
		objectName: "MainFocusScope"
        Layout.minimumWidth:  root.cellWidth + root.cellWidthSide
        Layout.maximumWidth:  root.cellWidth + root.cellWidthSide

        Layout.minimumHeight: (cellHeight * plasmoid.configuration.numberRows) + searchField.height +  units.iconSizes.smallMedium
        Layout.maximumHeight: (cellHeight * plasmoid.configuration.numberRows) + searchField.height +  units.iconSizes.smallMedium
        
        focus: true
		clip: true

		KWindowSystem { id: kwindowsystem } // Used for detecting compositing changes.
        KCoreAddons.KUser {   id: kuser  }  // Used for getting the username and icon.
        Logic {   id: logic }				// Probably useful.
        
        /*
		 * The user icon is supposed to stick out of the start menu, so a separate dialog window
		 * is required to pull that effect off. Inspiration taken from SnoutBug's MMcK launcher,
		 * however with some minor adjustments and improvements.
		 *
		 * The flag Qt.X11BypassWindowManagerHint is used to prevent the dialog from animating its
		 * opacity when its visibility is changed directly, and Qt.Popup is used to ensure that it's
		 * above the parent dialog window.
		 *
		 * Setting the location to "Floating" means that we can use manual positioning for the dialog
		 * which is important as positioning a dialog like this is tricky at best and unpredictable
		 * at worst. Positioning of this dialog window can only be done reliably when:
		 *
		 * 1. The parent dialog window is visible, this ensures that the positioning of the window
		 * 	  is actually initialized and not simply declared.
		 * 2. The width and height of the parent dialog window are properly initialized as well.
		 *
		 * This is why the position of this window is determined on the onHeightChanged slot of the
		 * parent window, as by then both the position and size of the parent are well defined.
		 * It should be noted that the position values for any dialog window are gonna become
		 * properly initialized once the visibility of the window is enabled, at least from what
		 * I could figure out. Anything before that and the properties won't behave well.
		 *
		 * To comment on MMcK's implementation, this is likely why positioning of the floating
		 * avatar is so weird and unreliable. Using uninitialized values always leads to
		 * unpredictable behavior, which leads to positioning being all over the place.
		 *
		 * The firstTimePopup is used to make sure that the dialog window has its correct position
		 * values before it is made visible to the user.
		 */

        PlasmaCore.Dialog {
            id: iconUser
            flags: Qt.WindowStaysOnTopHint | Qt.Popup | Qt.X11BypassWindowManagerHint // To prevent the icon from animating its opacity when its visibility is changed
            //type: "Notification" // So that we don't have to rely on this
			location: "Floating"
			x: 0
			y: 0
			backgroundHints: PlasmaCore.Types.NoBackground // To prevent the dialog background SVG from being rendered, we want a fully transparent window.
			visualParent: root
			visible: root.visible && !searching && compositingEnabled
			opacity: iconUser.visible && firstTimePopup // To prevent even more NP-hard unpredictable behavior
			mainItem: FloatingIcon {
				id: compositingIcon
				visible: compositingEnabled
			}
        }

        Connections {
        target: plasmoid.configuration
            function onNumberRowsChanged() {
                recents.model = rootModel.modelForRow(0);
                recents.model.refresh();
            }
        }
        PlasmaCore.DataSource {
            id: pmEngine
            engine: "powermanagement"
            connectedSources: ["PowerDevil", "Sleep States"]
            function performOperation(what) {
                var service = serviceForSource("PowerDevil")
                var operation = service.operationDescription(what)
                service.startOperationCall(operation)
            }
        }

        PlasmaCore.DataSource {
            id: executable
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

        PlasmaComponents.Highlight {
            id: delegateHighlight
            visible: false
            z: -1 // otherwise it shows ontop of the icon/label and tints them slightly
        }

        PlasmaExtras.Heading {
            id: dummyHeading
            visible: false
            width: 0
            level: 5
        }

        TextMetrics {
            id: headingMetrics
            font: dummyHeading.font
        }

        ActionMenu {
            id: actionMenu
            onActionClicked: visualParent.actionTriggered(actionId, actionArgument)
            onClosed: {
                /*if (pageList.currentItem) {
                    pageList.currentItem.itemGrid.currentIndex = -1;
                }*/
            }
        }
        
		/*
		 * This rectangle acts as a background for the left panel of the start menu.
		 * The rectangle backgroundBorderLine is the border separating the search field
		 * and the rest of the panel, while the searchBackground rectangle is the background
		 * for the search field.
		 */
        Rectangle {
        	id: backgroundRect
        	anchors.top: faves.top
        	anchors.topMargin: -4
        	anchors.left: faves.left

        	width:  root.cellWidth
        	height: (root.cellHeight * plasmoid.configuration.numberRows)  + searchBackground.height + 2

        	color: leftPanelBackgroundColor
        	border.color: leftPanelBorderColor

        	border.width: 1
        	radius: 3

        	z: 5

        	Behavior on width {
        	    NumberAnimation { easing.type: Easing.Linear; duration: slideAnimationDuration }
        	}
        	Rectangle {
        		id: backgroundBorderLine

        		width: backgroundRect.width-2
        		height: 2

        		color: searchPanelSeparatorColor
        		radius: 3

        	 	anchors { 
        	   		top: searchBackground.top
        	   		topMargin: 1
        	   		left: parent.left
        	   		leftMargin: 1
        		}
        		z: 5
        	}
        	Rectangle {
                id: searchBackground

                width: root.cellWidth - 2
                height: searchField.height + units.smallSpacing * 4.5 - 2

                Behavior on width {
                	NumberAnimation { easing.type: Easing.Linear; duration: slideAnimationDuration }
                }

                color: searchPanelBackgroundColor
                radius: 3

                anchors { 
                    bottom: parent.bottom 
                    bottomMargin: units.smallSpacing-2
                    left: parent.left
                    leftMargin: 1
                }
            }
        }
		/* 
		 *  Displays bookmarked/favorite applications and is displayed at the top of the start menu.
		 *  The source code is taken directly from Kickoff without additional changes.
		 */
        FavoritesView {
            id: faves

			anchors {
            	left: parent.left
            	top: parent.top
            	topMargin: 6
            	leftMargin: 2
			}

            width: root.cellWidth
            height: plasmoid.configuration.showRecentsView ? 
					((root.cellHeight * (faves.getFavoritesCount() > 9 ? 9 : faves.getFavoritesCount())) - units.smallSpacing * 2) :
					(root.cellHeight * plasmoid.configuration.numberRows - units.smallSpacing*2 - allProgramsButton.height - allProgramsSeparator.height)

            visible: !showingAllPrograms && !searching
            z: 8
        }
		/* 
			This is the separator between favorite applications and recently used applications.
		*/
        Rectangle {
       		id: tabBarSeparator

			anchors {
				top: faves.bottom
				left: parent.left
				right: faves.right
				leftMargin: units.smallSpacing*4+2
				rightMargin: units.smallSpacing*4
			}
       		
       		height: 1
       		opacity: 1

       		color: leftPanelSeparatorColor
       		visible: plasmoid.configuration.showRecentsView && (!showingAllPrograms && !searching)
        
       		z: 6
        }
		/*
			This is the view showing recently used applications. As soon as a program is executed and has a start menu
			entry (appears in KMenuEdit), it will be pushed at the beginning of the list. The source code is forked from
			Kickoff, featuring very minor changes. 
		*/
        OftenUsedView {
            id: recents

			anchors {
				top: faves.bottom
				left: parent.left
				topMargin: units.smallSpacing*2
				bottomMargin: units.smallSpacing
				leftMargin: 3
			}

            width: root.cellWidth-2 
            height: (root.cellHeight * plasmoid.configuration.numberRows) - (root.cellHeight * (faves.getFavoritesCount() > 9 ? 9 : 
					faves.getFavoritesCount())) - units.smallSpacing*2 - allProgramsButton.height
					
            visible: plasmoid.configuration.showRecentsView && (!showingAllPrograms && !searching)

            z: 8
        }
		/*
			Another separator between the button to show all programs and recently used applications
		*/
        Rectangle {
       		id: allProgramsSeparator
			anchors {
				top: plasmoid.configuration.showRecentsView ? recents.bottom : faves.bottom
				left: parent.left
				leftMargin: units.smallSpacing*4+2
				rightMargin: units.smallSpacing*4
			}
       		Behavior on width {
       			NumberAnimation { easing.type: Easing.Linear; duration: slideAnimationDuration }
       		}

       		width: root.cellWidth - units.smallSpacing*8
       		height: 1
       		opacity: 1

       		color: leftPanelSeparatorColor
       		z: 6
        }
		/* 
		 * Shows/hides the main view of the panel. Clicking on it in the default state will show the
		 * application menu. If the start menu is showing the application menu element or is in a searching
		 * state, clicking on this button will bring the start menu back to its default state.
		 */
        MouseArea {
        	id: allButtonsArea
        	hoverEnabled: true

			anchors {
				top: plasmoid.configuration.showRecentsView ? recents.bottom : faves.bottom
				left: parent.left
				topMargin: units.smallSpacing-1
				leftMargin: units.smallSpacing +2 
				rightMargin: units.smallSpacing
			}
			KeyNavigation.tab: searchField;
			KeyNavigation.backtab: returnPreviousView();
			function returnPreviousView() {
				if(searching) {
					return searchView.itemGrid;
				} else if(showingAllPrograms) {
					return appsView;
				} else if(plasmoid.configuration.showRecentsView) {
					return recents;
				} else {
					return faves;
				}
			}
			Keys.onPressed: {
				if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
					click(true);
				} else if(event.key == Qt.Key_Up) {
					var view = returnPreviousView();
					view.focus = true;
					if(typeof view.currentIndex !== "undefined") {
						view.currentIndex = returnPreviousView().count-1;
					} else {
						// To implement for search view
					}
				} else if(event.key == Qt.Key_Down) {
					searchField.focus = true;
				}
			}
        	onClicked: {
				click(false);
        	}
			function click(focusAppsView) {
        	    if(searching)
        	    {
        	        searchField.text = "";
        	    }
        	    else if(showingAllPrograms)
        	    {
        	        showingAllPrograms = false;
        	        appsView.reset();
        	    }
        	    else if(!searching && !showingAllPrograms)
        	    {
        	        showingAllPrograms = true;
					if(focusAppsView) appsView.focus = true;
        	    }
			}
        	width: root.cellWidth - units.smallSpacing*2
        	height: 25

        	Behavior on width {
        	    NumberAnimation { easing.type: Easing.Linear; duration: slideAnimationDuration }
        	}

        	z: 8
        	PlasmaCore.FrameSvgItem {
        	    id: allProgramsButton
       			anchors.fill: parent
       			imagePath: Qt.resolvedUrl("svgs/menuitem.svg")
       			
       			prefix: "hover"
       			opacity: {
					if(allButtonsArea.containsMouse) return 1.0;
					else if(allButtonsArea.focus) return 0.5;
					else return 0;
				}
        	}
        	PlasmaCore.SvgItem {
           		id: arrowDirection
           		svg: arrowsSvg
           		elementId: (searching || showingAllPrograms) ? "left-arrow-black" : "right-arrow-black"

           		anchors.left: parent.left
           		anchors.verticalCenter: parent.verticalCenter
           		anchors.leftMargin: units.smallSpacing

           		width: 16
           		height: 16
        	}
            Text {
            	text: showingAllPrograms || searching ? "Back" : "All programs"
            	font.pixelSize: 12
            	anchors.left: arrowDirection.right
            	anchors.leftMargin: units.smallSpacing
            	anchors.verticalCenter: parent.verticalCenter
            }
        }
        /*
		 * Shows search results when the user types something into the textbox. This view will only
		 * appear if that textbox is not empty, and it will extend the left panel to the entire
		 * width of the plasmoid. The source code is forked from Kickoff and features aesthetic
		 * changes.
		 */
        SearchView {
            id: searchView

			anchors {
           		top: parent.top
           		left: parent.left
           		right: parent.right
           		bottom: allProgramsSeparator.top

           		topMargin: units.smallSpacing*2 -2
           		leftMargin: 2
           		rightMargin: 2
			}

            height: root.cellHeight * plasmoid.configuration.numberRows - units.smallSpacing*2 - allProgramsButton.height

            opacity: 0
            visible: opacity
            Behavior on opacity {
                NumberAnimation { easing.type: Easing.InOutQuart; duration: 150 }
            }

            z: 7
        }
		/*
		 * Shows a list of all applications organized by categories. The source code is forked from Kickoff
		 * and features mostly aesthetic changes.
		 */
        ApplicationsView {
            id: appsView

			anchors {
            	top: parent.top
            	left: parent.left
            	right: faves.right

            	topMargin: 2
            	leftMargin: 2
			}

            width: root.cellWidth
            height: (root.cellHeight * plasmoid.configuration.numberRows) - units.smallSpacing*2 - allProgramsButton.height

            opacity: 0
            visible: opacity

            function resetIndex() {
                appsView.listView.currentIndex = -1;
            }

            z: 1
        }
        
        states: [

            State {
                name: "AllPrograms"; when: !searching && showingAllPrograms
                PropertyChanges {
                    target: faves; opacity: 0;
                }
                PropertyChanges {
                    target: recents; opacity: 0;
                }
                PropertyChanges {
                    target: tabBarSeparator; opacity: 0;
                }
                PropertyChanges {
                    target: appsView; opacity: 1;
                }
                PropertyChanges { 
                    target: appsView; z: 7;
                }
                StateChangeScript {
                    script: appsView.resetIndex();
                }
            },

            State {
                name: "Searching"; when: searching
                PropertyChanges {
                    target: searchView; opacity: (backgroundRect.width === searchView.width ? 1 : 0);
                }
                PropertyChanges {
                    target: faves; opacity: 0;
                }
                PropertyChanges {
                    target: recents; opacity: 0;
                }
                PropertyChanges {
                    target: tabBarSeparator; opacity: 0;
                }
                PropertyChanges {
                    target: searchBackground; width: searchView.width - units.smallSpacing;
                }
                PropertyChanges {
                    target: backgroundRect; width: searchView.width;
                }
                PropertyChanges {
                    target: allProgramsButton; width: searchView.width - units.smallSpacing*2;
                }
                PropertyChanges {
                    target: allProgramsSeparator; width: searchView.width - units.smallSpacing*8;
                }
                PropertyChanges {
                    target: allButtonsArea; width: searchView.width - units.smallSpacing*2;
                }
                PropertyChanges {
                    target: sidePanel; opacity: 0;
                }
                PropertyChanges {
                    target: sidePanel; enabled: false
                }
            }
        ]
        transitions: [ 
       		Transition {
       		    PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutQuad; duration: 100 }
       		}
        ]

        PlasmaExtras.ActionTextField {
            id: searchField
            z: 7

            focus: true

            anchors{
                bottom: parent.bottom
                bottomMargin: units.smallSpacing * 2.5
                left: parent.left
                right: faves.right
                rightMargin: units.smallSpacing * 2
                leftMargin:  units.smallSpacing * 2 + 2
            }  

			background:	PlasmaCore.FrameSvgItem {
				anchors.fill:parent
				anchors.left: parent.left
				imagePath: Qt.resolvedUrl("svgs/lineedit.svg")
				prefix: "base"

                PlasmaCore.IconItem {
                    source: "gtk-search"
					smooth: true
					visible: !searching
					width: units.iconSizes.small;
					height: width
                    anchors {
						top: parent.top
						bottom: parent.bottom
						bottomMargin: 1
						right: parent.right
						rightMargin: units.smallSpacing
					}
                }
			}
			inputMethodHints: Qt.ImhNoPredictiveText
            width: root.cellWidth - units.smallSpacing * 4 - 2
            height: units.smallSpacing * 7 - units.smallSpacing + 1
			clearButtonShown: false
            placeholderText: i18n("Search programs and files")
            text: ""
			color: "black"
			verticalAlignment: TextInput.AlignBottom
			font.italic: searchField.text == "" ? true : false

            onTextChanged: {
                searchView.onQueryChanged();
            }

			KeyNavigation.tab: columnItems.visibleChildren[0];
            Keys.priority: Keys.AfterItem
            Keys.onPressed: {
				if (event.key == Qt.Key_Escape) {
					event.accepted = true;
					if (searching) {
						root.reset();
					} else if(showingAllPrograms) {
						showingAllPrograms = false;
						appsView.reset();
					} else {
						root.visible = false;
					}
					return;
				}
                if (event.key == Qt.Key_Tab) {
                    faves.forceActiveFocus();
                    event.accepted = true;
                    return;
                }
				event.accepted = false;
            }


            function backspace() {
                if (!root.visible) {
                    return;
                }
                focus = true;
                text = text.slice(0, -1);
            }

            function appendText(newText) {
                if (!root.visible) {
                    return;
                }
                focus = true;
                text = text + newText;
            }
        }

        Item{
            id: sidePanel
            z: 7
            anchors{
                left: faves.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom 
                bottomMargin: units.largeSpacing
                leftMargin: units.smallSpacing * 2
                rightMargin: units.smallSpacing
                topMargin: compositingEnabled ? units.iconSizes.huge / 2 + units.smallSpacing : 0
            }

			FloatingIcon {
				id: nonCompositingIcon
				visible: !compositingEnabled
			}
            FileDialog {
                id: folderDialog
                visible: false
                folder: shortcuts.pictures

                function getPath(val){
                    if(val === 1)
                        return shortcuts.home
                    else if (val === 2)
                        return shortcuts.documents
                    else if (val === 3)
                        return shortcuts.pictures
                    else if (val === 4)
                        return shortcuts.music
                    else if (val === 5)
                        return shortcuts.movies
                    else if (val === 6)
                        return shortcuts.home + "/Downloads"
                    else if (val === 7)
                        return "file:///." // Root
					else if (val === 8)
						return "remote:/"
                }
            }
			Timer {
				id: delayTimer
				interval: 250
				repeat: false
				onTriggered: {
					if(root.activeFocusItem.objectName === "SidePanelItemDelegate") {
						compositingIcon.iconSource = root.activeFocusItem.itemIcon;
						nonCompositingIcon.iconSource = root.activeFocusItem.itemIcon;
					} else {
						compositingIcon.iconSource = "";
						nonCompositingIcon.iconSource = "";
					}
				}
			}
			//Side panel items
            ColumnLayout {
                id: columnItems
                spacing: 3
                anchors.top: compositingEnabled ? parent.top : nonCompositingIcon.bottom
                anchors.topMargin: compositingEnabled ? units.smallSpacing : units.smallSpacing*2
                anchors.left: parent.left
                width: parent.width

				property int currentIndex: -1
                
				SidePanelItemDelegate {
					itemText: kuser.loginName
					itemIcon: "user-home"
					executableString: folderDialog.getPath(1)
					visible: plasmoid.configuration.showHomeSidepanel
				}
				SidePanelItemDelegate {
					itemText: "Documents"
					itemIcon: "folder-txt"
					executableString: folderDialog.getPath(2)
					visible: plasmoid.configuration.showDocumentsSidepanel
				}
				SidePanelItemDelegate {
					itemText: "Pictures"
					itemIcon: "folder-images"
					executableString: folderDialog.getPath(3)
					visible: plasmoid.configuration.showPicturesSidepanel
				}
				SidePanelItemDelegate {
					itemText: "Music"
					itemIcon: "folder-sound"
					executableString: folderDialog.getPath(4)
					visible: plasmoid.configuration.showMusicSidepanel
				}
				SidePanelItemDelegate {
					itemText: "Videos"
					itemIcon: "folder-video"
					executableString: folderDialog.getPath(5)
					visible: plasmoid.configuration.showVideosSidepanel
				}
				SidePanelItemDelegate {
					itemText: "Downloads"
					itemIcon: "folder-download"
					executableString: folderDialog.getPath(6)
					visible: plasmoid.configuration.showDownloadsSidepanel
				}
				SidePanelItemDelegate {
					itemText: "Computer"
					itemIcon: "computer"
					executableString: folderDialog.getPath(7)
					visible: plasmoid.configuration.showRootSidepanel
				}
				SidePanelItemDelegate {
					itemText: "Network"
					itemIcon: "network-workgroup"
					executableString: folderDialog.getPath(8)
					visible: plasmoid.configuration.showNetworkSidepanel
				}
				SidePanelItemDelegate {
					itemText: "System Settings"
					itemIcon: "preferences-system"
					executableString: "systemsettings5"
					executeProgram: true
					visible: plasmoid.configuration.showSettingsSidepanel
				}
				SidePanelItemDelegate {
					itemText: "Default Programs"
					itemIcon: "preferences-desktop-default-applications"
					executableString: "systemsettings5 kcm_componentchooser"
					executeProgram: true
					visible: plasmoid.configuration.showDefaultsSidepanel
				}

				//Used to space out the rest of the side panel, so that the shutdown button is at the bottom of the plasmoid
                Item {
                    Layout.fillHeight: true
                    visible: false
                }
                Item {
                    height: units.smallSpacing
                    visible: false
                }
            }
        }
        
        RowLayout {
			id: leaveButtons
			anchors{
				top: searchField.top
				topMargin: 1
				left: searchField.right
				leftMargin: units.smallSpacing*4
			}
			spacing: 0
			z: 7
			function findUpItem() {
				if(searching) {
					return allButtonsArea;
				} else {
					return columnItems.visibleChildren[columnItems.visibleChildren.length-1];
				}
			}
			ListDelegate {
				id: shutdown
				objectName: "ShutdownButton"
				width: units.smallSpacing * 17
				height: units.smallSpacing * 6 - 1
				size: iconSizeSide

				KeyNavigation.tab: lockScreenDelegate
				KeyNavigation.backtab: leaveButtons.findUpItem();

				Keys.onPressed: {
					if(event.key == Qt.Key_Return) {
						ma.clicked(null);
					} else if(event.key == Qt.Key_Right) {
						lockScreenDelegate.focus = true;
					} else if(event.key == Qt.Key_Left) {
						searchField.focus = true;
					} else if(event.key == Qt.Key_Up) {
						leaveButtons.findUpItem().focus = true;
					}
				}

				Text {
					text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")

					font.pixelSize: 12
					color: searching ? shutdownTextColor : PlasmaCore.Theme.textColor
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter
					z: 5
				}

				PlasmaCore.FrameSvgItem {
					id: shutdownButton

					anchors.fill:parent
					anchors.left: parent.left
					imagePath: Qt.resolvedUrl("svgs/startmenu-buttons.svg")

					prefix: {
						if(ma.containsPress) return "pressed";
						else if(ma.containsMouse || lockma.containsMouse || shutdown.focus) return "hover";
						else return "normal";
					}
				}

				MouseArea {
					id: ma

					enabled: !root.hoverDisabled
					acceptedButtons: Qt.LeftButton
					hoverEnabled: true
					anchors.fill: parent
					onExited: {
						shutdown.focus = false;
					}
					onClicked: {
						root.visible = false;
						pmEngine.performOperation("requestShutDown");
					}
				}
			}

			ListDelegate {
				id: lockScreenDelegate
				Layout.leftMargin: -1
				height: shutdown.height 
				KeyNavigation.tab: faves
				KeyNavigation.backtab: shutdown

				Keys.onPressed: {
					if(event.key == Qt.Key_Return) {
						lockma.clicked(null);
					} else if(event.key == Qt.Key_Left) {
						shutdown.focus = true;
					} else if(event.key == Qt.Key_Up) {
						leaveButtons.findUpItem().focus = true;
					}
				}
				PlasmaCore.FrameSvgItem {
					id: lockButton

					anchors.fill: parent;
					anchors.left: parent.left
					imagePath: Qt.resolvedUrl("svgs/startmenu-buttons.svg")

					prefix: {
						if(ma.containsPress || lockma.containsPress || lockScreenDelegate.focus) return "rtl-pressed";
						else if(ma.containsMouse || lockma.containsMouse || shutdown.focus) return "rtl-hover";
						else return "rtl-normal";
					}
				}

				MouseArea {
					id: lockma
					enabled: !root.hoverDisabled
					acceptedButtons: Qt.LeftButton
					onClicked: {
						root.visible = false;
						pmEngine.performOperation("lockScreen")
					}
					hoverEnabled: true
					anchors.fill: lockButton
				}
				PlasmaCore.SvgItem {
					id: lsSvg
					svg: lockScreenSvg
					anchors {
						fill: lockButton
						leftMargin: units.smallSpacing*2
						rightMargin: units.smallSpacing*2
						topMargin: units.smallSpacing*1.5
						bottomMargin: units.smallSpacing*1.5
					}
					elementId: searching ? "dark-lock" : "light-lock"
				}
				enabled: pmEngine.data["Sleep States"]["LockScreen"]
				size: iconSizeSide
			}
		}
		
		KeyNavigation.tab: faves;
		Keys.forwardTo: searchField

	}

	Component.onCompleted: {
		kicker.reset.connect(reset);
		reset();
		faves.listView.currentIndex = -1;
		
		var pos = popupPosition(width, height);
		x = pos.x;
		y = pos.y;
	}
}
