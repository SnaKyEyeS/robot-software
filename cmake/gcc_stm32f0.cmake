set(CMAKE_C_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m0 -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "c compiler flags"
)
set(CMAKE_CXX_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m0 -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "cxx compiler flags"
)
set(CMAKE_ASM_FLAGS
    "-mthumb -mcpu=cortex-m0 -x assembler-with-cpp"
    cache INTERNAL "asm compiler flags"
)

set(CMAKE_EXE_LINKER_FLAGS
    "-Wl,--gc-sections -mthumb -mcpu=cortex-m0 -mabi=aapcs"
    cache INTERNAL "executable linker flags"
)
set(CMAKE_MODULE_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m0 -mabi=aapcs"
    cache INTERNAL "module linker flags"
)
set(CMAKE_SHARED_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m0 -mabi=aapcs"
    cache INTERNAL "shared linker flags"
)

set(STM32_CHIP_TYPES
    030x6
    030x8
    031x6
    038xx
    042x6
    048x6
    051x8
    058xx
    070x6
    070xB
    071xB
    072xB
    078xx
    091xC
    098xx
    030xC
    cache INTERNAL "stm32f0 chip types"
)
set(STM32_CODES
    "030.[46]"
    "030.8"
    "031.[46]"
    "038.6"
    "042.[46]"
    "048.6"
    "051.[468]"
    "058.8"
    "070.6"
    "070.B"
    "071.[8B]"
    "072.[8B]"
    "078.B"
    "091.[BC]"
    "098.C"
    "030.C"
)

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(
        regex
        replace
            "^[sS][tT][mM]32[fF]((03[018].[468C])|(04[28].[46])|(05[18].[468])|(07[0128].[68B])|(09[18].[BC])).*$"
            "\\1"
            STM32_CODE
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
    string(regex replace "^[sS][tT][mM]32[fF](0[34579][0128]).[468BC].*$" "\\1" STM32_CODE ${CHIP})
    string(regex replace "^[sS][tT][mM]32[fF]0[34579][0128].([468BC]).*$" "\\1" STM32_SIZE_CODE
                         ${CHIP}
    )

    if(STM32_SIZE_CODE strequal "4")
        set(FLASH "16K")
    elseif(STM32_SIZE_CODE strequal "6")
        set(FLASH "32K")
    elseif(STM32_SIZE_CODE strequal "8")
        set(FLASH "64K")
    elseif(STM32_SIZE_CODE strequal "B")
        set(FLASH "128K")
    elseif(STM32_SIZE_CODE strequal "C")
        set(FLASH "256K")
    endif()

    stm32_get_chip_type(${CHIP} TYPE)

    if(${TYPE} strequal 030x6)
        set(RAM "4K")
    elseif(${TYPE} strequal 030x8)
        set(RAM "8K")
    elseif(${TYPE} strequal 030xC)
        set(RAM "32K")
    elseif(${TYPE} strequal 031x6)
        set(RAM "4K")
    elseif(${TYPE} strequal 038xx)
        set(RAM "4K")
    elseif(${TYPE} strequal 042x6)
        set(RAM "6K")
    elseif(${TYPE} strequal 048x6)
        set(RAM "6K")
    elseif(${TYPE} strequal 051x8)
        set(RAM "8K")
    elseif(${TYPE} strequal 058xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 070x6)
        set(RAM "6K")
    elseif(${TYPE} strequal 070xB)
        set(RAM "16K")
    elseif(${TYPE} strequal 071xB)
        set(RAM "16K")
    elseif(${TYPE} strequal 072xB)
        set(RAM "16K")
    elseif(${TYPE} strequal 078xx)
        set(RAM "16K")
    elseif(${TYPE} strequal 091xC)
        set(RAM "32K")
    elseif(${TYPE} strequal 098xx)
        set(RAM "32K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
    set(${CCRAM_SIZE} "0K")
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32F0 chip type: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32F0;STM32F${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32F0;STM32F${CHIP_TYPE}")
    endif()
    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
