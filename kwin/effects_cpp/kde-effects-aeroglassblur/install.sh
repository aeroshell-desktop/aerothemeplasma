#!/bin/bash
rm -rf build
mkdir build
cd build

if [ "$1" == "--wayland" ]
then
    echo "Building Wayland effect..."
    cmake ../ -DCMAKE_INSTALL_PREFIX=/usr -DKWIN_BUILD_WAYLAND=ON
else
    echo "Building X11 effect..."
    cmake ../ -DCMAKE_INSTALL_PREFIX=/usr
fi

make
sudo make install
