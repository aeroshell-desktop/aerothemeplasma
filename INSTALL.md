# WIP Install guide, a more thorough one will be made once porting is done

## Prerequisites

On Arch, you'll need ```cmake, extra-cmake-modules, ninja, qt6-virtualkeyboard, qt6-multimedia, qt6-5compat, plasma-wayland-protocols, plasma5support, kvantum, optionally plymouth ```

### Notes:

1. Wayland support seems to be better than before probably, but it's not fully supported yet, it still has some jank
2. SevenTasks is missing from the repo until it is fully complete

## Plasma stuff

1. Move ```desktoptheme```, ```look-and-feel```, ```plasmoids```, ```shells``` into ```~/.local/share/plasma```
2. Move ```smod``` to ```~/.local/share```
3. Move ```sddm-theme-mod``` to ```/usr/share/sddm/themes```, run ```install-services.sh``` found in ```sddm-theme-mod/Services```
4. If needed, compile SevenStart's C++ component by running the install script found in ```plasmoids/src/sevenstart_src```
4. Import color scheme through system settings
5. Apply the appropriate settings in system settings
6. When applying the global theme, only apply the splash screen and uncheck everything else
6. Restart plasma (```plasmashell --replace & disown``` in terminal)


## KWin stuff

1. Compile the decoration theme and C++ KWin effects (found in ```effects_cpp``` and ```decoration``` respectively) using the install scripts provided (from experience, I don't think just placing the precompiled binaries will work as KWin won't register them)
2. Move ```effects```, ```tabbox```, ```outline```, ```scripts``` to ```~/.local/share/kwin```
3. Apply the appropriate settings in system settings
4. Restart kwin (```kwin_x11 --replace & disown``` in terminal)

## Misc stuff

1. Run the install script for ```defaulttooltip```
2. Move the ```Kvantum``` folder (the one inside the ```kvantum``` folder) to ```~/.config```
3. Unpack the sound archive and move the folders to ```~/.local/share/sounds```
4. Unpack the icon archive and move the folder to ```~/.local/share/icons```
5. Unpack the cursor archive and move the folder to ```/usr/share/icons``` (this is done so that SDDM can load the cursor theme)
5. Configure stuff in system settings and possibly elsewhere if needed (setting up cursors and SDDM stuff can be tricky sometimes, consult [this](https://www.youtube.com/watch?v=Dj7co2R7RKw) guide for installing cursors on Linux)
6. You'll need to install at least Segoe UI, Segoe UI Bold, and Segoe UI Italic as system-wide fonts

## Installation notes

2. If SDDM fails to pick up on the cursor theme, go to System Settings -> Startup and Shutdown -> Login Screen (SDDM), and click on Apply Plasma Settings to enforce your current cursor theme, and other relevant settings. Do this *after* installing everything else.
