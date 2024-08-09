/*
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import QtQuick.Controls 2.15 as QQC2

/**
 * A list item that expands when clicked to show additional actions and/or a
 * custom view.
 * The list item has a standardized appearance, with an icon on the left badged
 * with an optional emblem, a title and optional subtitle to the right, an
 * optional default action button, and a button to expand and collapse the list
 * item.
 *
 * When expanded, the list item shows a list of contextually-appropriate actions
 * if contextualActions has been defined.
 * If customExpandedViewContent has been defined, it will show a custom view.
 * If both have been defined, it shows both, with the actions above the custom
 * view.
 *
 * It is not valid to define neither; define one or both.
 *
 * Note: this component should only be used for lists where the maximum number
 * of items is very low, ideally less than 10. For longer lists, consider using
 * a different paradigm.
 *
 *
 * Example usage:
 *
 * @code
 * import QtQuick
 * import QtQuick.Controls as QQC2
 * import org.kde.kirigami as Kirigami
 * import org.kde.plasma.extras as PlasmaExtras
 * import org.kde.plasma.components as PlasmaComponents
 *
 * PlasmaComponents.ScrollView {
 *     ListView {
 *         anchors.fill: parent
 *         focus: true
 *         currentIndex: -1
 *         clip: true
 *         model: myModel
 *         highlight: PlasmaExtras.Highlight {}
 *         highlightMoveDuration: Kirigami.Units.shortDuration
 *         highlightResizeDuration: Kirigami.Units.shortDuration
 *         delegate: PlasmaExtras.ExpandableListItem {
 *             icon: model.iconName
 *             iconEmblem: model.isPaused ? "emblem-pause" : ""
 *             title: model.name
 *             subtitle: model.subtitle
 *             isDefault: model.isDefault
 *             defaultActionButtonAction: QQC2.Action {
 *                 icon.name: model.isPaused ? "media-playback-start" : "media-playback-pause"
 *                 text: model.isPaused ? "Resume" : "Pause"
 *                 onTriggered: {
 *                     if (model.isPaused) {
 *                         model.resume(model.name);
 *                     } else {
 *                         model.pause(model.name);
 *                     }
 *                 }
 *             }
 *             contextualActions: [
 *                 QQC2.Action {
 *                     icon.name: "configure"
 *                     text: "Configure…"
 *                     onTriggered: model.configure(model.name);
 *                 }
 *             ]
 *         }
 *     }
 * }
 * @endcode
 */
Item {
    id: listItem

    property alias mouseArea: listMouseArea
    /**
     * icon: var
     * The name of the icon used in the list item.
     * @sa Kirigami.Icon::source
     *
     * Required.
     */
    property alias icon: listItemIcon.source

    /**
     * iconEmblem: var
     * The name of the emblem to badge the icon with.
     * @sa Kirigami.Icon::source
     *
     * Optional, defaults to nothing, in which case there is no emblem.
     */
    property alias iconEmblem: iconEmblem.source

    /*
     * title: string
     * The name or title for this list item.
     *
     * Optional; if not defined, there will be no title and the subtitle will be
     * vertically centered in the list item.
     */
    property alias title: listItemTitle.text

    /*
     * subtitle: string
     * The subtitle for this list item, displayed under the title.
     *
     * Optional; if not defined, there will be no subtitle and the title will be
     * vertically centered in the list item.
     */
    property alias subtitle: listItemSubtitle.text

    /*
     * subtitleCanWrap: bool
     * Whether to allow the subtitle to become a multi-line string instead of
     * eliding when the text is very long.
     *
     * Optional, defaults to false.
     */
    property bool subtitleCanWrap: false

    /*
     * subtitleColor: color
     * The color of the subtitle text
     *
     * Optional; if not defined, the subtitle will use the default text color
     */
    property alias subtitleColor: listItemSubtitle.color

    /*
     * allowStyledText: bool
     * Whether to allow the title, subtitle, and tooltip to contain styled text.
     * For performance and security reasons, keep this off unless needed.
     *
     * Optional, defaults to false.
     */
    property bool allowStyledText: false

    /*
     * defaultActionButtonAction: T.Action
     * The Action to execute when the default button is clicked.
     *
     * Optional; if not defined, no default action button will be displayed.
     */
    property alias defaultActionButtonAction: defaultActionButton.action

    /*
     * defaultActionButtonVisible: bool
     * When/whether to show to default action button. Useful for making it
     * conditionally appear or disappear.
     *
     * Optional; defaults to true
     */
    property bool defaultActionButtonVisible: true

    /*
     * showDefaultActionButtonWhenBusy : bool
     * Whether to continue showing the default action button while the busy
     * indicator is visible. Useful for cancelable actions that could take a few
     * seconds and show a busy indicator while processing.
     *
     * Optional; defaults to false
     */
    property bool showDefaultActionButtonWhenBusy: false

    /*
     * contextualActions: list<T.Action>
     * A list of standard QQC2.Action objects that describes additional actions
     * that can be performed on this list item. For example:
     *
     * @code
     * contextualActions: [
     *     Action {
     *         text: "Do something"
     *         icon.name: "document-edit"
     *         onTriggered: doSomething()
     *     },
     *     Action {
     *         text: "Do something else"
     *         icon.name: "draw-polygon"
     *         onTriggered: doSomethingElse()
     *     },
     *     Action {
     *         text: "Do something completely different"
     *         icon.name: "games-highscores"
     *         onTriggered: doSomethingCompletelyDifferent()
     *     }
     * ]
     * @endcode
     *
     * Optional; if not defined, no contextual actions will be displayed and
     * you should instead assign a custom view to customExpandedViewContent,
     * which will be shown when the user expands the list item.
     */
    property list<T.Action> contextualActions

    readonly property list<T.Action> __enabledContextualActions: contextualActions.filter(action => action?.enabled ?? false)

    /*
     * A custom view to display when the user expands the list item.
     *
     * This component must define width and height properties. Width should be
     * equal to the width of the list item itself, while height: will depend
     * on the component itself.
     *
     * Optional; if not defined, no custom view actions will be displayed and
     * you should instead define contextualActions, and then actions will
     * be shown when the user expands the list item.
     */
    property Component customExpandedViewContent

    /*
     * The actual instance of the custom view content, if loaded.
     * @since 5.72
     */
    property alias customExpandedViewContentItem: customContentLoader.item

    /*
     * isBusy: bool
     * Whether or not to display a busy indicator on the list item. Set to true
     * while the item should be non-interactive because things are processing.
     *
     * Optional; defaults to false.
     */
    property bool isBusy: false

    /*
     * isDefault: bool
     * Whether or not this list item should be considered the "default" or
     * "Current" item in the list. When set to true, and the list itself has
     * more than one item in it, the list item's title and subtitle will be
     * drawn in a bold style.
     *
     * Optional; defaults to false.
     */
    property bool isDefault: false

    /**
     * expanded: bool
     * Whether the expanded view is visible.
     *
     * @since 5.98
     */
    readonly property alias expanded: expandedView.expanded

    /*
     * hasExpandableContent: bool (read-only)
     * Whether or not this expandable list item is actually expandable. True if
     * this item has either a custom view or else at least one enabled action.
     * Otherwise false.
     */
    readonly property bool hasExpandableContent: customExpandedViewContent !== null || __enabledContextualActions.length > 0

    /*
     * expand()
     * Show the expanded view, growing the list item to its taller size.
     */
    function expand() {
        if (!listItem.hasExpandableContent) {
            return;
        }
        expandedView.expanded = true
        listItem.itemExpanded()
    }

    /*
     * collapse()
     * Hide the expanded view and collapse the list item to its shorter size.
     */
    function collapse() {
        if (!listItem.hasExpandableContent) {
            return;
        }
        expandedView.expanded = false
        listItem.itemCollapsed()
    }

    /*
     * toggleExpanded()
     * Expand or collapse the list item depending on its current state.
     */
    function toggleExpanded() {
        if (!listItem.hasExpandableContent) {
            return;
        }
        expandedView.expanded ? listItem.collapse() : listItem.expand()
    }

    signal itemExpanded()
    signal itemCollapsed()

    width: parent ? parent.width : undefined // Assume that we will be used as a delegate, not placed in a layout
    height: mainLayout.height

   /* Behavior on height {
        enabled: false //listItem.ListView.view.highlightResizeDuration > 0
        SmoothedAnimation { // to match the highlight
            id: heightAnimation
            duration: listItem.ListView.view.highlightResizeDuration || -1
            velocity: listItem.ListView.view.highlightResizeVelocity
            easing.type: Easing.InOutCubic
        }
    }
    clip: heightAnimation.running || expandedItemOpacityFade.running*/

    onEnabledChanged: if (!listItem.enabled) { collapse() }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (defaultActionButtonAction) {
                defaultActionButtonAction.trigger()
            } else {
                toggleExpanded();
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            if (expandedView.expanded) {
                collapse();
                event.accepted = true;
            }
            // if not active, we'll let the Escape event pass through, so it can close the applet, etc.
        } else if (event.key === Qt.Key_Space) {
            toggleExpanded();
            event.accepted = true;
        }
    }

    /*KeyNavigation.tab: defaultActionButtonVisible ? defaultActionButton : expandToggleButton
    KeyNavigation.right: defaultActionButtonVisible ? defaultActionButton : expandToggleButton
    KeyNavigation.down: expandToggleButton.KeyNavigation.down*/
    Keys.onDownPressed: event => {
        if (!actionsListLoader.item || ListView.view.currentIndex < 0) {
            ListView.view.incrementCurrentIndex();
            ListView.view.currentItem.forceActiveFocus(Qt.TabFocusReason);
            event.accepted = true;
            return;
        }
        event.accepted = false; // Forward to KeyNavigation.down
    }
    Keys.onUpPressed: event => {
        if (ListView.view.currentIndex === 0) {
            event.accepted = false;
        } else {
            ListView.view.decrementCurrentIndex();
            ListView.view.currentItem.forceActiveFocus(Qt.BacktabFocusReason);
        }
    }

    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: subtitle

    // Handle left clicks and taps; don't accept stylus input or else it steals
    // events from the buttons on the list item
    TapHandler {
        enabled: listItem.hasExpandableContent

        acceptedPointerTypes: PointerDevice.Generic | PointerDevice.Finger

        onSingleTapped: {
            listItem.ListView.view.currentIndex = index
            listItem.toggleExpanded()
        }
    }

    MouseArea {
        id: listMouseArea
        anchors.fill: parent

        // This MouseArea used to intercept RightButton to open a context
        // menu, but that has been removed, and now it's only used for hover
        acceptedButtons: Qt.RightButton
        hoverEnabled: true

        // using onPositionChanged instead of onContainsMouseChanged so this doesn't trigger when the list reflows
        onPositionChanged: {
            // don't change currentIndex if it would make listview scroll
            // see https://bugs.kde.org/show_bug.cgi?id=387797
            // this is a workaround till https://bugreports.qt.io/browse/QTBUG-114574 gets fixed
            // which would allow a proper solution
            if (parent.y - listItem.ListView.view.contentY >= 0 && parent.y - listItem.ListView.view.contentY + parent.height  + 1 /* border */ < listItem.ListView.view.height) {
                listItem.ListView.view.currentIndex = (containsMouse ? index : -1)
            }
        }
        onExited: if (listItem.ListView.view.currentIndex === index) {
            listItem.ListView.view.currentIndex = -1;
        }

        ColumnLayout {
            id: mainLayout

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 0

            RowLayout {
                id: mainRowLayout

                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
                // Otherwise it becomes taller when the button appears
                Layout.minimumHeight: defaultActionButton.height

                // Icon and optional emblem
                Kirigami.Icon {
                    id: listItemIcon

                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium

                    Kirigami.Icon {
                        id: iconEmblem

                        visible: valid

                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                    }
                }

                // Title and subtitle
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    spacing: 0

                    Kirigami.Heading {
                        id: listItemTitle

                        visible: text.length > 0

                        Layout.fillWidth: true

                        level: 5

                        textFormat: listItem.allowStyledText ? Text.StyledText : Text.PlainText
                        elide: Text.ElideRight
                        maximumLineCount: 1

                        // Even if it's the default item, only make it bold when
                        // there's more than one item in the list, or else there's
                        // only one item and it's bold, which is a little bit weird
                        font.weight: listItem.isDefault && listItem.ListView.view.count > 1
                                            ? Font.Bold
                                            : Font.Normal
                    }

                    PlasmaComponents3.Label {
                        id: listItemSubtitle

                        visible: text.length > 0
                        font: Kirigami.Theme.smallFont

                        // Otherwise colored text can be hard to see
                        opacity: color === Kirigami.Theme.textColor ? 0.7 : 1.0

                        Layout.fillWidth: true

                        textFormat: listItem.allowStyledText ? Text.StyledText : Text.PlainText
                        elide: Text.ElideRight
                        maximumLineCount: subtitleCanWrap ? 9999 : 1
                        wrapMode: subtitleCanWrap ? Text.WordWrap : Text.NoWrap
                    }
                }

                // Busy indicator
                PlasmaComponents3.BusyIndicator {
                    id: busyIndicator

                    visible: listItem.isBusy

                    // Otherwise it makes the list item taller when it appears
                    Layout.maximumHeight: defaultActionButton.implicitHeight
                    Layout.maximumWidth: Layout.maximumHeight
                }

                // Default action button
                PlasmaComponents3.ToolButton {
                    id: defaultActionButton

                    visible: defaultActionButtonAction
                            && listItem.defaultActionButtonVisible
                            && (!busyIndicator.visible || listItem.showDefaultActionButtonWhenBusy)

                    /*KeyNavigation.tab: expandToggleButton
                    KeyNavigation.right: expandToggleButton
                    KeyNavigation.down: expandToggleButton.KeyNavigation.down*/
                    Keys.onUpPressed: event => listItem.Keys.upPressed(event)

                    Accessible.name: action !== null ? action.text : ""
                }

                // Expand/collapse button
                /*PlasmaComponents3.ToolButton {
                    id: expandToggleButton
                    visible: listItem.hasExpandableContent

                    display: PlasmaComponents3.AbstractButton.IconOnly
                    text: expandedView.expanded ? i18ndc("libplasma6", "@action:button", "Collapse") : i18ndc("libplasma6", "@action:button", "Expand")
                    icon.name: expandedView.expanded ? "collapse" : "expand"

                    Keys.onUpPressed: event => listItem.Keys.upPressed(event)

                    onClicked: listItem.toggleExpanded()

                    PlasmaComponents3.ToolTip {
                        text: parent.text
                    }
                }*/
            }


            // Expanded view with actions and/or custom content in it
            Item {
                id: expandedView
                property bool expanded: false

                Layout.preferredHeight: expanded ?
                    expandedViewLayout.implicitHeight + expandedViewLayout.anchors.topMargin + expandedViewLayout.anchors.bottomMargin : 0
                Layout.fillWidth: true

                opacity: expanded ? 1 : 0
               /* Behavior on opacity {
                    enabled: false //listItem.ListView.view.highlightResizeDuration > 0
                    SmoothedAnimation { // to match the highlight
                        id: expandedItemOpacityFade
                        duration: listItem.ListView.view.highlightResizeDuration || -1
                        // velocity is divided by the default speed, as we're in the range 0-1
                        velocity: listItem.ListView.view.highlightResizeVelocity / 200
                        easing.type: Easing.InOutCubic
                    }
                }*/
                visible: opacity > 0

                ColumnLayout {
                    id: expandedViewLayout
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing

                    spacing: Kirigami.Units.smallSpacing

                    // Actions list
                    Loader {
                        id: actionsListLoader

                        visible: status === Loader.Ready
                        active: expandedView.visible && listItem.__enabledContextualActions.length > 0

                        Layout.fillWidth: true

                        sourceComponent: Item {
                            height: buttonFlow.implicitHeight /2
                            width: actionsListLoader.width // basically, parent.width but null-proof

                            Flow {
                                id: buttonFlow
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                //anchors.leftMargin: Kirigami.Units.iconSizes.small
                                //anchors.rightMargin: Kirigami.Units.iconSizes.small

                                spacing: Kirigami.Units.smallSpacing
                                layoutDirection: Qt.RightToLeft

                                Repeater {
                                    id: actionRepeater

                                    model: listItem.__enabledContextualActions

                                    delegate: QQC2.Button {
                                        id: buttonDelegate
                                        required property int index
                                        required property T.Action modelData

                                        //Layout.fillWidth: true
                                        //Layout.alignment: Qt.AlignRight

                                        text: modelData.text
                                        icon.name: modelData.icon.name

                                        //KeyNavigation.up: index > 0 ? actionRepeater.itemAt(index - 1) : expandToggleButton
                                        Keys.onDownPressed: event => {
                                            if (index === actionRepeater.count - 1) {
                                                event.accepted = true;
                                                listItem.ListView.view.incrementCurrentIndex();
                                                listItem.ListView.view.currentItem.forceActiveFocus(Qt.TabFocusReason);
                                            } else {
                                                event.accepted = false; // Forward to KeyNavigation.down
                                            }
                                        }

                                        onClicked: {
                                            modelData.trigger()
                                            collapse()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Separator between the two items when both are shown
                    KSvg.SvgItem {
                        Layout.fillWidth: true
                        imagePath: "widgets/line"
                        elementId: "horizontal-line"
                        visible: actionsListLoader.visible && customContentLoader.visible
                    }

                    // Custom content item, if any
                    Loader {
                        id: customContentLoader
                        visible: status === Loader.Ready

                        Layout.fillWidth: true

                        active: expandedView.visible
                        asynchronous: true
                        sourceComponent: listItem.customExpandedViewContent
                    }
                }
            }
        }
    }
}
