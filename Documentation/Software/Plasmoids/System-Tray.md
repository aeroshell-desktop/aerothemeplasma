# SYSTEM TRAY

## TABLE OF CONTENTS
1. [Detailed description](#description)
2. [File structure](#files)
3. [File details](#details)

## Detailed description <a name="description"></a>

The system tray is a special plasmoid in KDE Plasma that essentially contains a collection of other widgets and displays them within the popup panel. This plasmoid also features third party tray icons from other programs, which is standard across many desktop environments. 

Because of the complexity of this plasmoid, this document won't explain everything in detail (as it would be out of scope for this project), instead only showing and explaining the changes done to the source code. Additionally, the source code of this fork hasn't been regularly synchronised with the upstream, so any noticeable differences in the source code not specified here are the result of that. The modifications featured in this fork are purely visual, without altering the core functionality. 

Here is the list of visual changes done to the plasmoid:

**Compact representation:**

- The "Show hidden icons" button has been moved to the left, and features a button texture for the hover, press and active states. 
- The "small" icon size has been reduced even more to the resolution of 16x16 pixels.
- Each tray icon has an animated hover and press state, removing the transition animation when the user clicks from one tray icon to another.
- Additionally, the indicator texture no longer gets rendered when the user clicks on the "Show hidden icons" button.
- The "pop" animation has been removed from the tray icon (the PulseAnimation that happens when a tray icon needs attention is retained).

**Expanded representation:**

- The popup panel is now a floating panel that has is slightly padded from the bottom.
- The popup panel now uses the solid dialog panel SVG texture.
- The popup panel is now smaller in both width and height. 
- The header text is smaller and more consistent in size. 
- The internal plasmoid also has some additional small padding between itself and the panel borders.
- In the "Status and Notifications" view, the item highlight no longer lingers when no item is highlighted by the mouse. 

## File structure <a name="files"></a>

This section lists the locations of modified files and a short description of their roles. Further documentation is provided in each source file.
<br>

|Name                      |Location          |Description                                                        |
|--------------------------|------------------|-------------------------------------------------------------------|
|AbstractItem.qml          |contents/ui/items/|Skeleton code for all tray icons.                                  |
|CurrentItemHighLight.qml  |contents/ui/      |The texture that appears around a tray icon when it's pressed.     |
|ExpanderArrow.qml         |contents/ui/      |The "Show hidden items" button in the compact representation.      |
|ExpandedRepresentation.qml|contents/ui/      |The floating dialog panel that appears when expanding the plasmoid.|
|main.qml                  |contents/ui/      |The main file of the plasmoid.                                     |


