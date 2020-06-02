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
    100xB
    100xBA
    100xC
    151xB
    151xBA
    151xC
    151xCA
    151xD
    151xDX
    151xE
    152xB
    152xBA
    152xC
    152xCA
    152xD
    152xDX
    152xE
    162xC
    162xCA
    162xD
    162xDX
    162xE
    cache INTERNAL "stm32l1 chip types"
)
set(STM32_CODES
    "100.B"
    "100.BA"
    "100.C"
    "151.B"
    "151.BA"
    "151.C"
    "151.CA"
    "151.D"
    "151.DX"
    "151.E"
    "152.B"
    "152.BA"
    "152.C"
    "152.CA"
    "152.D"
    "152.DX"
    "152.E"
    "162.C"
    "162.CA"
    "162.D"
    "162.DX"
    "162.E"
)

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(
        regex
        replace
            "^[sS][tT][mM]32[lL]((100.[BC])|(100.[BC]A)|(15[12].[BCE])|(15[12].[BC]A)|(15[12].DX)|(162.[EDC])|(162.CA)|(162.DX)).+$"
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

macro(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE)
    string(regex replace "^[sS][tT][mM]32[lL](1[056][012]).([68BCDE]$|[68BCDE][AX]$)" "\\1"
                         STM32_CODE ${CHIP}
    )
    string(regex replace "^[sS][tT][mM]32[lL](1[056][012]).([68BCDE]$|[68BCDE][AX]$)" "\\2"
                         STM32_SIZE_CODE ${CHIP}
    )

    if(STM32_SIZE_CODE strequal "6" or STM32_SIZE_CODE strequal "6A")
        set(FLASH "32K")
    elseif(STM32_SIZE_CODE strequal "8" or STM32_SIZE_CODE strequal "8A")
        set(FLASH "64K")
    elseif(STM32_SIZE_CODE strequal "B" or STM32_SIZE_CODE strequal "BA")
        set(FLASH "128K")
    elseif(STM32_SIZE_CODE strequal "C" or STM32_SIZE_CODE strequal "CA")
        set(FLASH "256K")
    elseif(STM32_SIZE_CODE strequal "D" or STM32_SIZE_CODE strequal "DX")
        set(FLASH "384K")
    elseif(STM32_SIZE_CODE strequal "E")
        set(FLASH "512K")
    endif()

    stm32_get_chip_type(${CHIP} TYPE)

    if(${TYPE} strequal 100xB)
        set(RAM "10K")
        set(FLASH "128K")
    elseif(${TYPE} strequal 100xBA)
        set(RAM "16K")
        set(FLASH "128K")
    elseif(${TYPE} strequal 100xC)
        set(RAM "16K")
        set(FLASH "256K")

    elseif(${TYPE} strequal 151xB)
        set(RAM "16K")
        set(FLASH "128K")
    elseif(${TYPE} strequal 151xBA)
        set(RAM "32K")
        set(FLASH "128K")
    elseif(${TYPE} strequal 151xC)
        set(RAM "32K")
        set(FLASH "256K")
    elseif(${TYPE} strequal 151xCA)
        set(RAM "32K")
        set(FLASH "256K")
    elseif(${TYPE} strequal 151xD)
        set(RAM "48K")
        set(FLASH "384K")
    elseif(${TYPE} strequal 151xDX)
        set(RAM "80K")
        set(FLASH "384K")
    elseif(${TYPE} strequal 151xE)
        set(RAM "80K")
        set(FLASH "512K")

    elseif(${TYPE} strequal 152xB)
        set(RAM "16K")
        set(FLASH "128K")
    elseif(${TYPE} strequal 152xBA)
        set(RAM "32K")
        set(FLASH "128K")
    elseif(${TYPE} strequal 152xC)
        set(RAM "32K")
        set(FLASH "256K")
    elseif(${TYPE} strequal 152xCA)
        set(RAM "32K")
        set(FLASH "256K")
    elseif(${TYPE} strequal 152xD)
        set(RAM "48K")
        set(FLASH "384K")
    elseif(${TYPE} strequal 152xDX)
        set(RAM "80K")
        set(FLASH "384K")
    elseif(${TYPE} strequal 152xE)
        set(RAM "80K")
        set(FLASH "512K")

    elseif(${TYPE} strequal 162xC)
        set(RAM "32K")
        set(FLASH "256K")
    elseif(${TYPE} strequal 162xCA)
        set(RAM "32K")
        set(FLASH "256K")
    elseif(${TYPE} strequal 162xD)
        set(RAM "48K")
        set(FLASH "384K")
    elseif(${TYPE} strequal 162xDX)
        set(RAM "80K")
        set(FLASH "384K")
    elseif(${TYPE} strequal 162xE)
        set(RAM "80K")
        set(FLASH "512K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32L1 chip type: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32L${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32L${CHIP_TYPE}")
    endif()
    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
