#rm -rf build
#mkdir build
#cd build
#cmake -DCMAKE_INSTALL_PREFIX=`kde4-config --prefix` ..
cd build
make
sudo make install
kwin_x11 --replace &
echo he didts it boys
