# AEROTHEMEPLASMA DOCUMENTATION

## TABLE OF CONTENTS

1. [Introduction](#intro)
2. [List of components](#list-of-components)
3. [Components to be implemented](#todo)

## Introduction <a name="intro"></a>

The purpose of this documentation is to provide a detailed explanation of elements that contribute to the look, feel and functionality of this project. 
Since this project features a large variety of components, ranging from simple themes to
entire applications, documentation will be organized into multiple categories based on the 
language the component is written in (plasmoids, applications) or the standard that defines it (themes). Components will categorized in the following way:

- **Themes**
    - [Plasma theme (Seven-Black)](./Documentation/Themes/Seven-Black.md)
    - [Window decoration theme (Emerald/Smaragd)](./Documentation/Themes/Smaragd-Theme.md)
- **Software**
    - Plasmoids
        - [System tray (org.kde.plasma.private.systemtray)](./Documentation/Software/Plasmoids/System-Tray.md)
        - [Desktop icons (org.kde.desktopcontainment)](./Documentation/Software/Plasmoids/DesktopContainment.md)
        - [SevenStart (io.gitgud.wackyideas.SevenStart)](./Documentation/Software/Plasmoids/SevenStart.md)
        - [SevenTasks (io.gitgud.wackyideas.seventasks)](./Documentation/Software/Plasmoids/SevenTasks.md)
    - KWin
        - [Smaragd](./Documentation/Software/KWin/Smaragd.md)
        - [Reflection effect](./Documentation/Software/KWin/Reflection.md)

To keep the documentation condensed and to prevent redundancy, components that don't require documentation or are out of scope for this project (as in, documentation exists elsewhere) will not be documented here:

- Date and time (io.gitgud.wackyideas.digitalclocklite)
- Show desktop (Aero) (io.gitgud.wackyideas.win7showdesktop)
- Keyboard switcher (org.kde.plasma.keyboardlayout)
- Splash screen (aero-splash-screen)
- Plasma tooltip (DefaultToolTip.qml)
- Wine theme (Windows Style Builder)
- Color scheme ([KDE's docs](https://docs.kde.org/stable5/en/plasma-workspace/kcontrol/colors/index.html), [Video guide](https://www.youtube.com/watch?v=6VW--o7CEEA))
- Icon theme ([Freedesktop](https://specifications.freedesktop.org/icon-naming-spec/icon-naming-spec-latest.html) [specification](https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html))
- Cursor theme ([Freedesktop specification](https://www.freedesktop.org/wiki/Specifications/cursor-spec/))
- Sound theme (KDE system settings)
- GTK2 theme ([GTK2](https://wiki.gnome.org/Attic/GnomeArt/Tutorials/GtkThemes) [theme details](https://www.orford.org/gtk/))
- Kvantum theme* ([Kvantum](https://raw.githubusercontent.com/tsujan/Kvantum/master/Kvantum/doc/Theme-Making.pdf) [documentation](https://raw.githubusercontent.com/tsujan/Kvantum/master/Kvantum/doc/Theme-Config.pdf))

*While Kvantum won't be discussed here, one important detail worth mentioning is that Kvantum does not respect KDE's color schemes for the most part and that this sometimes leads to unexpected visual results. Still, it's recommended to apply a KDE color scheme alongside Kvantum for maximum compatibility.

In the future, some components might receive their dedicated documentation, in case it's required.

## List of components <a name="list-of-components"></a>

This is a list of components that are included in this project, as well as their completion status. Note that finished components are still subject to bugs, general enhancements and maintenance, but they are "more or less" feature complete. The forked column links to the original projects and their authors. Please consider taking a look at their work, because without them, this project would not be possible. 

### Plasmoids

|Name                   |Description                                                                              |System|Finished|Fork    |
|-----------------------|-----------------------------------------------------------------------------------------|------|--------|--------|
|DigitalClockLite Seven |Displays a calendar, time, events and holidays.                                          |N     |Y       |[Intika](https://www.kde-look.org/p/1225135/)|
|SevenStart             |An application launcher made to look like Windows 7's Start menu.                        |N     |N       |[adhe](https://store.kde.org/p/1386465/),<br>[oKcerG](https://github.com/oKcerG/QuickBehaviors),<br>[SnoutBug](https://store.kde.org/p/1720532)|
|SevenTasks             |Task manager made to look like Windows 7's taskbar buttons.                              |N     |N       |[KDE](https://invent.kde.org/plasma/plasma-desktop/-/tree/master/applets/taskmanager)|
|Show Desktop (Aero)    |Textured button that shows the desktop when clicked. Supports peeking.                   |N     |Y       |[Zren](https://www.kde-look.org/p/1100895/)|
|DefaultToolTip.qml     |QML component used for displaying tooltips. Reduced padding and size.                    |Y     |Y       |[KDE](https://api.kde.org/frameworks/plasma-framework/html/DefaultToolTip_8qml_source.html)|
|Desktop icons          |Improved desktop shell that reduces padding between icons.                               |Y     |Y       |[KDE](https://invent.kde.org/plasma/plasma-desktop)|
|Keyboard layout switcher|Textured button for switching layouts, with reduced size and better alignment.          |Y|Y|[KDE](https://invent.kde.org/plasma/plasma-desktop)|
|System tray|Redesigned with reorganized placement, floating panels, hoverable icons and reduced size and padding.|Y|Y|[KDE](https://invent.kde.org/plasma/plasma-workspace/-/tree/master/applets/systemtray)|


### Themes

|Name              |Description                                                                                                       |Finished|Fork|
|------------------|------------------------------------------------------------------------------------------------------------------|--------|----|
|Aero cursors      |Cursor pack for KDE. Currently only has the small size (96 DPI).                                                       |N       |[Moony](https://store.kde.org/p/999972/)|
|SevenBlack        |Windows 7 theme for KDE Plasma. Contains non-standard theme elements.                                             |N       |[Mirko Gennari](https://kde-look.org/p/998614),<br> [DrGordBord](https://store.kde.org/p/1722560/),<br> [bionegative](https://www.pling.com/p/998823)|
|Sound collection  |Sounds taken from Windows 7 directly.                                                                             |Y       |Microsoft|
|VistaVG Wine theme|Msstyle used for theming Wine applications.                                                                       |Y       |[Vishal Gupta](https://www.deviantart.com/vishal-gupta/art/VistaVG-Ultimate-57715902)|
|Win2-7            |Windows 7 theme for GTK2 applications. Adapted to work better with QGtkStyle.                                     |Y       |[Juandejesuss](https://www.gnome-look.org/p/1012465)|
|Windows 7 Kvantum |Fixed certain padding and sizing issues, added more textures.                                                     |Y       |[DrGordBord](https://store.kde.org/p/1679903)|
|WindowsIcons      |Windows 8.1 icon pack adapted to fit KDE better while also changing certain icons to their Windows 7 counterparts.|N       |[B00merang team](https://b00merang.weebly.com/icon-themes.html)|


### KWin

|Name             |Description                                                                                                                   |Finished|Fork|
|-----------------|------------------------------------------------------------------------------------------------------------------------------|--------|----|
|Aero Emerald     |Custom, non-standard Emerald theme made to work with Smaragd Seven.                                                           |Y       |[nicu96](https://store.kde.org/p/1003826/)|
|Reflection Effect|Effect that renders a glassy texture under windows.                                        |N       |[KDE](https://invent.kde.org/plasma/kwin/-/tree/master/src/plugins/blur)|
|Smaragd Seven    |KWin decoration theme which uses Emerald themes as a basis, with some Aero specific changes and bugfixes. Lacks HiDPI support.|N       |[KDE](https://invent.kde.org/plasma/smaragd)|
|Thumbnail Seven  |KWin task switcher that mostly replicates the look and behavior of Windows 7's task switcher|N|[KDE](https://invent.kde.org/plasma/kwin/-/tree/master/src/tabbox/switchers/thumbnail_grid)|

### Applications

|Name          |Description                                                            |Finished|Fork|
|--------------|-----------------------------------------------------------------------|--------|----|
|AeroColorMixer|Program designed for changing the accent color across the entire theme. (NOTE: This program is now deprecated and has been moved into the reflection effect.)|Y       |N/A |

### Miscellaneous

|Name               |Description                     |Finished|Fork|
|-------------------|--------------------------------|--------|----|
|Aero Splash Screen |Aero themed login splash screen.|Y       |[Matias Saibene](https://store.kde.org/p/1920070/)|




## Components to be implemented <a name="todo"></a>

These components are listed from highest priority to lowest priority.

- **Qt visual style based on reading Msstyle themes (Like QWindowsVistaStyle)**
- **Proper sound theme (upcoming in KDE Plasma 6)**
- **SDDM Login theme and lock screen**
- **Better folder thumbnailer plugin**
- **Plymouth theme(?)**
