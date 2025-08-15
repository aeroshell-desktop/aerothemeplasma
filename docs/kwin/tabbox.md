# Tabbox switchers (Alt+Tab switchers)

1. Thumbnail Seven
2. Flipswitch (3D)

## Notes about Thumbnail Seven

- Thumbnail Seven replaces the default behavior of the "Show Desktop" entry with the built-in "MinimizeAll" KWin script by querying the item that's supposed to be activated and checking if it is the "Show Desktop" entry. This is done with a [DBus call](https://gitgud.io/wackyideas/aerothemeplasma/-/blob/master/kwin/tabbox/thumbnail_seven/contents/ui/main.qml?ref_type=heads#L28) from within the QML code itself. 
