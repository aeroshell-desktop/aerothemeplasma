## Building

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

1. Install ```snapeffecttextures.smod.rcc``` into ```~/.local/share/smod```
2. Navigate to ```Desktop Effects```, then enable the ```SMOD Snap``` effect and disable the ```Screen Edge``` effect

## Licenses

"SMOD Snap" is licensed under the GPL-3.0 or later.
The default animation art is licensed under the Creative Commons Zero (CC0).
