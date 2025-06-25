#!/bin/bash

CUR_DIR=$(pwd)
USE_SCRIPT="install.sh"

if [[ -z "$(command -v kpackagetool6)" ]]; then
    echo "kpackagetool6 not found. Stopping."
    exit
fi

if [[ -z "$(command -v cmake)" ]]; then
    echo "CMake not found. Stopping."
    exit
fi
if [[ -z "$(command -v ninja)" ]]; then
    if [[ -z "$(command -v make)" ]]; then
        echo "Neither Ninja or GNU Make were found. Stopping"
        exit
    fi
fi

if [[ $1 == '--no-compile' ]]; then
    echo "Skipping compilation..."
else
    echo "Compiling plasmoids..."

    for filename in "$PWD/plasma/plasmoids/src/"*; do
        cd "$filename"
        echo "Compiling $(pwd)"
        sh $USE_SCRIPT $@
        echo "Done."
        cd "$CUR_DIR"
    done
fi

function install_plasmoid {
    PLASMOID=$(basename "$1")
    if [[ $PLASMOID == 'src' ]]; then
        echo "Skipping $PLASMOID"
        return
    fi
    INSTALLED=$(kpackagetool6 -l -t "Plasma/Applet" | grep $PLASMOID)
    if [[ -z "$INSTALLED" ]]; then
        echo "$PLASMOID isn't installed, installing normally..."
        kpackagetool6 -t "Plasma/Applet" -i "$1"
    else
        echo "$PLASMOID found, upgrading..."
        kpackagetool6 -t "Plasma/Applet" -u "$1"
    fi
    echo -e "\n"
    cd "$CUR_DIR"
}

# KPackageTool will update plasmoids on the fly, and this results in
# the system tray forgetting the visibility status of upgraded plasmoids.
# As such, we need to first terminate plasmashell in order to retain
# saved configurations

killall plasmashell

for filename in "$PWD/plasma/plasmoids/"*; do
    install_plasmoid "$filename"
done

setsid plasmashell --replace & # Restart plasmashell and detach it from the script


