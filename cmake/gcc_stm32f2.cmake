set(CMAKE_C_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m3 -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "c compiler flags"
)
set(CMAKE_CXX_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m3 -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "cxx compiler flags"
)
set(CMAKE_ASM_FLAGS
    "-mthumb -mcpu=cortex-m3 -x assembler-with-cpp"
    cache INTERNAL "asm compiler flags"
)

set(CMAKE_EXE_LINKER_FLAGS
    "-Wl,--gc-sections -mthumb -mcpu=cortex-m3 -mabi=aapcs"
    cache INTERNAL "executable linker flags"
)
set(CMAKE_MODULE_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m3 -mabi=aapcs"
    cache INTERNAL "module linker flags"
)
set(CMAKE_SHARED_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m3 -mabi=aapcs"
    cache INTERNAL "shared linker flags"
)

set(STM32_CHIP_TYPES
    205xB
    205xC
    205xE
    205xF
    205xG
    215xE
    215xG
    207xC
    207xE
    207xF
    207xG
    217xE
    217xG
)
set(STM32_CODES
    "205.B"
    "205.C"
    "205.E"
    "205.F"
    "205.G"
    "215.E"
    "215.G"
    "207.C"
    "207.E"
    "207.F"
    "207.G"
    "217.E"
    "217.G"
)

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(regex replace "^[sS][tT][mM]32[fF](2[01][57].[BCDEFG]).*$" "\\1" STM32_CODE ${CHIP})
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
    string(regex replace "^[sS][tT][mM]32[fF]2[01][57].([BCDEFG]).*$" "\\1" STM32_SIZE_CODE ${CHIP})

    if(STM32_SIZE_CODE strequal "B")
        set(FLASH "128K")
    elseif(STM32_SIZE_CODE strequal "C")
        set(FLASH "256K")
    elseif(STM32_SIZE_CODE strequal "D")
        set(FLASH "384K")
    elseif(STM32_SIZE_CODE strequal "E")
        set(FLASH "512K")
    elseif(STM32_SIZE_CODE strequal "F")
        set(FLASH "768K")
    elseif(STM32_SIZE_CODE strequal "G")
        set(FLASH "1024K")
    endif()

    stm32_get_chip_type(${CHIP} TYPE)

    set(RAM "128K")

    if(${TYPE} strequal 205xC)
        set(RAM "96K")
    elseif(${TYPE} strequal 205xB)
        set(RAM "64K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
    set(${CCRAM_SIZE} "0K")
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32F2 chip type: ${CHIP_TYPE}")
    endif()

    string(regex replace "^(2[01][57]).[BCDEFG]" "\\1" DEVICE_NUM ${STM32_CHIP_TYPE})

    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32F2;STM32F${DEVICE_NUM}xx;${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32F2;STM32F${DEVICE_NUM}xx")
    endif()
    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
