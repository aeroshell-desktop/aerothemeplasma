#!/bin/sh

for i in $(ls *.qrc); do
    rcc --binary $i -o ${i%.qrc}.smod.rcc
done
