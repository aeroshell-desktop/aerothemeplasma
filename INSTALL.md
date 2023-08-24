# Installation

## TABLE OF CONTENTS

1. [Prerequisites](#preq)
1. [KDE Plasma Settings](#plasma-settings)
1. [KDE Plasma Theme](#plasma-theme)
1. [Icons and cursors](#icons)
1. [Qt Visual Style](#application-theme)
1. [Fonts](#fonts)
1. [Window Manager](#wm)
1. [Reflection Effect](#reflection)
1. [Plasma Widgets](#widgets)
1. [Task Switcher](#task-switcher)
1. [Splash Screen](#splash-screen)
1. [Sounds](#sounds)
1. [Wine](#wine)
1. [Terminal](#terminal)


### Prerequisites <a name="preq"></a>

The following software is required for this project:

- KDE Plasma
- KWinFT/KWin with compositing support for blur and other effects
- Kvantum
- Some program to change the GTK2 theme, like ```gtk-chtheme```.
- Qt5 GraphicalEffects package (```qt5-graphicaleffects``` on Arch)

Optional programs:

- KMix, for a volume menu that looks more like Windows 7. For Pipewire users it might be better to just use the default volume plasmoid KDE provides.

### KDE Plasma Settings <a name="plasma-settings"></a>

Starting off with the simplest modifications, this is a list of recommended settings which are configurable in the system settings, to make Plasma behave more like Windows 7:

- Under Workspace Behaviour:
    - Under General Behaviour:
        - Clicking files or folders: Selects them
    - Under Desktop Effects:
        - Disable 'Background contrast' *(This theme does not make use of this option #9)*
        - Enable 'Blur', set Blur strength to 2, and Noise strength to 0
        - Enable 'Desaturate unresponsive applications'
        - Enable 'Fading popups'
        - Enable 'Login', check 'Fade to black' *(Apparently this effect is currently broken? It won't actually fade to black.)*
        - Enable 'Logout'
        - Enable 'Morphing popups'
        - Disable 'Sliding Popups'
        - Disable 'Translucency'
        - Enable 'Glide':
            - Duration: 200ms
            - Window Open Animation: Top, 8, 20
            - Window Close Animation: Bottom, 15, 30
        - Enable 'Window Aperture'
        - If using KWinFT, enable 'Flip Switch':
            - Flip animation duration: 200
            - Angle: 45°.
        - Enable 'Scale' (Appearance)
    - Under Screen Edges:
        - Turn off all 8 screen edges
    - Under Touch Screen:
        - Disable all 4 triggers
    - Under Virtual Desktops:
        - Remove all but one desktop, set maximum rows to 1

- Under Window Management:
    - Under Window Behaviour:
       - Under Window Actions:
            - Modifier key: Meta
    - Under KWin Scripts:
         - Enable 'MinimizeAll'

When editing Plasma's bottom panel, make sure its width is set to 40 pixels. 
 
### KDE Plasma Theme <a name="plasma-theme"></a>

Seven-Black is the theme for Plasma's shell. To install it, put it in the following directory (create it if it doesn't exist):

```
$ ~/.local/share/plasma/desktoptheme/
```

To apply it, go to ```System Settings -> Appearance -> Plasma Style``` to find it and select it.

### Icons and cursors <a name="icons"></a>

The icon theme is ```windowsicon```, while ```aero-cursors``` is the cursor theme. Extract the tar archives and move the folders in the following directory:

```
$ ~/.local/share/icons/
``` 

To apply them, go to ```System Settings -> Appearance -> Icons``` and ```System Settings -> Appearance -> Cursors``` respectively to select them.

It is also strongly recommended to install the [Oxygen](https://invent.kde.org/frameworks/oxygen-icons5) icon theme if it's not already installed on your system, as this project's icon theme optionally depends on it.

### Qt Visual Style <a name="application-theme"></a>

Installing Kvantum requires installing the package ```kvantum``` which is available in the community repository for Arch, and is available on most other Linux distributions as well. 

To install the GTK2 theme, locate and move the following directory:

```
$ ./Qt/Application_Theme/QGtkStyle/win27pixmap/
```

to this directory (create it if it doesn't exist):

```
$ ~/.themes/
```

Installing the Kvantum theme is simply done through Kvantum's settings. Afterwards, Kvantum can be set as the visual style in ```System Settings -> Appearance -> Application Style```.

**Applying the GTK2 theme:**

Through a utility program like ```gtk-chtheme```, set the GTK2 theme to Win2-7. When configuring GTK2, make sure to set the font to the same font as configured in the system settings (for this theme, the default is Segoe UI, size 9).

In case the GTK2 theme isn't persistent throughout sessions, in order to keep it applied, add the following line:

```
GTK2_RC_FILES=/home/[username]/.themes/win27pixmap/gtk-2.0/gtkrc
```

in 

```
# /etc/environment
```

Replace ```[username]``` with your own user name. Restart the Plasma session to see the effect.

**Installing the color scheme:**

To install the color scheme, go to ```System Settings -> Appearance -> Colors``` and click "Install from file". Locate the following file and select it:

```
./Plasma/Color_Scheme/AeroColorScheme.colors
```

Select the color scheme and apply it.


### Fonts <a name="fonts"></a>

For the sake of keeping this theme pack relatively compact, and to avoid potential licensing issues, this repository won't include Windows fonts, but acquiring them from an already present Windows installation is easy.
On Windows, fonts are stored in the following directory:

```
C:\Windows\Fonts\
```

If you have an existing Windows installation, you can simply copy the fonts over to the following directory (note that this will install the fonts across the entire system):

```
# /usr/share/fonts/windows/
``` 

It might be necessary to also update the fontconfig cache:

```
$ fc-cache
```

As for the actual font rendering configuration, in ```System Settings -> Appearance -> Fonts``` apply the following settings:

- General: Segoe UI 9pt
- Fixed width: Fixedsys 11pt
- Small: Segoe UI 8pt
- Toolbar: Segoe UI 9pt
- Menu: Segoe UI 9pt
- Window title: Segoe UI 9pt <br>
- Anti-aliasing: Enable
- Sub-pixel rendering: RGB *(This may vary depending on the monitor, choose the setting that looks best for your monitor and eyes.)*
- Hinting: Slight

Relog into a new Plasma session to see the results.

Note: Font rendering on Linux is [largely broken now](https://gitlab.gnome.org/GNOME/pango/-/issues/656) [and has been](https://gitlab.gnome.org/GNOME/pango/-/issues/463) [for](https://gitlab.gnome.org/GNOME/pango/-/issues/404) [several](https://github.com/harfbuzz/harfbuzz/issues/2394) [years](https://www.phoronix.com/news/HarfBuzz-Hinting-Woe). As a result, **pretty much all** font hinting options are broken except for **slight** font hinting and HiDPI rendering (because at that point, subpixel rendering isn't even needed). This regression has taken away the aggressive font hinting which made rendering nearly identical to ClearType on Windows 7. Currently, full font hinting _should technically work again_, but certain glyphs aren't horizontally aligned correctly, which still makes text unreadable. Until this issue is resolved, the only viable choice is to use slight font hinting.


### Window Manager <a name="wm"></a>

To install the window decoration, move the file:

```
$ ./KWin/smaragd_bin/kwin_smaragd.so
```

to:

```
# /usr/lib/qt/plugins/org.kde.kdecoration2/
``` 

The window decoration requires an Emerald theme to be present as well. To install the theme, move the following directory (If it doesn't appear, enable viewing hidden files):

```
$ ./KWin/.emerald/
``` 

to the home directory.

To apply the window decoration, go to ```System settings -> Appearance -> Window Decorations``` and select Smaragd. 

#### Compiling instructions

Compiling Smaragd on Arch Linux requires a few dependencies to be installed on the system:

- cmake
- cairo
- glib2
- kdebase-runtime
- kdelibs 4.14.x

The last two dependencies are provided in this repository as prebuilt Arch packages. The package `kdebase-runtime` doesn't exist anymore for Arch, not even the AUR, so the only place to find it outside of this repository is through [this](https://archive.org/details/archlinux_pkg_kdebase-runtime) link. The package `kdelibs` can be installed through the AUR, however it isn't recommended as compiling the package takes very long, and as of right now, building the package seems to fail. Distributions like Debian might be better in terms of offering legacy packages.

To compile Smaragd from the terminal:

```bash
cd smaragd-0.1.1
mkdir build #You can delete the build directory that already exists, or use a different name
cd build
cmake -DCMAKE_INSTALL_PREFIX=`kf5-config --prefix` ..
make
sudo make install
```

If compiling multiple times, only the last step is required. Steps 1-4. are for setting the environment up for the first time. 
To see the changes after compiling and setting Smaragd in the System Settings, simply restart KWin.

### Reflection Effect <a name="reflection"></a>

To install the reflection effect, it's recommended to build it from source. The required dependencies are:

- cmake
- extra-cmake-modules

Then, go to the folder:

```
cd ./KWin/kwin_reflect/
sh install.sh
```

After it has been compiled, you can log out or restart plasma and kwin, then go to ```System settings -> Workspace Behavior -> Desktop Effects``` and enable the effect.


### Plasma widgets <a name="widgets"></a>

### User plasmoids

These plasmoids do not require root privileges or editing system files to install. Installing them can be done by moving the plasmoid folder found in the following directory:

```
$ ./Plasma/Plasma_Widgets/User/
```

to:

```
$ ~/.local/share/plasma/plasmoids/
```

Example:

To install Seven Start, move the directory:

```
$ ./Plasma/Plasma_Widgets/User/io.wackyideas.SevenStart/
```

to:

```
$ ~/.local/share/plasma/plasmoids/
```

#### Seven Tasks

Before installing this plasmoid normally, it requires moving a file to a directory which requires root privileges. Move this file:

```
$ ./Plasma/Plasma_Widgets/User/plasma_applet_seventasks.so
```

to:

```
# /usr/lib/qt/plugins/plasma/applets/plasma_applet_seventasks.so
```

This library is used to create [this effect](https://superuser.com/questions/730804/how-does-windows-7-calculate-the-color-to-use-for-taskbar-color-hot-tracking) from Windows 7. 

It is possible to toggle showing labels by toggling the "Show labels on taskbar buttons" option in the configuration window like this:

<img src="Screenshots/SevenTasksConfig.png">

#### Digital Clock Lite

This plasmoid doesn't require additional configuration after installation if other steps have been completed. If for some reason the font and size do not look appropriate, set them to the following: 

- Font size px: 9
- Font style: Segoe UI Light, bold

### System modifications

These plasmoids and QML modifications require root privileges to install. It's recommended to move the original files somewhere safe as a backup, instead of replacing them directly. **Always make backups before replacing system files.**

An important thing to keep in mind is that these changes will be reset everytime KDE is updated, meaning that it is necessary to perform this part of the installation after every update.

#### Modified System Tray

To install, move the following directory:

```
$ ./Plasma/Plasma_Widgets/System/org.kde.plasma.private.systemtray/
```

to:

```
# /usr/share/plasma/plasmoids/
``` 

Restart plasma to apply changes. If necessary, set the icon size to "Small" in the configuration window.

#### Modified Keyboard Layout Switcher

To install, move the following directory:

```
$ ./Plasma/Plasma_Widgets/System/org.kde.plasma.keyboardlayout
```

to:

```
# /usr/share/plasma/plasmoids/
```

Restart plasma to apply changes.

#### Desktop icons

To install, move the following directory:

```
$ ./Plasma/Plasma_Widgets/System/org.kde.desktopcontainment
```

to:

```
# /usr/share/plasma/plasmoids/
```

Restart plasma to apply changes.

To make the desktop look more like Windows 7 by default, right click on the desktop and click "Configure Desktop and Wallpaper...", change the following settings:

- Icons:
    - Icon size: 2
    - Label width: Narrow
    - Features: All checked except for "Folder preview popups"

#### Plasma tooltips

To install, move the following file:

```
$ ./Plasma/Plasma_Widgets/System/Tooltips/DefaultTooltip.qml
```

to:

```
# /usr/lib/qt/qml/org/kde/plasma/core/private/
```

Restart plasma to apply changes.

### Task Switcher <a name="task-switcher"></a>

To install, move the following folder:

```
$ ./KWin/thumbnail_seven
```

to:

```
$ ~/.local/share/kwin/tabbox/
```

In ```System Settings -> Window Management -> Task Switcher```, set the following:

In Main:

- Visualization: Set "Thumbnail Seven" as the visualization style.
- Shortcuts (for All Windows): 
    - Forward: Alt + Tab 
    - Backward: Alt + Shift + Tab
- Check "Include "Show Desktop" icon"

In Alternative: 

- Visualization: Set "Flip Switch" as the visualization style.
- Shortcuts (for All Windows):
    - Forward: Meta + Tab
    - Backward: Meta + Shift + Tab 
- Check "Include "Show Desktop" icon"

### Splash Screen <a name="splash-screen"></a>

To install the splash screen, move the folder:

```
$ ./Plasma/Splash_Screen/io.gitgud.wackyideas.aerosplashscreen
```

To the following directory:

```
$ ~/.local/share/plasma/look-and-feel/
```

Create the directory in case it doesn't exist.

Set the splash screen in ```System Settings -> Appearance -> Splash Screen```.

### Sounds <a name="sounds"></a>
On Windows, system sound files are located in:

```
C:\Windows\Media
```

To install the sound files bundled with this project, move the two following directories:

```
$ ./Plasma/Sounds/media_windows
$ ./Plasma/Sounds/stereo_windows
```

to:

```
# /usr/share/sounds/
```

To apply them, go to ```System Settings -> Notifications```. There, click on the 'Configure'
button. Scroll down to ```Plasma Workspace```, and click on the 'Configure Events' button.
Set the sounds for the following notifications:

|Sound                    |File                                                         |
|-------------------------|-------------------------------------------------------------|
|Notification             |```/usr/share/sounds/stereo_windows/dialog-information.ogg```|
|Warning Message          |```/usr/share/sounds/stereo_windows/dialog-warning.ogg```    |
|Fatal Error, Catastrophe |```/usr/share/sounds/stereo_windows/dialog-error.ogg```      |
|Logout                   |```/usr/share/sounds/stereo_windows/desktop-logout.ogg```    |
|Question                 |```/usr/share/sounds/stereo_windows/dialog-question.ogg```   |
|Login                    |```/usr/share/sounds/stereo_windows/desktop-login.ogg```     |
|Warning                  |```/usr/share/sounds/stereo_windows/dialog-warning.ogg```    |
|Trash, Emptied           |```/usr/share/sounds/media_windows/Windows Recycle.wav```    |
|Critical Message         |```/usr/share/sounds/stereo_windows/dialog-warning.ogg```    |
|Information Message      |```/usr/share/sounds/stereo_windows/dialog-information.ogg```|
|Beep                     |```/usr/share/sounds/stereo_windows/button-pressed.ogg```    |

Then, under ```Power Management```, click on the 'Configure Events' button. Set the sounds for the following
notifications:

|Sound                              |File                                                              |
|-----------------------------------|------------------------------------------------------------------|
|Battery Low, Peripheral Battery Low|```/usr/share/sounds/media_windows/Windows Battery Low.wav```     |
|Battery Critical                   |```/usr/share/sounds/media_windows/Windows Battery Critical.wav```|

### Wine <a name="wine"></a>

To install the msstyle for Wine applications, run ```winecfg```, and under the 'Desktop Integration' tab, click 'Install theme' and choose the following file:

```
$ ./Wine/VistaVG Ultimate/vistavg_ultimate.msstyles
```

After that, go through the entire 'Item' list, and change the font everywhere to:

- Font: Segoe UI
- Size: 9pt

### Terminal <a name="terminal"></a>

To make your terminal emulator of choice look a bit more like the command prompt from Windows, do the following:

- Hide the menu bar
- Hide the tab bar if there's only one tab available
- Set the terminal font to Fixedsys (Excelsior 3.01), 11pt.
- Add the following line to `~/.bashrc`: 

```printf 'Microsoft Windows [Version 6.1.7601] \nCopyright <c> 2009 Microsoft Corporation. All rights reserved.\n\n'```

The last part will print the provided string every time a new bash session is started.
