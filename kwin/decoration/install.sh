#!/bin/bash

BUILD_DST="build"
USE_NINJA=
BUILD_COMMAND="make"

if [[ "$*" == *"--ninja"* ]]
then
    if [[ -z "$(command -v ninja)" ]]; then
        echo "Attempted to build using Ninja, but Ninja was not found on the system. Falling back to GNU Make."
    else
        echo "Compiling using Ninja"
        USE_NINJA="-G Ninja"
        BUILD_COMMAND="ninja"
    fi
fi


rm -rf "$BUILD_DST"
mkdir "$BUILD_DST"
cd "$BUILD_DST"
cmake -DCMAKE_INSTALL_PREFIX=/usr .. $USE_NINJA
$BUILD_COMMAND
sudo $BUILD_COMMAND install
