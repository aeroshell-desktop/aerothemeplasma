# CMake generated Testfile for 
# Source directory: /home/pswin56/Escritorio/seventasks_src
# Build directory: /home/pswin56/Escritorio/seventasks_src
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(appstreamtest "/usr/bin/cmake" "-DAPPSTREAMCLI=/usr/bin/appstreamcli" "-DINSTALL_FILES=/home/pswin56/Escritorio/seventasks_src/install_manifest.txt" "-P" "/usr/share/ECM/kde-modules/appstreamtest.cmake")
set_tests_properties(appstreamtest PROPERTIES  _BACKTRACE_TRIPLES "/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;168;add_test;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;187;appstreamtest;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;0;;/home/pswin56/Escritorio/seventasks_src/CMakeLists.txt;11;include;/home/pswin56/Escritorio/seventasks_src/CMakeLists.txt;0;")
subdirs("src")
