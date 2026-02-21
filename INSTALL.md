# Installation

## TABLE OF CONTENTS

1. [Prerequisites](#preq)
2. [Migration notice](#migration)
3. [Getting started](#started)
4. [Optional](#optional)
5. [GTK](#gtk)
6. [Uninstalling AeroThemePlasma (old)](#uninstall_old)

## Prerequisites <a name="preq"></a>

It's necessary to have KDE Plasma already installed on your system (plasma-workspace and plasma-desktop) in order to get all the Plasma-specific dependencies for AeroThemePlasma.

Before installing AeroThemePlasma, it's important to know which display server you're running on (Wayland or X11). This can be checked using Plasma's Info Center page in the settings. It's recommended to run AeroThemePlasma on X11 for now, as it's generally the more stable and feature rich experience (certain restrictions on the Wayland session make some effects and features impossible to achieve, this should hopefully be addressed in the future).

### Arch Linux

Required packages:

```bash
pacman -S git cmake extra-cmake-modules ninja curl unzip qt6-virtualkeyboard qt6-multimedia qt6-5compat qt6-wayland plasma-wayland-protocols plasma5support kvantum sddm sddm-kcm base-devel plasma-nm plasma-pa plasma-workspace plasma-desktop kwin-x11 plasma-x11-session
```

Since Plasma 6.4, the X11 session has been separated from the main codebase. On Arch Linux, additional dependencies for X11 include:

- `kwin-x11`
- `plasma-x11-session`

KSysGuard has been officially deprecated by KDE, however an unofficial [port](https://github.com/zvova7890/ksysguard6) exists for Qt6, which can be installed using the [AUR](https://aur.archlinux.org/packages/ksysguard6-git) package on Arch-based distros.

### Note: Dependencies for other distros besides Arch Linux have been provided by contributors and aren't updated frequently, which may result in incorrect or missing dependencies.

### Fedora KDE

Required Packages:

```bash
dnf install plasma-workspace-devel unzip kvantum qt6-qtmultimedia-devel qt6-qt5compat-devel libplasma-devel qt6-qtbase-devel qt6-qtwayland-devel plasma-activities-devel kf6-kpackage-devel kf6-kglobalaccel-devel qt6-qtsvg-devel wayland-devel plasma-wayland-protocols kf6-ksvg-devel kf6-kcrash-devel kf6-kguiaddons-devel kf6-kcmutils-devel kf6-kio-devel kdecoration-devel kf6-ki18n-devel kf6-knotifications-devel kf6-kirigami-devel kf6-kiconthemes-devel cmake gmp-ecm-devel kf5-plasma-devel libepoxy-devel kwin-devel kf6-karchive kf6-karchive-devel plasma-wayland-protocols-devel qt6-qtbase-private-devel qt6-qtbase-devel kf6-knewstuff-devel kf6-knotifyconfig-devel kf6-attica-devel kf6-krunner-devel kf6-kdbusaddons-devel kf6-sonnet-devel plasma5support-devel plasma-activities-stats-devel polkit-qt6-1-devel qt-devel libdrm-devel kf6-kitemmodels-devel kf6-kstatusnotifieritem-devel kf6-frameworkintegration-devel
```

On Fedora, additional dependencies for X11 include:

- `kwin-x11`
- `kwin-x11-devel`

### openSUSE Leap / Tumbleweed

Required packages:

```bash
zypper install cmake make ninja gcc gcc-c++ gmp-ecm-devel kf6-extra-cmake-modules qt6-base-devel qt6-quick-devel qt6-svg-devel qt6-quickcontrols2-devel kf6-kwindowsystem-devel kf6-karchive-devel kf6-kirigami-devel kf6-kbookmarks-devel kf6-kcodecs-devel kf6-kcolorscheme-devel kf6-kcompletion-devel kf6-kconfig-devel kf6-kconfigwidgets-devel kf6-kcoreaddons-devel kf6-kguiaddons-devel kf6-ki18n-devel kf6-kio-devel kf6-kitemviews-devel kf6-kjobwidgets-devel kf6-kservice-devel kf6-kwidgetsaddons-devel kf6-kxmlgui-devel kf6-solid-devel kf6-kglobalaccel-devel kf6-kiconthemes-devel kf6-knotifications-devel kf6-kpackage-devel kf6-ksvg-devel plasma6-activities-devel plasma-wayland-protocols qt6-wayland-devel qt6-quicktest-devel qt6-gui-private-devel kdecoration6-devel kf6-kcmutils-devel qt6-uitools-devel kf6-kcrash-devel libepoxy-devel kwin6-devel kwin6-x11-devel kf6-qqc2-desktop-style-devel knotifications-devel kf6-kauth-devel libplasma6-devel plasma5support6-devel plasma6-activities-stats-devel plasma6-workspace-devel
```

In openSUSE, additional dependencies for X11 include:

- `kwin6-x11-devel`

### Ubuntu 25.10

```bash
apt install build-essential cmake ninja-build curl libqt6virtualkeyboard6 libqt6multimedia6 libqt6core5compat6 libplasma5support6 libkdecorations3-dev libkf6colorscheme-dev libkf6i18n-dev libkf6iconthemes-dev libkf6kcmutils-dev libkirigami-dev libkf6kio-dev libkf6notifications-dev libkf6svg-dev libkf6crash-dev libkf6globalaccel-dev libplasma-dev libplasmaactivities-dev libxcb-composite0-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-damage0-dev libepoxy-dev libqt6svg6-dev kwin-dev plasma-wayland-protocols libkf5qqc2desktopstyle-dev libkf6qqc2desktopstyle-dev libplasma5support-dev libkf6auth-dev libkf6newstuff-dev libkf6notifyconfig-dev libkf6attica-dev libkf6runner-dev libkf6dbusaddons-dev libkf6sonnet-dev libkf6xmlgui-dev libkf6coreaddons-dev libkf6widgetsaddons-dev libkf6guiaddons-dev qt6-base-dev qt6-5compat-dev qml-module-org-kde-qqc2desktopstyle libplasmaactivitiesstats-dev plasma-workspace-dev libkf6statusnotifieritem-dev qml-module-org-kde-kirigami-addons-sounds qml6-module-org-kde-kirigamiaddons-sounds
```

On Ubuntu, additional dependencies for X11 include:

- `kwin-x11`
- `kwin-x11-dev`

## Migration notice <a name="migration"></a>

AeroThemePlasma has moved to an installation method based on CMake, meant to simplify the entire process, as well as make it easier for distro packaging in the future. The old install scripts are deprecated and no longer work. It's highly recommended to first uninstall the old instance of AeroThemePlasma following these steps:

1. Run the uninstall script:

```bash
$ bash migration-uninstall.sh
```

2. To undo the font rendering modifications, delete the `~/.config/fontconfig/fonts.conf` file provided by the previous versions of ATP.
3. Remove the line `QML_DISABLE_DISTANCEFIELD=1` from `/etc/environment`

It's advisable to also consult [Uninstalling AeroThemePlasma (old)](#uninstall_old) for more details. 

## Getting started <a name="started"></a>

### Arch Linux 

*AUR packages coming soon*

### From source 

To download this repository, clone it with `git`:

```bash
$ git clone https://gitgud.io/wackyideas/aerothemeplasma.git aerothemeplasma
$ cd aerothemeplasma
```

It's highly recommended to use git for downloading AeroThemePlasma as updating becomes much easier.

Run the following script:

```sh
$ bash install.sh --ninja # Pass --ninja to reduce build times
``` 

This will clone every repository needed for AeroThemePlasma and build everything from source.

You can also run the install script like this:

```bash
$ chmod +x install.sh && ./install.sh
```

## NOTE

The script relies on `LIBEXEC_DIR` in order to determine the location of `/usr/$LIBEXEC_DIR/plasma-dbus-run-session-if-needed`, needed for the Wayland session to properly start. By default, this is set to `lib`. If you're installing ATP on a distribution where this is different, such as Fedora, this needs to be set to the appropriate value for your specific distribution. For example, on Fedora, `LIBEXEC_DIR` should be `libexec`:

```bash
$ LIBEXEC_DIR=libexec bash install.sh --ninja
```

The script will ask for admin privileges for file installation. Do **NOT** run any of the provided install scripts with sudo/doas or as root.

**It's highly recommended** to keep the generated build files, so uninstalling AeroThemePlasma and its dependencies can be done using `sudo make uninstall` or `sudo ninja uninstall` in each build directory. A backup of all `install_manifest.txt` files (that list all files that have been installed on the system) is stored in the `manifest` folder.

### Updating AeroThemePlasma

Update and do `git pull` on the cloned repository to get new changes:

```bash
$ cd /path/to/aerothemeplasma
$ git pull
```

Re-run the install script as described in [Getting started](#started). The script will automatically pull changes for all cloned repositories and rebuild them. In case something needs to be rebuilt completely, simply delete the repository folder causing the build error, and re-run the install script.

When doing a full system upgrade, KWin effects and `libplasma` modifications tend to stop working. Re-running the install script after a full system upgrade is required for them to work again (assuming no breaking upstream changes happen).

### Uninstalling AeroThemePlasma

Uninstalling AeroThemePlasma can be done by running the following script:

```bash
$ bash uninstall.sh
```

This will go through almost every build directory and run `sudo make uninstall` or `sudo ninja uninstall` in those directories. After this, the `libplasma` package should be reinstalled using your distro's package manager. 

```bash
# On Arch Linux
$ sudo pacman -Sy libplasma
```

### Fonts 

On Arch Linux, use [this script](https://gitgud.io/aeroshell/aeroshell-workspace/-/blob/Plasma/6.6/scripts/install_fonts_arch.sh) to extract fonts and install them as an Arch package from a valid Windows 7 ISO. A 32-bit Windows 7 ISO is recommended for faster download speeds.

## Optional <a name="optional"></a>

1. For Wine users it's recommended to install the [VistaVG Ultimate](https://www.deviantart.com/vishal-gupta/art/VistaVG-Ultimate-57715902) msstyles theme.
2. Add the following to `~/.bashrc` to get bash to look more like the command prompt on Windows:

```bash
PS1='C:${PWD//\//\\\\}> '

echo -e "Microsoft Windows [Version 6.1.7600]\nCopyright (c) 2009 Microsoft Corporation.  All rights reserved.\n"
```

3. In the terminal emulator of your choice (e.g Konsole), set the font to [TerminalVector](https://www.yohng.com/software/terminalvector.html), size 9pt. Disable smooth font rendering and bold text, reduce the line spacing and margins to 0px, set the cursor shape to underline, and enable cursor blinking.

4. Install [PlymouthVista](https://github.com/furkrn/PlymouthVista) which supports Windows 7 boot animations, and features a more detailed setup guide.

## GTK <a name="gtk"></a>

AeroThemePlasma officially doesn't have any kind of maintenance, development or support for GTK applications. Instead, check out
[Windows 7 Better](https://gitgud.io/Gamer95875/Windows-7-Better) by [Gamer95875](https://gitgud.io/Gamer95875), which is the recommended set of themes that works best with AeroThemePlasma.

## Uninstalling AeroThemePlasma (old) <a name="uninstall_old"></a>

### This section is meant for users migrating away from older versions of AeroThemePlasma (Before Plasma 6.6). 

AeroThemePlasma provides an uninstall script that undoes much of what's installed on the system. The script assumes that all of the CMake build files are still present in the repo, most importantly the `install_manifest.txt` files generated as a result of installing compiled parts of ATP. If these files are missing from the repo, they need to be regenerated by once again rerunning the necessary scripts like this:

```bash
$ bash compile.sh --skip-libplasma [--wayland] [--ninja]
$ bash install_plasmoids.sh --skip-kpackages [--ninja]
```

Once this is done, the script is simply executed:

```bash
$ bash uninstall.sh
```

This should be run outside of the AeroThemePlasma session, preferrably in a regular Plasma session. The script will ask for confirmation to uninstall components of the system. **Please check that none of the locations are ill-formed before accepting each prompt, especially those that require additional privileges to uninstall. In case this happens to you, report it as an issue ASAP.**

Afterwards, `libplasma` and `polkit-kde-agent` should be reinstalled using your distro's package manager. For example, on Arch Linux:

```bash
sudo pacman -Sy libplasma polkit-kde-agent
```

### Manual uninstallation

The script performs the following steps in order to uninstall ATP. Uninstalling ATP should be done outside of the ATP session itself. Log into the Plasma session before performing any of these steps.

### CMake

- Perform `sudo make uninstall` or `sudo ninja uninstall` in the following directories if applicable:

```
kwin/decoration/build
plasma/sddm/login-sessions/build
plasma/aerothemeplasma-kcmloader/build
plasma/plasmoids/src/systemtray_src/build
plasma/plasmoids/src/notifications_src/build
plasma/plasmoids/src/volume_src/build
plasma/plasmoids/src/sevenstart_src/build
plasma/plasmoids/src/seventasks_src/build
plasma/plasmoids/src/desktopcontainment/build
kwin/effects_cpp/kde-effects-aeroglassblur/build
kwin/effects_cpp/kwin-effect-smodsnap-v2/build
kwin/effects_cpp/smodglow/build
kwin/effects_cpp/aeroglide/build
kwin/effects_cpp/startupfeedback/build

# For Wayland builds
kwin/effects_cpp/kde-effects-aeroglassblur/build-wl
kwin/effects_cpp/kwin-effect-smodsnap-v2/build-wl
kwin/effects_cpp/smodglow/build-wl
kwin/effects_cpp/aeroglide/build-wl
kwin/effects_cpp/startupfeedback/build-wl
```

### Plasmoids 

- Perform `kpackagetool6 -t "Plasma/Applet" -r "plasmoid_id"` for each plasmoid, replacing `plasmoid_id` with the following:

```
io.gitgud.wackyideas.battery
io.gitgud.wackyideas.desktopcontainment
io.gitgud.wackyideas.digitalclocklite
io.gitgud.wackyideas.keyboardlayout
io.gitgud.wackyideas.networkmanagement
io.gitgud.wackyideas.panel
io.gitgud.wackyideas.SevenStart
io.gitgud.wackyideas.seventasks
io.gitgud.wackyideas.volume
io.gitgud.wackyideas.win7showdesktop
```

### Plasma components 

- Perform the following commands:

```bash
kpackagetool6 -t "Plasma/LookAndFeel" -r "authui7"
kpackagetool6 -t "Plasma/LayoutTemplate" -r "io.gitgud.wackyideas.taskbar"
kpackagetool6 -t "Plasma/Theme" -r "Seven-Black"
kpackagetool6 -t "Plasma/Shell" -r "io.gitgud.wackyideas.desktop"
```

- Delete `~/.local/share/color-schemes/Aero.colors`
- Delete `~/.config/Kvantum/Windows7Aero` 
- Delete the sound themes from `~/.local/share/sounds`:

```
'Windows 7'
'Windows 7 Afternoon'
'Windows 7 Calligraphy'
'Windows 7 Characters'
'Windows 7 Cityscape'
'Windows 7 Delta'
'Windows 7 Festival'
'Windows 7 Garden'
'Windows 7 Heritage'
'Windows 7 Landscape'
'Windows 7 Quirky'
'Windows 7 Raga'
'Windows 7 Savanna'
'Windows 7 Sonata'
```

- Delete the icon theme at `~/.local/share/icons/Windows 7 Aero`
- Delete the following files at `~/.local/share/mime/packages`:

```
application-vnd.microsoft.portable-executable.xml 
application-x-ms-dll.xml 
application-x-msdownload.xml 
application-x-ms-ne-executable.xml
```

and run `update-mime-database ~/.local/share/mime` to refresh MIME associations

### KWin components 

- Perform `kpackagetool6 -t "KWin/Effect" -r "effect_id"` for each effect, replacing `effect_id` with the following:

```
dimscreenaero
fadingpopupsaero
loginaero
seventasks-thumbnails
smodpeekeffect
squashaero
```

- Perform the following: 

```bash
kpackagetool6 -t "KWin/Script" -r "smodpeekscript"
kpackagetool6 -t "KWin/WindowSwitcher" -r "flip3d"
kpackagetool6 -t "KWin/WindowSwitcher" -r "thumbnail_seven"
```

- Delete the outline at `~/.local/share/kwin/outline`
- Delete the symlinks `~/.local/share/kwin-x11` and `~/.local/share/kwin-wayland`
- Delete the branding at `~/.config/kdedefaults/kcm-about-distrorc` and the logo (`~/.config/kdedefaults/kcminfo.png`)

### Other components 

- Delete the cursor theme at `/usr/share/icons/aero-drop`
- Delete the SDDM theme at `/usr/share/sddm/themes/sddm-theme-mod`
- Delete the SMOD files at `/usr/share/smod` and `~/.local/share/smod`
- Delete `/opt/aerothemeplasma`
