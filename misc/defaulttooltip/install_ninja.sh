#!/bin/bash

OUTPUT=$(plasmashell --version)
IFS=' ' read -a array <<< "$OUTPUT"
VERSION="${array[1]}"
URL="https://invent.kde.org/plasma/libplasma/-/archive/v${VERSION}/libplasma-v${VERSION}.tar.gz"
ARCHIVE="libplasma-v${VERSION}.tar.gz"
SRCDIR="libplasma-v${VERSION}"

INSTALLDST="/usr/lib/x86_64-linux-gnu/qt6/qml/org/kde/plasma/core/libcorebindingsplugin.so"

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
cd ./build/$SRCDIR/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -G Ninja ..
cmake --build . --target corebindingsplugin
sudo cp ./bin/org/kde/plasma/core/libcorebindingsplugin.so $INSTALLDST
#plasmashell --replace & disown
echo "Done."
