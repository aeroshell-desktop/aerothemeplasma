#!/bin/sh

ORIGINAL_DIR=$(pwd)

rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make
sudo make install

cd $ORIGINAL_DIR
