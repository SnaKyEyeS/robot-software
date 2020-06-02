add_library(pid pid.c)

target_include_directories(pid public include)

cvra_add_test(TARGET pid_test SOURCES tests/pid_test.cpp DEPENDENCIES pid)
