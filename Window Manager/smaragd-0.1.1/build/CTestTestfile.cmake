# CMake generated Testfile for 
# Source directory: /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/Desktop/Aero_Theme/Window Manager/smaragd-0.1.1
# Build directory: /mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/Desktop/Aero_Theme/Window Manager/smaragd-0.1.1/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(appstreamtest "/usr/bin/cmake" "-DAPPSTREAMCLI=/usr/bin/appstreamcli" "-DINSTALL_FILES=/mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/Desktop/Aero_Theme/Window Manager/smaragd-0.1.1/build/install_manifest.txt" "-P" "/usr/share/ECM/kde-modules/appstreamtest.cmake")
set_tests_properties(appstreamtest PROPERTIES  _BACKTRACE_TRIPLES "/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;161;add_test;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;179;appstreamtest;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;0;;/mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/Desktop/Aero_Theme/Window Manager/smaragd-0.1.1/CMakeLists.txt;20;include;/mnt/731b17da-2f45-4ded-b563-c94773bf847d/home/anon/Desktop/Aero_Theme/Window Manager/smaragd-0.1.1/CMakeLists.txt;0;")
subdirs("src")
