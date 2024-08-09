# WIP Install guide

## Prerequisites

On Arch, you'll need ```cmake, extra-cmake-modules, qt6-virtualkeyboard, qt6-multimedia, qt6-5compat, kdeplasma-addons, plasma5support, kvantum, optionally plymouth ```

### Notes:

1. Wayland support seems to be better than before probably, but it's not fully supported yet, it still has some jank

## Plasma stuff

1. Move ```desktoptheme```, ```look-and-feel```, ```plasmoids```, ```shells``` into ```~/.local/share/plasma```
2. Move ```smod``` to ```~/.local/share```
3. Move ```sddm-theme-mod``` to ```/usr/share/sddm/themes```
4. Import color scheme through system settings
5. Apply the appropriate settings in system settings
6. Restart plasma (```plasmashell --replace & disown``` in terminal)

## KWin stuff

1. Compile the decoration theme and C++ KWin effects using the install scripts provided, I don't think just placing the precompiled ones will work as KWin won't register them
2. Move ```effects```, ```tabbox```, ```outline```, ```scripts``` to ```~/.local/share/kwin```
3. Apply the appropriate settings in system settings
4. Restart kwin (```kwin_x11 --replace & disown``` in terminal)

## Misc stuff

1. Run the install script for defaulttooltip
2. Move the ```Kvantum``` folder (the one inside the ```kvantum``` folder) to ```~/.config```
3. Unpack the sound archive and move the folders to ```~/.local/share/sounds```
4. Unpack the icon and cursor archives and move the folders to ```~/.local/share/icons```
5. Configure stuff in system settings and possibly elsewhere if needed (setting up cursors and SDDM stuff can be tricky sometimes)
6. You'll need to install at least Segoe UI, Segoe UI Bold, and Segoe UI Italic as system-wide fonts
