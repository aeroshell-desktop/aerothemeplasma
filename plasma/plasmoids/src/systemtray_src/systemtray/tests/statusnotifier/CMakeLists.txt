set(statusnotifiertest_SRCS
    main.cpp
    statusnotifiertest.cpp statusnotifiertest.h
    pumpjob.cpp pumpjob.h
)

ki18n_wrap_ui(statusnotifiertest_SRCS statusnotifiertest.ui)

add_executable(statusnotifiertest ${statusnotifiertest_SRCS})

target_link_libraries(statusnotifiertest
    Qt::Widgets
    Qt::Core
    KF6::CoreAddons
    KF6::KIOCore
    KF6::Service
    KF6::StatusNotifierItem
    KF6::I18n
    KF6::ConfigCore
    Qt::DBus
)
