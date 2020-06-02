cvra_add_test(TARGET version_test SOURCES tests/test_version.cpp DEPENDENCIES version)

add_custom_command(
    command ./version.sh \"${CVRA_BOARD_NAME}\" ${CMAKE_BINARY_DIR}/version.c
    working_directory ${CMAKE_CURRENT_SOURCE_DIR}
    output ${CMAKE_BINARY_DIR}/version.c
    comment "Generating git version"
)

add_library(version ${CMAKE_BINARY_DIR}/version.c)
target_include_directories(version interface include)
