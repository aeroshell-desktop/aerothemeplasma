# Installation

## TABLE OF CONTENTS

1. [Prerequisites](#preq)
2. [KDE Plasma Settings](#plasma-settings)
3. [KDE Plasma Theme](#plasma-theme)
4. [Icons and cursors](#icons)
5. [Aero Color Mixer](#aeromixer)
6. [Qt Visual Style](#application-theme)
7. [Fonts](#fonts)
8. [Window Manager](#wm)
9. [Plasma Widgets](#widgets)
10. [Task Switcher](#task-switcher)
11. [Sounds](#sounds)
12. [Wine](#wine)

### Prerequisites <a name="preq"></a>

The following software is required for this project:

- KDE Plasma
- KWinFT/KWin with compositing support enabled
- Kvantum/QGtkStyle/Both (QGtkStyle is included in the package ```qt5-styleplugins```)
    - If using QGtkStyle, ```gtk-chtheme``` is recommended for switching between GTK2 themes
- Qt5 Graphicaleffects package (```qt5-graphicaleffects``` on Arch and derivatives)

Optional programs:

- KMix
- Wine

Optional components which are deprecated and/or not supported:

- Compiz with Emerald
- QtCurve

**Detailed explanation:**

This project looks best when used with sofware which uses the Qt framework. 

The Qt visual style can be set to either Kvantum or QGtkStyle. Kvantum offers a simple to customise SVG-based theme of Aero with perks such as animated transitions, scaling support and better Qt integration, while QGtkStyle renders Qt as if it were a GTK2 style, which makes GTK2 and Qt programs look more unified. It is up to the user's personal preference to choose between either visual style.

**NOTE: From now on, paths starting with a period (```.```) will refer to paths within this git repository.**

### KDE Plasma Settings <a name="plasma-settings"></a>

Starting off with the simplest modifications, this is a list of recommended settings which are configurable in System Settings, to make Plasma behave closely like Windows 7. Of course, these settings are optional and simply personal preference.


- Under Workspace Behaviour:

    - Under General Behaviour:
        - Clicking files or folders: Selects them
    - Under Desktop Effects:
        - Blur, set Blur strength to 3, and Noise strength to 0
        - Desaturate Unresponsive Applications
        - Fading popups
        - Login
        - Logout
        - Morphing popups
        - Translucency (Turn this off if it makes moving windows transparent)
        - Scale
        - Window Aperture
        - If using KWinFT, enable Flip Switch; Set Flip animation duration to 200, and Angle to 45°.
        - Scale (Window Open/Close Animation)
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
             - Enable MinimizeAll script

When editing Plasma's bottom panel, make sure its width is set to 40 pixels. 
 
### KDE Plasma Theme <a name="plasma-theme"></a>
The Seven-Black Plasma theme is the main theme for KDE Plasma's shell. Put it in the following directory:

```~/.local/share/plasma/desktoptheme/Seven-Black```


To apply it, go to ```System Settings -> Appearance -> Plasma Style``` to find it and select it.

### Icons and cursors <a name="icons"></a>
The folder ```windowsicon``` is the icon theme, while ```aero-cursors``` is the cursor theme. Both of these belong in
the following directory:

```/usr/share/icons``` (Requires root privileges)


To apply them, go to ```System Settings -> Appearance -> Icons``` and ```System Settings -> Appearance -> Cursors``` respectively.

### Aero Color Mixer <a name="aeromixer"></a>

AeroColorMixer is a configuration utility meant for customising this Aero theme to your liking. It is built based on the Personalisation features from Windows 7, with the ability to change the accent color of the glassy visual effects. The colors and names features within the program are taken from Windows 7, while it is also possible to adjust the color to your own liking. 

The binary for AeroColorMixer is located in the build folder of the source code:

```./Plasma/KDE Plasma Theme/AeroColorMixer/build```

No installation is required, however it is advised to place the binary in a path listed in the user's PATH, like:

```/usr/bin``` (Requires root privileges)

A few notes regarding AeroColorMixer:

- The configuration file is stored in: ```~/.config/.aerorc``` and it stores information regarding the custom color, transparency settings, and which color is currently applied. 
- Directly editing this configuration file DOES NOT change your theme's colors, instead it is used for the utility to load itself into a known state. 
- Toggling the transparency setting inside this program does not affect compositing settings on your window manager.

Both the source code and binaries are provided, and the binary is compiled with Qt version 5.15.5, glibc 2.36 and on the x86_64 architecture. 

**NOTE: This program is meant to work only with this theme, and it assumes that you have both the Plasma theme and the Emerald theme installed on your system.**

### Qt Visual Style <a name="application-theme"></a>

Installing QGtkStyle requires installing the package ```qt5-styleplugins``` which is available in the AUR for Arch users and the galaxy repository for Artix users.

Installing Kvantum requires installing the package ```kvantum``` which is available in the community repository.

To install the GTK2 theme, locate and move the following directory:

```./Qt/Application Theme/QGtkStyle/win27pixmap```

to the following directory:

```~/.themes```

If this directory does not exist, simply make it.

Installing the Kvantum theme is simply done through Kvantum Manager. 

**Applying the GTK2 theme:**

To use the GTK2 theme for Qt programs, it must be selected in ```System Settings -> Appearance -> Application Style```, and it must be applied as a regular GTK2 theme as well. To do this, use a program like ```gtk-chtheme``` to set it for all GTK2 programs. Be sure to set the font to Segoe UI, size 9.

In case the GTK2 theme isn't persistent throughout sessions, in order to keep it applied, add the following line:

```GTK2_RC_FILES=/home/[username]/.themes/win27pixmap/gtk-2.0/gtkrc```

in ```/etc/environment```. This requires root privileges. Replace ```[username]``` with your own user name. Restart your Plasma session to see the effect.

**Installing the color scheme:**

To install the color scheme, go to ```System Settings -> Appearance -> Colors```, and click "Install from file.". Locate the following file and select it:

```./Plasma/Color Scheme/KvCurvesLight.colors```

Select the color scheme and apply it.


### Fonts <a name="fonts"></a>

For the sake of keeping this theme pack relatively compact, and due to licensing issues, this project won't include the Microsoft Windows fonts, but you can get them if you have a Windows installation.
Windows fonts are stored in the following directory:

```C:\Windows\Fonts\```

If you have an existing Windows installation, you can simply copy them over to the following directory:

```/usr/share/fonts/windows``` (Requires root privileges)

Make sure to keep them all tidy in a separate folder from the rest.
As for the actual font configurations, in System settings, go to ```Appearance -> Fonts```, and then apply the following
settings:

- General: Segoe UI 9pt
- Fixed width: Fixedsys 11pt (Can be any monospace font)
- Small: Segoe UI 8pt
- Toolbar: Segoe UI 9pt
- Menu: Segoe UI 9pt
- Window title: Segoe UI 9pt <br>
- Anti-aliasing: Enable
- Sub-pixel rendering: RGB
- Hinting: Slight

Tweak these settings around as you'd like. 
Since KDE isn't that stable you may have to restart it in order to actually see the real results - KDE tends to
butcher font rendering upon changing settings. I don't know why.

Note: [Font rendering on Linux is largely broken now and has been for several years](https://www.phoronix.com/news/HarfBuzz-Hinting-Woe). This is because Pango no longer uses FreeType for font rendering, using HarfBuzz instead. As a result, **all** font hinting options are broken except for slight font hinting, and HiDPI rendering. Despite the backlash, the developers arrogantly suggest using only HiDPI screens from now on, or "to get used to it". This regression has taken away the aggressive font hinting which was nearly identical to ClearType on Windows 7. 


### Window Manager <a name="wm"></a>

To install Smaragd, move the file:

```./KWin/bin/kwin_smaragd.so```

to:

```/usr/lib/qt/plugins/org.kde.kdecoration2/kwin_smaragd.so``` (Requires root privileges)

To install the theme in question, move the following directory:

```./KWin/.emerald``` (If it doesn't appear, turn on 'Show hidden files')

to:

```~/.emerald```

To apply Smaragd, select it in ```System settings -> Appearance -> Window Decorations```. 

Any changes made to the theme will be nearly instant. The changes are applied as soon as the window is updated (resizing, maximizing/restoring the window). It is not recommended to edit the theme file by hand.


### Plasma widgets <a name="widgets"></a>

### User plasmoids

These plasmoids do not require root privileges or editing system files to install. Installing them can be done by moving the plasmoid folders found in the following directory:

```./Plasma/Plasma Widgets/User```

to:

```~/.local/share/plasma/plasmoids```

Example:

To install Seven Start, move the directory:

```./Plasma/Plasma Widgets/User/Start Menu/SevenStart```

to:

```~/.local/share/plasma/plasmoids/SevenStart```

Also, it is necessary to have the KDE Plasma theme installed and applied beforehand, or else the plasmoids will not display correctly.

The following segments will explain how to configure these widgets.


#### Seven Start

After installing and adding this widget to the main panel, you will notice that it has no icon. It is necessary to open the configuration window and set the icons as shown in the screenshot below: 

<img src="Screenshots/SevenStartConfig.png">

The icons are located in:

```./Plasma/Plasma Widgets/User/Start Menu/Orbs```

#### Seven Tasks

Seven Tasks requires an additional install step which requires root privileges. It is necessary to complete this step first before installing and using this plasmoid. To complete the installation, move the following file:

```./Plasma/Plasma Widgets/User/Task Icons/bin/plasma_applet_seventasks.so```

to:

```/usr/lib/qt/plugins/plasma/applets/plasma_applet_seventasks.so``` (Requires root privileges)

This library is used to create the hot tracking glow effect. 

It is possible to toggle showing labels on the fly by checking the "Show labels on taskbar buttons" option in the configuration window like this:

<img src="Screenshots/SevenTasksConfig.png">

#### Digital Clock Lite

This plasmoid doesn't require additional configuration after installation if other steps have been completed. If for some reason the font and size do not look appropriate, set them to the following: 

- Font size px: 9
- Font style: Segoe UI

You can tweak the other settings to your liking. 

#### Show Desktop (Win7, custom)

Set the following properties to the following values:

In Look:

- Size: 13px;
 
In Click:

 - Run Command: ```qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "MinimizeAll"``` <br>
    (Note: in order for this to work, the ```MinimizeAll``` KWin script must be installed and enabled)

In Peek:

- Show desktop on hover: Enable
- Peek threshold: 750ms

Other properties can be configured to your liking. 

### System modifications

These plasmoids and QML modifications require root privileges to install, as well as replacing/modifying system files which may or may not break KDE as a result. **Be sure to make backups before replacing system files on your computer. A simple rename of the files or directories that would be modified is enough.**

Another thing to note is that these changes will be reset after each system update, meaning that it is necessary to reinstall these modifications after every update.

#### Modified System Tray

To install, move or copy the following directory:

```./Plasma/Plasma Widgets/System/System Tray/org.kde.plasma.private.systemtray```

to:

```/usr/share/plasma/plasmoids/org.kde.plasma.private.systemtray``` (Requires root privileges)

Restart plasma to apply changes. If necessary, set the icon size to "Small" in the configuration window.

#### Modified Keyboard Layout Switcher

To install, move or copy the following directory:

```./Plasma/Plasma Widgets/System/Keyboard Switcher/org.kde.plasma.keyboardlayout```

to:

```/usr/share/plasma/plasmoids/org.kde.plasma.keyboardlayout``` (Requires root privileges)

Restart plasma to apply changes. No further configuration is needed.

#### Desktop icons

To install, move or copy the following directory:

```./Plasma/Plasma Widgets/System/Desktop Icons/org.kde.desktopcontainment```

to:

```/usr/share/plasma/plasmoids/org.kde.desktopcontainment``` (Requires root privileges)

Restart plasma to apply changes. No further configuration is needed.

#### Plasma tooltips

To install, move or copy the following file:

```./Plasma/Plasma Widgets/System/Tooltips/DefaultTooltip.qml```

to:

```/usr/lib/qt/qml/org/kde/plasma/core/private/DefaultTooltip.qml```

Restart plasma to apply changes. No further configuration is needed.

### Task Switcher <a name="task-switcher"></a>

<img src="https://upload.wikimedia.org/wikipedia/en/5/59/Windows7_flip.png">

In ```System Settings -> Window Management -> Task Switcher```, set the following:

In Main:

- Visualization: Set "Thumbnails" as the visualization style.
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

Configuration options for the Flip Switch style are described in [KDE Plasma Settings](#plasma-settings).

### Sounds <a name="sounds"></a>
On Windows, the full set of sound files is located in the following directory:

```C:\Windows\Media```

To install the sound files bundled with this project, move the two following directories:

```./Plasma/Sounds/media_windows```
 and
```./Plasma/Sounds/stereo_windows```

to:

```/usr/share/sounds/media_windows```
and
 ```/usr/share/sounds/stereo_windows```

respectively.

To select and apply them, go to ```System Settings -> Notifications```. There, click on the ```Configure...```
button on the bottom. Scroll down to ```Plasma Workspace```, and click on the ```Configure Events...``` button.
Set the sounds for the following notifications:

 - Notification:             ```/usr/share/sounds/stereo_windows/dialog-information.ogg```
 - Warning Message:          ```/usr/share/sounds/stereo_windows/dialog-warning.ogg```
 - Fatal Error, Catastrophe: ```/usr/share/sounds/stereo_windows/dialog-error.ogg```
 - Logout:                   ```/usr/share/sounds/stereo_windows/desktop-logout.ogg```
 - Question:                 ```/usr/share/sounds/stereo_windows/dialog-question.ogg```
 - Login:                    ```/usr/share/sounds/stereo_windows/desktop-login.ogg```
 - Warning:                  ```/usr/share/sounds/stereo_windows/dialog-warning.ogg```
 - Trash: Emptied:           ```/usr/share/sounds/media_windows/Windows Recycle.wav```
 - Critical Message:         ```/usr/share/sounds/stereo_windows/dialog-warning.ogg```
 - Information Message:      ```/usr/share/sounds/stereo_windows/dialog-information.ogg```
 - Beep:                     ```/usr/share/sounds/stereo_windows/button-pressed.ogg```

Then, under ```Power Management```, click on the ```Configure Events...``` button. Set the sounds for the following
notifications:

 - Battery Low, Peripheral Battery Low: ```/usr/share/sounds/media_windows/Windows Battery Low.wav```
 - Battery Critical:                    ```/usr/share/sounds/media_windows/Windows Battery Critical.wav```

### Wine <a name="wine"></a>

To install and configure, run ```winecfg```, and under the ```Desktop Integration``` tab, click ```Install theme...``` and choose the following file:

```./Wine/VistaVG Ultimate/VistaVG Ultimate.msstyles```

After that, go through all elements in the "Item" list, and change the font everywhere to match:

- Font: Segoe UI
- Size: 9pt

