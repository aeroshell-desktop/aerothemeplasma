#!/bin/bash

OUTPUT=$(plasmashell --version)
IFS=' ' read -a array <<< "$OUTPUT"
VERSION="${array[1]}"
URL="https://invent.kde.org/plasma/polkit-kde-agent-1/-/archive/master/polkit-kde-agent-1-master.tar.gz"
ARCHIVE="polkit-kde-agent-1-master.tar.gz"
SRCDIR="polkit-kde-agent-1-master"

INSTALLDST="/usr/lib/x86_64-linux-gnu/polkit-kde-authentication-agent-1"

if [ ! -f ${INSTALLDST} ]; then
	INSTALLDST="/usr/lib64/polkit-kde-authentication-agent-1"
fi

if [ ! -d ./build/${SRCDIR} ]; then
	rm -rf build
	mkdir build
	echo "Downloading $ARCHIVE"
	curl $URL -o ./build/$ARCHIVE
	tar -xvf ./build/$ARCHIVE -C ./build/
	echo "Extracted $ARCHIVE"
fi

cp -r patches/* ./build/$SRCDIR/
cd ./build/$SRCDIR/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
cmake --build .
echo "Installing..."
systemctl --user stop plasma-polkit-agent
kwriteconfig6 --file ~/.config/plasmanotifyrc --group Services --group policykit1-kde --key ShowPopups --notify --type bool false # Disable notification popup
kwriteconfig6 --file ~/.config/plasmanotifyrc --group Services --group policykit1-kde --key ShowInHistory --notify --type bool false # Disable notification in history
sudo cp ./bin/polkit-kde-authentication-agent-1 $INSTALLDST
echo "Restarting systemd service..."
systemctl --user start plasma-polkit-agent
echo "Done, refreshing plasmashell..."
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.refreshCurrentShell
