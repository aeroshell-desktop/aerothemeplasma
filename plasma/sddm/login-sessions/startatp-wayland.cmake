#!/bin/sh

export XDG_CONFIG_DIRS="/etc/xdg/aerothemeplasma:/etc/xdg:$XDG_CONFIG_DIRS"
export QML_DISABLE_DISTANCEFIELD=1
export USE_UAC_AGENT=1
export PLASMA_DEFAULT_SHELL=io.gitgud.wackyideas.desktop
@CMAKE_INSTALL_FULL_LIBEXECDIR@/plasma-dbus-run-session-if-needed ${CMAKE_INSTALL_FULL_BINDIR}/startplasma-wayland
