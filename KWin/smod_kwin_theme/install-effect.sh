#!/bin/bash

echo "Installing kwin effect"
echo

cd kwin-effect-smodwindowbuttons || exit 1

echo "Running: sudo make install"
sudo make -C build install && echo "Done"
cd ..
