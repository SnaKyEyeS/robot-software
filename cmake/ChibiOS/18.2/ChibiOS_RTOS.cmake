foreach(FAMILY F0 L0 L4)
    set(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_${FAMILY}
        os/common/startup/ARMCMx/compilers/GCC/crt0_v6m.S os/common/ports/ARMCMx/chcore.c
        os/common/ports/ARMCMx/chcore_v6m.c os/common/ports/ARMCMx/compilers/GCC/chcoreasm_v6m.S
    )
endforeach()

foreach(FAMILY F1 F2 F3 F4 F7)
    set(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_${FAMILY}
        os/common/startup/ARMCMx/compilers/GCC/crt0_v7m.S os/common/ports/ARMCMx/chcore.c
        os/common/ports/ARMCMx/chcore_v7m.c os/common/ports/ARMCMx/compilers/GCC/chcoreasm_v7m.S
    )
endforeach()

foreach(
    FAMILY
    F0
    F1
    F2
    F3
    F4
    F7
    L0
    L1
)
    set(CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}_${FAMILY}
        os/common/startup/ARMCMx/devices/STM32${FAMILY}xx os/common/ext/ST/STM32${FAMILY}xx
        os/common/oslib/include os/common/ports/ARMCMx os/common/ports/ARMCMx/compilers/GCC
    )
endforeach()

set(CHIBIOS_SOURCES_${CHIBIOS_KERNEL} os/common/startup/ARMCMx/compilers/GCC/crt1.c
                                      os/common/startup/ARMCMx/compilers/GCC/vectors.S
)

set(CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}
    os/license os/common/portability/GCC os/common/startup/ARMCMx/compilers/GCC
    os/common/ext/ARM/CMSIS/Core/Include
)

set(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_MAILBOXES os/common/oslib/src/chmboxes.c)
set(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_MEMCORE os/common/oslib/src/chmemcore.c)
set(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_HEAP os/common/oslib/src/chheap.c)
set(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_MEMPOOLS os/common/oslib/src/chmempools.c)
set(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_FACTORY os/common/oslib/src/chfactory.c)

set(CHIBIOS_SOURCES_rt_TM os/rt/src/chtm.c)
set(CHIBIOS_SOURCES_rt_REGISTRY os/rt/src/chregistry.c)
set(CHIBIOS_SOURCES_rt_SEMAPHORES os/rt/src/chsem.c)
set(CHIBIOS_SOURCES_rt_MUTEXES os/rt/src/chmtx.c)
set(CHIBIOS_SOURCES_rt_CONDVARS os/rt/src/chcond.c)
set(CHIBIOS_SOURCES_rt_EVENTS os/rt/src/chevents.c)
set(CHIBIOS_SOURCES_rt_MESSAGES os/rt/src/chmsg.c)
set(CHIBIOS_SOURCES_rt_DYNAMIC os/rt/src/chdynamic.c)

list(append CHIBIOS_SOURCES_nil os/nil/src/ch.c)
list(append CHIBIOS_INCLUDES_nil os/nil/include)

list(
    append
    CHIBIOS_SOURCES_rt
    os/rt/src/chsys.c
    os/rt/src/chdebug.c
    os/rt/src/chstats.c
    os/rt/src/chtrace.c
    os/rt/src/chvt.c
    os/rt/src/chschd.c
    os/rt/src/chthreads.c
)

list(append CHIBIOS_INCLUDES_rt os/rt/include)

if(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_${STM32_FAMILY})
    list(append CHIBIOS_SOURCES_${CHIBIOS_KERNEL}
         ${CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_${STM32_FAMILY}}
    )
endif()

if(CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}_${STM32_FAMILY})
    list(append CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}
         ${CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}_${STM32_FAMILY}}
    )
endif()

foreach(COMP ${CHIBIOS_RTOS_COMPONENTS})
    if(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_${COMP})
        list(append CHIBIOS_SOURCES_${CHIBIOS_KERNEL} ${CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_${COMP}})
    endif()
    if(CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}_${COMP})
        list(append CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}
             ${CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}_${COMP}}
        )
    endif()

    if(CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_${COMP}_${STM32_FAMILY})
        list(append CHIBIOS_SOURCES_${CHIBIOS_KERNEL}
             ${CHIBIOS_SOURCES_${CHIBIOS_KERNEL}_${COMP}_${STM32_FAMILY}}
        )
    endif()
    if(CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}_${COMP}_${STM32_FAMILY})
        list(append CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}
             ${CHIBIOS_INCLUDES_${CHIBIOS_KERNEL}_${COMP}_${STM32_FAMILY}}
        )
    endif()
endforeach()
