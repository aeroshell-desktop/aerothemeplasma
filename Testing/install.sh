#!/bin/bash

# Automatic installer script for AeroThemePlasma
# See INSTALL.md for more details on what this
# script does and does not do.
# wackyideas 2023, https://gitgud.io/wackyideas/aerothemeplasma

# kwriteconfig5
# kreadconfig5
# tar -xf [file.tar.gz]

# Defining some useful paths
# User directories
PLASMA_THEMES=~/.local/share/plasma/desktoptheme/
USER_PLASMOIDS=~/.local/share/plasma/plasmoids/
USER_LOOK_AND_FEEL=~/.local/share/plasma/look-and-feel/
COLOR_SCHEMES=~/.local/share/color-schemes/
GTK2_THEMES=/home/$USER/.themes/
EMERALD_PATH=~/.emerald/
USER_CONFIG=~/.config/
KVANTUM_THEMES=${USER_CONFIG}Kvantum/
USER_ICONS=~/.local/share/icons/

# System directories
FONTS_DIR=/usr/share/fonts/windows/
KWIN_PLUGIN_DIR=/usr/lib/qt/plugins/org.kde.kdecoration2/
KWIN_EFFECTS_DIR=/usr/lib/qt/plugins/kwin/effects/plugins/
KWIN_CONFIGS_DIR=/usr/lib/qt/plugins/kwin/effects/configs/
SYSTEM_PLASMOIDS=/usr/share/plasma/plasmoids/
PLASMOID_PLUGINS=/usr/lib/qt/plugins/plasma/applets/
TOOLTIP_DIR=/usr/lib/qt/qml/org/kde/plasma/core/private/
SOUNDS_DIR=/usr/share/sounds/
BIN=/usr/bin/

# Inner directories

# Plasma
INNER_PLASMA_WIDGETS=./Plasma/Plasma_Widgets/
INNER_COLOR_SCHEME=./Plasma/Color_Scheme/
INNER_SOUNDS="./Plasma/Sounds/"
INNER_GLOBAL_THEME=./Plasma/Global_Theme/
INNER_PLASMA_THEME=./Plasma/KDE_Plasma_Theme/

# Qt
INNER_KVANTUM_THEME=./Qt/Application_Theme/Kvantum/
INNER_GTK2_THEME=./Qt/Application_Theme/QGtkStyle/

# Icons and cursors
INNER_ICON_THEME=./Icons\ and\ cursors/

# KWin
INNER_KWIN="./KWin/"

# NAMES

# System plasmoids
SYSTRAY=org.kde.plasma.private.systemtray
KEYBOARD_LAYOUT=org.kde.plasma.keyboardlayout
DESKTOP_CONTAINMENT=org.kde.desktopcontainment
TOOLTIP_QML=DefaultToolTip.qml

# User plasmoids
SEVEN_START=io.gitgud.wackyideas.SevenStart
SEVEN_TASKS=io.gitgud.wackyideas.seventasks
SEVEN_TASKS_PLUGIN=plasma_applet_seventasks.so
DIGITALCLOCKLITE=io.gitgud.wackyideas.digitalclocklite
SHOW_DESKTOP=io.gitgud.wackyideas.win7showdesktop

# Themes
PLASMA_THEME=Seven-Black
GTK2_THEME=win27pixmap
KVANTUM_THEME=Windows7Kvantum_Aero
SPLASH_SCREEN=io.gitgud.wackyideas.aerosplashscreen
COLOR_SCHEME=AeroColorScheme.colors

KWIN_PLUGIN=kwin_smaragd.so
KWIN_EFFECT=libkwin4_effect_reflect.so
KWIN_CONFIG=kwin4_effect_reflect_config.so

# Icons and cursors 
ICONTHEME=windowsicon
CURSORTHEME=aero-cursors

# GTK2 Settings
ENV=/etc/environment
LINE="GTK2_RC_FILES=${GTK2_THEMES}${GTK2_THEME}/gtk-2.0/gtkrc"

BACKUP_FOLDER=~/AeroThemePlasma_Backups/
ORIGINAL_FOLDER="${BACKUP_FOLDER}First_Time_Backup/"


function backup {
	echo "Performing backup..."
	mkdir -p ${BACKUP_FOLDER}
	if [ ! -d "${ORIGINAL_FOLDER}" ] 
	then
		# Perform first time backup
		echo "Performing first time backup..."
		echo "Creating a backup at $ORIGINAL_FOLDER"
		mkdir -p "${ORIGINAL_FOLDER}"
		cp -r "${SYSTEM_PLASMOIDS}${SYSTRAY}" 			  "${ORIGINAL_FOLDER}" # System Tray
		cp -r "${SYSTEM_PLASMOIDS}${DESKTOP_CONTAINMENT}" "${ORIGINAL_FOLDER}" # Desktop Containment
		cp -r "${SYSTEM_PLASMOIDS}${KEYBOARD_LAYOUT}"     "${ORIGINAL_FOLDER}" # Keyboard Layout
		cp -r "${TOOLTIP_DIR}${TOOLTIP_QML}"			  "${ORIGINAL_FOLDER}" # DefaultToolTip.qml
		
		# Backing up /etc/environment
		if grep "GTK2_RC_FILES" "$ENV" &> /dev/null
		then
			cp "$ENV" "$ORIGINAL_FOLDER"
		fi

		# Emerald
		if [ -d "$EMERALD_PATH" ]
		then
			mkdir -p "${ORIGINAL_FOLDER}.emerald" 
			cp -r "${EMERALD_PATH}theme" 				  "${ORIGINAL_FOLDER}.emerald/theme" 
			cp    "${EMERALD_PATH}settings.ini" 		  "${ORIGINAL_FOLDER}.emerald/settings.ini" 
		fi
	fi


	local answer="Y"
	read -p "If you have already installed AeroThemePlasma before, would you like to create a backup of the currently installed version? [Y/n] " answer
	if [[ $answer != "n" ]] && [[ $answer != "N" ]]
	then
			local tstamp=$(date +%Y-%m-%d_%H_%M_%S)
			local bpath="${BACKUP_FOLDER}${tstamp}"
			echo "Creating a backup at $bpath"
			mkdir -p "$bpath"

			echo "Backing up system files..."
			cp -r "${SYSTEM_PLASMOIDS}${SYSTRAY}" 			  "$bpath" # System Tray 
			cp -r "${SYSTEM_PLASMOIDS}${DESKTOP_CONTAINMENT}" "$bpath" # Desktop Containment
			cp -r "${SYSTEM_PLASMOIDS}${KEYBOARD_LAYOUT}"     "$bpath" # Keyboard Layout
			cp -r "${TOOLTIP_DIR}${TOOLTIP_QML}"			  "$bpath" # DefaultToolTip.qml

			echo "Backing up Smaragd..."
			cp 	  "${KWIN_PLUGIN_DIR}${KWIN_PLUGIN}"		  "$bpath" # kwin_smaragd.so

			echo "Backing up Smaragd theme..." 
			mkdir -p "${bpath}/.emerald" 
			cp -r "${EMERALD_PATH}theme" 				  	  "${bpath}/.emerald/theme"
			cp    "${EMERALD_PATH}settings.ini" 		  	  "${bpath}/.emerald/settings.ini"

			echo "Backing up Plasma theme..."
			cp -r "${PLASMA_THEMES}${PLASMA_THEME}"		  	  "$bpath" # SevenBlack

			echo "Backing up user plasmoids..."
			
			for f in ${USER_PLASMOIDS}io.gitgud.wackyideas.*; do 
				cp -r "$f" "$bpath"
			done

			cp 	  "${PLASMOID_PLUGINS}${SEVEN_TASKS_PLUGIN}"  "$bpath" # SevenTasks plugin
			
			#echo "Backing up splash screen..."
			#cp -r "${USER_SPLASH}${SPLASH_SCREEN}"			  "$bpath" # Aero-splash-screen
			
			echo "Backing up Kvantum theme..."
			cp -r "${KVANTUM_THEMES}${KVANTUM_THEME}"		  "$bpath" # Windows7Kvantum_Aero

			# ADD REFLECTION EFFECT HERE, TODO
			echo "Backing up Reflection effect..."
			cp -r "${KWIN_EFFECTS_DIR}${KWIN_EFFECT}" "$bpath"
			cp -r "${KWIN_CONFIGS_DIR}${KWIN_CONFIG}" "$bpath"

			echo "Backing up global theme..."
			cp -r "${USER_LOOK_AND_FEEL}aerothemeplasma" "$bpath"

			answer="N"
			read -p "Do you want to make a backup of the icon theme? [y/N] " answer
			if [[ $answer = "y" ]] || [[ $answer = "Y" ]] 
			then
				echo "Backing up icon theme..."
				cp -r "${SYSTEM_ICONS}${ICONTHEME}"	"$bpath"
			fi
			echo "Finished backup."
			return
	fi

}
function print_help {
	printf "WARNING: THIS SCRIPT IS NOT READY FOR USE. IT'S LARGELY INCOMPLETE\n"
	printf "AND MIGHT EVEN BREAK YOUR SYSTEM IN ITS CURRENT STATE.\n"
	printf "AeroThemePlasma installer usage:\n\n"
	printf "	./install.sh COMMAND\n"
	printf "	Semi-automated installer and updater for AeroThemePlasma.\n\n"
	printf "Available commands:\n"
	printf "	help			Shows this screen.\n"
	printf "	install			Performs a CLEAN install of AeroThemePlasma. Recommended for first time installations.\n"
	printf "	update			Pulls the latest changes from the git repo and updates AeroThemePlasma.\n"
	printf "	restore [PATH]	Restores a backup provided by an absolute path to a directory. If no path is provided, the installer will restore the original backup.\n\n"
	printf "For more information, see the INSTALL.md page.\n"
	exit
}
function warning {
	printf "\nWARNING:\nThis script requires root privileges as it installs certain components in locations not writable by regular users, and also\n"
	printf "modifies certain system components tied to KDE.\n"
	printf "For more information about the installation process, as well as all the components added or modified by this project, see\nINSTALL.md and DOCUMENTATION.md respectively.\n\n"

	local answer="N"
	read -p "Do you want to continue? [y/N] " answer
	if [[ $answer != "y" ]] && [[ $answer != "Y" ]]
	then
		printf "Exiting installer.\n"
		exit
	else
		return
	fi
}
function dependencies {
	printf "Required dependencies:\n- git\n- kdialog\n- kvantum\n- kwin\n- tar\n"
	printf "Checking dependencies..."
	
	if [ $(echo $XDG_CURRENT_DESKTOP | grep KDE &> /dev/null) ]
	then
		printf "\nThis script couldn't detect KDE running on this system. The installer will now exit.\n"
		exit
	fi
	if [ command -v git &> /dev/null ] || [ command -v kdialog &> /dev/null ] || [ command -v tar &> /dev/null ] || [ command -v kvantummanager &> /dev/null ] || [ command -v kwin_x11 &> /dev/null ]
	then
		printf "\nMissing dependencies. The installer will now exit.\n"
		exit
	else
		printf " done.\n"
	fi
}
function install_system {
	echo "Overwriting system components..."
	sudo echo "Permissions granted, installing desktop modifications..."

	echo "Installing DefaultToolTip.qml..."
	sudo mkdir -p "${TOOLTIP_DIR}"
	sudo cp "${INNER_PLASMA_WIDGETS}System/Tooltips/${TOOLTIP_QML}" "${TOOLTIP_DIR}${TOOLTIP_QML}"
	echo "Installing system plasmoids..."

	sudo rm -r "${SYSTEM_PLASMOIDS}${SYSTRAY}"
	sudo rm -r "${SYSTEM_PLASMOIDS}${KEYBOARD_LAYOUT}"
	sudo rm -r "${SYSTEM_PLASMOIDS}${DESKTOP_CONTAINMENT}"
	for f in ${INNER_PLASMA_WIDGETS}System/org.kde.*; do
		sudo cp -r "$f" "${SYSTEM_PLASMOIDS}"
	done
}
function install {
	printf "Running AeroThemePlasma installer\n"
	dependencies

	backup
	mkdir -p $PLASMA_THEMES
	mkdir -p $USER_PLASMOIDS
	mkdir -p $COLOR_SCHEMES
	mkdir -p $GTK2_THEMES
	mkdir -p $USER_ICONS
	mkdir -p $USER_LOOK_AND_FEEL
	warning
	install_system

	echo "Installing user plasmoids..."
	sudo mkdir -p "${PLASMOID_PLUGINS}"
	sudo cp "${INNER_PLASMA_WIDGETS}User/${SEVEN_TASKS_PLUGIN}" "${PLASMOID_PLUGINS}"
	rm -r "${USER_PLASMOIDS}${SEVEN_TASKS}"
	rm -r "${USER_PLASMOIDS}${SEVEN_START}"
	rm -r "${USER_PLASMOIDS}${DIGITALCLOCKLITE}"
	rm -r "${USER_PLASMOIDS}${SHOW_DESKTOP}"
	for f in ${INNER_PLASMA_WIDGETS}User/io.gitgud.wackyideas.*; do 
		cp -r "$f" "${USER_PLASMOIDS}"
	done

	echo "Installing icon theme..."
	tar -xf "${INNER_ICON_THEME}${ICONTHEME}.tar.gz"
	rm -rf "${USER_ICONS}${ICONTHEME}"
	mv "${ICONTHEME}" "${USER_ICONS}"
	echo "Installing cursor theme..."
	tar -xf "${INNER_ICON_THEME}${CURSORTHEME}.tar.gz"
	rm -rf "${USER_ICONS}${CURSORTHEME}"
	mv "${CURSORTHEME}" "${USER_ICONS}"

	echo "Installing Smaragd Seven..."
	sudo mkdir -p "${KWIN_PLUGIN_DIR}"
	sudo cp "${INNER_KWIN}smaragd_bin/${KWIN_PLUGIN}" "${KWIN_PLUGIN_DIR}"
	cp -r "${INNER_KWIN}.emerald" ~

	echo "Installing Reflection effect..."

	sudo mkdir -p "${KWIN_EFFECTS_DIR}"
	sudo mkdir -p "${KWIN_CONFIGS_DIR}"
	sudo cp "${INNER_KWIN}reflect_bin/${KWIN_EFFECT}" "${KWIN_EFFECTS_DIR}"
	sudo cp "${INNER_KWIN}reflect_bin/${KWIN_CONFIG}" "${KWIN_CONFIGS_DIR}"

	echo "Installing sounds..."
	sudo mkdir -p "${SOUNDS_DIR}"
	for f in ${INNER_SOUNDS}*; do 
		sudo cp -r "$f" "${SOUNDS_DIR}"
	done

	#echo "Installing splash screen..."
	#rm -r "${USER_SPLASH}${SPLASH_SCREEN}"
	#cp -r "${INNER_SPLASH_SCREEN}${SPLASH_SCREEN}" "${USER_SPLASH}"

	echo "Installing color scheme..."
	cp "${INNER_COLOR_SCHEME}${COLOR_SCHEME}" "${COLOR_SCHEMES}"

	echo "Installing KDE Plasma theme..."
	rm -r "${PLASMA_THEMES}${PLASMA_THEME}"
	cp -r "${INNER_PLASMA_THEME}${PLASMA_THEME}" "${PLASMA_THEMES}"

	echo "Installing Kvantum theme..."
	mkdir -p "${KVANTUM_THEMES}${KVANTUM_THEME}"
	cp -r "${INNER_KVANTUM_THEME}${KVANTUM_THEME}" "${KVANTUM_THEMES}"

	echo "Installing GTK2 theme..."
	cp -r "${INNER_GTK2_THEME}${GTK2_THEME}" "${GTK2_THEMES}"

	echo "Installing global theme..."
	cp -r "${INNER_GLOBAL_THEME}aerothemeplasma" "${USER_LOOK_AND_FEEL}"
	
	local answer="N"
	read -p "Do you want to set up a new desktop layout? WARNING: This will replace your current configuration. [y/N] " answer
	if [[ $answer != "y" ]] && [[ $answer != "Y" ]]
	then
		plasma-apply-lookandfeel --reset-layout -a aerothemeplasma
	else
		plasma-apply-lookandfeel -a aerothemeplasma
	fi
	kvantummanager --set $KVANTUM_THEME
}

if [[ $1 = "install" ]]
then
	install
else
	print_help
fi

