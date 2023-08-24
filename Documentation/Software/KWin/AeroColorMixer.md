# AEROCOLORMIXER (DEPRECATED)

## TABLE OF CONTENTS

1. [Detailed description](#desc)
2. [Configuration file](#config)
3. [List of files modified by AeroColorMixer](#files)
4. [Notes](#notes)

<a name="desc"></a>
## Detailed description 

The appearance of transparent glass textures in this theme is managed by two separate programs that define color information differently. KDE Plasma's shell renders many of its elements by loading in SVG files as textures, while KWin's window decorations are managed by Smaragd.

AeroColorMixer manages both Smaragd and Plasma's shell at the same time in order to provide a unified accent color across the entire desktop. It is designed to look and function like Windows 7's Personalization menu, including the accent colors found on Windows 7. The accent colors were directly pulled from the following registry key: 

```[ HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM\ColorizationColor ]```

On Windows Vista, 7 and 8.1, this registry key holds the currently applied accent color, stored in the hexadecimal AARRGGBB format. The predefined colors are:
<br>

|Color|Name|Value|
|-----|----|-----|
|<span style="background-color: #6b74b8fc; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Sky|#6b74b8fc|
|<span style="background-color: #a80046ad; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Twilight|#a80046ad|
|<span style="background-color: #8032cdcd; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Sea|#8032cdcd|
|<span style="background-color: #6614a600; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Leaf|#6614a600|
|<span style="background-color: #6697d937; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Lime|#6697d937|
|<span style="background-color: #54fadc0e; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Sun|#54fadc0e|
|<span style="background-color: #80ff9c00; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Pumpkin|#80ff9c00|
|<span style="background-color: #a8ce0f0f; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Ruby|#a8ce0f0f|
|<span style="background-color: #66ff0099; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Fuchsia|#66ff0099|
|<span style="background-color: #70fcc7f8; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Blush|#70fcc7f8|
|<span style="background-color: #856e3ba1; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Violet|#856e3ba1|
|<span style="background-color: #528d5a94; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Lavander|#528d5a94|
|<span style="background-color: #6698844c; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Taupe|#6698844c|
|<span style="background-color: #a84f1b1b; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Chocolate|#a84f1b1b|
|<span style="background-color: #80555555; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Slate|#80555555|
|<span style="background-color: #54fcfcfc; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Frost|#54fcfcfc|
|<span style="background-color: #89e61f8c; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Sunset|#89e61f8c|

Sunset is a predefined color exclusive to AeroThemePlasma, as it wasn't featured in Windows 7. 

Windows Vista and 8.1 feature a unique selection of colors as well. Vista features significantly less colors than Windows 7, with a lot more straightforward color names:
<br>

|Color|Name|Value|
|-----|----|-----|
|<span style="background-color: #45409efe; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Default|#45409efe|
|<span style="background-color: #a3000000; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Graphite|#a3000000|
|<span style="background-color: #a8004ade; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Blue|#a8004ade|
|<span style="background-color: #82008ca5; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Teal|#82008ca5|
|<span style="background-color: #9cce0c0f; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Red|#9cce0c0f|
|<span style="background-color: #a6ff7700; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Orange|#a6ff7700|
|<span style="background-color: #49f93ee7; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Pink|#49f93ee7|
|<span style="background-color: #cceff7f7; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|Frost|#cceff7f7|

Windows 8.1 features almost the same number of colors as Windows 7 (albeit with very disappointing names) and includes a new feature that can determine the accent color from the wallpaper by choosing its dominant color:
<br>

|Color|Value|
|-----|-----|
|<span style="background-color: #c48f8f8f; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c48f8f8f|
|<span style="background-color: #c484c6ff; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c484c6ff|
|<span style="background-color: #c4f276c9; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c4f276c9|
|<span style="background-color: #c4f0c300; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c4f0c300|
|<span style="background-color: #c492cb2a; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c492cb2a|
|<span style="background-color: #c44ccdcd; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c44ccdcd|
|<span style="background-color: #c4ff981d; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c4ff981d|
|<span style="background-color: #c4ff4040; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c4ff4040|
|<span style="background-color: #c4ff57ab; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c4ff57ab|
|<span style="background-color: #c40abf46; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c40abf46|
|<span style="background-color: #c4c071ff; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c4c071ff|
|<span style="background-color: #c454afff; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c454afff|
|<span style="background-color: #c48c90ff; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c48c90ff|
|<span style="background-color: #c4b09d8b; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c4b09d8b|
|<span style="background-color: #c4ffffff; font-size: 24px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>|#c4ffffff|

<br><br>
While not very conclusive, [here](https://stackoverflow.com/questions/3560890/vista-7-how-to-get-glass-color) is a useful thread for more information on how accent colors work in Aero, focused mainly on Windows 7. 

<a name="config"></a>
## Configuration file

AeroColorMixer has a configuration file found in:

```$ ~/.config/.aerorc```

which has the following format:

```
transparency={0,1} # Tells AeroColorMixer if transparency is enabled or not.
red=[0,255]        # The red component of the custom accent color.
green=[0,255]      # The green component of the custom accent color.
blue=[0,255]       # The blue component of the custom accent color.
alpha=[0,255]      # The alpha component of the custom accent color.
color=[0,17]       # Tells AeroColorMixer which color is being used. If the value is 0, then the custom accent color is used.
```

This configuration file is not meant to be edited by hand, as the file only directly effects AeroColorMixer, but won't actually change the accent color on the fly. 

<a name="files"></a>
## List of files modified by AeroColorMixer

When AeroColorMixer applies the accent color across the entire theme, it writes to the following files:

```$ ~/.local/share/plasma/desktoptheme/Seven-Black/widgets/panel-background.svg```

```$ ~/.local/share/plasma/desktoptheme/Seven-Black/widgets/tooltip.svg```

```$ ~/.local/share/plasma/desktoptheme/Seven-Black/dialogs/background.svg```

```$ ~/.local/share/plasma/desktoptheme/Seven-Black/solid/dialogs/background.svg```

```$ ~/.emerald/theme/theme.ini```

On startup, AeroColorMixer will check if these files exist on the system. If at least one SVG file is missing from the system, the program will assume the Plasma theme is not installed, and will only make changes to the Smaragd decoration instead. If the Smaragd theme is not present, then it will only write to the SVG files, and if neither are present on the system, the program will simply close.

<a name="notes"></a>
## Notes

- AeroColorMixer has an option to enable or disable transparency when applying the accent color, however this option does not affect compositing at all. Disabling transparency in AeroColorMixer will instead make the applied accent color opaque, and blends the color with rgb(235, 235, 235), where alpha defines the percentage of the color mixing.
- AeroColorMixer will not write to SVG files that can be found in the "opaque" and "transparent" folders of the Plasma theme.
- When transparency is enabled, the color intensity slider won't actually make the accent color fully opaque or fully transparent when the slider is set to the minimum or maximum value.
- Due to certain limitations, the reflection effect will not be visible at all if transparency is disabled in AeroColorMixer.*

*One idea would be to blend the accent color with the blur during rendering which would keep the reflections visible, but this would potentially break applications which rely on custom blur regions that are colored differently from the rest of the desktop (for example, Konsole).










 
