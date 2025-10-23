#!/bin/sh

export XDG_CONFIG_DIRS="$HOME/.config/aerothemeplasma:/etc/xdg:$XDG_CONFIG_DIRS" 
export PLASMA_DEFAULT_SHELL=io.gitgud.wackyideas.desktop
@CMAKE_INSTALL_FULL_LIBEXECDIR@/plasma-dbus-run-session-if-needed ${CMAKE_INSTALL_FULL_BINDIR}/startplasma-wayland
