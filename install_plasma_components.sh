#!/bin/bash

CUR_DIR=$(pwd)

if [[ -z "$(command -v kpackagetool6)" ]]; then
    echo "kpackagetool6 not found. Stopping."
    exit
fi
if [[ -z "$(command -v tar)" ]]; then
    echo "tar not found. Stopping."
    exit
fi
if [[ -z "$(command -v sddmthemeinstaller)" ]]; then
    echo "sddmthemeinstaller not found. Stopping."
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

#killall plasmashell

# LNF
install_component "$PWD/plasma/look-and-feel/authui7" "Plasma/LookAndFeel"
# Layout template
install_component "$PWD/plasma/layout-templates/io.gitgud.wackyideas.taskbar" "Plasma/LayoutTemplate"
# Plasma Style
install_component "$PWD/plasma/desktoptheme/Seven-Black" "Plasma/Theme"
# Shell
install_component "$PWD/plasma/shells/org.kde.plasma.desktop" "Plasma/Shell"

# Color scheme
echo -e "Installing color scheme..."
COLOR_DIR="$HOME/.local/share/color-schemes"
mkdir -p "$COLOR_DIR"
cp "$PWD/plasma/color_scheme/AeroColorScheme1.colors" "$COLOR_DIR"
#plasma-apply-colorscheme AeroColorScheme1

# SMOD
echo -e "Installing SMOD resources..."
pkexec cp -r "$PWD/plasma/smod" "/usr/share/"
# SDDM
echo -e "Installing SDDM theme..."
cd "plasma/sddm"
tar -zcvf "sddm-theme-mod.tar.gz" "sddm-theme-mod"
sddmthemeinstaller -i "sddm-theme-mod.tar.gz"
rm "sddm-theme-mod.tar.gz"

#setsid plasmashell --replace & # Restart plasmashell and detach it from the script


