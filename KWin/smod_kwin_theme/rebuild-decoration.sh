#!/bin/bash

echo "Building decoration"
echo

cd breeze || exit 1

mkdir -p build
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr .
make -C build && echo "Done"
cd ..
