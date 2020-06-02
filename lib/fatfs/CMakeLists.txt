if(${CMAKE_CROSSCOMPILING})
    add_library(fatfs ff.c)

    target_include_directories(fatfs public include)
    target_link_libraries(fatfs chibios)

    # This library contains only ffconf.h, which is required by ChibiOS
    add_library(fatfs_conf interface)
    target_include_directories(fatfs_conf interface include/fatfs)
endif()
