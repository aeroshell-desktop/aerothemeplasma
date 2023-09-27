
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
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

/*
 * This is the Dialog that displays the Start menu orb when it sticks out
 * of the panel. In principle, it works in almost the same way as the
 * Start menu user icon, in fact most of the code is directly copied from
 * there.
 *
 * With this approach, two important problems come up:
 * 1. Right clicking on this dialog window won't open the standard
 *    context menu as expected, as it actually isn't part of the
 *    compact or full representation.
 * 2. When compositing is disabled, even with the NoBackground hint, this
 *    dialog window will simply be drawn with an opaque, black background.
 *
 * This source code tackles both problems in such a way to avoid having to
 * introduce a compiled component of the plasmoid, which would greatly
 * reduce its portability and ease of installation. The downside of this
 * approach is that the solution to the second problem leaves us bound to
 * the Seven-Black Plasma theme, as it uses the SVG file found in
 *
 * /solid/widgets/tooltip.svg
 *
 * However, this can be circumvented by copying this file over to any other
 * theme, as this is probably the *least* used SVG texture in KDE, if not
 * completely unused. This SVG file contains only the opacity and input
 * mask of the dialog window, which gets applied when X11 compositing is
 * disabled. Another slight limitation to this approach is that the
 * possible choice of menu orbs is limited to perfect spheres in this
 * particular configuration. This can be corrected if the opacity mask is
 * changed in the SVG file, meaning that installing custom orbs might
 * potentially be a two-step process now.
 *
 * Compared to the popup avatar, this dialog window should NOT have any
 * visualParent set, as it causes inexplicable behavior where the orb
 * moves away. I have no idea why it does that.
 *
 * This has been developed only for the bottom/south oriented panel, and
 * other orientations should receive support when I begin giving pretty
 * much *everything* else support for other orientations.
 *
 */

 PlasmaCore.Dialog {
    id: iconUser
    flags: Qt.WindowStaysOnTopHint | Qt.Popup | Qt.X11BypassWindowManagerHint // To prevent the icon from animating its opacity when its visibility is changed
    type: "Tooltip" // Crucial to making this work under no compositing. See above for details.
	location: "Floating"

    // Positions are defined when the plasmoid has been fully loaded, to prevent undefined behavior.
	x: 0
	y: 0
    onYChanged: { // Tries to circumvent possible inexplicable changes in position. Currently doesn't seem to run in practice anymore, as it has most likely been fixed by keeping the visualParent undefined.
        var pos = plasmoid.mapToGlobal(kicker.x, kicker.y);
        if(iconUser.y - pos.y < 0) {
            iconUser.y -= iconUser.y - pos.y + panelSvg.margins.bottom*2 + panelSvg.margins.top*2;
        }
    }
	backgroundHints: PlasmaCore.Types.SolidBackground
	visible: root.visible && stickOutOrb
	opacity: iconUser.visible // To prevent even more NP-hard unpredictable behavior

	// The actual orb button, this dialog window is just a container for it.
	mainItem: FloatingOrb {
        id: floatingOrbIcon
    }
    Component.onCompleted: {
        /*
         * When compositing is enabled, we want to simply use the NoBackground
         * hint to render a fully transparent, blur-free window. If we used the
         * same opacity mask for both cases, blur would be applied behind the
         * orb, which would also by extension render reflections and colorize
         * the entire area as well.
         */
        iconUser.backgroundHints = compositing ? 0 : 2;
    }
}
