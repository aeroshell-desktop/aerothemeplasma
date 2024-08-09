#!/bin/bash

IM="$(cat imagemagick-version.txt)"

cd "$IM"
sudo make install
