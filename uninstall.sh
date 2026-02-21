#!/bin/bash

CUR_DIR=${PWD}

SU_CMD=sudo
if [[ -z "$(command -v $SU_CMD)" ]]; then
    SU_CMD=doas
    if [[ -z "$(command -v $SU_CMD)" ]]; then
        echo "Neither sudo or doas were detected on the system."
        exit
    fi
fi

BUILD_FILES=(
        "repos/aeroshell-kwin-components/build"
        "repos/aeroshell-kwin-components/build_x11"
        "repos/aeroshell-workspace/build"
        "repos/aerothemeplasma-icons/build"
        "repos/aerothemeplasma-sounds/build"
        "repos/smod/build"
        "repos/smod/smodglow/build"
        "repos/smod/smodglow/build-wl"
        "repos/uac-polkit-agent/build"
        "build"
)

function uninstall_cmake_component {
    if [ ! -f "$CUR_DIR/$1/install_manifest.txt" ]; then
        echo -e "File install_manifest.txt in $CUR_DIR/$1 was not found."
        echo -e "If this component was already removed from the system, you can ignore this message.\n"
        echo -e "Otherwise, to generate this file, run install.sh as detailed in the install guide of this repo."
        echo -e "Afterwards, re-run this script."
    else
        cd "$CUR_DIR/$1"
        BUILD_TOOL=make
        if [ -f "build.ninja" ]; then
            BUILD_TOOL=ninja
        fi
        $SU_CMD $BUILD_TOOL uninstall
        echo -e "Done."
        cd "$CUR_DIR"
    fi
}

for path in ${BUILD_FILES[@]}; do
    uninstall_cmake_component "$path"
done

echo "Done. To complete the uninstallation, reinstall KDE Plasma's 'libplasma' package."
