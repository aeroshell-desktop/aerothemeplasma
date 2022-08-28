# CMake generated Testfile for 
# Source directory: /mnt/792afca2-ecd6-4e41-938a-2e818d0f60d1/home/anon/gitgud-repositories/KDE/seventasks_src
# Build directory: /mnt/792afca2-ecd6-4e41-938a-2e818d0f60d1/home/anon/gitgud-repositories/KDE/seventasks_src/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(appstreamtest "/usr/bin/cmake" "-DAPPSTREAMCLI=/usr/bin/appstreamcli" "-DINSTALL_FILES=/mnt/792afca2-ecd6-4e41-938a-2e818d0f60d1/home/anon/gitgud-repositories/KDE/seventasks_src/build/install_manifest.txt" "-P" "/usr/share/ECM/kde-modules/appstreamtest.cmake")
set_tests_properties(appstreamtest PROPERTIES  _BACKTRACE_TRIPLES "/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;162;add_test;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;180;appstreamtest;/usr/share/ECM/kde-modules/KDECMakeSettings.cmake;0;;/mnt/792afca2-ecd6-4e41-938a-2e818d0f60d1/home/anon/gitgud-repositories/KDE/seventasks_src/CMakeLists.txt;10;include;/mnt/792afca2-ecd6-4e41-938a-2e818d0f60d1/home/anon/gitgud-repositories/KDE/seventasks_src/CMakeLists.txt;0;")
subdirs("src")
