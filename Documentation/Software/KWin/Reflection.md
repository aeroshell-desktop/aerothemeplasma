# REFLECTION EFFECT FOR KWIN

## TABLE OF CONTENTS

1. [Detailed description](#description)
2. [List of excluded windows](#excluded-windows)
3. [Reflection algorithm](#algorithm)
4. [Colorization](#colorization)
5. [Configuration menu](#config)


## Detailed description <a name="description"></a>

This is a KWin effect forked from the internal blur effect. It provides the reflection and colorization effect from Windows Vista and 7. These two effects achieve a "tinted glass" effect which is applied to most transparent graphical effects. Despite being a fork of the internal blur effect from KWin, all of the blurring functionality has been stripped out, as this effect is designed to be used alongside the blur effect, rather than being a drop-in replacement.

Before the introduction of this effect, this project didn't have proper reflections and colorization was done in a rather inefficient way, having to directly edit SVG files and the Emerald theme config file in order to change the accent color across KDE. Furthermore, real time changes weren't possible through this method, instead having to reload the Plasma style and restart the compositor in order to apply the changes. AeroColorMixer did all of this under the hood, and would often break after subsequent updates.

AeroColorMixer as a standalone program is now deprecated and most of the underlying code has been removed, while the rest has been moved to this effect's settings menu. With this, the following changes have been made to simplify the process of applying accent colors:

1. SVG files are no longer edited and elements that are supposed to be colorized are now completely transparent. 
2. Likewise, the Emerald theme is also no longer edited and elements that are supposed to be colorized are now completely transparent.
3. Changes to the accent color and transparency are instant and rely on shared memory between the effect and the config menu.
4. Everything is contained within the configuration of this effect. Because of this, ```~/.config/.aerorc``` is no longer used. 

The rendering priority relative to the blur effect, assuming no other active effects, goes like this:

1. Blur
2. Colorization
3. Reflections
4. Decorations

This ensures that reflections are always visible regardless of transparency options, which was a limitation of the previous approach to applying accent colors. 

The user can provide their own reflection texture in the config menu for the effect, in a PNG format. A default reflection texture is already provided by the effect, which also acts as a fallback in case the provided texture file is invalid, doesn't exist or the path itself is invalid.

## List of excluded windows <a name="excluded-windows"></a>

Reflections will not render on certain types of windows, even if they are normally allowed to have blur behind them. Here's the list of windows that are not affected by this effect, as defined by the method ```isWindowValid(KWin::EffectWindow*)```:

- The desktop shell
- Toolbars
- Tooltips
- Menus
- Dropdown menus
- Popup menus
- Splash screens
- Normal and critical notifications
- OSDs
- Combo boxes
- Do not disturb icons
- Windows specifically excluded by the user

The user can define a list of programs that should be excluded by this effect. The programs are identified by their X11 window class, separated by a semicolon (;) in the config menu.

The colorization effect can also be ignored for programs defined by the user in the same manner as above, however it should be noted that the colorization is applied to all server-side decorations regardless of the defined restrictions.

## Reflection algorithm <a name="algorithm"></a>

As the reflection effect from Windows Vista and 7 is closed source, this is merely an effort to recreate the effect based on what can be deduced just by looking at what the effect does. At its core, the effect is very simple; it works as if the reflection texture is stretched across the monitor (or across multiple monitors) and transparent windows render the portion of the texture that they're "hovering above".

Of course, as the monitor configuration changes in any way (resolution, monitor placement), the texture is "stretched" again to cover all monitors. This may cause the texture to scale and distort out of proportion. Some examples of how the effect stretches the texture across different monitor configurations are shown below.

<img src="../img/reflection_mockup.png">

In the fragment shader, as the window draws the texture, the fragment coordinates are normalized relative to the screen geometry, and then used to sample the reflection texture. It should be noted that the sampling is done with a bilinear filter, and the alpha blending is done using ```glBlendFunc(GL_CONSTANT_ALPHA, GL_ONE_MINUS_SRC_ALPHA)```.

There is also a secondary part of the reflection effect, which is a subtle horizontal offset that makes the reflection appear to move as the window is moved, creating a sort of parallax effect. This offset is calculated independently for every window by subtracing the horizontal midpoint of the screen with the horizontal midpoint of the window, and dividing that difference by some constant. Through some experimentation, a constant with the value of 10 gives acceptable results.

This additional parallax effect can be toggled in the config menu by the user.

## Colorization <a name="colorization"></a>

Colorization is the effect of rendering a color over the blurred background behind windows, causing a tinted appearance. The color can be either semi-transparent or opaque, and depending on the option set by the user, the accent color is altered in the following way:

1. If transparency is enabled, the color is blended using ```glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)``` as it's being rendered.
2. If transparency is disabled, the color is mixed with a base color ```#e1e1e1``` and the alpha component is treated as the percentage of mixing.

It should be noted that if transparency is disabled, this won't affect compositing, and it will also not guarantee that all graphical elements will be rendered with an opaque color due to user-defined exclusions of colorization. For example, Konsole can still render blur behind its custom blur region, if it is included in the exclusion list. 

The accent color also changes depending on the window's focus state:

1. If transparency is enabled, the alpha component of the accent color gets halved when the window is out of focus.
2. If transparency is disabled, the saturation component (HSL) gets halved when the window is out of focus. 

This only applies to regular windows (most windows with server-side decorations).

## Configuration menu <a name="config"></a>

The accent color can be edited in real time through the configuration menu. Internally, the color is stored in the RGB color model as that's what OpenGL expects during rendering. The color mixer window is designed to look and function like Windows 7's Personalization menu, and includes the accent colors found on Windows 7, which were directly pulled from the following registry key:  


```[ HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM\ColorizationColor ]```

On Windows Vista, 7 and 8.1, this registry key holds the currently applied accent color, stored in the #AARRGGBB format. The predefined colors are:
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

Sunset is a predefined color exclusive to AeroThemePlasma.

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

Windows 8.1 features a slightly more pastel variety of colors compared to Windows 7 and includes a new feature that can determine the accent color from the wallpaper by choosing its dominant color:
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
While not very conclusive, [here](https://stackoverflow.com/questions/3560890/vista-7-how-to-get-glass-color) is a useful thread for more information on how accent colors work in Aero, focusing mainly on Windows 7. 