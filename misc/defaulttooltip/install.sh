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
	mkdir build
	echo "Downloading $ARCHIVE"
	curl $URL -o ./build/$ARCHIVE
	tar -xvf ./build/$ARCHIVE -C ./build/
	echo "Extracted $ARCHIVE"
fi

cp DefaultToolTip.qml ./build/$SRCDIR/src/declarativeimports/core/private/DefaultToolTip.qml
cp tooltiparea.h ./build/$SRCDIR/src/declarativeimports/core/tooltiparea.h
cp tooltiparea.cpp ./build/$SRCDIR/src/declarativeimports/core/tooltiparea.cpp
cp tooltipdialog.cpp ./build/$SRCDIR/src/declarativeimports/core/tooltipdialog.cpp
cp plasmawindow.cpp ./build/$SRCDIR/src/plasmaquick/plasmawindow.cpp
cd ./build/$SRCDIR/
mkdir build
cd build
echo "Stopping plasmashell to prevent crashes. Will be restarted after the script has finished."
killall plasmashell
cmake -DCMAKE_INSTALL_PREFIX=/usr .. $USE_NINJA
cmake --build . --target corebindingsplugin # Implicitly compiles plasmaquick
sudo cp ./bin/org/kde/plasma/core/libcorebindingsplugin.so $INSTALLDST

for filename in "$PWD/bin/libPlasma"*; do
	echo "Copying $filename to $LIBDIR"
	sudo cp "$filename" "$LIBDIR"
done
setsid plasmashell --replace &
echo "Done."
