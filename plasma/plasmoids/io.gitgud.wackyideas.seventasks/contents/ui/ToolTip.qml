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
    onParentTaskChanged: {
        if(parentTask !== null) {
            loaderItem.active = true;
            // visualParent = parentTask;
        }
    }

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

    property bool firstCreation: true
    property bool compositionEnabled: tasks.compositionEnabled

    property bool containsDrag: false

    readonly property int flyoutMargin: compositionEnabled ? (Kirigami.Units.smallSpacing*2 - Kirigami.Units.smallSpacing/2) : 0

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
        var pos = tasks.mapToGlobal(taskX, taskY);
        var availScreen = Plasmoid.containment.availableScreenRect;
        var screen = Plasmoid.containment.screenGeometry;

        // if(KWindowSystem.isPlatformWayland) visualParent = null; // to reposition the preview without issues

        switch(Plasmoid.location) {
            case(PlasmaCore.Types.BottomEdge):
                x = pos.x - width / 2 + taskWidth / 2;
                y = pos.y - height - flyoutMargin;
                break;
            case(PlasmaCore.Types.TopEdge):
                x = pos.x - width / 2 + taskWidth / 2;
                y = rootPos.y + tasks.height + flyoutMargin;
                break;

            case(PlasmaCore.Types.RightEdge):
                y = pos.y - height / 2 + flyoutMargin;
                x = rootPos.x - flyoutMargin - width;
                break;
            case(PlasmaCore.Types.LeftEdge):
                y = pos.y - height / 2 + flyoutMargin;
                x = rootPos.x + tasks.width + flyoutMargin;
                break;
        }

        // if(KWindowSystem.isPlatformWayland) {
        //     visualParent = parentTask; // re-set the visualParent
        //     refreshBlur(); // blur can break during this change so refresh it
        // }

        if(x <= availScreen.x) x = availScreen.x + flyoutMargin;
        if((x + tooltip.width - screen.x) >= availScreen.x + availScreen.width) {
            x = screen.x + availScreen.width - tooltip.width - flyoutMargin;
        }
        if(y <= availScreen.y) ypos = availScreen.y + flyoutMargin;
        if((y + tooltip.height - screen.y) >= availScreen.y + availScreen.height) {
            y = screen.y + availScreen.height - tooltip.height - flyoutMargin;
        }

        fixScreenPos.start()
    }

    opacity: 0

    function refreshBlur() {
        if(loaderItem.thumbnailLoaded) Plasmoid.setToolTip(tooltip, loaderItem.item.bg.mask, loaderItem.item.bg.imagePath);
        blurFix.start();
    }

    function show() {
        correctScreenLocation();
        Qt.callLater(() => {
            // Dialog freezing gets worse with this under Wayland.
            if(KWindowSystem.isPlatformX11) tooltip.y += taskHeight/2;
            refreshBlur();
            tooltip.visible = true;
        });
    }

    onVisibleChanged: if(!visible) tooltip.destroy();
    onOpacityChanged: if(tooltip.opacity == 1 && firstCreation) firstCreation = false;

    onWidthChanged: {
        correctScreenLocation();
        Qt.callLater(() => {refreshBlur()});
    }
    onHeightChanged: {
        correctScreenLocation();
        Qt.callLater(() => {refreshBlur()});
    }

    mainItem: Loader {
        id: loaderItem

        property bool thumbnailLoaded: false

        active: false
        asynchronous: true
        sourceComponent: childCount > 1 ? groupThumbnails : windowThumbnail

        onLoaded: {
            thumbnailLoaded = true;
            refreshBlur();
            if(loaderItem.item.thumbnailHeight == 94 || loaderItem.item.thumbnailHeight === undefined) tooltip.opacity = 1;
        }

        Connections {
            target: loaderItem.item
            function onThumbnailHeightChanged() {
                if(tooltip.firstCreation) tooltip.opacity = 1;
            }
        }

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
                if(tooltip.y <= availScreen.y) tooltip.y = availScreen.y + flyoutMargin;
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
}
