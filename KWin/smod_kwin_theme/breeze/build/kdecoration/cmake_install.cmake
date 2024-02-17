# Install script for directory: /home/anon/Desktop/smod_reduced/breeze/kdecoration

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "breeze" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/qt/plugins/org.kde.kdecoration2/smoddecoration.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/qt/plugins/org.kde.kdecoration2/smoddecoration.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/qt/plugins/org.kde.kdecoration2/smoddecoration.so"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/qt/plugins/org.kde.kdecoration2" TYPE MODULE FILES "/home/anon/Desktop/smod_reduced/breeze/build/bin/smoddecoration.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/qt/plugins/org.kde.kdecoration2/smoddecoration.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/qt/plugins/org.kde.kdecoration2/smoddecoration.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/qt/plugins/org.kde.kdecoration2/smoddecoration.so"
         OLD_RPATH "/home/anon/Desktop/smod_reduced/breeze/build/bin:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/qt/plugins/org.kde.kdecoration2/smoddecoration.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "breeze" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/CMakeFiles/smoddecoration.dir/install-cxx-module-bmi-noconfig.cmake" OPTIONAL)
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/config/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Devel" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/SMOD/Decoration" TYPE FILE FILES
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breeze.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breezebutton.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breezedecoration.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breezeexceptionlist.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breezesettingsprovider.h"
    "/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/breezesettings.cpp"
    "/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/breezesettings.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breeze.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breezebutton.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breezedecoration.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breezeexceptionlist.h"
    "/home/anon/Desktop/smod_reduced/breeze/kdecoration/breezesettingsprovider.h"
    "/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/Breeze"
    "/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/BreezeButton"
    "/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/BreezeDecoration"
    "/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/BreezeExceptionList"
    "/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/BreezeSettingsProvider"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "breeze" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/anon/Desktop/smod_reduced/breeze/build/kdecoration/smoddecoration.pc")
endif()

