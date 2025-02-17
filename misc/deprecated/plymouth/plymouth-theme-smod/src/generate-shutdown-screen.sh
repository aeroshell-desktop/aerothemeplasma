#!/bin/bash

# The text on the shutdown screen should be RGB subpixel anti-aliased,
# but pango-view produces green garbled crap when trying to render text
# onto a transparent background.
# https://stackoverflow.com/questions/49319212/pangocairo-discolouration-on-transparent-recording-surfaces
#
# Instead we recreate the shutdown screen inside a basic SDDM theme, then launch
# sddm-greeter and save a screenshot.

sddm-greeter --test-mode --theme . &
sleep 1
spectacle --fullscreen --background --nonotify --delay 1000 --output ../assets/background-shutdown.png
sleep 1
killall sddm-greeter
