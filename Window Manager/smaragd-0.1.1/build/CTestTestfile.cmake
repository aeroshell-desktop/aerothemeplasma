# CMake generated Testfile for 
# Source directory: /home/boki/Downloads/smaragd-0.1.1
# Build directory: /home/boki/Downloads/smaragd-0.1.1/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(appstreamtest "/usr/bin/cmake" "-DAPPSTREAMCLI=/usr/bin/appstreamcli" "-DINSTALL_FILES=/home/boki/Downloads/smaragd-0.1.1/build/install_manifest.txt" "-P" "/usr/share/ECM/kde-modules/appstreamtest.cmake")
set_tests_properties(appstreamtest PROPERTIES  _BACKTRACE_TRIPLES "/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;163;add_test;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;181;appstreamtest;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;0;;/home/boki/Downloads/smaragd-0.1.1/CMakeLists.txt;20;include;/home/boki/Downloads/smaragd-0.1.1/CMakeLists.txt;0;")
subdirs("src")
