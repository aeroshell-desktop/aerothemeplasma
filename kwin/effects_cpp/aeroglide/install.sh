#!/bin/bash

rm -rf build-kf6
cmake -B build-kf6 -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_KF6=ON .
make -C build-kf6
sudo make -C build-kf6 install
