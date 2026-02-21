#!/bin/bash

CUR_DIR=$(pwd)

# Sanity check to see if the proper tools are installed
if [[ -z "$(command -v tar)" ]]; then
    echo "tar not found. Stopping."
    exit
fi
if [[ -z "$(command -v unzip)" ]]; then
    echo "unzip not found. Stopping."
    exit
fi

TMP_DIR="/tmp/atp"
mkdir -p "$TMP_DIR"

# Installs the Kvantum theme.
echo "Installing Kvantum theme..."
KV_DIR="$HOME/.config"
cp -r "$PWD/misc/kvantum/Kvantum" "$KV_DIR"
echo "Done."

# Installs the sound themes.
echo "Unpacking sound themes..."
SOUNDS_DIR="$HOME/.local/share/sounds"
mkdir -p "$SOUNDS_DIR"
tar -xf "$PWD/misc/sounds/sounds.tar.gz" --directory "$SOUNDS_DIR"
echo "Done."

# Installs the icon theme.
echo "Unpacking icon theme..."
ICONS_DIR="$HOME/.local/share/icons"
mkdir -p "$ICONS_DIR"
tar -xf "$PWD/misc/icons/Windows 7 Aero.tar.gz" --directory "$ICONS_DIR"
echo "Done."

# Installs the cursor theme. Requires admin privileges as this theme gets installed globally so SDDM can use it.
echo "Unpacking cursor theme..."
CURSOR_DIR="/usr/share/icons"
pkexec tar -xf "$PWD/misc/cursors/aero-drop.tar.gz" --directory "$CURSOR_DIR"
echo "Done."

# Installs the modified mimetype associations.
echo "Installing mimetypes..."
MIMETYPE_DIR="$HOME/.local/share/mime/packages"
mkdir -p "$MIMETYPE_DIR"
for filename in "$PWD/misc/mimetype/"*; do
    cp -r "$filename" "$MIMETYPE_DIR"
done
update-mime-database "$HOME/.local/share/mime"
echo "Done."


# Optional components
echo "Do you want to install a custom font configuration for Segoe UI fonts? (Recommended) (y/N)"
read answer
FONTCONF_DIR="$HOME/.config"

if [ "$answer" != "${answer#[Yy]}" ] ;then

    # Installs custom fontconfig to tweak Segoe UI.
    if test -f "$FONTCONF_DIR/fontconfig/fonts.conf"; then
        echo "Backing up fonts.conf to fonts.conf.old"
        cp -r "$FONTCONF_DIR/fontconfig/fonts.conf" "$FONTCONF_DIR/fontconfig/fonts.conf.old"
    fi
    echo "Installing custom font configuration..."
    cp -r "$PWD/misc/fontconfig/" "$FONTCONF_DIR"

    # Defines QML_DISABLE_DISTANCEFIELD environment variable which generally enhances the font rendering.
    HAS_VAR=$(grep "QML_DISABLE_DISTANCEFIELD" /etc/environment)
    echo "Adding QML_DISABLE_DISTANCEFIELD=1 to /etc/environment"
    if [[ -n "$HAS_VAR" ]]; then
        echo "Variable already added, skipping..."
    else
	    pkexec sh -c "echo \"QML_DISABLE_DISTANCEFIELD=1\" >> /etc/environment"
    fi
fi
echo "Done."

# Installs custom branding for the system settings info page.
echo "Do you want to install custom branding for Info Center? (y/N)"
read answer
BRANDING_DIR="$HOME/.config/kdedefaults"
mkdir -p "$BRANDING_DIR"

if [ "$answer" != "${answer#[Yy]}" ] ;then
    for filename in "$PWD/misc/branding/"*; do
        cp -r "$filename" "$BRANDING_DIR"
    done
    kwriteconfig6 --file "$BRANDING_DIR/kcm-about-distrorc" --group General --key LogoPath "$BRANDING_DIR/kcminfo.png"
fi
echo "Done."

# Installs the terminal font.
echo "Do you want to install the command prompt font (Terminal Vector)? (y/N)"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    curl -L https://www.yohng.com/files/TerminalVector.zip > "$TMP_DIR/TerminalVector.zip"
    unzip "$TMP_DIR/TerminalVector.zip" -d "$TMP_DIR"
    kfontinst "$TMP_DIR/TerminalVector.ttf"
fi
echo "Done."

# Installs the Plymouth theme.
echo "Do you want to install the Plymouth theme? (y/N)"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    if [[ -z "$(command -v git)" ]]; then
        echo "Git not found. Cannot install Plymouth theme automatically!"
        echo "Please download the repository from https://github.com/furkrn/PlymouthVista as a zip file by clicking the green code button."
        echo "Then extract the zip file and run './compile.sh ; sudo ./install.sh' from the extracted directory."
    else
        git clone https://github.com/furkrn/PlymouthVista
        cd PlymouthVista
        chmod +x ./compile.sh
        chmod +x ./install.sh
        ./compile.sh
        pkexec --keep-cwd ./install.sh
        echo "For more details, check out the project at https://github.com/furkrn/PlymouthVista"
    fi
fi

echo "Done."
