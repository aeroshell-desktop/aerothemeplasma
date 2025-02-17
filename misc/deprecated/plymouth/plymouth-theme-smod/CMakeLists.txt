cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(plymouth-theme-smod)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

option(INSTALL_SERVICES "Install wait services" OFF)

find_package(Plymouth REQUIRED)

set(PLYMOUTH_THEME_INSTALL_DIR ${Plymouth_THEMESDIR})

set(BOOT_ANIM_START_DELAY "2"    CACHE STRING "Time in seconds before the boot animation begins")
set(BOOT_PROGRESS_CLEAR   "0.99" CACHE STRING "Value between 0 and 1 to clear the entire screen")
set(SMOD_WAIT_BOOT        "6"    CACHE STRING "Time to delay Plymouth during boot")
set(SMOD_WAIT_SHUTDOWN    "8"    CACHE STRING "Time to delay Plymouth during shutdown")

configure_file(smod.plymouth ${CMAKE_CURRENT_BINARY_DIR}/smod.plymouth)
configure_file(smod.script   ${CMAKE_CURRENT_BINARY_DIR}/smod.script)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/preview.png
              ${CMAKE_CURRENT_BINARY_DIR}/smod.script
              ${CMAKE_CURRENT_BINARY_DIR}/smod.plymouth
        DESTINATION ${PLYMOUTH_THEME_INSTALL_DIR}/smod)
install(DIRECTORY assets
        DESTINATION ${PLYMOUTH_THEME_INSTALL_DIR}/smod)

if (INSTALL_SERVICES)
configure_file(smod-plymouth-wait-for-animation.service          ${CMAKE_CURRENT_BINARY_DIR}/smod-plymouth-wait-for-animation.service)
configure_file(smod-plymouth-wait-for-animation-poweroff.service ${CMAKE_CURRENT_BINARY_DIR}/smod-plymouth-wait-for-animation-poweroff.service)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/smod-plymouth-wait-for-animation-poweroff.service
              ${CMAKE_CURRENT_BINARY_DIR}/smod-plymouth-wait-for-animation.service
        DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/systemd/system)
endif ()
