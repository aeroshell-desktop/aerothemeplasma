#!/bin/bash

COMMAND=/usr/bin/aplay
SOUND=/usr/share/sddm/themes/sddm-theme-mod/Assets/session-start.wav
if [ ! -f $COMMAND ]; then
    COMMAND=/usr/bin/paplay
fi

$COMMAND $SOUND & disown
