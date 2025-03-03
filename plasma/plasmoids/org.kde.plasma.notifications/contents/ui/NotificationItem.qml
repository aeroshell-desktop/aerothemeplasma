/*
    SPDX-FileCopyrightText: 2018-2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami
import Qt5Compat.GraphicalEffects

import org.kde.notificationmanager as NotificationManager

import org.kde.plasma.private.notifications 2.0 as Notifications

ColumnLayout {
    id: notificationItem

    property int maximumLineCount: 0
    property alias bodyCursorShape: bodyLabel.cursorShape

    property int notificationType
    property int urgency

    property bool inGroup: false
    property bool inHistory: false
    property ListView listViewParent: null

    property alias applicationIconSource: notificationHeading.applicationIconSource
    property alias applicationName: notificationHeading.applicationName
    property alias originName: notificationHeading.originName

    property string summary
    property alias time: notificationHeading.time

    property alias configurable: notificationHeading.configurable
    property alias dismissable: notificationHeading.dismissable
    property alias dismissed: notificationHeading.dismissed
    property alias closable: notificationHeading.closable

    // This isn't an alias because TextEdit RichText adds some HTML tags to it
    property string body
    property string accessibleDescription
    property var icon
    property var urls: []

    property int jobState
    property int percentage
    property int jobError: 0
    property bool suspendable
    property bool killable

    property QtObject jobDetails

    property alias configureActionLabel: notificationHeading.configureActionLabel
    property var actionNames: []
    property var actionLabels: []

    property bool hasReplyAction
    property string replyActionLabel
    property string replyPlaceholderText
    property string replySubmitButtonText
    property string replySubmitButtonIconName

    property int headingLeftPadding: 0
    property int headingRightPadding: 0

    property int thumbnailLeftPadding: 0
    property int thumbnailRightPadding: 0
    property int thumbnailTopPadding: 0
    property int thumbnailBottomPadding: 0

    property alias timeout: notificationHeading.timeout
    property alias remainingTime: notificationHeading.remainingTime

    readonly property bool menuOpen: bodyLabel.contextMenu !== null
                                     || Boolean(thumbnailStripLoader.item?.menuOpen || jobLoader.item?.menuOpen)

    readonly property bool dragging: Boolean(thumbnailStripLoader.item?.dragging || jobLoader.item?.dragging)
    property bool replying: false
    readonly property bool hasPendingReply: replyLoader.item?.text !== ""
    readonly property alias headerHeight: headingElement.height
    property int extraSpaceForCriticalNotificationLine: 0

    signal bodyClicked
    signal closeClicked
    signal configureClicked
    signal dismissClicked
    signal actionInvoked(string actionName)
    signal replied(string text)
    signal openUrl(string url)
    signal fileActionInvoked(QtObject action)
    signal forceActiveFocusRequested

    signal suspendJobClicked
    signal resumeJobClicked
    signal killJobClicked

    spacing: 0//Kirigami.Units.smallSpacing

    Kirigami.Theme.colorSet: notificationItem.inHistory ? Kirigami.Theme.Header : Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    // Header
    Item {
        id: headingElement
        Layout.fillWidth: !notificationItem.inGroup
        Layout.preferredHeight: notificationHeading.implicitHeight
        Layout.preferredWidth: notificationHeading.implicitWidth
        Layout.alignment: notificationItem.inGroup && summaryLabel.lineCount > 1 ? Qt.AlignTop : 0
        Layout.topMargin: notificationItem.inGroup && summaryLabel.lineCount > 1 ? Math.max(0, (summaryLabelTextMetrics.height - Layout.preferredHeight) / 2) : Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing/2
        NotificationHeader {
            id: notificationHeading
            anchors {
                fill: parent
                leftMargin: notificationItem.headingLeftPadding
                rightMargin: notificationItem.headingRightPadding
            }

            inGroup: notificationItem.inGroup
            inHistory: notificationItem.inHistory
            urgency: notificationItem.urgency

            notificationType: notificationItem.notificationType
            jobState: notificationItem.jobState
            jobDetails: notificationItem.jobDetails

            onConfigureClicked: notificationItem.configureClicked()
            onDismissClicked: notificationItem.dismissClicked()
            onCloseClicked: notificationItem.closeClicked()
        }
    }

    // Everything else that goes below the header
    // This is its own ColumnLayout-within-a-ColumnLayout because it lets us set
    // the left margin once rather than several times, in each of its children
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: childrenRect.height
        Layout.leftMargin: (notificationItem.inGroup || !notificationItem.inHistory ? 0 : notificationItem.spacing) + notificationHeading.hasIcon ? (Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.largeSpacing) : 0
        Layout.topMargin: notificationItem.inHistory ? 0 : -Kirigami.Units.smallSpacing

        Accessible.role: notificationItem.inHistory ? Accessible.NoRole : Accessible.Notification
        Accessible.name: summaryLabel.text
        Accessible.description: notificationItem.accessibleDescription

        // Notification body
        RowLayout {
            id: summaryRow
            anchors {
                left: parent.left
                right: iconContainer.left
                rightMargin: Kirigami.Units.mediumSpacing
            }
            visible: summaryLabel.text !== ""

            Kirigami.Heading {
                id: summaryLabel
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                Layout.topMargin: notificationItem.inGroup && lineCount > 1 ? Math.max(0, (headingElement.Layout.preferredHeight - summaryLabelTextMetrics.height) / 2) : 0
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.mediumSpacing
                textFormat: Text.PlainText
                maximumLineCount: 3
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                opacity: 0.66
                level: 5
                color: "black"
                // Give it a bit more visual prominence than the app name in the header
                //type: Kirigami.Heading.Type.Primary
                text: {
                    if (notificationItem.notificationType === NotificationManager.Notifications.JobType) {
                        if (notificationItem.jobState === NotificationManager.Notifications.JobStateSuspended) {
                            if (notificationItem.summary) {
                                return i18ndc("plasma_applet_org.kde.plasma.notifications", "Job name, e.g. Copying is paused", "%1 (Paused)", notificationItem.summary);
                            }
                        } else if (notificationItem.jobState === NotificationManager.Notifications.JobStateStopped) {
                            if (notificationItem.jobError) {
                                if (notificationItem.summary) {
                                    return i18ndc("plasma_applet_org.kde.plasma.notifications", "Job name, e.g. Copying has failed", "%1 (Failed)", notificationItem.summary);
                                } else {
                                    return i18nd("plasma_applet_org.kde.plasma.notifications", "Job Failed");
                                }
                            } else {
                                if (notificationItem.summary) {
                                    return i18ndc("plasma_applet_org.kde.plasma.notifications", "Job name, e.g. Copying has finished", "%1 (Finished)", notificationItem.summary);
                                } else {
                                    return i18nd("plasma_applet_org.kde.plasma.notifications", "Job Finished");
                                }
                            }
                        }
                    }
                    // some apps use their app name as summary, avoid showing the same text twice
                    // try very hard to match the two
                    if (notificationItem.summary && notificationItem.summary.toLocaleLowerCase().trim() != notificationItem.applicationName.toLocaleLowerCase().trim()) {
                        return notificationItem.summary;
                    }
                    return "";
                }
                visible: text !== ""

                TextMetrics {
                    id: summaryLabelTextMetrics
                    font: summaryLabel.font
                    text: summaryLabel.text
                }
            }

            // inGroup headerItem is reparented here
        }

        SelectableLabel {
            id: bodyLabel

            readonly property real maximumHeight: Kirigami.Units.iconSizes.small * notificationItem.maximumLineCount
            readonly property bool truncated: notificationItem.maximumLineCount > 0 && bodyLabel.implicitHeight > maximumHeight

            height: truncated ? maximumHeight : implicitHeight
            anchors {
                top: summaryRow.bottom
                topMargin: summaryRow.visible && notificationItem.inGroup && iconContainer.visible ? notificationItem.spacing : 0
                left: parent.left
                right: iconContainer.left
                rightMargin: iconContainer.visible ? notificationItem.spacing : -Kirigami.Units.largeSpacing
            }

            listViewParent: notificationItem.listViewParent
            // HACK RichText does not allow to specify link color and since LineEdit
            // does not support StyledText, we have to inject some CSS to force the color,
            // cf. QTBUG-81463 and to some extent QTBUG-80354
            text: "<style>a { color: " + Kirigami.Theme.linkColor + "; }</style>" + notificationItem.body

            // Cannot do text !== "" because RichText adds some HTML tags even when empty
            visible: notificationItem.body !== ""
            onClicked: notificationItem.bodyClicked()
            onLinkActivated: Qt.openUrlExternally(link)
        }

        Item {
            id: iconContainer

            width: visible ? iconItem.width : 0
            height: visible ? Math.max(iconItem.height + notificationItem.spacing * 2, bodyLabel.height + bodyLabel.anchors.topMargin + (notificationItem.inGroup ? 0 : summaryRow.implicitHeight)) : 0
            anchors {
                top: notificationItem.inGroup ? bodyLabel.top : parent.top
                right: parent.right
            }
            visible: iconItem.shouldBeShown

            Kirigami.Icon {
                id: iconItem

                width: Kirigami.Units.iconSizes.large
                height: Kirigami.Units.iconSizes.large
                anchors.verticalCenter: parent.verticalCenter

                // don't show two identical icons
                readonly property bool shouldBeShown: valid && source != notificationItem.applicationIconSource

                smooth: true
                source: notificationItem.icon
            }

            DropShadow {
                anchors.fill: iconItem
                horizontalOffset: 2
                verticalOffset: 2
                radius: 3.0
                color: "#2b000000"
                source: iconItem
            }
        }
    }

    // Job progress reporting
    Loader {
        id: jobLoader
        Layout.fillWidth: true
        Layout.preferredHeight: item ? item.implicitHeight : 0
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.leftMargin: notificationHeading.hasIcon ? (Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.largeSpacing) : 0
        active: notificationItem.notificationType === NotificationManager.Notifications.JobType
        visible: active
        sourceComponent: JobItem {
            iconContainerItem: iconContainer

            jobState: notificationItem.jobState
            jobError: notificationItem.jobError
            percentage: notificationItem.percentage
            suspendable: notificationItem.suspendable
            killable: notificationItem.killable

            jobDetails: notificationItem.jobDetails

            onSuspendJobClicked: notificationItem.suspendJobClicked()
            onResumeJobClicked: notificationItem.resumeJobClicked()
            onKillJobClicked: notificationItem.killJobClicked()

            onOpenUrl: notificationItem.openUrl(url)
            onFileActionInvoked: notificationItem.fileActionInvoked(action)
        }
    }

    // Actions
    Item {
        id: actionContainer
        Layout.fillWidth: true
        Layout.preferredHeight: childrenRect.height
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: -Kirigami.Units.smallSpacing
        Layout.leftMargin: notificationHeading.hasIcon ? (Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.largeSpacing) : 0
        visible: actionRepeater.count > 0 && actionFlow.parent === this

        // Notification actions
        Flow { // it's a Flow so it can wrap if too long
            id: actionFlow
            // For a cleaner look, if there is a thumbnail, puts the actions next to the thumbnail strip's menu button
            parent: thumbnailStripLoader.item?.actionContainer ?? actionContainer
            width: parent.width
            spacing: Kirigami.Units.smallSpacing
            layoutDirection: Qt.RightToLeft
            enabled: !replyLoader.active
            opacity: replyLoader.active ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            Repeater {
                id: actionRepeater

                model: {
                    var buttons = [];
                    var actionNames = (notificationItem.actionNames || []);
                    var actionLabels = (notificationItem.actionLabels || []);
                    // HACK We want the actions to be right-aligned but Flow also reverses
                    for (var i = actionNames.length - 1; i >= 0; --i) {
                        buttons.push({
                            actionName: actionNames[i],
                            label: actionLabels[i]
                        });
                    }

                    if (notificationItem.hasReplyAction) {
                        buttons.unshift({
                            actionName: "inline-reply",
                            label: notificationItem.replyActionLabel || i18nc("Reply to message", "Reply")
                        });
                    }

                    return buttons;
                }

                PlasmaComponents3.ToolButton {
                    flat: false
                    // why does it spit "cannot assign undefined to string" when a notification becomes expired?
                    text: modelData.label || ""

                    onClicked: {
                        if (modelData.actionName === "inline-reply") {
                            replyLoader.beginReply();
                            return;
                        }

                        notificationItem.actionInvoked(modelData.actionName);
                    }
                }
            }
        }

        // inline reply field
        Loader {
            id: replyLoader
            width: parent.width
            height: active && item ? item.implicitHeight : 0
            // When there is only one action and it is a reply action, show text field right away
            active: notificationItem.replying || (notificationItem.hasReplyAction && (notificationItem.actionNames || []).length === 0)
            visible: active
            opacity: active ? 1 : 0
            x: active ? 0 : parent.width
            /*Behavior on x {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }*/

            function beginReply() {
                notificationItem.replying = true;

                notificationItem.forceActiveFocusRequested();
                replyLoader.item.activate();
            }

            sourceComponent: NotificationReplyField {
                placeholderText: notificationItem.replyPlaceholderText
                buttonIconName: notificationItem.replySubmitButtonIconName
                buttonText: notificationItem.replySubmitButtonText
                onReplied: notificationItem.replied(text)

                replying: notificationItem.replying
                onBeginReplyRequested: replyLoader.beginReply()
            }
        }
    }

    // Thumbnails
    Loader {
        id: thumbnailStripLoader
        Layout.leftMargin: notificationItem.thumbnailLeftPadding
        Layout.rightMargin: notificationItem.thumbnailRightPadding
        // no change in Layout.topMargin to keep spacing to notification text consistent
        Layout.topMargin: 0
        Layout.bottomMargin: notificationItem.thumbnailBottomPadding
        Layout.fillWidth: true
        Layout.preferredHeight: item ? item.implicitHeight : 0
        active: notificationItem.urls.length > 0
        visible: active
        sourceComponent: ThumbnailStrip {
            leftPadding: -thumbnailStripLoader.Layout.leftMargin
            rightPadding: -thumbnailStripLoader.Layout.rightMargin
            topPadding: -notificationItem.thumbnailTopPadding
            bottomPadding: -thumbnailStripLoader.Layout.bottomMargin
            urls: notificationItem.urls
            onOpenUrl: notificationItem.openUrl(url)
            onFileActionInvoked: notificationItem.fileActionInvoked(action)
        }
    }

    states: [
         State {
            when: notificationItem.inGroup
            PropertyChanges {
                target: headingElement
                parent: summaryRow
            }

            PropertyChanges {
                target: summaryRow
                visible: true
            }
            PropertyChanges {
                target: summaryLabel
                visible: true
            }

            /*PropertyChanges {
                target: bodyLabel.Label
                alignment: Qt.AlignTop
            }*/
        }
    ]
}
