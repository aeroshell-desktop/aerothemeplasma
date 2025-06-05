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

Item {
    id: tooltip

    readonly property Mpris.PlayerContainer playerData: mpris2Source.playerForLauncherUrl(launcherUrl, pidParent)

    property QtObject parentTask
    onParentTaskChanged: {
        if(parentTask !== null) {
            loaderItem.active = true;
        }
    }
    property string display: "undefined"
    property var icon: "undefined"
    property bool active: false
    property bool minimized: false
    property bool startup: false
    property var windows
    property bool taskHovered: false
    property var modelIndex
    property var taskIndex
    property bool isGroupParent: false
    property bool dragDrop: false

    property bool isPeeking: false

    // needed for mpris
    property int pidParent
    property url launcherUrl

    property bool containsDrag: false

    property bool demandsAttention

    implicitWidth: loaderItem.implicitWidth
    implicitHeight: loaderItem.implicitHeight

    Loader {
        id: loaderItem

        active: false
        asynchronous: true
        sourceComponent: isGroupParent ? groupThumbnails : windowThumbnail

        Binding {
            target: tooltip
            property: "implicitWidth"
            value: loaderItem.implicitWidth
            restoreMode: Binding.RestoreBinding
        }
        Binding {
            target: tooltip
            property: "implicitHeight"
            value: loaderItem.implicitHeight
            restoreMode: Binding.RestoreBinding
        }

        Component {
            id: groupThumbnails

            GroupThumbnails { root: tooltip; parent: loaderItem }
        }
        Component {
            id: windowThumbnail

            WindowThumbnail { root: tooltip; parent: loaderItem }
        }
    }
}
