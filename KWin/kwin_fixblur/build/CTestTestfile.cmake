# CMake generated Testfile for 
# Source directory: /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_fixblur
# Build directory: /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_fixblur/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(appstreamtest "/usr/bin/cmake" "-DAPPSTREAMCLI=/usr/bin/appstreamcli" "-DINSTALL_FILES=/mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_fixblur/build/install_manifest.txt" "-P" "/usr/share/ECM/kde-modules/appstreamtest.cmake")
set_tests_properties(appstreamtest PROPERTIES  _BACKTRACE_TRIPLES "/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;165;add_test;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;183;appstreamtest;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;0;;/mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_fixblur/CMakeLists.txt;21;include;/mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_fixblur/CMakeLists.txt;0;")
subdirs("src")
