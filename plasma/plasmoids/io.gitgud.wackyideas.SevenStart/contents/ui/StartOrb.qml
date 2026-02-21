
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.1
import QtQuick.Dialogs
import QtQuick.Window 2.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.coreaddons as KCoreAddons // kuser
import org.kde.plasma.private.shell 2.0

import org.kde.kwindowsystem 1.0

import org.kde.kirigami 2.13 as Kirigami

/*
 * This is the Dialog that displays the Start menu orb when it sticks out
 * of the panel. In principle, it works in almost the same way as the
 * Start menu user icon, in fact most of the code is directly copied from
 * there.
 *
 * Compared to the popup avatar, this dialog window should NOT have any
 * visualParent set, as it causes inexplicable behavior where the orb
 * moves away during certain interactions. I have no idea why it does that.
 *
 * This has been developed only for the bottom/south oriented panel, and
 * other orientations should receive support when I begin giving pretty
 * much *everything* else support for other orientations.
 *
 */

 PlasmaCore.Dialog {
    id: iconUser
    flags: Qt.WindowTransparentForInput
	location: "Floating"

    type: "Notification"
    title: "aeroshell-floatingorb"

    // Positions are defined later when the plasmoid has been fully loaded, to prevent undefined behavior.
	x: 0
	y: 0

	// Input masks won't be applied correctly when compositing is disabled unless I do this. WHY?
	onYChanged: {
        Plasmoid.setTransparentWindow();
    }
	onXChanged: {
        Plasmoid.setTransparentWindow();
    }

    onVisibleChanged: {
    }
	backgroundHints: PlasmaCore.Types.NoBackground // Prevents a dialog SVG background from being drawn.
	visible: {
        if(KWindowSystem.isPlatformX11) return kicker.compositingEnabled ? true : stickOutOrb;
        return stickOutOrb
    }
	opacity: iconUser.visible && root.visible && stickOutOrb// To prevent even more NP-hard unpredictable behavior and visual glitches.

	// The actual orb button, this dialog window is just a container for it.
	mainItem: FloatingOrb {
        id: floatingOrbIcon
    }
}
