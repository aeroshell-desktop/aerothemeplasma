# SMARAGD SEVEN KDECORATION2 ENGINE

## TABLE OF CONTENTS

1. [Detailed description](#desc)
2. [Compiling](#compiling)
3. [File structure](#files)
4. [Notes](#notes)

## Detailed description <a name="description"></a>

Smaragd Seven is a fork of the [Smaragd](https://invent.kde.org/plasma/smaragd) window decoration plugin. Originally designed to allow Emerald themes to be used with KWin, this fork focuses specifically on making KWin's decorations look like the decorations found on Windows Vista and 7. 

The motive for forking Smaragd in particular was simply because Emerald already has fairly good Aero themes available on sites like [Pling](https://www.pling.com/), and Smaragd seemed to fit the bill perfectly. Emerald as a (collection of) decoration engine(s) still has a few limitations that prevent it from being able to replicate Aero window decorations faithfully (not to mention that Smaragd introduces a few compatibility issues of its own), so forking Smaragd was the next step. 

This document contains information about the window decoration engine, for more information about the extended Emerald theme used by this project, see [Smaragd-Theme.md](../Themes/Smaragd-Theme.md).

Smaragd Seven differs from the original in the following ways:

- The glow effect behind the title text is now correctly implemented using code from [this thread](https://stackoverflow.com/questions/28918230/qt-how-to-create-a-clearly-visible-glow-effect-for-a-qlabel-e-g-using-qgraph). 
- Caption buttons won't get rendered if they are disabled by the application, and will reappear correctly in case they're enabled again.
- Fixes some minor margin issues, mostly having to do with the maximized window state.
- Renders additional textures on the sides and upper corners of the decoration. 
- It's more limited in scope and sacrifices the general purpose functionality of using different Emerald themes. This could be fixed later down the line.

## Compiling <a name="compiling"></a>

Dependencies, and compiling instructions are provided in [INSTALL.md](../../INSTALL.md), under the **Window Manager** section.

## File structure <a name="files"></a>

The most significant changes can be found in the following files: 

|Name            |Description      |
|----------------|-----------------|
|kwin_smaragd.h  |Main header file.|
|kwin_smaragd.cpp|Implementation of the main header file.|
|qgraphicsgloweffect.h|Header file for QGraphicsGlowEffect. Used to render the glow effect behind text.|
|qgraphicsgloweffect.cpp|Implementation of the header file for QGraphicsGlowEffect.|

## Notes <a name="notes"></a>

- Smaragd Seven also fixes the original glow effect used by the vrunner engine, however this feature has been disabled in favor of using QGraphicsGlowEffect, as it enables a more layered way of rendering visual elements.