#!/bin/bash
inkscape animation.svg -o animation.png
convert animation.png -crop 8x8@ frame%d.png
for ((i=63;i>=0;i--)); do mv frame$i.png frame$((i + 1)).png; done
for ((i=9;i<=64;i++)); do rm frame$i.png; done
rcc --binary -o snapeffecttextures.smod.rcc snapeffecttextures.qrc
