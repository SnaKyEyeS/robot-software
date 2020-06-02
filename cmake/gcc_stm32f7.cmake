set(CMAKE_C_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "c compiler flags"
)
set(CMAKE_CXX_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "cxx compiler flags"
)
set(CMAKE_ASM_FLAGS
    "-mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -x assembler-with-cpp"
    cache INTERNAL "asm compiler flags"
)

set(CMAKE_EXE_LINKER_FLAGS
    "-Wl,--gc-sections -mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -mabi=aapcs"
    cache INTERNAL "executable linker flags"
)
set(CMAKE_MODULE_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -mabi=aapcs"
    cache INTERNAL "module linker flags"
)
set(CMAKE_SHARED_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=softfp -mabi=aapcs"
    cache INTERNAL "shared linker flags"
)
set(STM32_CHIP_TYPES
    745xx
    746xx
    756xx
    767xx
    777xx
    769xx
    779xx
    cache INTERNAL "stm32f7 chip types"
)
set(STM32_CODES
    "745.."
    "746.."
    "756.."
    "767.."
    "777.."
    "769.."
    "779.."
)

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(regex replace "^[sS][tT][mM]32[fF](7[4567][5679].[EGI]).*$" "\\1" STM32_CODE ${CHIP})
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
    string(regex replace "^[sS][tT][mM]32[fF](7[4567][5679].[EGI]).*$" "\\1" STM32_CODE ${CHIP})
    string(regex replace "^[sS][tT][mM]32[fF]7[4567][5679].([EGI]).*$" "\\1" STM32_SIZE_CODE
                         ${CHIP}
    )

    if(STM32_SIZE_CODE strequal "E")
        set(FLASH "512K")
    elseif(STM32_SIZE_CODE strequal "G")
        set(FLASH "1024K")
    elseif(STM32_SIZE_CODE strequal "I")
        set(FLASH "2048K")
    endif()

    stm32_get_chip_type(${CHIP} TYPE)

    if(${TYPE} strequal "745xx")
        set(RAM "320K")
    elseif(${TYPE} strequal "746xx")
        set(RAM "320K")
    elseif(${TYPE} strequal "756xx")
        set(RAM "320K")
    elseif(${TYPE} strequal "767xx")
        set(RAM "512K")
    elseif(${TYPE} strequal "777xx")
        set(RAM "512K")
    elseif(${TYPE} strequal "769xx")
        set(RAM "512K")
    elseif(${TYPE} strequal "779xx")
        set(RAM "512K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
    # First 64K of RAM are already CCM...
    set(${CCRAM_SIZE} "0K")
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32F7 chip type: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32F7;STM32F${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32F7;STM32F${CHIP_TYPE}")
    endif()

    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
