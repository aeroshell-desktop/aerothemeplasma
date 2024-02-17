#!/bin/bash

echo "Installing decoration"
echo

cd breeze || exit 1

echo "Running: sudo make install"
sudo make -C build install && echo "Done"
cd ..
