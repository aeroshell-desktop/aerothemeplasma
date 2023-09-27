
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
    flags: Qt.WindowStaysOnTopHint | Qt.Popup
	location: "Floating"

    outputOnly: true // Simplifies things, prevents accidental misclicks when clicking close to the orb.

    // Positions are defined later when the plasmoid has been fully loaded, to prevent undefined behavior.
	x: 0
	y: 0

	// Input masks won't be applied correctly when compositing is disabled unless I do this. WHY?
	onYChanged: {
        plasmoid.nativeInterface.setTransparentWindow();
    }
	onXChanged: {
        plasmoid.nativeInterface.setTransparentWindow();
    }
    onVisibleChanged: {
        if(visible) {
            orbTimer.start(); // Delayed initialization, again, for what reason?
        }
    }
	backgroundHints: PlasmaCore.Types.NoBackground // Prevents a dialog SVG background from being drawn.
	visible: root.visible && stickOutOrb
	opacity: iconUser.visible // To prevent even more NP-hard unpredictable behavior and visual glitches.

	// The actual orb button, this dialog window is just a container for it.
	mainItem: FloatingOrb {
        id: floatingOrbIcon
    }
    Component.onCompleted: {
        console.log("Orb initialized.");
    }
}
