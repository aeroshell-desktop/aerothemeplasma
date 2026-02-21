#!/bin/bash
CUR_DIR=${PWD}

SU_CMD=sudo
USE_NINJA=
NINJA_PARAM=
if [[ "$*" == *"--ninja"* ]]
then
    if [[ -z "$(command -v ninja)" ]]; then
        echo "Attempted to build using Ninja, but Ninja was not found on the system. Falling back to GNU Make."
    else
        echo "Compiling using Ninja"
        USE_NINJA="-G Ninja"
        NINJA_PARAM="--ninja"
    fi
fi

if [[ -z "$(command -v $SU_CMD)" ]]; then
    SU_CMD=doas
    if [[ -z "$(command -v $SU_CMD)" ]]; then
        echo "Neither sudo or doas were detected on the system."
        exit
    fi
fi

if [ -z $LIBEXEC_DIR ]; then
        LIBEXEC_DIR=lib
fi

mkdir -p repos
mkdir -p manifest
cd repos

# uac-polkit-agent
git clone https://gitgud.io/aeroshell/uac-polkit-agent.git uac-polkit-agent
cd uac-polkit-agent
git pull
cmake $USE_NINJA -DCMAKE_INSTALL_PREFIX=/usr -B build . || exit 1
cmake --build build || exit 1
$SU_CMD cmake --install build || exit 1
cp build/install_manifest.txt "$CUR_DIR/manifest/uac-polkit-agent_install_manifest.txt"
cd "$CUR_DIR/repos"

# SMOD
git clone https://gitgud.io/aeroshell/smod.git smod
cd smod
git pull
bash install.sh $NINJA_PARAM
cp build/install_manifest.txt "$CUR_DIR/manifest/smod_install_manifest.txt"
cp smodglow/build/install_manifest.txt "$CUR_DIR/manifest/smodglow_install_manifest.txt"
cp smodglow/build-wl/install_manifest.txt "$CUR_DIR/manifest/smodglow-x11_install_manifest.txt"
cd "$CUR_DIR/repos"

# Aeroshell Workspace
git clone https://gitgud.io/aeroshell/aeroshell-workspace.git aeroshell-workspace
cd aeroshell-workspace
git pull
cmake $USE_NINJA -DCMAKE_INSTALL_PREFIX=/usr -B build . || exit 1
cmake --build build || exit 1
$SU_CMD cmake --install build || exit 1
$SU_CMD update-mime-database "/usr/local/share/mime"
cp build/install_manifest.txt "$CUR_DIR/manifest/aeroshell-workspace_install_manifest.txt"
cd "$CUR_DIR/repos"

# Aeroshell KWin
git clone https://gitgud.io/aeroshell/aeroshell-kwin-components.git aeroshell-kwin-components
cd aeroshell-kwin-components
git pull
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DKWIN_BUILD_WAYLAND=ON -B build . || exit 1
cmake --build build || exit 1
$SU_CMD cmake --install build || exit 1
cp build/install_manifest.txt "$CUR_DIR/manifest/aeroshell-kwin-components_install_manifest.txt"
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DKWIN_BUILD_WAYLAND=OFF -DKWIN_INSTALL_MISC=OFF -B build_x11 . || exit 1
cmake --build build_x11 || exit 1
$SU_CMD cmake --install build_x11 || exit 1
cp build_x11/install_manifest.txt "$CUR_DIR/manifest/aeroshell-kwin-components-x11_install_manifest.txt"
cd "$CUR_DIR/repos"

# Aerothemeplasma icons
git clone https://gitgud.io/aeroshell/atp/aerothemeplasma-icons aerothemeplasma-icons
cd aerothemeplasma-icons
git pull
cmake $USE_NINJA -DCMAKE_INSTALL_PREFIX=/usr -B build . || exit 1
cmake --build build || exit 1
$SU_CMD cmake --install build || exit 1
cp build/install_manifest.txt "$CUR_DIR/manifest/icons_install_manifest.txt"
cd "$CUR_DIR/repos"

# Aerothemeplasma sounds
git clone https://gitgud.io/aeroshell/atp/aerothemeplasma-icons aerothemeplasma-sounds
cd aerothemeplasma-sounds
git pull
cmake $USE_NINJA -DCMAKE_INSTALL_PREFIX=/usr -B build . || exit 1
cmake --build build || exit 1
$SU_CMD cmake --install build || exit 1
cp build/install_manifest.txt "$CUR_DIR/manifest/sounds_install_manifest.txt"
cd "$CUR_DIR/repos"

# Aerothemeplasma
cd "$CUR_DIR"
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBEXECDIR=$LIBEXEC_DIR -B build . || exit 1
cmake --build build || exit 1
$SU_CMD cmake --install build || exit 1
cp build/install_manifest.txt "$CUR_DIR/manifest/aerothemeplasma_install_manifest.txt"
cd "$CUR_DIR/repos"

# libplasma last
git clone https://gitgud.io/aeroshell/libplasma.git libplasma
cd libplasma
git pull
cmake $USE_NINJA -DCMAKE_INSTALL_PREFIX=/usr -B build . || exit 1
cmake --build build || exit 1
$SU_CMD cmake --install build || exit 1
cp build/install_manifest.txt "$CUR_DIR/manifest/libplasma_install_manifest.txt"
cd "$CUR_DIR/repos"

echo "Done."
