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
URL="https://invent.kde.org/plasma/libplasma/-/archive/v${VERSION}/libplasma-v${VERSION}.tar.gz"
ARCHIVE="libplasma-v${VERSION}.tar.gz"
SRCDIR="libplasma-v${VERSION}"

INSTALLDST="/usr/lib/x86_64-linux-gnu/qt6/qml/org/kde/plasma/core/libcorebindingsplugin.so"
LIBDIR="/usr/lib/x86_64-linux-gnu/"

if [ ! -d ${LIBDIR} ]; then
	LIBDIR="/usr/lib64/"
fi

if [ ! -f ${INSTALLDST} ]; then
	INSTALLDST="/usr/lib64/qt6/qml/org/kde/plasma/core/libcorebindingsplugin.so"
fi

if [ ! -d ./build/${SRCDIR} ]; then
	rm -rf build
	mkdir -p build
	echo "Downloading $ARCHIVE"
	curl $URL -o ./build/$ARCHIVE
	tar -xvf ./build/$ARCHIVE -C ./build/
	echo "Extracted $ARCHIVE"
fi

PWDDIR=$(pwd)
cp -r src ./build/$SRCDIR/
cd ./build/$SRCDIR/
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr .. $USE_NINJA
cmake --build . --target corebindingsplugin

TMPDIR="/opt/aerothemeplasma/tmp"
sudo mkdir -p $TMPDIR
sudo cp ./bin/org/kde/plasma/core/libcorebindingsplugin.so $TMPDIR
for filename in "$PWD/bin/libPlasma"*; do
	echo "Copying $filename to $TMPDIR"
	sudo cp "$filename" "$TMPDIR"
done

cd $PWDDIR
sudo cp apply $TMPDIR
sudo chmod +x "$TMPDIR/apply"
sudo cp apply-libplasma-patches.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable apply-libplasma-patches.service

echo "Libraries have been compiled and moved to $TMPDIR. Restart your computer to apply the changes."
echo "In case Plasma crashes and/or fails to load after installing these patches, simply reinstall the libplasma package from your respective distro."
