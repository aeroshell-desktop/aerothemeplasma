# Installation

## TABLE OF CONTENTS

1. [Prerequisites](#preq)
2. [Plasma components](#plasma)
3. [KWin components](#kwin)
4. [Miscellaneous components](#misc)
5. [Configuring AeroThemePlasma](#conf)

## Prerequisites <a name="preq"></a>

### Arch Linux
Required packages:

```bash
pacman -S cmake extra-cmake-modules ninja qt6-virtualkeyboard qt6-multimedia qt6-5compat plasma-wayland-protocols plasma5support kvantum
```
- (optionally) plymouth

### KDE Neon/Kubuntu
Required Packages:

```bash
apt install cmake extra-cmake-modules ninja-dev qt6-virtualkeyboard qt6-virtualkeyboard-dev qt6-multimedia qt6-multimedia-dev qt6-5compat plasma-wayland-protocols kf6-plasma5support kf6-kcolorscheme-dev kf6-ki18n-dev kf6-kiconthemes-dev kf6-kcmutils-dev kf6-kirigami-dev libkdecorations2-dev kwin-dev kf6-kio-dev kf6-knotifications-dev kf6-ksvg-dev plasma-workspace-dev kf6-kactivities-dev gettext kvantum
```
- optionally plymouth (pre-installed on KDE Neon)

### Fedora KDE
Required Packages:

```bash
dnf install plasma-workspace-devel kvantum qt6-qtmultimedia-devel qt6-qt5compat-devel libplasma-devel qt6-qtbase-devel qt6-qtwayland-devel plasma-activities-devel kf6-kpackage-devel kf6-kglobalaccel-devel qt6-qtsvg-devel wayland-devel plasma-wayland-protocols kf6-ksvg-devel kf6-kcrash-devel kf6-kguiaddons-devel kf6-kcmutils-devel kf6-kio-devel kdecoration-devel kf6-ki18n-devel kf6-knotifications-devel kf6-kirigami-devel kf6-kiconthemes-devel cmake
```

## Plasma components <a name="plasma"></a>

This section relates to the directories found in the ```plasma``` folder.

1. Move the ```smod``` folder to ```~/.local/share```. This will install the resources required by many other components.

2. Move the folders ```desktoptheme```, ```look-and-feel```, ```plasmoids```, ```shells``` into ```~/.local/share/plasma```. If the folder doesn't exist, create it. These folders contain the following:
    - Plasma Style
    - Global Theme (more accurately, just the lock screen)
    - Plasmoids
    - Plasma shell

Make sure to compile the C++ components of plasmoids located in ```plasmoids/src/``` by running ```install.sh``` for every source folder. 

3. Move ```sddm-theme-mod``` to ```/usr/share/sddm/themes```, and then run ```install-services.sh``` found in ```sddm-theme-mod/Services```.
4. Import and apply the color scheme through System Settings. 
7. When applying the global theme, only apply the splash screen and uncheck everything else.

## KWin components <a name="kwin"></a>

This section relates to the directories found in the ```kwin``` folder.

1. Compile the decoration theme and C++ KWin effects (found in ```effects_cpp``` and ```decoration``` respectively) using the provided install scripts.
2. Move ```effects```, ```tabbox```, ```outline```, ```scripts``` to ```~/.local/share/kwin```.
3. In System Settings, apply the following settings: 
- In Window Behavior -> Titlebar Actions: 
    - Mouse wheel: Do nothing
- In Window Behavior -> Task Switcher:
    - Main: Thumbnail Seven, Include "Show Desktop" entry
    - Alternative: Flip Switch, Forward shortcut: Meta+Tab
- In Window Behavior -> KWin Scripts: 
    - Enable Minimize All, SMOD Peek
- In Window Behavior -> Desktop Effects, enable the following: 
    - Aero Glass Blur
    - Desaturate Unresponsive Applications
    - Fading Popups
    - Login
    - Logout
    - SMOD Glow
    - SMOD Snap
    - Squash
    - SMOD Peek
    - Scale
    - Dim Screen for Administrator Mode
- In Window Behavior -> Desktop Effects, **disable** the following: 
    - Background Contrast
    - Blur
    - Maximize
    - Sliding Popups
    - Dialog Parent
    - Dim Inactive

## Miscellaneous components <a name="misc"></a>

This section relates to the directories found in the ```misc``` folder.

1. Run the install script for ```defaulttooltip```
2. Move the ```Kvantum``` folder (the one inside the ```kvantum``` folder) to ```~/.config```, then in Kvantum Manager select the theme.
3. Unpack the sound archive and move the folders to ```~/.local/share/sounds```, then select the sound theme in System Settings.
4. Unpack the icon archive and move the folder to ```~/.local/share/icons```, then select the icon theme in System Settings.
5. Unpack the cursor archive and move the folder to ```/usr/share/icons```, then follow [this](https://www.youtube.com/watch?v=Dj7co2R7RKw) guide to install the cursor theme. 
5. Move the files located in ```mimetype``` into ```~/.local/share/mime/packages``` and then run ```update-mime-database ~/.local/share/mime``` to fix DLLs and EXE files sharing the same icons.
6. Segoe UI, Segoe UI Bold, and Segoe UI Italic are required for this theme and they should be installed as system-wide fonts.

If SDDM fails to pick up on the cursor theme, go to System Settings -> Startup and Shutdown -> Login Screen (SDDM), and click on Apply Plasma Settings to enforce your current cursor theme, and other relevant settings. Do this *after* installing everything else. If even that fails, change the default cursor theme in ```/usr/share/icons/default/index.theme``` to say ```aero-drop```.

## Configuring AeroThemePlasma <a name="conf"></a>

1. Set the panel height to 40px (or 30px for small taskbar).
2. Upon installation and configuring the panel layout, restart plasmashell and/or kwin (```plasmashell --replace & disown``` and ```kwin_x11 --replace & disown``` in the terminal respectively) as needed
3. When updating KDE Plasma, usually through a full system upgrade, recompiling KWin effects and the DefaultToolTip component is necessary.
4. In System Settings -> Fonts, configure the fonts as shown here:

<img src="screenshots/fontconfig.png">

The following steps are optional: 

4. To enable full font hinting just for Segoe UI, move the ```fontconfig``` folder to ```~/.config```. This will enable full font hinting for Segoe UI while keeping slight font hinting for other fonts. *While full font hinting makes the font rendering look sharper and somewhat closer to Windows 7's ClearType, on Linux this option causes noticeably faulty kerning. This has been a [prominent](https://github.com/OpenTTD/OpenTTD/issues/11765) [issue](https://gitlab.gnome.org/GNOME/pango/-/issues/656) [for](https://gitlab.gnome.org/GNOME/pango/-/issues/463) [several](https://gitlab.gnome.org/GNOME/pango/-/issues/404) [years](https://github.com/harfbuzz/harfbuzz/issues/2394) [now](https://www.phoronix.com/news/HarfBuzz-Hinting-Woe) and while the situation has improved from being unreadable to just being ugly, a complete solution for this doesn't seem to be coming anytime soon.*
5. For Wine users it's recommended to install the [VistaVG Ultimate](https://www.deviantart.com/vishal-gupta/art/VistaVG-Ultimate-57715902) msstyles theme.
6. Add the following to ```~/.bashrc``` to get bash to look more like the command prompt on Windows:

```
PS1='C:${PWD//\//\\\\}> '

echo -e "Microsoft Windows [Version 6.1.7600]\nCopyright (c) 2009 Microsoft Corporation.  All rights reserved.\n"
```

7. In the terminal emulator of your choice (e.g Konsole), set the font to [TerminalVector](https://www.yohng.com/software/terminalvector.html), size 9pt. Disable smooth font rendering and bold text, reduce the line spacing and margins to 0px, set the cursor shape to underline, and enable cursor blinking. 
