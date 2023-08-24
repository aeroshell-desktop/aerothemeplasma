<h1>Version 0.2</h1>

<h2>SUMMARY:</h2>

The folder structure has been modified to simplify things and prepare it for an eventual install script. Most changes are internal, fixing bugs and cleaning up the codebase. Updated to work with KDE Plasma 5.27.7.

Major changes in this release include the addition of documentation, the reflection effect for KWin, a login splash screen, and a complete redesign of Seven Tasks' context menu. An important change is that AeroColorMixer has been deprecated in this release, and most of the codebase has been merged with the reflection effect. This change simplifies the process of applying accent colors to windows and eliminates the need to directly edit config files and SVG textures. Additionally, this change now lets the user see the accent color changing in real time as they configure the effect.

An effort is being made to standardize the internal codebase as well as the internal folder structure. The documentation is not complete, but I feel that it's a good start.

The install script is a very early WIP, and I don't recommend using it, I'm not particularly happy with its current state so I have chosen to leave it in the "Testing" folder. Initially I wanted to include an install script for this release of AeroThemePlasma, but ultimately I decided it would be best to keep working on it and hopefully come up with a more sophisticated solution than whatever this is right now. The same goes for the Global/Look and feel theme, it's still early in development and probably broken right now.

Lastly, I'd like to apologize for the radio silence and for taking so long. I haven't been in the right space for a while now, and recovery has taken up most of my time and energy, I hope that's understandable. Regardless, thank you for your patience if you've waited this long.

<h2>NEW:</h2>

- Added Aero Splash Screen (io.gitgud.wackyideas.aerosplashscreen).
- Added documentation for various components of this project.
- Added a KWin reflection effect.
- Added a KWin task switcher (Thumbnail Seven).
- Added a new color in the list of predefined accent colors (Sunset).
- Deprecated AeroColorMixer, code has been merged with the reflection effect.

<h2>CHANGED:</h2>

<h3>Meta:</h3>

- [INSTALL.md](./INSTALL.md) has been updated to reflect the new changes in the internal folder structure.
- Most folders now have underscores instead of spaces in their names for easier handling for the future install script.
- Most plasmoids have been renamed in a more standardized fashion.
- Most plasmoids no longer have their own folder, and they're now only separated between User and System widgets.
- Color scheme has been renamed to AeroColorScheme.
- The icon and cursor themes are provided as tar archives.
- Most plasmoids now use their own internal SVG textures instead of pulling them from Seven-Black. In the future, Seven-Black will get rid of these non-standard SVG elements.
- Removed the accent color in all SVG textures from Seven-Black, as that is now handled by the reflection effect.
- Most plasmoids now have updated default configs, reducing the amount of work needed during installation.
- Minor changes done to the Plasma style.

<h3>Icon theme:</h3>

- The icon theme now optionally depends on the [Oxygen icon theme](https://invent.kde.org/frameworks/oxygen-icons5).
- Updated a lot of icons, mainly related to icons related to Office and development.

<h3>Seven Start:</h3>

- Start menu orbs are now included within the project itself and are provided as a default option.
- Start menu orbs now behave more like Windows 7's menu orbs, removing the animated transition between hovered and pressed states, as it was causing weird visual bugs.
- Sidebar items can now be toggled on or off.
- When adding the widget, it won't add default favorite items anymore.
- The entire start menu now has basic keyboard navigation support. It's still a bit rough around the edges, but everything works.
- The profile icon now sticks out of the start menu when compositing is enabled. When compositing is disabled, the icon is moved fully inside the start menu.
- The profile icon now crossfades into icons depending on the selected sidebar item.
- The search text box now has a decorative magnifying glass icon on the right.

<h3>Desktop containment:</h3>

- Tooltips no longer show the icon of the hovered item.
- Reduced padding as a result of text alignment.
- The textbox that appears when renaming an item is now properly aligned.

<h3>DigitalClockLite:</h3>

- Added a link label at the top of the expanded representation representing the currently selected date. Clicking on it will select the current day.

<h3>Kvantum:</h3>

- Changed the tooltip to look more like Windows 7's tooltip design.

<h3>Seven Tasks:</h3>

- Completely redesigned the context menu to match the appearance from Windows Vista and 7.
- The context menu won't aggressively grab key inputs anymore, unlike standard context menus.
- Seven Tasks will no longer create pinned tasks when adding the plasmoid to a panel.
- Tooltips now have a dedicated SVG texture for the close button.
- Tooltips that display cover art now have a textured frame around the blurred background of the cover art.

<h3>Smaragd Seven:</h3>

- Updated to provide a correct blur region.
- Smaragd Seven no longer requires the reflection texture to function, as that is now handled by KWin's reflection effect.

<h2>FIXED:</h2>

- Added higher resolution icons so certain plasmoids don't display their low resolution counterparts.
- In the expanded view of the system tray, the icon highlight won't get stuck anymore when the mouse exits an icon.
- Clicking on an icon in the compact view of the system tray will now always close the expanded representation, if applicable.
- Seven Start now accepts key inputs more consistently and will no longer accept unprintable characters to the search text box.
- Seven Start will no longer try to open Dolphin when opening sidebar entries. Instead, it will open the directories using the default file manager on the system.
- Fixed bug in the Desktop containment where the symlink icon in the corner is drawn smaller than it should be when the icon is provided by a thumbnailer plugin.
- Smaragd Seven no longer renders the fake reflection effect.
- Kvantum will no longer attempt to blur certain elements like tooltips.
- Updated plasmoids to work with the latest version of KDE.
- Minor visual enhancements in various aspects of this project.
- Certain tooltips are no longer rendered incorrectly (this could have just been a problem on my machine)
- Seven-Black has updated panel margins so that panels now render correctly on newer versions of KDE.
- Minor bugfixes and fixing deprecated code.
- The color mixer window (formerly AeroColorMixer) has been fixed to work with Wayland.

<h1>Version 0.1 (Formal release)</h1>

<h2>SUMMARY:</h2>

A lot of components have been added into this project, as well as some overhauled design, improvements in the themes, bug fixes that come from both the project and upstream development. Updated to work with KDE Plasma 5.25.4, and KWin 5.25.4 (KWinFT 5.25.0).

The biggest changes were made to the Start Menu, System Tray, the Date & Time, and general Plasma look and feel to make it more compact and use up less visual space, as well as improve readability in many areas.

This release also features a new Qt visual style for Kvantum, which is supposed to replace QGtkStyle for Qt applications. The GTK2 theme is still available for GTK2 applications, and can optionally still be used for Qt applications as well. 

<h3>NEW:</h3>

- The following plasmoids have been added:
    - Added **DigitalClockLite Seven**, a fork of DigitalClockLite.
    - Added **Seven Start**, a fork of Avalon Menu.
    - Added **Seven Tasks**, a fork of KDE's Icons-only Task Manager.
    - Added a forked version of the **Show Desktop (Win 7)** plasmoid. 
- Added Plasma theme **Seven Black**.
- Added a Windows 7 icon theme.
- Added a Windows 7 cursor theme.
- Added Windows 7 system sounds.
- Added an Aero Kvantum theme.
- Added an Aero GTK2 theme.
- Added KWin decoration **Smaragd Seven**, a fork of Smaragd.
- Added an Aero Emerald theme for Smaragd Seven.
- Added an Aero Wine theme.
- Added **AeroColorMixer**, an application for configuring this theme.

<h3>CHANGED:</h3>

- The following changes have been made to the System Tray:
    - The size of the popup dialog has been reduced.
    - The popup dialog is now a floating popup.
    - The popup dialog now follows the **solid** variant of dialogs.
    - The popup dialog's title text has been reduced in size. 
    - The 'Show hidden icons' arrow has been moved to the beginning of the System Tray.
    - The 'Show hidden icons' arrow has a hover and press state. 
    - Tray icons have a hover and press state which have faded transitions. 
- DigitalClockLite Seven follows the same visual aesthetic as the System Tray.
- DigitalClockLite Seven's compact representation has a hover and press state.
- DigitalClockLite Seven has's full representation has been reduced in size and padding.
- The Show Desktop (Win 7) button is now textured to match the Aero visual style.
- Desktop icons are smaller and have less spacing between them.
- Tooltips have better text visibility and small font sizes, as well as less padding.
- The following changes have been made to the Icons-only Task Manager (Seven Tasks):
    - Task icons can now switch between showing/hiding labels on the fly, without the need for two different plasmoids.
    - KSysGuard can be accessed from the taskbar by right clicking on an empty space and selecting "Task manager".
    - Pinned tasks have a hover and press state and smaller, compact tooltips.
    - Opening a program shows a startup animation, and the icon fades away after a while in case the program is not responding or opening right away. 
    - Tasks have hot tracking hover effects based on the icon's dominant colour.
    - Tasks have Aero-like grouping visual elements.
    - Task previews are designed to look like Aero task previews.
    - Task previews now have a small icon in the top-left corner.
    - Task previews have one row of text on top instead of two, omitting the redundant application name, displaying it only as a fallback.
    - Task previews have been reduced in size and have readjusted margins. 
    - Task preview font sizes have been reduced.
    - Media controls in task previews have been reduced in size.
    - Task previews have a more accurate and functional hover element to indicate the state of the window and its actions.
- The keyboard layout switcher plasmoid has a reduced font size and improved alignment. 
- The keyboard layout switcher also features a hover and press state button element.
- AeroColorMixer now reads its configuration file from ```~/.config/.aerorc``` in order to not pollute the home directory. 
- Overhauled Seven Start's search layout in style.
- Improved Seven Start's padding, layout, and sped up the animation to make it feel snappier.
- Reorganised the entire repository to make it look and feel less cluttered.

<h3>FIXED:</h3>

- Fixed the state logic for the hover effect on desktop icons. The hover effect now properly implements the hover, selected, and hover+selected states. 
- The taskbar hover preview is no longer enabled on startup, even if the user hasn't actually hovered over the preview.
- Taskbar hover previews will no longer show scrollbars.
- Task icons in the taskbar will now show a generic icon when the programs fails to provide its own icon. 
- Removed a deprecated line of code which crashes Seven Tasks due to upstream changes. [#5]
- Fixed the bug where Smaragd will still allow you to resize the window when it is maximized. 
- The binary for Smaragd is now placed in an easy to find directory and is properly documented. [#2]
- Smaragd will now disable rounded corners for maximized windows. 
- Fixed minor padding issues with Smaragd.
- Smaragd will no longer draw text glow if there is no text in the first place.
- Updated Smaragd to the new API changes in upstream. Smaragd blurs properly once again and no longer has the "kornerbug" issue. [#6]
- Fixed various positioning bugs related to Seven Start. [#1][#4]
- Updated side links to the latest syntax for KDE's System Settings and Default Programs in Seven Start.
- The avatar icon in Seven Start now causes the mouse cursor to change to the pointing hand cursor.
- The buttons for changing Seven Start's orb icons are no longer disabled by mistake. [#4]
- Seven Start's side elements will no longer randomly glitch out for no reason.
- Fixed layering issues with Seven Start. 
- Fixed certain crashes related to Seven Start.
- Recent programs will now update every time Seven Start is opened. 
- Fixed the animation duration for System Tray icons. 
- Fixed minor padding, sizing and alignment issues in various places. 
- Fixed the huge separator line appearing in a few plasmoids.
- Restored the appearance of the tab widget used for plasmoids.
- Fixed AeroColorMixer to work with the current version. 
- Added and replaced a bunch of icons with Aero counterparts. 
- Removed unnecessary debugging console output. 
- Many visual elements have been ported from Aero with as SVGs for DPI scaling.
- Replaced (most) raster textures used in Seven Start with SVGs for better DPI scaling.
