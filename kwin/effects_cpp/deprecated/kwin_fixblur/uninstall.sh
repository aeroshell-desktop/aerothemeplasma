#!/bin/sh
cd build
sudo make uninstall && echo "Uninstalled successfully!"
cd ..
rm -rf build
