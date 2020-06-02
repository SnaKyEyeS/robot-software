set(CMAKE_C_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "c compiler flags"
)
set(CMAKE_CXX_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "cxx compiler flags"
)
set(CMAKE_ASM_FLAGS
    "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -x assembler-with-cpp"
    cache INTERNAL "asm compiler flags"
)

set(CMAKE_EXE_LINKER_FLAGS
    "-Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs"
    cache INTERNAL "executable linker flags"
)
set(CMAKE_MODULE_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs"
    cache INTERNAL "module linker flags"
)
set(CMAKE_SHARED_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs"
    cache INTERNAL "shared linker flags"
)
set(STM32_CHIP_TYPES
    431xx
    432xx
    433xx
    442xx
    443xx
    451xx
    452xx
    462xx
    471xx
    475xx
    476xx
    485xx
    486xx
    496xx
    4a6xx
    4r5xx
    4r7xx
    4r9xx
    4s5xx
    4s7xx
    4s9xx
    cache INTERNAL "stm32l4 chip types"
)
set(STM32_CODES
    "431.."
    "432.."
    "433.."
    "442.."
    "443.."
    "451.."
    "452.."
    "462.."
    "471.."
    "475.."
    "476.."
    "485.."
    "486.."
    "496.."
    "4a6.."
    "4r5.."
    "4r7.."
    "4r9.."
    "4s5.."
    "4s7.."
    "4s9.."
)

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(regex replace "^[sS][tT][mM]32[lL](4[3456789ARS][1235679].[BCEGI]).*$" "\\1" STM32_CODE
                         ${CHIP}
    )
    set(INDEX 0)
    foreach(C_TYPE ${STM32_CHIP_TYPES})
        list(get STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)
        if(STM32_CODE matches ${CHIP_TYPE_REGEXP})
            set(RESULT_TYPE ${C_TYPE})
        endif()
        math(EXPR INDEX "${INDEX}+1")
    endforeach()
    set(${CHIP_TYPE} ${RESULT_TYPE})
endmacro()

macro(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE CCRAM_SIZE)
    string(regex replace "^[sS][tT][mM]32[lL](4[3456789ARS][1235679].[BCEGI]]).*$" "\\1" STM32_CODE
                         ${CHIP}
    )
    string(regex replace "^[sS][tT][mM]32[lL]4[3456789ARS][1235679].([BCEGI]).*$" "\\1"
                         STM32_SIZE_CODE ${CHIP}
    )

    if(STM32_SIZE_CODE strequal "B")
        set(FLASH "128K")
    elseif(STM32_SIZE_CODE strequal "C")
        set(FLASH "256K")
    elseif(STM32_SIZE_CODE strequal "E")
        set(FLASH "512K")
    elseif(STM32_SIZE_CODE strequal "G")
        set(FLASH "1024K")
    elseif(STM32_SIZE_CODE strequal "I")
        set(FLASH "2048K")
    endif()

    stm32_get_chip_type(${CHIP} TYPE)

    if(${TYPE} strequal "431xx")
        set(RAM "64K")
    elseif(${TYPE} strequal "432xx")
        set(RAM "64K")
    elseif(${TYPE} strequal "433xx")
        set(RAM "64K")
    elseif(${TYPE} strequal "442xx")
        set(RAM "64K")
    elseif(${TYPE} strequal "443xx")
        set(RAM "64K")
    elseif(${TYPE} strequal "451xx")
        set(RAM "160K")
    elseif(${TYPE} strequal "452xx")
        set(RAM "160K")
    elseif(${TYPE} strequal "462xx")
        set(RAM "160K")
    elseif(${TYPE} strequal "471xx")
        set(RAM "128K")
    elseif(${TYPE} strequal "475xx")
        set(RAM "128K")
    elseif(${TYPE} strequal "476xx")
        set(RAM "128K")
    elseif(${TYPE} strequal "485xx")
        set(RAM "128K")
    elseif(${TYPE} strequal "486xx")
        set(RAM "128K")
    elseif(${TYPE} strequal "496xx")
        set(RAM "320K")
    elseif(${TYPE} strequal "4a6xx")
        set(RAM "320K")
    elseif(${TYPE} strequal "4r5xx")
        set(RAM "640K")
    elseif(${TYPE} strequal "4r7xx")
        set(RAM "640K")
    elseif(${TYPE} strequal "4r9xx")
        set(RAM "640K")
    elseif(${TYPE} strequal "4s5xx")
        set(RAM "640K")
    elseif(${TYPE} strequal "4s7xx")
        set(RAM "640K")
    elseif(${TYPE} strequal "4s9xx")
        set(RAM "640K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
    set(${CCRAM_SIZE} "64K")
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32L4 chip type: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32L4;STM32L${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32L4;STM32L${CHIP_TYPE}")
    endif()

    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
