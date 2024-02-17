#!/bin/bash

echo "Building decoration"
echo

cd breeze || exit 1

rm -rf build
mkdir -p build
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr .
make -C build && echo "Done"
cd ..
