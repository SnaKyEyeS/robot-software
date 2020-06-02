add_library(goap interface)
target_include_directories(goap interface include)

cvra_add_test(
    TARGET
    goap_test
    SOURCES
    tests/goap_internals.cpp
    tests/goap_test.cpp
    DEPENDENCIES
    goap
)
