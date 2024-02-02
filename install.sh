#!/usr/bin/env bash

# Somewhat automatic install script for AeroThemePlasma
# This installer is a WIP and doesn't do much other than
# copy files to their intended locations.
# Currently only works on Arch based systems, support for Debian
# based distros is planned.
# Read INSTALL.md for more information.
# wackyideas 2024, https://gitgud.io/wackyideas/aerothemeplasma

# Defining some useful paths
# User directories

set -e

USER_CONFIG=~/.config/
USER_LOCAL=~/.local/share/
PLASMA_THEMES=${USER_LOCAL}plasma/desktoptheme/
USER_PLASMOIDS=${USER_LOCAL}plasma/plasmoids/
USER_LOOK_AND_FEEL=${USER_LOCAL}plasma/look-and-feel/
COLOR_SCHEMES=${USER_LOCAL}color-schemes/
USER_ICONS=${USER_LOCAL}icons/
KWIN_SWITCHER_DIR=${USER_LOCAL}kwin/tabbox/
EMERALD_PATH=~/.emerald/
KVANTUM_THEMES=${USER_CONFIG}Kvantum/
CURSOR_USER=~/.icons/default/
CURSOR_SYSTEM=/usr/share/icons/

# System directories
KWIN_PLUGIN_DIR=/usr/lib/qt/plugins/org.kde.kdecoration2/ # Used for installing Smaragd
KWIN_EFFECTS_DIR=/usr/lib/qt/plugins/kwin/effects/plugins/ # Used for installing the reflection effect
KWIN_CONFIGS_DIR=/usr/lib/qt/plugins/kwin/effects/configs/ # Used for installing the reflection effect config
SYSTEM_PLASMOIDS=/usr/share/plasma/plasmoids/ # No longer necessary 
PLASMOID_PLUGINS=/usr/lib/qt/plugins/plasma/applets/ # Used for installing C++ components of SevenTasks and SevenStart
TOOLTIP_DIR=/usr/lib/qt/qml/org/kde/plasma/core/private/ # Used for installing the modified tooltip component
SOUNDS_DIR=/usr/share/sounds/ # Used for installing sounds, will most likely be deprecated when KDE 6 is out

FONTS_DIR=/usr/share/fonts/windows/

# Inner directories

# Plasma
INNER_PLASMA_WIDGETS=./Plasma/Plasma_Widgets/
INNER_COLOR_SCHEME=./Plasma/Color_Scheme/
INNER_SOUNDS="./Plasma/Sounds/"
INNER_GLOBAL_THEME=./Plasma/Global_Theme/ # Unused
INNER_PLASMA_THEME=./Plasma/KDE_Plasma_Theme/
INNER_LOOK_AND_FEEL=./Plasma/Look_and_Feel/

# Qt
INNER_KVANTUM_THEME=./Qt/Application_Theme/Kvantum/

# Icons and cursors
INNER_ICON_THEME=./Icons\ and\ cursors/

# KWin
INNER_KWIN="./KWin/"

# NAMES

# System plasmoids
TOOLTIP_QML=DefaultToolTip.qml

SYSTRAY=org.kde.plasma.private.systemtray
KEYBOARD_LAYOUT=org.kde.plasma.keyboardlayout
DESKTOP_CONTAINMENT=org.kde.desktopcontainment

# User plasmoids
SEVEN_START=io.gitgud.wackyideas.SevenStart
SEVEN_TASKS=io.gitgud.wackyideas.seventasks
DIGITALCLOCKLITE=io.gitgud.wackyideas.digitalclocklite
SHOW_DESKTOP=io.gitgud.wackyideas.win7showdesktop
SEVEN_TASKS_PLUGIN=plasma_applet_seventasks.so
SEVEN_START_PLUGIN=plasma_applet_SevenStart.so

# Themes
PLASMA_THEME=Seven-Black
KVANTUM_THEME=Windows7Kvantum_Aero
SPLASH_SCREEN=authui7
COLOR_SCHEME=AeroColorScheme.colors

# KWin
KWIN_PLUGIN=kwin_smaragd.so
KWIN_EFFECT=libkwin4_effect_reflect.so
KWIN_CONFIG=kwin4_effect_reflect_config.so
KWIN_SWITCHER=thumbnail_seven

# Icons and cursors 
ICONTHEME=windowsicon
CURSORTHEME=aero-drop

function print_help {
	printf "WARNING: This script is early in development\n"
	printf "AeroThemePlasma installer usage:\n\n"
	printf "	./install.sh [command]\n"
	printf "	Semi-automated installer for AeroThemePlasma.\n\n"
	printf "Available commands:\n"
	printf "	help			Shows this screen.\n"
	printf "	install			Performs a CLEAN install of AeroThemePlasma. Recommended for first time installations.\n"
	printf "	fix			Replaces system files (This should be run after every system upgrade).\n"
	printf "For more information, see the INSTALL.md page.\n"
	exit
}
function warning {
	printf "\nWARNING:\nThe installer requires root privileges as it installs certain components in locations not writable by regular users, and also modifies a few system components tied to KDE.\n"
	printf "Important notes:\n- The installer will NOT install Windows fonts\n- The installer will only copy the necessary files to their intended locations\n- The configuration and customization steps are still left for the user to do after this script is finished\n"

	local answer="N"

	read -p "Do you want to continue? [y/N] " answer
	if [[ $answer != [Yy] ]]
	then
		printf "Exiting installer.\n"
		exit
	else
		return
	fi
}
function dependencies {
	local answer="N"

	if (( EUID != 0 ))
	then
		printf "Not running as root. The installer will now exit.\n"
		exit 1
	fi

	if [ command -v pacman &> /dev/null ] 
	then
		read -p "The installer couldn't detect an Arch-based distribution installed on your computer.\nCurrently only Arch-based distributions are supported by the installer. Do you wish to continue? [y/N]\n\n" answer

		if [[ $answer != [Yy] ]]
		then 
			printf "Exiting installer.\n"
			exit
		fi
	fi
	
	printf "Required dependencies:\n- git\n- kvantum\n- tar\n- cmake\n- extra-cmake-modules\n- Qt5 GraphicalEffects\n"
	printf "Checking dependencies..."
	
	if [[ $XDG_CURRENT_DESKTOP != KDE ]]
	then
		printf "\nThe installer couldn't detect KDE running on this system. The installer will now exit.\n"
		exit
	fi
	for cmd in git tar cmake kvantummanager \
		/usr/lib/qt/qml/QtGraphicalEffects/qmldir \
		/usr/share/ECM/cmake/ECMConfig.cmake
	do
		if ! command -v "$cmd" >/dev/null
		then
			printf "Dependency '%s' is missing. The installer will now exit.\n" "$cmd"
			exit 1
		else
			printf " done.\n"
		fi
	done
}
function install_system {
	echo "Overwriting system components..."
	sudo echo "Permissions granted, installing desktop modifications..."

	sudo mkdir -p "${TOOLTIP_DIR}"
	echo "Backing up DefaultToolTip.qml..."

	if [[ ! -f ${TOOLTIP_DIR}${TOOLTIP_QML}.bak ]]; then
		sudo cp "${TOOLTIP_DIR}${TOOLTIP_QML}" "${TOOLTIP_DIR}${TOOLTIP_QML}.bak"
	fi
	echo "Installing DefaultToolTip.qml..."
	sudo cp "${INNER_PLASMA_WIDGETS}System/${TOOLTIP_QML}" "${TOOLTIP_DIR}${TOOLTIP_QML}"
}
function install {
	printf "Running AeroThemePlasma installer\n"
	warning
	install_system
	mkdir -p \
		"$PLASMA_THEMES" \
		"$USER_PLASMOIDS" \
		"$COLOR_SCHEMES" \
		"$USER_ICONS" \
		"$USER_LOOK_AND_FEEL" \
		"$KWIN_SWITCHER_DIR" \
		"$CURSOR_USER"
	echo "Installing user plasmoids..."
	sudo mkdir -p "${PLASMOID_PLUGINS}"
	sudo cp "${INNER_PLASMA_WIDGETS}User/${SEVEN_TASKS_PLUGIN}" "${PLASMOID_PLUGINS}"
	sudo cp "${INNER_PLASMA_WIDGETS}User/${SEVEN_START_PLUGIN}" "${PLASMOID_PLUGINS}"
	rm -r \
		"${USER_PLASMOIDS}${SEVEN_TASKS}" \
		"${USER_PLASMOIDS}${SEVEN_START}" \
		"${USER_PLASMOIDS}${DIGITALCLOCKLITE}" \
		"${USER_PLASMOIDS}${SHOW_DESKTOP}"

	sudo rm -r "${USER_PLASMOIDS}${SYSTRAY}" \
		"${USER_PLASMOIDS}${KEYBOARD_LAYOUT}" \
		"${USER_PLASMOIDS}${DESKTOP_CONTAINMENT}"

	rm -rf \
		"${CURSOR_USER}" \
		"${USER_ICONS}${CURSORTHEME}" \
		"${USER_LOOK_AND_FEEL}${SPLASH_SCREEN}" \
		"${PLASMA_THEMES}${PLASMA_THEME}" \
		"${KWIN_SWITCHER_DIR}${KWIN_SWITCHER}"

	for f in ${INNER_PLASMA_WIDGETS}User/io.gitgud.wackyideas.*; do 
		cp -r "$f" "${USER_PLASMOIDS}"
	done
	for f in ${INNER_PLASMA_WIDGETS}User/org.kde.*; do
		sudo cp -r "$f" "${USER_PLASMOIDS}"
	done

	echo "Installing icon theme..."
	tar -xf "${INNER_ICON_THEME}${ICONTHEME}.tar.gz"
	mv "${ICONTHEME}" "${USER_ICONS}"
	echo "Installing cursor theme..."
	tar -xf "${INNER_ICON_THEME}${CURSORTHEME}.tar.gz"
	sudo mv "${CURSORTHEME}" "${CURSOR_SYSTEM}"
	cp "${INNER_ICON_THEME}index.theme" "${CURSOR_USER}index.theme"
	ln -s "${CURSOR_SYSTEM}${CURSORTHEME}/cursors" "${CURSOR_USER}cursors"

	echo "Installing Smaragd Seven..."
	sudo mkdir -p "${KWIN_PLUGIN_DIR}"
	sudo cp "${INNER_KWIN}smaragd_bin/${KWIN_PLUGIN}" "${KWIN_PLUGIN_DIR}"
	cp -r "${INNER_KWIN}.emerald" ~

	echo "Installing Reflection effect..."

	local rootdir=$PWD
	local script=./install.sh

	cd "${INNER_KWIN}kwin_reflect"
	chmod +x "$script" && "$script"
	cd "$rootdir"

	echo "Installing Firefox Blur Region Fix effect..."
	local rootdir=$PWD
	local script=./install.sh

	cd "${INNER_KWIN}kwin_fixblur"
	chmod +x "$script" && "$script"
	cd "$rootdir"
	#sudo mkdir -p "${KWIN_EFFECTS_DIR}"
	#sudo mkdir -p "${KWIN_CONFIGS_DIR}"
	#sudo cp "${INNER_KWIN}kwin_reflect/bin/${KWIN_EFFECT}" "${KWIN_EFFECTS_DIR}"
	#sudo cp "${INNER_KWIN}kwin_reflect/bin/${KWIN_CONFIG}" "${KWIN_CONFIGS_DIR}"

	echo "Installing task switcher..."
	cp -r "${INNER_KWIN}${KWIN_SWITCHER}" "${KWIN_SWITCHER_DIR}"

	echo "Installing sounds..."
	sudo mkdir -p "${SOUNDS_DIR}"
	for f in ${INNER_SOUNDS}*; do 
		sudo cp -r "$f" "${SOUNDS_DIR}"
	done

	echo "Installing splash screen..."
	cp -r "${INNER_LOOK_AND_FEEL}${SPLASH_SCREEN}" "${USER_LOOK_AND_FEEL}"

	echo "Installing color scheme..."
	cp "${INNER_COLOR_SCHEME}${COLOR_SCHEME}" "${COLOR_SCHEMES}"

	echo "Installing KDE Plasma theme..."
	cp -r "${INNER_PLASMA_THEME}${PLASMA_THEME}" "${PLASMA_THEMES}"

	echo "Installing Kvantum theme..."
	mkdir -p "${KVANTUM_THEMES}${KVANTUM_THEME}"
	cp -r "${INNER_KVANTUM_THEME}${KVANTUM_THEME}" "${KVANTUM_THEMES}"

	echo "AeroThemePlasma has been installed on your system. In order to apply the theme, follow INSTALL.md for more instructions."
}

if [[ $1 = "install" ]]
then
	dependencies
	install
elif [[ $1 = "fix" ]]
then
	dependencies
	install_system
else
	print_help
fi

