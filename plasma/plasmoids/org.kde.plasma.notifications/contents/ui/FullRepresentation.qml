/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.10
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QQC2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami

import org.kde.coreaddons 1.0 as KCoreAddons

import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.private.notifications as Notifications

import "global"

PlasmaExtras.Representation {
    // TODO these should be configurable in the future
    readonly property int dndMorningHour: 6
    readonly property int dndEveningHour: 20
    readonly property var appletInterface: root

    Layout.minimumWidth: Kirigami.Units.iconSizes.small * 12
    Layout.minimumHeight: Kirigami.Units.iconSizes.small * 12
    Layout.preferredWidth: Kirigami.Units.iconSizes.small * 18
    Layout.preferredHeight: Kirigami.Units.iconSizes.small * 24
    Layout.maximumWidth: Kirigami.Units.iconSizes.small * 80
    Layout.maximumHeight: Kirigami.Units.iconSizes.small * 40

    Layout.fillHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    collapseMarginsHint: true

    Keys.onDownPressed: dndCheck.forceActiveFocus(Qt.TabFocusReason);

    Connections {
        target: root
        function onExpandedChanged() {
            if (root.expanded) {
                list.positionViewAtBeginning();
                list.currentIndex = -1;
            }
        }
    }

    header: PlasmaExtras.PlasmoidHeading {
        ColumnLayout {
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
            }
            id: header
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                QQC2.CheckBox {
                    id: dndCheck
                    enabled: NotificationManager.Server.valid
                    text: i18n("Do not disturb")
                    icon.name: "notifications-disabled"
                    checkable: true
                    checked: Globals.inhibited

                    KeyNavigation.down: list
                    KeyNavigation.tab: list

                    // Let the menu open on press
                    onPressed: {
                        if (!Globals.inhibited) {
                            dndMenu.date = new Date();
                            // shows ontop of CheckBox to hide the fact that it's unchecked
                            // until you actually select something :)
                            dndMenu.open(0, 0);
                        }
                    }
                    // but disable only on click
                    onClicked: {
                        if (Globals.inhibited) {
                            Globals.revokeInhibitions();
                        }
                    }


                    PlasmaExtras.ModelContextMenu {
                        id: dndMenu
                        property date date
                        visualParent: dndCheck

                        onClicked: {
                            notificationSettings.notificationsInhibitedUntil = model.date;
                            notificationSettings.save();
                        }

                        model: {
                            var model = [];

                            // For 1 hour
                            var d = dndMenu.date;
                            d.setHours(d.getHours() + 1);
                            d.setSeconds(0);
                            model.push({date: d, text: i18n("For 1 hour")});

                            d = dndMenu.date;
                            d.setHours(d.getHours() + 4);
                            d.setSeconds(0);
                            model.push({date: d, text: i18n("For 4 hours")});

                            // Until this evening
                            if (dndMenu.date.getHours() < dndEveningHour) {
                                d = dndMenu.date;
                                // TODO make the user's preferred time schedule configurable
                                d.setHours(dndEveningHour);
                                d.setMinutes(0);
                                d.setSeconds(0);
                                model.push({date: d, text: i18n("Until this evening")});
                            }

                            // Until next morning
                            if (dndMenu.date.getHours() > dndMorningHour) {
                                d = dndMenu.date;
                                d.setDate(d.getDate() + 1);
                                d.setHours(dndMorningHour);
                                d.setMinutes(0);
                                d.setSeconds(0);
                                model.push({date: d, text: i18n("Until tomorrow morning")});
                            }

                            // Until Monday
                            // show Friday and Saturday, Sunday is "0" but for that you can use "until tomorrow morning"
                            if (dndMenu.date.getDay() >= 5) {
                                d = dndMenu.date;
                                d.setHours(dndMorningHour);
                                // wraps around if necessary
                                d.setDate(d.getDate() + (7 - d.getDay() + 1));
                                d.setMinutes(0);
                                d.setSeconds(0);
                                model.push({date: d, text: i18n("Until Monday")});
                            }

                            // Until "turned off"
                            d = dndMenu.date;
                            // Just set it to one year in the future so we don't need yet another "do not disturb enabled" property
                            d.setFullYear(d.getFullYear() + 1);
                            model.push({date: d, text: i18n("Until manually disabled")});

                            return model;
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                PlasmaComponents3.ToolButton {
                    visible: !(Plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentDrawsPlasmoidHeading)

                    Accessible.name: root.clearHistoryAction.text
                    icon.name: "edit-clear-history"
                    enabled: root.clearHistoryAction.visible
                    onClicked: root.clearHistoryAction.trigger()

                    PlasmaComponents3.ToolTip {
                        text: parent.Accessible.name
                    }
                }
            }

            PlasmaExtras.DescriptiveLabel {
                Layout.leftMargin: dndCheck.mirrored ? 0 : dndCheck.indicator.width + 2 * dndCheck.spacing + Kirigami.Units.iconSizes.smallMedium
                Layout.rightMargin: dndCheck.mirrored ? dndCheck.indicator.width + 2 * dndCheck.spacing + Kirigami.Units.iconSizes.smallMedium : 0
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                text: {
                    if (!Globals.inhibited) {
                        return "";
                    }

                    var inhibitedUntil = notificationSettings.notificationsInhibitedUntil;
                    var inhibitedUntilTime = inhibitedUntil.getTime();
                    var inhibitedByApp = notificationSettings.notificationsInhibitedByApplication;
                    var inhibitedByMirroredScreens = notificationSettings.inhibitNotificationsWhenScreensMirrored
                                                        && notificationSettings.screensMirrored;
                    var dateNow = Date.now();

                    var sections = [];

                    // Show until time if valid but not if too far int he future
                    if (!isNaN(inhibitedUntilTime) && inhibitedUntilTime - dateNow > 0 &&
                        inhibitedUntilTime - dateNow < 100 * 24 * 60 * 60 * 1000 /* 1 year*/) {
                        const endTime = KCoreAddons.Format.formatRelativeDateTime(inhibitedUntil, Locale.ShortFormat);
                        const lowercaseEndTime = endTime[0] + endTime.slice(1);
                        sections.push(i18nc("Do not disturb until date", "Automatically ends: %1", lowercaseEndTime));
                    }

                    if (inhibitedByApp) {
                        var inhibitionAppNames = notificationSettings.notificationInhibitionApplications;
                        var inhibitionAppReasons = notificationSettings.notificationInhibitionReasons;

                        for (var i = 0, length = inhibitionAppNames.length; i < length; ++i) {
                            var name = inhibitionAppNames[i];
                            var reason = inhibitionAppReasons[i];

                            if (reason) {
                                sections.push(i18nc("Do not disturb until app has finished (reason)", "While %1 is active (%2)", name, reason));
                            } else {
                                sections.push(i18nc("Do not disturb until app has finished", "While %1 is active", name));
                            }
                        }
                    }

                    if (inhibitedByMirroredScreens) {
                        sections.push(i18nc("Do not disturb because external mirrored screens connected", "Screens are mirrored"))
                    }

                    return sections.join(" · ");
                }
                visible: text !== ""
            }
        }
    }

    Notifications.WheelForwarder {
        id: wheelForwarder
        toItem: scrollView.contentItem
    }

    PlasmaComponents3.ScrollView {
        id: scrollView
        anchors.fill: parent
        background: null
        focus: true

        contentItem: ListView {
            id: list
            width: scrollView.availableWidth
            focus: true
            model: root.expanded ? historyModel : null
            currentIndex: -1

            topMargin: Kirigami.Units.largeSpacing
            bottomMargin: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            readonly property alias wheelForwarder: wheelForwarder

            KeyNavigation.up: dndCheck

            Keys.onDeletePressed: {
                var idx = historyModel.index(currentIndex, 0);
                if (historyModel.data(idx, NotificationManager.Notifications.ClosableRole)) {
                    historyModel.close(idx);
                    // TODO would be nice to stay inside the current group when deleting an item
                }
            }
            Keys.onEnterPressed: event => { Keys.returnPressed(event) }
            Keys.onReturnPressed: {
                // Trigger default action, if any
                var idx = historyModel.index(currentIndex, 0);
                if (historyModel.data(idx, NotificationManager.Notifications.HasDefaultActionRole)) {
                    historyModel.invokeDefaultAction(idx);
                    return;
                }

                // Trigger thumbnail URL if there's one
                var urls = historyModel.data(idx, NotificationManager.Notifications.UrlsRole);
                if (urls && urls.length === 1) {
                    Qt.openUrlExternally(urls[0]);
                    return;
                }

                // TODO for finished jobs trigger "Open" or "Open Containing Folder" action
            }
            Keys.onLeftPressed: setGroupExpanded(currentIndex, LayoutMirroring.enabled)
            Keys.onRightPressed: setGroupExpanded(currentIndex, !LayoutMirroring.enabled)

            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Home:
                    currentIndex = 0;
                    break;
                case Qt.Key_End:
                    currentIndex = count - 1;
                    break;
                }
            }

            function setGroupExpanded(row, expanded) {
                var rowIdx = historyModel.index(row, 0);
                var persistentRowIdx = historyModel.makePersistentModelIndex(rowIdx);
                var persistentGroupIdx = historyModel.makePersistentModelIndex(historyModel.groupIndex(rowIdx));

                historyModel.setData(rowIdx, expanded, NotificationManager.Notifications.IsGroupExpandedRole);

                // If the current item went away when the group collapsed, scroll to the group heading
                if (!persistentRowIdx || !persistentRowIdx.valid) {
                    if (persistentGroupIdx && persistentGroupIdx.valid) {
                        list.positionViewAtIndex(persistentGroupIdx.row, ListView.Contain);
                        // When closed via keyboard, also set a sane current index
                        if (list.currentIndex > -1) {
                            list.currentIndex = persistentGroupIdx.row;
                        }
                    }
                }
            }

            highlightMoveDuration: 0
            highlightResizeDuration: 0
            // Not using PlasmaExtras.Highlight as this is only for indicating keyboard focus
            highlight: KSvg.FrameSvgItem {
                imagePath: "widgets/listitem"
                prefix: "pressed"
            }

            // This is so the delegates can detect the change in "isInGroup" and show a separator
            section {
                property: "isInGroup"
                criteria: ViewSection.FullString
            }

            delegate: DraggableDelegate {
                id: delegate
                width: ListView.view.width
                contentItem: delegateLoader

                // NOTE: The following animations replace the Transitions in the ListView
                // because they don't work when the items change size during the animation
                // (showing/hiding the show more/show less button) in that case they will
                // animate to a wrong position and stay there
                // see https://bugs.kde.org/show_bug.cgi?id=427894 and QTBUG-110366
                property real oldY: -1
                property int oldListCount: -1
                onYChanged: {
                    if (oldY < 0 || oldListCount === list.count) {
                        oldY = y;
                        return;
                    }
                    traslAnim.from = oldY - y;
                    traslAnim.running = true;
                    oldY = y;
                    oldListCount = list.count;
                }
                transform: Translate {
                    id: transl
                }
                NumberAnimation {
                    id: traslAnim
                    target: transl
                    properties: "y"
                    to: 0
                    duration: Kirigami.Units.longDuration
                }
                opacity: 0
                ListView.onAdd: appearAnim.restart();
                Component.onCompleted: {
                    Qt.callLater(() => {
                        if (!appearAnim.running) {
                            opacity = 1;
                        }
                    });
                    oldListCount = list.count;
                }

                SequentialAnimation {
                    id: appearAnim
                    PropertyAnimation { target: delegate; property: "opacity"; to: 0 }
                    PauseAnimation { duration: Kirigami.Units.longDuration}
                    NumberAnimation {
                        target: delegate
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Kirigami.Units.longDuration
                    }
                }

                SequentialAnimation {
                    id: removeAnimation
                    PropertyAction { target: delegate; property: "ListView.delayRemove"; value: true }
                    ParallelAnimation {
                        NumberAnimation { target: delegate; property: "opacity"; to: 0; duration: Kirigami.Units.longDuration }
                        NumberAnimation {
                            target: transl
                            property: "x"
                            to: list.width - (scrollView.PlasmaComponents3.ScrollBar.vertical.visible ? Kirigami.Units.largeSpacing * 2 : 0)
                            duration: Kirigami.Units.longDuration
                        }
                    }
                    PropertyAction { target: delegate; property: "ListView.delayRemove"; value: false }
                }

                draggable: !model.isGroup && model.type != NotificationManager.Notifications.JobType

                onDismissRequested: {
                    removeAnimation.start();

                    historyModel.close(historyModel.index(index, 0));
                }

                Loader {
                    id: delegateLoader
                    anchors {
                        left: parent.left
                        leftMargin: Kirigami.Units.largeSpacing
                        right: parent.right
                        rightMargin: Kirigami.Units.largeSpacing
                    }
                    sourceComponent: model.isGroup ? groupDelegate : notificationDelegate

                    Component {
                        id: groupDelegate
                        NotificationHeader {
                            applicationName: model.applicationName
                            applicationIconSource: model.applicationIconName
                            originName: model.originName || ""

                            // don't show timestamp for group

                            configurable: model.configurable
                            closable: model.closable
                            closeButtonTooltip: i18n("Close Group")

                            onCloseClicked: historyModel.close(historyModel.index(index, 0));
                            onConfigureClicked: historyModel.configure(historyModel.index(index, 0))
                        }
                    }

                    Component {
                        id: notificationDelegate
                        ColumnLayout {
                            spacing: Kirigami.Units.smallSpacing

                            RowLayout {
                                Item {
                                    id: groupLineContainer
                                    Layout.fillHeight: true
                                    Layout.topMargin: Kirigami.Units.smallSpacing
                                    width: Kirigami.Units.iconSizes.small
                                    visible: model.isInGroup

                                    // Not using the Plasma theme's vertical line SVG because we want something thicker
                                    // than a hairline, and thickening a thin line SVG does not necessarily look good
                                    // with all Plasma themes.
                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 3
                                        height: parent.height
                                        // TODO: use separator color here, once that color role is implemented
                                        color: Kirigami.Theme.textColor
                                        opacity: 0.2
                                    }
                                }

                                NotificationItem {
                                    Layout.fillWidth: true

                                    notificationType: model.type

                                    inGroup: model.isInGroup
                                    inHistory: true
                                    listViewParent: list

                                    applicationName: model.applicationName
                                    applicationIconSource: model.applicationIconName
                                    originName: model.originName || ""

                                    time: model.updated || model.created

                                    // configure button on every single notifications is bit overwhelming
                                    configurable: !inGroup && model.configurable

                                    dismissable: model.type === NotificationManager.Notifications.JobType
                                        && model.jobState !== NotificationManager.Notifications.JobStateStopped
                                        && model.dismissed
                                        // TODO would be nice to be able to undismiss jobs even when they autohide
                                        && notificationSettings.permanentJobPopups
                                    dismissed: model.dismissed || false
                                    closable: model.closable

                                    summary: model.summary
                                    body: model.body || ""
                                    icon: model.image || model.iconName

                                    urls: model.urls || []

                                    jobState: model.jobState || 0
                                    percentage: model.percentage || 0
                                    jobError: model.jobError || 0
                                    suspendable: !!model.suspendable
                                    killable: !!model.killable
                                    jobDetails: model.jobDetails || null

                                    configureActionLabel: model.configureActionLabel || ""
                                    // In the popup the default action is triggered by clicking on the popup
                                    // however in the list this is undesirable, so instead show a clickable button
                                    // in case you have a non-expired notification in history (do not disturb mode)
                                    // unless it has the same label as an action
                                    readonly property bool addDefaultAction: (model.hasDefaultAction
                                                                            && model.defaultActionLabel
                                                                            && (model.actionLabels || []).indexOf(model.defaultActionLabel) === -1) ? true : false
                                    actionNames: {
                                        var actions = (model.actionNames || []);
                                        if (addDefaultAction) {
                                            actions.unshift("default"); // prepend
                                        }
                                        return actions;
                                    }
                                    actionLabels: {
                                        var labels = (model.actionLabels || []);
                                        if (addDefaultAction) {
                                            labels.unshift(model.defaultActionLabel);
                                        }
                                        return labels;
                                    }

                                    onCloseClicked: close()

                                    onDismissClicked: {
                                        model.dismissed = false;
                                        root.closePlasmoid();
                                    }
                                    onConfigureClicked: historyModel.configure(historyModel.index(index, 0))

                                    onActionInvoked: {
                                        if (actionName === "default") {
                                            historyModel.invokeDefaultAction(historyModel.index(index, 0));
                                        } else {
                                            historyModel.invokeAction(historyModel.index(index, 0), actionName);
                                        }

                                        expire();
                                    }
                                    onOpenUrl: {
                                        Qt.openUrlExternally(url);
                                        expire();
                                    }
                                    onFileActionInvoked: {
                                        if (action.objectName === "movetotrash" || action.objectName === "deletefile") {
                                            close();
                                        } else {
                                            expire();
                                        }
                                    }

                                    onSuspendJobClicked: historyModel.suspendJob(historyModel.index(index, 0))
                                    onResumeJobClicked: historyModel.resumeJob(historyModel.index(index, 0))
                                    onKillJobClicked: historyModel.killJob(historyModel.index(index, 0))

                                    function expire() {
                                        if (model.resident) {
                                            model.expired = true;
                                        } else {
                                            historyModel.expire(historyModel.index(index, 0));
                                        }
                                    }

                                    function close() {
                                        removeAnimation.start();
                                        historyModel.close(historyModel.index(index, 0));
                                    }
                                }
                            }

                            PlasmaComponents3.ToolButton {
                                icon.name: model.isGroupExpanded ? "arrow-up" : "arrow-down"
                                text: model.isGroupExpanded ? i18n("Show Fewer")
                                                            : i18nc("Expand to show n more notifications",
                                                                    "Show %1 More", (model.groupChildrenCount - model.expandedGroupChildrenCount))
                                visible: (model.groupChildrenCount > model.expandedGroupChildrenCount || model.isGroupExpanded)
                                    && delegate.ListView.nextSection !== delegate.ListView.section
                                onClicked: list.setGroupExpanded(model.index, !model.isGroupExpanded)
                            }

                            KSvg.SvgItem {
                                Layout.fillWidth: true
                                Layout.bottomMargin: Kirigami.Units.smallSpacing
                                imagePath: "widgets/line"
                                elementId: "horizontal-line"

                                // property is only atached to the delegate itself (the Loader in our case)
                                visible: (!model.isInGroup || delegate.ListView.nextSection !== delegate.ListView.section)
                                                && delegate.ListView.nextSection !== "" // don't show after last item
                                                && !removeAnimation.running
                            }
                        }
                    }
                }
            }

            Loader {
                anchors.centerIn: parent
                width: parent.width - (Kirigami.Units.iconSizes.small * 4)

                active: list.count === 0
                visible: active
                asynchronous: true

                sourceComponent: NotificationManager.Server.valid ? noUnreadMessage : notAvailableMessage
            }

            Component {
                id: noUnreadMessage

                PlasmaExtras.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width

                    iconName: "checkmark"
                    text: i18n("No unread notifications")
                }
            }

            Component {
                id: notAvailableMessage

                PlasmaExtras.PlaceholderMessage {
                    // Checking valid to avoid creating ServerInfo object if everything is alright
                    readonly property NotificationManager.ServerInfo currentOwner: NotificationManager.Server.currentOwner

                    anchors.centerIn: parent
                    width: parent.width

                    iconName: "notifications-disabled"
                    text: i18n("Notification service not available")
                    explanation: currentOwner && currentOwner.vendor && currentOwner.name
                                ? i18nc("Vendor and product name", "Notifications are currently provided by '%1 %2'", currentOwner.vendor, currentOwner.name)
                                : ""
                }
            }
        }
    }
}
