# SEVENSTART

## TABLE OF CONTENTS
1. [Detailed description](#description)
2. [File structure](#files)

## Detailed description <a name="description"></a>

SevenStart is an application launcher designed to look and feel like the Windows 7 start menu. While not a perfect recreation of the start menu, SevenStart implements the following features:

1. Animated menu orb, configurable much like Classic/Open Shell.
2. Layout similar to Windows 7's Start menu.
3. Sidebar with configurable entries.
4. User profile icon that sticks out of the menu when compositing is enabled.
5. Crossfading icons between the user profile icon and sidebar entries.
6. Search results that are organized into separate categories.

As SevenStart uses code from other application launchers in KDE, it improves upon the original start menu mainly in the search department, as SevenStart will show results from available KRunner search plugins installed on the system.

SevenStart (and other plasmoids) can use internal resources for components such as FrameSvgItems through the use of ```Qt.resolveUrl(path)```, where ```path``` is a relative path to a file or directory. The path provided is relative to the internal source code of the plasmoid, so where ```main.qml``` is located. The function returns a ```url``` that ends up being the absolute path to the file.
This is heavily used throughout most other AeroThemePlasma's plasmoids in order to use custom SVGs without having to resort to workarounds such as polluting the Plasma style, however SevenStart arguably uses it the most.

### CompactRepresentation

The first notable thing about SevenStart is the use of animated icons or "orbs" as they're called on Windows. Since QtQuick doesn't offer image crossfading by default, the effect is achieved "manually", using three separate images and gradually changing their opacities and visibility.

In earlier versions of SevenStart, only two images were used, but now three images are used due to upstream updates causing subtle timing issues that would cause undesirable visual effects. Using three images did end up allowing SevenStart to replicate the effects of Vista and 7's Start menu more accurately. By default, SevenStart uses internal icons if no external icons are provided in the configuration window.

Another notable thing about the compact representation is that it is used in an unusual way compared to how plasmoids are generally designed to behave. Plasmoids have two representations:

1. Compact representation, which is used when the plasmoid is in a panel.
2. Full representation, which is used when the plasmoid is either activated from the panel, or placed on the desktop.

In practice, compact representations are just icons that get highlighted when hovered over with the mouse, with a tooltip explaining what the icon is supposed to be.
If the compact representation is set to null, then the plasmoid will be presented in its full representation regardless of its parent object. This is useful for application launchers, which typically should always have their main menu hidden behind a clickable button, regardless of its placement and hierarchy. However, this means that the main dialog window, which would normally be the full representation, now has to be handled manually by the plasmoid, and it's up to the developer on how to make it appear on the screen.

### User icon

The user icon in SevenStart is actually just another dialog window that is placed on top of the full representation, which is also a dialog window. To prevent the dialog from rendering its background, the ```backgroundHints``` property is set to ```PlasmaCore.Types.NoBackground```, which also disables shadows and blur. In a similar fashion, other plasmoids in this project use this property to change the appearance of their dialog windows, setting the property to ```PlasmaCore.Types.SolidBackground```.

The window flag ```Qt.X11BypassWindowManagerHint``` is used to prevent the dialog from animating its opacity when its visibility is changed directly, and ```Qt.Popup``` is used to ensure that it's
above the parent dialog window.

Setting the location to "Floating" means that we can use manual positioning for the dialog
which is important as positioning a dialog like this is tricky at best and unpredictable
at worst. Positioning of this dialog window can only be done reliably when:

1. The parent dialog window is visible, this ensures that the positioning of the window is actually initialized and not simply declared.
2. The width and height of the parent dialog window are properly initialized as well.

This is why the position of this window is determined on the ```onHeightChanged``` slot of the
parent window, as by then both the position and size of the parent are well defined*.
The ```firstTimePopup``` boolean is used to make sure that the dialog window has its correct position values before it is made visible to the user.

*It should be noted that the position values for any dialog window are gonna become
properly initialized once the visibility of the window is enabled, at least from what
I could figure out. Anything before that and the properties won't behave well. To comment on [MMcK Launcher](https://store.kde.org/p/1720532)'s implementation, this is likely why positioning of the floating
avatar is so weird and unreliable. Using uninitialized values always leads to
unpredictable behavior, which leads to positioning being all over the place.

## File structure <a name="files"></a>

While this section won't cover all of the files, it will cover the most important ones.

Directories:

|Location|Description|
|--------|-----------|
|config/ |Contains the configuration properties and the loader QML file.|
|pics/   |Contains raster images used by this plasmoid.|
|ui/     |Most of the QML source code can be found here.|
|ui/svgs/|SVG textures used by this plasmoid.|
|ui/orbs/|Default orb textures for the compact representation.|
|ui/code/|Helper JS code used by various parts of this plasmoid.|

Files:

|Name|Description|
|----|-----------|
|main.qml|Main QML file used to run the plasmoid.|
|CompactRepresentation.qml|Compact representation which displays the animated orb icons.|
|MenuRepresentation.qml|The expanded representation which is the application launcher itself.|
|KickoffListView.qml|Generic list view used by most views of this plasmoid.|
|CrossFadeBehavior.qml|Behavior used when crossfading two or more images.|
|IconPicker.qml|Used for opening and selecting icons. Used for selecting different icons.|
|SearchView.qml|Used to display the search results.|
|FavoritesView.qml|Used to display favorite programs.|
|OftenUsedView.qml|Used to display recently opened programs.|
|SidePanelItemDelegate.qml|Displays and holds information about the sidebar menu entries.|
|ApplicationsView.qml|Used to display all applications installed on the system.|
