cmake_minimum_required(VERSION 3.19)
project(aerothemeplasma-kcmloader LANGUAGES CXX)

set(QT_MIN_VERSION "6.8.0")
set(KF6_MIN_VERSION "6.14.0")
set(CMAKE_AUTOMOC ON)
set(QT_MAJOR_VERSION 6)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core)
find_package(ECM 1.4.0 REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    DBus
    Widgets
)

qt_standard_project_setup()

qt_add_executable(aerothemeplasma-kcmloader
    main.cpp
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    KCMUtils
)

target_link_libraries(aerothemeplasma-kcmloader
    PRIVATE Qt::Core
    KF6::KCMUtils
)

include(GNUInstallDirs)

install(TARGETS aerothemeplasma-kcmloader
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
