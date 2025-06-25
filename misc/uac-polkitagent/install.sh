#!/bin/bash

USE_NINJA=

if [[ "$*" == *"--ninja"* ]]
then
    if [[ -z "$(command -v ninja)" ]]; then
        echo "Attempted to build using Ninja, but Ninja was not found on the system. Falling back to GNU Make."
    else
        echo "Compiling using Ninja"
        USE_NINJA="-G Ninja"
    fi
fi

OUTPUT=$(plasmashell --version)
IFS=' ' read -a array <<< "$OUTPUT"
VERSION="${array[1]}"
URL="https://invent.kde.org/plasma/polkit-kde-agent-1/-/archive/v${VERSION}/polkit-kde-agent-1-v${VERSION}.tar.gz"
ARCHIVE="polkit-kde-agent-1-v${VERSION}.tar.gz"
SRCDIR="polkit-kde-agent-1-v${VERSION}"

INSTALLDST="/usr/lib/x86_64-linux-gnu/polkit-kde-authentication-agent-1"

if [ ! -f ${INSTALLDST} ]; then
	INSTALLDST="/usr/libexec/kf6/polkit-kde-authentication-agent-1"
fi

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
cmake -DCMAKE_INSTALL_PREFIX=/usr .. $USE_NINJA
cmake --build .
echo "Installing..."
systemctl --user stop plasma-polkit-agent
sudo cp ./bin/polkit-kde-authentication-agent-1 $INSTALLDST
echo "Restarting systemd service..."
systemctl --user start plasma-polkit-agent
echo "Done, refreshing plasmashell..."

QDBUS_COMMAND=qdbus6

if ! command -v $QDBUS_COMMAND; then
	QDBUS_COMMAND=qdbus
fi

$QDBUS_COMMAND org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.refreshCurrentShell
