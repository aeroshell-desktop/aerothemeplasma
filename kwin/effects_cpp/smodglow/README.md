# SMOD Glow Effect

A KWin Effect for KDE Plasma

## Building and installation

### Plasma 5

```sh
cmake -B build-kf5 -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .
make -C build-kf5
sudo make -C build-kf5 install
```

### Plasma 6

```sh
cmake -B build-kf6 -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_KF6=ON .
make -C build-kf6
sudo make -C build-kf6 install
```

## Installation

1. Install ```smodgloweffecttextures.smod.rcc``` into ```~/.local/share/smod```
2. Open KDE System Settings and navigate to ```Desktop Effects```, then enable the ```SMOD Glow``` effect

## License

GPL-3.0

## Known Issues

* Sometimes after changing the global animation speed in system settings, then rapidly hovering over the caption buttons, the glow will appear at the window origin instead of the button origin
* PAINTING: resizing a window while hovering over a caption button causes a paint artifact
* PAINTING: some windows (noticed this with Team Fortress 2, possibly related to graphics), fail to repaint the glow ONLY when no other windows are intersecting its client geometry, regardless of stacking order and focus state.
