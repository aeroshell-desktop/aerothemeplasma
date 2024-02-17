#!/bin/bash

echo "Building kwin effect"
echo

cd kwin-effect-smodwindowbuttons || exit 1

mkdir -p build
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr . || exit 1
make -C build && echo "Done"
cd ..
