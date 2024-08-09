#!/bin/bash

# Extracts the Windows startup sound WAV file from imageres.dll
# Takes in a path to imageres.dll

mkdir -p .tmp_atpres
7z x $1 -o.tmp_atpres
cp .tmp_atpres/.rsrc/WAVE/5080 session-start.wav
rm -rf .tmp_atpres
echo "Done."
