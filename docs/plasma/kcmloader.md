# KCM Loader

KCM Loader is a small application that can load arbitrary KCMs and open them as separate dialog windows using [KCMultiDialog](https://api.kde.org/frameworks/kcmutils/html/classKCMultiDialog.html).

### Usage:

KCM Loader takes two arguments:

1. Relative path to a KCM's `.so` file. The path is relative to `/usr/lib/qt6/plugins/`
2. Icon name from the icon theme

Example:

```bash
aerothemeplasma-kcmloader org.kde.kdecoration3.kcm/kcm_smoddecoration.so application-x-theme
```

It's important to note that it isn't necessary to explicitly specify `kwin-x11` in the path when trying to load a KWin effect's KCM. KCM Loader will automatically load the X11 variant of the KCM if the application is executed in an X11 session.

### Custom behaviors

Upon loading a KCM with KCM Loader, it will pass a [KPluginMetaData](https://api.kde.org/frameworks/kcoreaddons/html/classKPluginMetaData.html) instance with a custom JSON object. Currently, the JSON object only has a boolean property `standalone` set to `true`, but in theory the JSON object could have any arbitrary data attached to it. Normally (or at least, based on experience), KCMs tend to ignore the `KPluginMetaData` object that's passed to them, but with this mechanism we can write KCMs that can respond differently based on the provided JSON information.   

The primary example of this mechanism in use is quick access to AeroGlassBlur's accent color page. Normally, it is accessed by opening the System settings, navigating to the KCM, and clicking on the link that opens the page. With KCM Loader, however, the KCM will read and recognize the `standalone` property from the JSON object, and automatically open the accent color page.

### Future plans

- Turn this into a generic C++ library that can be accessed from QML or other parts of C++ code
- Expand the custom behavior mechanism to allow for arbitrary data that KCMs can interpret
