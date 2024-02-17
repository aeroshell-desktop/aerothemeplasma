#!/bin/bash

echo "Uninstalling decoration"
echo

cd breeze || exit 1

echo "Running: sudo make uninstall"
sudo make -C build uninstall && echo "Done"
cd ..
