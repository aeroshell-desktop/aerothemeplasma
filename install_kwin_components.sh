#!/bin/bash

CUR_DIR=$(pwd)

if [[ -z "$(command -v kpackagetool6)" ]]; then
    echo "kpackagetool6 not found. Stopping."
    exit
fi

# install_component $filename "Plasma/Shell"
function install_component {
    COMPONENT=$(basename "$1")
    INSTALLED=$(kpackagetool6 -l -t "$2" | grep $COMPONENT)
    if [[ -z "$INSTALLED" ]]; then
        echo "$COMPONENT isn't installed, installing normally..."
        kpackagetool6 -t "$2" -i "$1"
    else
        echo "$COMPONENT found, upgrading..."
        kpackagetool6 -t "$2" -u "$1"
    fi
    echo -e "\n"
    cd "$CUR_DIR"
}

echo "Installing KWin effects (JS)..."
for filename in "$PWD/kwin/effects/"*; do
    install_component "$filename" "KWin/Effect"
done
echo "Done."

echo "Installing KWin scripts..."
for filename in "$PWD/kwin/scripts/"*; do
    install_component "$filename" "KWin/Script"
done
echo "Done."

echo "Installing KWin task switchers..."
for filename in "$PWD/kwin/tabbox/"*; do
    install_component "$filename" "KWin/WindowSwitcher"
done
echo "Done."

# Outline
echo "Installing outline..."
KWIN_DIR="$HOME/.local/share/kwin"
cp -r "$PWD/kwin/outline" "$KWIN_DIR"
echo "Done."

echo "Making kwin-x11 and kwin-wayland symlinks..."
ln -s kwin kwin-x11
ln -s kwin kwin-wayland
echo "Done."




