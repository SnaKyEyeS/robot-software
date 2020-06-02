if(not ChibiOS_FIND_COMPONENTS)
    set(ChibiOS_FIND_COMPONENTS nil hal)
    message(status "No ChibiOS components specified, using default: ${ChibiOS_FIND_COMPONENTS}")
endif()

set(CHIBIOS_COMPONENTS
    nil
    rt
    hal
    streams
    shell
    cppwrappers
    evtimer
)

list(find ChibiOS_FIND_COMPONENTS nil ChibiOS_FIND_COMPONENTS_nil)
list(find ChibiOS_FIND_COMPONENTS rt ChibiOS_FIND_COMPONENTS_rt)
list(find ChibiOS_FIND_COMPONENTS hal ChibiOS_FIND_COMPONENTS_hal)

if((${ChibiOS_FIND_COMPONENTS_nil} less 0) and (${ChibiOS_FIND_COMPONENTS_rt} less 0))
    message(status "No kernel component selected, using Nil kernel")
    list(append ChibiOS_FIND_COMPONENTS nil)
    set(CHIBIOS_KERNEL nil)
else()
    if((not (${ChibiOS_FIND_COMPONENTS_nil} less 0)) and (not (${ChibiOS_FIND_COMPONENTS_rt} less 0)
                                                         )
    )
        message(fatal_error "Cannot use RT and Nil kernel at the same time")
    endif()
    if(not (${ChibiOS_FIND_COMPONENTS_nil} less 0))
        set(CHIBIOS_KERNEL nil)
    else()
        set(CHIBIOS_KERNEL rt)
    endif()
endif()

if(${ChibiOS_FIND_COMPONENTS_hal} less 0)
    list(append ChibiOS_FIND_COMPONENTS hal)
endif()

if(not CHIBIOS_HALCONF_FILE)
    message(
        fatal_error "Cannot find halconf.h, please specify it using CHIBIOS_HALCONF_FILE variable"
    )
endif()

if(not CHIBIOS_CHCONF_FILE)
    message(
        fatal_error "Cannot find chconf.h, please specify it using CHIBIOS_CHCONF_FILE variable"
    )
endif()

file(strings ${CHIBIOS_CHCONF_FILE} CHCONF_LINES regex "#define CH_CFG_USE_([a-zA-Z_0-9]+) +TRUE")
foreach(LINE ${CHCONF_LINES})
    string(regex replace "#define CH_CFG_USE_([a-zA-Z_0-9]+) +TRUE" "\\1" COMP ${LINE})
    list(append CHIBIOS_RTOS_COMPONENTS ${COMP})
endforeach()

message(status "Detected ChibiOS RTOS components:")
foreach(COMP ${CHIBIOS_RTOS_COMPONENTS})
    message(status "\t${COMP}")
endforeach()

file(strings ${CHIBIOS_HALCONF_FILE} HALCONF_LINES regex "#define HAL_USE_([a-zA-Z_0-9]+) +TRUE")
foreach(LINE ${HALCONF_LINES})
    string(regex replace "#define HAL_USE_([a-zA-Z_0-9]+) +TRUE" "\\1" COMP ${LINE})
    list(append CHIBIOS_HAL_COMPONENTS ${COMP})
endforeach()

message(status "Detected ChibiOS HAL components:")
foreach(COMP ${CHIBIOS_HAL_COMPONENTS})
    message(status "\t${COMP}")
endforeach()

include(ChibiOS/18.2/ChibiOS_RTOS)
include(ChibiOS/18.2/ChibiOS_HAL)

set(CHIBIOS_INCLUDES_streams os/hal/lib/streams)

set(CHIBIOS_SOURCES_streams os/hal/lib/streams/nullstreams.c os/hal/lib/streams/chprintf.c
                            os/hal/lib/streams/memstreams.c
)

set(CHIBIOS_INCLUDES_shell os/various/shell/)

set(CHIBIOS_SOURCES_shell os/various/shell/shell.c os/various/shell/shell_cmd.c)

set(CHIBIOS_INCLUDES_cppwrappers os/various/cpp_wrappers)

set(CHIBIOS_SOURCES_cppwrappers os/various/cpp_wrappers/ch.cpp)

set(CHIBIOS_INCLUDES_evtimer os/various/)

set(CHIBIOS_SOURCES_evtimer os/various/evtimer.c)

message(status "RTOS sources: ")
foreach(SOURCE ${CHIBIOS_SOURCES_${CHIBIOS_KERNEL}})
    message(status "\t${SOURCE}")
endforeach()

message(status "HAL sources: ")
foreach(SOURCE ${CHIBIOS_SOURCES_hal})
    message(status "\t${SOURCE}")
endforeach()

if(not ChibiOS_LINKER_SCRIPT)
    message(
        status
            "ChibiOS doesn't have linker script for your chip, please specify it directly using ChibiOS_LINKER_SCRIPT variable."
    )
endif()

foreach(comp ${ChibiOS_FIND_COMPONENTS})
    list(find CHIBIOS_COMPONENTS ${comp} INDEX)
    if(INDEX equal -1)
        message(
            fatal_error
                "Unknown ChibiOS component: ${comp}\nSupported ChibiOS components: ${CHIBIOS_COMPONENTS}"
        )
    endif()
    foreach(source ${CHIBIOS_SOURCES_${comp}})
        find_file(
            CHIBIOS_${comp}_${source}
            names ${source}
            paths ${CHIBIOS_ROOT}
            no_default_path cmake_find_root_path_both
        )
        list(append ChibiOS_SOURCES ${CHIBIOS_${comp}_${source}})
    endforeach()
    foreach(incl ${CHIBIOS_INCLUDES_${comp}})
        list(append ChibiOS_INCLUDE_DIRS ${CHIBIOS_ROOT}/${incl})
    endforeach()
endforeach()
