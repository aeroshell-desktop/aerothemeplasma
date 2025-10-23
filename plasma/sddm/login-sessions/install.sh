#!/bin/bash

mkdir -p build
cd build

LIBEXEC_PATH="-DCMAKE_INSTALL_LIBEXECDIR=lib"
if [[ -z "$(command -v pacman)" ]]; then
    LIBEXEC_PATH=
fi

cmake .. -DCMAKE_INSTALL_PREFIX=/usr $LIBEXEC_PATH
sudo cmake --build . --target install
