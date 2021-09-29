# AERO THEME FOR KDE PLASMA

## Donate

```BTC: bc1qfs0w6xstcgkjggu9e7gqucrpqvshwfj73h4d4t```


## Credits


1. [Seven-Black](https://www.kde-look.org/p/998614)
2. [Win2-7(Pixmap)](https://www.opendesktop.org/p/1014539)
3. [Win2-7](https://www.gnome-look.org/p/1012465)
4. [Seven Black Aurorae](https://store.kde.org/p/1002615)
5. [Smaragd](https://www.pling.com/p/1167274)
6. [Aero for Emerald](https://store.kde.org/p/1003826/)
7. [Windows 7 GTK3 Theme](https://b00merang.weebly.com/windows-7.html)
8. [Avalon Menu](https://store.kde.org/p/1386465/)
9. [Digital Clock Lite](https://www.kde-look.org/p/1225135/)
10. [Show Desktop (Win7)](https://www.kde-look.org/p/1100895/)
11. [Equilibrium GTK3](https://store.kde.org/p/1493643/)
12. [Aero Mouse Cursors with Drop Shadow](https://store.kde.org/p/999972/)
13. [Volatile](https://www.pling.com/p/998823)
    
These are all the projects mentioned which I have forked into this theme pack. Please consider checking them out and checking out the authors who created these themes.


## TABLE OF CONTENTS
1. [Introduction](#introduction)  
2. [Screenshots](#screenshots)
3. [Installation](#installation)  
    1. [Prerequisites](#installation)
    2. [KDE Plasma Theme](#plasma-theme)
    3. [KDE Application Theme](#application-theme)
    4. [Aero Color Mixer](#aeromixer)
    5. [Icons and cursors](#icons)
    6. [Fonts](#fonts)
    7. [Window Manager](#wm)
    8. [Plasma Widgets](#widgets)
    9. [Workspace Behavior](#behaviour)
    10. [Task Switcher](#task-switcher)
    11. [GTK3](#gtk)
    12. [Sounds](#sounds)
4. [Shortcomings](#shortcomings)
    1. [KDE-specific problems](#kde-problems)
    2. [Lack of features problem](#feature-problems)
5. [TODO List](#todo-list)


## Introduction <a name="introduction"></a>

This is a theme which aims to recreate the look and feel of Windows 7 as much as possible on KDE Plasma.
The theme is still in active early development and testing, and has only been tested on the following
relevant specifications:

 - Arch Linux (5.10.43-1 LTS, 64-bit), Artix (5.13.10-artix1-1, 64-bit), Kubuntu 20.04
 - X11 
 - KDE Plasma 5.22.3, KDE Frameworks 5.84.0
 - Qt 5.15.2
 - Intel integrated Graphics, AMD GPUs
 - 96 DPI scaling

This theme has NOT been tested on HiDPI monitors. Contributors who are able to test it on HiDPI scaling are
greatly welcome. Your mileage may vary in terms of results, depending on your distro and other specifications.
This theme has also not been tested on Wayland, and I do not intend to test or support this theme on Wayland. 

Keep in mind that I'm not a designer, and that the most I've done is modify the themes I've come across the
Internet. I'll put a link to all the themes I've included and modified in this theme pack. I'm just a passionate user
who really wants to keep the Aero visual style alive. 
Feel free to take this theme pack and modify it for yourself or share it with others, or if 
there are any improvements to be made here, any and all effort would be greatly appreciated.

## Screenshots <a name="screenshots"></a>

### Example Desktop
<img src="Screenshots/Desktop.png">

### Start Menu
<img src="Screenshots/Start_Menu.png">

<video controls="true" allowfullscreen="true">
    <source src="Screenshots/starthover.webm" type="video/webm">
</video>

### Dolphin
<img src="Screenshots/Dolphin_2.png">

### Context Menu

<img src="Screenshots/Context_Menu.png">
<img src="Screenshots/Context_Menu_2.png">

### Taskbar

<video controls="true" allowfullscreen="true">
    <source src="Screenshots/hovertask.webm" type="video/webm">
</video>
<img src="Screenshots/Taskbar.png">

### System Tray

<img src="Screenshots/System_Tray.png">

### Plasma Style

<img src="Screenshots/Notification.png">

<img src="Screenshots/Media_Controls.png">

### AeroColorMixer

<img src="Screenshots/AeroColorMixer.png">

### Window Style

<img src="Screenshots/Window_Decorations.png">




## Installation <a name="installation"></a>

### Prerequisites

In order to have this theme truly work, you'll need to have KDE Plasma installed on your system.
This theme also assumes that you're using KDE provided programs and other Qt programs (Dolphin, Konsole, etc.).
This theme collection also assumes that you're using KWin as the window manager. You can technically run
compiz on KDE for marginally better results, however I've found that compiz is really buggy and crashes on
my machine, so I choose not to use it. 

In the previous release of this theme pack a QtCurve theme was provided and recommended as the main widget
style to replicate the look of Aero. However, since I've discovered QGtkStyle, QtCurve is no longer a 
requirement to have for this theme pack. Instead, you'll need GTK2, an application that can
switch between GTK2 themes, and the .so file for the widget style itself. More on that in [KDE Application Theme](#application-theme).

Lastly, in order to have blur effects, animations and transparency, it is important that your hardware supports compositing and that it is enabled.


### KDE Plasma Theme <a name="plasma-theme"></a>
The Seven-Black Plasma theme is the main theme for KDE Plasma's shell. Put it in the following directory:

```~/.local/share/plasma/desktoptheme/Seven-Black```


Since this is a Plasma Style, to apply it simply go to ```System Settings -> Appearance -> Plasma Style``` to find it and select it.

Make sure that your panel's width is set to 40.

### Aero Color Mixer <a name="aeromixer"></a>

In the ```KDE Plasma Theme``` folder there is also a QtWidgets program called <b>AeroColorMixer</b>. It is a utility for changing the colors of the Plasma theme and the Emerald decorator theme. It is meant to look and feel similar to the color mixer featured in Windows 7 and Windows 8/8.1. The colors included are pulled directly from Windows 7. Some important notes about AeroColorMixer:

- The configuration file is stored in ```~/.aerorc```, which contains information about the custom color, whether or not transparency is enabled, and which color is currently applied
- Enabling/disabling transparency through this program does not affect the compositing settings in KWin's settings. 
- This program applies the colors to the standard theme, the "translucent" variant of the theme, and the "opaque" variant of the theme (which is applied when compositing is disabled)
- This program does not yet change the color of text in the theme for better readability. This will hopefully be worked on in the future updates
- By default, the Plasma theme and program are configured with the Sky color scheme.

Both the source code and binaries are provided, and the binary is compiled with Qt version 5.15.2, glibc 2.33 and on the x86_64 architecture. 

NOTE: This program is meant to work only with this theme, and it assumes that you have both the Plasma theme and the Emerald theme installed on your system. This program has only been tested so far on two machines so YMMV.

### KDE Application Theme <a name="application-theme"></a>

As previously mentioned, this theme now uses the QGtkStyle widget style to theme Qt programs. This solution is
also advantageous since GTK2 programs and Qt programs will now look unified. As for GTK 3/4 programs, this theme 
won't provide any support, though there are themes on opendesktop.org that accomplish this for GTK 3. 

Arch users can install the "qt5-styleplugins" package from the AUR to get QGtkStyle, however I found this to
be a buggy package which makes certain parts of KDE completely flip out.
KDE's system settings would get a really messed up theme if you have this package installed on your
system. As a workaround, I'll be providing only the ```libqgtk2style.so``` file which is the only thing required
anyway. To install it, simply move it to the following directory:

```/usr/lib/qt/plugins/styles```

This directory may vary depending on your distro. 

After this, take the win27pixmap folder and move it to the ```~/.themes``` directory. This is the GTK2 theme based off
of the Win2-7 (Pixmap) theme (https://www.opendesktop.org/p/1014539 and https://www.gnome-look.org/p/1012465). 
By selecting QGtkStyle in ```System Settings -> Appearance -> Application Style```, and setting the GTK2 theme with something like ```gtk-chtheme```, your 
Qt programs should look a lot more like Windows 7 now. You should also set a light color theme for all of this. My personal recommendations are ```KvCurvesLight``` and ```Oxygen Cold```.

In case the GTK2 theme isn't persistent throughout sessions, in order to keep it applied, add the following line:

```GTK2_RC_FILES=/home/[username]/.themes/win27pixmap/gtk-2.0/gtkrc```

in ```/etc/environment```. Restart your Plasma session to see the effect.
 
The downside of this theme is that it is a light theme, whereas the QtCurve approach can be both a light and dark
theme depending on your liking. Maybe in a future release I'll release a followup GTK2 theme which is just an Aero
dark theme. 

### Icons and cursors <a name="icons"></a>
The folder ```windowsicon``` is the icon theme, while ```aero-cursors``` is the cursor theme. Both of these belong in
the following directory:

```/usr/share/icons```


Select the icon and cursor themes in the settings.

### Fonts <a name="fonts"></a>
For the sake of keeping this theme pack relatively compact, and for legal issues, I won't include the Microsoft Windows font pack, but you can get them if you have a Windows installation.
Windows fonts are stored in the following directory:

```C:\Windows\Fonts\```

If you have an existing Windows installation, you can simply copy them over to the following directory:

```/usr/share/fonts```

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
- Hinting: Medium
- Force font DPI: 99

Tweak these settings around as you'd like. 
Since KDE isn't that stable you may have to restart it in order to actually see the real results - KDE tends to
butcher font rendering upon changing settings. I don't know why.

### Window Manager <a name="wm"></a>
I have decided to use smaragd instead of Aurorae decoration engine for the window manager theme, mainly because
Aurorae has an extremely annoying graphical glitch which heavily distorts the window decoration, including the 
window title, by stretching/shrinking them upon resizing. Strangely enough, this also happens on compiz 0.8.
If, however, you still want to use Aurorae instead of smaragd, use this theme: https://www.kde-look.org/p/1002615

In the directory: 

```./Window Manager/smaragd-0.1.1/build/bin/```

there is a precompiled binary of smaragd, because actually compiling
it takes forever and requires a bunch of old deprecated dependencies. To save everyone the trouble of compiling it,
I've included them there, along with the source code and everything. I've edited the source code to fix a few 
annoying bugs, most notably the maximised decorations being really weird - the caption buttons being slightly off
from the corner of the screen, and there was also an annoying feature/bug where clicking and moving your mouse from the
topmost pixel of the screen would actually resize the window instead of restoring it, most likely due to margin errors.

To install smaragd, simply move the ```kwin_smaragd.so``` file to the following directory:

```/usr/lib/qt/plugins/org.kde.kdecoration2/kwin_smaragd.so```

I've seen other similar directories on other distros, so if you can't exactly find this directory, my apologies.

Smaragd pulls its theme from Emerald, the Compiz decoration engine. However, you do not actually need to install Emerald
in order to get Smaragd to work (it does greatly help if you want to edit the theme to your liking, however).
If you don't have emerald, simply put the ".emerald" folder in your home directory, and then apply Smaragd in
```System settings -> Appearance -> Window Decorations```. Any changes you make to the emerald theme will be nearly instant. The changes are applied as soon as the window is updated (resizing, maximizing/restoring the window).
The current theme is a modified theme taken from https://www.kde-look.org/p/1003826/


### Plasma widgets <a name="widgets"></a>

#### Seven Start
In the ```Plasma Widgets``` folder you will find the plasmoid ```SevenStart```. This is a fork of Avalon Menu. (https://store.kde.org/p/1386465/)

To install it, simply move this to the following directory:

```~/.local/share/plasma/plasmoids/```

If needed, restart Plasma to see it installed. This launcher features three Start Menu buttons, which are animated just like in Windows 7. To properly configure this plasmoid, you have to set these three icons in the plasmoid's configuration as shown here:

<img src="Screenshots/SevenStartConfig.png">

The icons are located in ```./Plasma Widgets/AeroTheme/```. The usage of three start menu buttons allows for greater customisation, along with using custom menu orbs much like ClassicShell/OpenShell.

#### Seven Tasks

Seven Tasks is a fork of KDE Plasma's Task manager. This fork morphs both the regular task manager and the Icons-only task manager into one plasmoid for convenience, and they can be switched out on the fly in the configuration. By default, this plasmoid acts as an Icons-only task manager. 

<img src="Screenshots/SevenTasksConfig.png">

Installing this widget is the same as Seven Start. Move the ```org.kde.plasma.seventasks``` folder located in ```./Plasma Widgets/Task Manager``` to the following directory:

```~/.local/share/plasma/plasmoids/```

There is another file which needs to be added in order for this plasmoid to work. This is the C++ portion of the plasmoid which is used to calculate the dominant color of the taskbar button's icon. The library is compiled for x86_64 platforms. The source is included for those who need to compile it for different architectures. Move the file located in ```./Plasma Widgets/Task Manager/lib``` to the following directory:

```/usr/lib/qt/plugins/plasma/applets/```

You will need root permissions to do this. When that's done, replace your current task manager with Seven Tasks. 


#### Modified System Tray

This modification will add hover animations to the default system tray plasmoid, as well as remove the annoying popup animation which happens upon clicking on an item. 
Since the system tray is a complex plasmoid, its files have to be replaced with a modified version provided in this theme, instead of it acting as a standalone plasmoid. To do this, copy the ```org.kde.plasma.private.systemtray``` found in the ```Plasma Widgets``` folder to the following directory:

```/usr/share/plasma/plasmoids/```

This will override the default System Tray plasmoid. It is not recommended to edit this particular plasmoid, so proceed with caution. Make sure to back up the original plasmoid somewhere safe before trying this.


#### Digital Clock Lite

Install the widget ```Digital Clock Lite``` (https://www.kde-look.org/p/1225135/) and replace the ugly large clock widget with 
it. By default it should already look a lot like Windows 7's clock, but if it doesn't, change the following settings:

- Font size px: 9
- Font style: Segoe UI

You can tweak the other settings to your liking. 

#### Show Desktop (Win7)

Lastly, install the ```Show Desktop (Win7)``` widget (https://www.kde-look.org/p/1100895/) and configure it to these settings:

In Look:

- Size: 8px;
 
In Click:

 - Run Command: ```qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "MinimizeAll"``` <br>
    (Note: in order for this to work, the ```MinimizeAll``` KWin script must be installed and enabled)

In Peek:

- Show desktop on hover: Enable
- Peek threshold: 750ms

### Workspace Behavior <a name="behaviour"></a>
In ```System Settings -> Workspace Behavior -> Desktop Effects```, check the following settings:

- Blur (Note: set the Blur strength and Noise strength to 3 to make it look somewhat accurately blurry)
- Desaturate Unresponsive Applications 
- Fading Popups
- Login
- Logout 
- Translucency
- Squash
- Window Aperture
- Scale

### Task Switcher <a name="task-switcher"></a>

<img src="https://upload.wikimedia.org/wikipedia/en/5/59/Windows7_flip.png">

This section will talk about how to make the Task Switcher in KDE look more like Windows 7. It will also recreate the look and behaviour of the "Flip 3D" feature. In ```System Settings -> Window Management -> Task Switcher```, set the following:

In Main:

- Visualization: Set "Thumbnails" as the visualization style.
- Shortcuts (for All Windows): 
    - Forward: Alt + Tab 
    - Backward: Alt + Shift + Tab
- Check the "Include "Show Desktop" icon" checkbox

In Alternative: 

- Visualization: Set "Flip Switch" as the visualization style.
- Shortcuts (for All Windows):
    - Forward: Meta + Tab
    - Backward: Meta + Shift + Tab 
- Check the "Include "Show Desktop" icon" checkbox

For the Flip Switch visualization style, you can configure it to your liking. Personally, I like to have the "Flip Animation Duration" set to 200. 

### GTK3/4 <a name="gtk"></a>
This theme doesn't touch upon GTK3/4 all that much, mainly because I feel that there's no good looking theme
for GTK3/4, but I've still decided to give some tips on how to make GTK3/4 look a bit less ugly:

- Use this theme: https://b00merang.weebly.com/windows-7.html
- If you want a dark theme, My personal pick is this one: https://store.kde.org/p/1493643/

I don't use applications that use GTK3/4 all that much, and it will likely just keep breaking support with 
upcoming updates, so I don't bother trying to keep up with it. GTK3/4 tends to break compatibility, and it never integrates well with the rest of your system regardless of how you theme it. For those reasons, GTK3 and GTK4 are **not** supported, and will likely never be supported for this theme. Sorry once again. 

### Sounds <a name="sounds"></a>
This theme isn't complete without sounds. On Windows, the sound files are located in the following directory:

```C:\Windows\Media```

In my folder I've included the sound files for the default Windows Aero theme, along with other themes from
Windows 7. To install them, simply move the two folders to the following directory:

```/usr/share/sounds```

With that done, you need to go to ```System Settings -> Notifications```. There, click on the ```Configure...```
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

There are probably sounds that I haven't configured or missed out on, but these are the most commonly heard
sounds in Windows 7 anyway. 

## Shortcomings <a name="shortcomings"></a>

### KDE-specific problems <a name="kde-problems"></a>

I'd like to point out that this theme is far from perfect and that it still leaves a lot to be desired, especially
with someone who pays attention to a lot of these details. In other words, this theme is a WIP.

There are imperfections that are caused by KDE itself, and other imperfections are really just aesthetic features
that are lacking from the original Aero style.
Some  annoying things about this theme (as with any other KDE theme, really), are that font sizes aren't all that 
consistent, and neither is the font contrast, meaning that in the worst case scenario, the text will be
difficult to read. This could probably be improved by making the backgrounds of elements more opaque. Most of the
text is going to be most readable when they're under a dark background. 

The icon theme is also pretty lackluster. Unfortunately I haven't been able to find a satisfying icon theme, as
all icon themes that I've found are either 90% blank, empty icons, or they've been replaced with minimalist icons. (Most icon themes are developed for GTK-based desktop environments, few tend to support KDE)
The closest I was able to find was a Windows 8 icon theme. (https://b00merang.weebly.com/icon-themes.html)

I modified the icon theme by replacing a few minimalist icons with the Win7 alternatives, though it's not complete. 

The last KDE-specific defect is the text-only tooltips, which for some reason have insane padding. This used to
not be a problem, but after a specific update it started happening. I'm not very familiar with KDE theming as it's
fairly confusing, so I don't know how I would fix this issue.

### Lack of features problem <a name="feature-problems"></a>

As for features that are lacking compared to Windows 7, there's a few that I'd like to point out:

1.  <b>The window manager</b><br>
    This theme collection uses smaragd, a KWin decoration engine that essentially uses emerald themes for its
    decorations. While this has enabled Kwin to get a very detailed and close feeling of the Aero visual style,
    it's not perfect. The decorations look a bit weird when maximised, especially when out of focus, but this is
    pretty minor. The second issue is that it doesn't feature window reflections, which makes it pretty jarring
    to look at. 
2.  <b>True Aero peek and Aero shake</b><br>
    There's a widget called Show Desktop (Win7) (https://store.kde.org/p/1100895/) which implements a Windows 7-like
    Show desktop button, with a working Aero Peek. Of course, though, the Aero peek animation depends on KDE's
    settings. KDE comes with two animations for this effect, however neither one really accomplishes the Aero effect,
    so this is something that is left to be desired. Aero shake to my knowledge is also not a thing, but in all honesty
    I've always found it to be a niche feature, so it's not a real priority to recreate. 
    
## TODO List <a name="todo-list"></a>

1. Improve the Seven Start menu plasmoid
    1. Add separator lines and more sidebar entries
        1. If possible, make the sidebar entries configurable
    2. Add proper Recents support and Favourite application support
    3. Add a button "All programs" which lists all programs alphabetically
    4. If possible, make the top-right icon stick out of the Start menu (I have not found a way to make this happen yet sadly)
    5. If possible, make the top-right icon change depending on which sidebar is hovered over.
2. Improve the icon theme
3. Implement window reflections
4. Add 32 bit support (QGtkStyle and Smaragd)




    
