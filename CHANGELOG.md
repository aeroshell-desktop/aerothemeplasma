#Version 0.1 (Formal release)

##SUMMARY:

A lot of components have been added into this project, as well as some overhauled design, improvements in the themes, bug fixes that come from both the project and upstream development. Updated to work with KDE Plasma 5.25.4, and KWin 5.25.4 (KWinFT 5.25.0).

The biggest changes were made to the Start Menu, System Tray, the Date & Time, and general Plasma look and feel to make it more compact and use up less visual space, as well as improve readability in many areas.

This release also features a new Qt visual style for Kvantum, which is supposed to replace QGtkStyle for Qt applications. The GTK2 theme is still available for GTK2 applications, and can optionally still be used for Qt applications as well. 

**Authors of forked projects are all credited in the README.md file. **

The full list of all additions, changes and fixes:

###NEW:

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

###CHANGED:

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

###FIXED:

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
