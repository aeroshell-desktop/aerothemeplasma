#!/bin/bash

echo "Uninstalling kwin effect"
echo

cd kwin-effect-smodwindowbuttons || exit 1

echo "Running: sudo make uninstall"
sudo make -C build uninstall && echo "Done"
cd ..
