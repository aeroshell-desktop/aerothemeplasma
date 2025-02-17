This Plymouth theme provides a boot and shutdown screen, as well as a password prompt for encrypted disks.

*NOTE: this theme does not provide an update screen (e.g. Fedora)*

### Installation

```sh
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr .
make -C build
sudo make -C build install
```

Once installed, apply the theme by following your distribution's instructions on switching Plymouth themes.

### Tweaks

The theme can be tweaked by passing the following options to cmake:

* ```
  -DBOOT_ANIM_START_DELAY=3
  ```
  The time in seconds to delay the boot animation graphic.

* ```
  -DBOOT_PROGRESS_CLEAR=0.99
  ```
  A percentage between zero and one (e.g. 0.95 for 95%) that "clears" the screen at the specified boot progress. This simply sets the opacity of all onscreen graphics to zero.

* ```
  -DINSTALL_SERVICES=ON
  ```
  Two systemd services can optionally be installed to delay Plymouth ending by a specified amount of time. You may need to install these to see the full animation if your system boots/powers off too quickly. These are ```smod-plymouth-wait-for-animation.service``` and ```smod-plymouth-wait-for-animation-poweroff.service```, and are based on [this Arch Wiki extry](https://wiki.archlinux.org/title/Plymouth#Slow_down_boot_to_show_the_full_animation).

* ```
  -DSMOD_WAIT_BOOT=30
  ``` 
  The time in seconds to wait before Plymouth quits at boot.

* ```
  -DSMOD_WAIT_SHUTDOWN=10
  ``` 
  The time in seconds to wait before Plymouth quits at shutdown.


