FULL CHANGELOG OF THE NEWEST RELEASE:

Bugfixes:

- Fixed Start menu not appearing in the right place.
- Start menu elements will no longer become messed up after opening certain settings pages.
- Taskbar tooltips will no longer automatically select themselves as if it is hovered for the first time.
- The close button of taskbar tooltips will no longer prevent highlighting of a window.
- The tooltip hover will now be automatically visible only for the currently active window.
- The clock widget has a tooltip again, displaying the current day, month and year.
- Some system tray tooltips have their text moved from the subText property to mainText, to improve readability.
- Fixed smaragd's awkward maximised window rendering.
- The Desktop no longer rearranges itself during startup.
- Fixed plasma themed tabs.

QoL changes:

The following graphical elements now have SVG textures for better scaling and more faithful design:
- System tray "Show hidden icons" arrow
- Show Desktop widget
- Start menu sidebar menu entries
- Start menu shutdown and lock buttons

SYSTEM TRAY:

- The size of system tray icons has been reduced to 16px.
- The size of the system tray popup menu has been reduced.
- The system tray popup menu has a new design which stands out from other dialogue menus. This style follows the colour scheme set by AeroColorMixer.
- System tray items will have a hover effect, as well as a press effect.
- The popup menu is now a floating dialogue menu.
- The system tray has updated icons.

DIGITAL CLOCK:

- The clock has a hover and press effect.
- The popup menu shares the same design as the system tray.
- The size of the clock popup menu has been reduced, making the calendar much smaller.
- The clock shows the current day, and long date at the top of the popup menu.
- The layout has been moved to make the calendar appear on the left, while events appear on the right and take up less space.

WINDOW DECORATIONS:

- The height of the window titlebar is now smaller.
- The horizontal offset of caption buttons is reduced past its minimum limit of 0. (CAUTION: Opening the window theme in Emerald settings will reset the horizontal offset back to 0. Reverting the horizontal offset back requires editing the theme configuration file manually.)
- Window decorations have sidebar glow effects.
- Window decorations have text caption glow.
- Window decorations have an incomplete reflection effect. (TODO: The effect does not update itself upon moving the window)

TASKBAR: 

- The size of taskbar tooltips has been reduced, and hovering over a tooltip will show a highlighted rectangle. 
- The size of taskbar items themselves are set to match the size of Windows 7 taskbar items.
- Taskbar item labels can be switched on or off on the fly in the settings, instead of having to change plasmoids completely.
- Taskbar items now have mouse hot tracking, which takes the dominant colour of the task icon. 
- If the task icon is missing, it will be replaced by a generic icon. 
- If the icon in question has a dominant colour with low saturation and lightness (greys, white and black colours), the dominant colour is then set to a predefined blue colour. 
- The text sizes of taskbar tooltips have been greatly reduced.
- The task manager (KSysGuard) can be opened from the taskbar.
- The task buttons have an updated look for grouped tasks. 
- Newly opened tasks will show an animation which fades out after a while if the application refuses to start. This feature needs more work.
- Tasks pinned to the taskbar now have a hover and press animation similar to the system tray and clock plasmoids.

START MENU:

- The Start menu button has three states: Normal, hover, and pressed.
- These states are configurable by the user, who can set icons, custom images files or bitmaps for each state.
- There is a smooth transition when changing between states.
- The Start menu follows the design of Windows 7's Start menu.

PLASMA THEME:

- Some buttons and tabs have a new and improved look.
- The highlight svg has an improved look.
- Solid dialogues have been added to make the system tray and clock plasmoids look distinct.
- The entire plasma theme is configurable via AeroColorMixer, which is able to change the colour scheme.
- Elements affected by AeroColorMixer are the panel, window decoration, dialogues and 'solid' dialogues.
- Replaced certain plasma icons with Windows 7 counterparts.
- Progress bars have an updated look and have more width.
- Task elements have a stacked+ prefix, which are used by the task manager to display grouped tasks.
- The 'busy' widget has an updated look.
- Most icons have been downscaled to 16px sizes.

MISC:

- The desktop has reduced icon sizes as well as reduced spacing.
- The general icon theme has been updated and improved in many areas. Work still needs to be done here.
- Kvantum has been added as an optional Qt visual style to replace QGtkStyle, although either one can be picked by the user. 
- GTK 2 applications can also be themed to look like Windows 7.


