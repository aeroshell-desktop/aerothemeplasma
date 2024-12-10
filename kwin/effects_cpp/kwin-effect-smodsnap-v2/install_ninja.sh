#!/bin/bash
rm -rf build-kf6
cmake -B build-kf6 -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -G Ninja -DBUILD_KF6=ON .
ninja -C build-kf6
sudo ninja -C build-kf6 install
