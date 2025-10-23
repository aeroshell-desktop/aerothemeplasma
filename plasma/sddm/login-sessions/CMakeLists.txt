## For Plasma end users
cmake_minimum_required(VERSION 3.16)

project(loginsessions)
find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)


if(PLASMA_X11_DEFAULT_SESSION)
   set(PLASMA_X11_DESKTOP_FILENAME aerothemeplasma.desktop CACHE INTERNAL "Filename for Plasma X11 session")
   set(PLASMA_WAYLAND_DESKTOP_FILENAME aerothemeplasmawayland.desktop CACHE INTERNAL "Filename for Plasma Wayland session")
else()
   set(PLASMA_X11_DESKTOP_FILENAME aerothemeplasmax11.desktop CACHE INTERNAL "Filename for Plasma X11 session")
   set(PLASMA_WAYLAND_DESKTOP_FILENAME aerothemeplasma.desktop CACHE INTERNAL "Filename for Plasma Wayland session")
endif()

configure_file(startatp.cmake ${CMAKE_CURRENT_BINARY_DIR}/startatp)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/startatp
	PERMISSIONS OWNER_EXECUTE GROUP_EXECUTE WORLD_EXECUTE OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ
        DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
configure_file(startatp-wayland.cmake ${CMAKE_CURRENT_BINARY_DIR}/startatp-wayland)
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/startatp-wayland
	PERMISSIONS OWNER_EXECUTE GROUP_EXECUTE WORLD_EXECUTE OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ
        DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})

configure_file(aerothemeplasmax11.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PLASMA_X11_DESKTOP_FILENAME})
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PLASMA_X11_DESKTOP_FILENAME}
        DESTINATION ${KDE_INSTALL_DATADIR}/xsessions
)

configure_file(aerothemeplasmawayland.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PLASMA_WAYLAND_DESKTOP_FILENAME})
install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PLASMA_WAYLAND_DESKTOP_FILENAME}
        DESTINATION ${KDE_INSTALL_DATADIR}/wayland-sessions
)
