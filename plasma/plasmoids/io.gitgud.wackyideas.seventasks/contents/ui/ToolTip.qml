import QtQuick
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.kquickcontrolsaddons
import org.kde.kwindowsystem
import org.kde.ksvg as KSvg

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mpris as Mpris

PlasmaCore.Dialog {
    id: tooltip

    readonly property Mpris.PlayerContainer playerData: mpris2Source.playerForLauncherUrl(launcherUrl, pidParent)

    property QtObject parentTask

    property string display: "undefined"
    property var icon: "undefined"
    property bool active: false
    property bool pinned: false
    property bool minimized: false
    property bool startup: false
    property var windows
    property bool taskHovered: false
    property var modelIndex
    property var taskIndex
    property int childCount
    property bool dragDrop: false

    property bool isPeeking: false

    // needed for mpris
    property int pidParent
    property url launcherUrl

    property int taskWidth: 0
    property int taskHeight: 0
    property int taskX: 0
    property int taskY: 0

    property bool shouldDisplayToolTip: {
        if(!Plasmoid.configuration.showPreviews) return true
        else {
            if(pinned) return true
            if(startup) return true
            if(!compositionEnabled && childCount == 0) return true
            return false
        }
    }
    property bool firstCreation: false
    property bool compositionEnabled: tasks.compositionEnabled

    property bool containsDrag: false

    readonly property int flyoutMargin: !tooltip.shouldDisplayToolTip && compositionEnabled ? (Kirigami.Units.smallSpacing*2 - Kirigami.Units.smallSpacing/2) : 0

    onTaskXChanged: correctScreenLocation()

    width: loaderItem.implicitWidth
    height: loaderItem.implicitHeight

    backgroundHints: PlasmaCore.Types.NoBackground
    type: PlasmaCore.Dialog.Dock
    flags: Qt.WindowDoesNotAcceptFocus | Qt.ToolTip
    location: "Floating"
    title: "seventasks-tooltip"
    objectName: "tooltipWindow"

    function correctScreenLocation() {
        var rootPos = tasks.mapToGlobal(tasks.x, tasks.y);
        var pos = tasks.mapToGlobal(parentTask.x, parentTask.y);
        var availScreen = Plasmoid.containment.availableScreenRect;
        var screen = Plasmoid.containment.screenGeometry;

        if(Plasmoid.location === PlasmaCore.Types.BottomEdge) {
            x = pos.x - width / 2 + taskWidth / 2;
            y = pos.y - height - flyoutMargin;

        } else if(Plasmoid.location === PlasmaCore.Types.LeftEdge) {
            y = pos.y - height / 2 + flyoutMargin;
            x = rootPos.x + tasks.width + flyoutMargin;

        } else if(Plasmoid.location === PlasmaCore.Types.RightEdge) {
            y = pos.y - height / 2 + flyoutMargin;
            x = rootPos.x - flyoutMargin - width;

        } else if(Plasmoid.location === PlasmaCore.Types.TopEdge) {
            x = pos.x - width / 2 + taskWidth / 2;
            y = rootPos.y + tasks.height + flyoutMargin;
        }

        if(x <= availScreen.x) x = availScreen.x + flyoutMargin;
        if((x + tooltip.width - screen.x) >= availScreen.x + availScreen.width) {
            x = screen.x + availScreen.width - tooltip.width - flyoutMargin;
        }
        if(y <= availScreen.y) y = availScreen.y + flyoutMargin;
        if((y + tooltip.height - screen.y) >= availScreen.y + availScreen.height) {
            y = screen.y + availScreen.height - tooltip.height - flyoutMargin;
        }
    }

    function refreshBlur() {
        Plasmoid.setToolTip(tooltip, loaderItem.item.bg.mask, loaderItem.item.bg.imagePath);
        if(KWindowSystem.isPlatformWayland) blurFix.start();
    }

    onVisibleChanged: if(!visible) tooltip.destroy();

    onWidthChanged: {
        correctScreenLocation();
        Qt.callLater(() => {fixScreenPos.start()});
        Qt.callLater(() => {refreshBlur()});
    }
    onHeightChanged: {
        correctScreenLocation();
        Qt.callLater(() => {fixScreenPos.start()});
        Qt.callLater(() => {refreshBlur()});
    }

    mainItem: Loader {
        id: loaderItem

        active: tooltip.visible
        asynchronous: true
        sourceComponent: shouldDisplayToolTip ? pinnedToolTip : (childCount > 1 ? groupThumbnails : windowThumbnail)

        // I hate how I have to run this part of the positioning code
        // again but delayed for the tooltip to not go off-bounds.
        Timer {
            id: fixScreenPos

            interval: 150
            triggeredOnStart: false
            onTriggered: {
                var availScreen = Plasmoid.containment.availableScreenRect;
                var screen = Plasmoid.containment.screenGeometry;

                if(tooltip.x <= availScreen.x) tooltip.x = availScreen.x + flyoutMargin;
                if((tooltip.x + tooltip.width - screen.x) >= availScreen.x + availScreen.width) {
                    tooltip.x = screen.x + availScreen.width - tooltip.width - flyoutMargin;
                }
                if(y <= availScreen.y) tooltip.y = availScreen.y + flyoutMargin;
                if((tooltip.y + tooltip.height - screen.y) >= availScreen.y + availScreen.height) {
                    tooltip.y = screen.y + availScreen.height - tooltip.height - flyoutMargin;
                }
            }
        }

        // Do it again but delayed because Wayland reasons
        Timer {
            id: blurFix

            interval: 100
            triggeredOnStart: false
            onTriggered: Plasmoid.setToolTip(tooltip, loaderItem.item.bg.mask, loaderItem.item.bg.imagePath);
        }

        Binding {
            target: tooltip
            property: "width"
            value: loaderItem.implicitWidth
            restoreMode: Binding.RestoreBinding
        }
        Binding {
            target: tooltip
            property: "height"
            value: loaderItem.implicitHeight
            restoreMode: Binding.RestoreBinding
        }

        Component {
            id: groupThumbnails

            GroupThumbnails { root: toolTipItem; parent: loaderItem }
        }
        Component {
            id: pinnedToolTip

            PinnedToolTip { root: toolTipItem; parent: loaderItem }
        }
        Component {
            id: windowThumbnail

            WindowThumbnail { root: toolTipItem; parent: loaderItem }
        }
    }

    Component.onCompleted: {
        correctScreenLocation();
        Qt.callLater(() => {fixScreenPos.start()});
        Qt.callLater(() => {refreshBlur()});
    }
}
