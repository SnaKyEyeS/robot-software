find_package (Threads)
add_library(msgbus
    messagebus.c
)

target_include_directories(msgbus PUBLIC include)

add_library(msgbus_mocks_synchronization
    tests/mocks/synchronization.cpp
)

target_link_libraries(msgbus_mocks_synchronization msgbus)

cvra_add_test(TARGET msgbus_test SOURCES
    tests/atomicity.cpp
    tests/msgbus.cpp
    tests/signaling.cpp
    tests/foreach.cpp
    tests/watchgroups.cpp
    tests/new_topic_callbacks.cpp
    tests/test_cpp_interface.cpp
    DEPENDENCIES
    msgbus
    msgbus_mocks_synchronization
)

add_library(msgbus_posix
    examples/posix/port.c
)

target_link_libraries(msgbus_posix
   msgbus
   Threads::Threads
)

target_include_directories(msgbus_posix
    PUBLIC
    examples/posix/include
)

add_executable(msgbus_demo
    examples/posix/demo.c
)
target_link_libraries(msgbus_demo
    msgbus
    msgbus_posix
)

add_executable(msgbus_demo_watchgroups
    examples/posix/demo_watchgroups.c
)

target_link_libraries(msgbus_demo_watchgroups 
    msgbus
    msgbus_posix
)

if(${CMAKE_CROSSCOMPILING})
    add_library(msgbus_chibios
        examples/chibios/port.c
    )
    target_link_libraries(msgbus_chibios msgbus chibios)
endif()

