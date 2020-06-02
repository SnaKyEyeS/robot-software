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
    100xE
    101x6
    101xB
    101xE
    101xG
    102x6
    102xB
    103x6
    103xB
    103xE
    103xG
    105xC
    107xC
    cache INTERNAL "stm32f1 chip types"
)
set(STM32_CODES
    "100.[468B]"
    "100.[CDE]"
    "101.[46]"
    "101.[8B]"
    "101.[CDE]"
    "101.[FG]"
    "102.[46]"
    "102.[8B]"
    "103.[46]"
    "103.[8B]"
    "103.[CDE]"
    "103.[FG]"
    "105.[8BC]"
    "107.[BC]"
)

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(regex replace "^[sS][tT][mM]32[fF](10[012357].[468BCDEFG]).*$" "\\1" STM32_CODE ${CHIP})
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
    string(regex replace "^[sS][tT][mM]32[fF](10[012357]).[468BCDEFG].*$" "\\1" STM32_CODE ${CHIP})
    string(regex replace "^[sS][tT][mM]32[fF]10[012357].([468BCDEFG]).*$" "\\1" STM32_SIZE_CODE
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

    if(${TYPE} strequal 100xB)
        if((STM32_SIZE_CODE strequal "4") or (STM32_SIZE_CODE strequal "6"))
            set(RAM "4K")
        else()
            set(RAM "8K")
        endif()
    elseif(${TYPE} strequal 100xE)
        if(STM32_SIZE_CODE strequal "C")
            set(RAM "24K")
        else()
            set(RAM "32K")
        endif()
    elseif(${TYPE} strequal 101x6)
        if(STM32_SIZE_CODE strequal "4")
            set(RAM "4K")
        else()
            set(RAM "6K")
        endif()
    elseif(${TYPE} strequal 101xB)
        if(STM32_SIZE_CODE strequal "8")
            set(RAM "10K")
        else()
            set(RAM "16K")
        endif()
    elseif(${TYPE} strequal 101xE)
        if(STM32_SIZE_CODE strequal "C")
            set(RAM "32K")
        else()
            set(RAM "48K")
        endif()
    elseif(${TYPE} strequal 101xG)
        set(RAM "80K")
    elseif(${TYPE} strequal 102x6)
        if(STM32_SIZE_CODE strequal "4")
            set(RAM "4K")
        else()
            set(RAM "6K")
        endif()
    elseif(${TYPE} strequal 102xB)
        if(STM32_SIZE_CODE strequal "8")
            set(RAM "10K")
        else()
            set(RAM "16K")
        endif()
    elseif(${TYPE} strequal 103x6)
        if(STM32_SIZE_CODE strequal "4")
            set(RAM "6K")
        else()
            set(RAM "10K")
        endif()
    elseif(${TYPE} strequal 103xB)
        set(RAM "20K")
    elseif(${TYPE} strequal 103xE)
        if(STM32_SIZE_CODE strequal "C")
            set(RAM "48K")
        else()
            set(RAM "54K")
        endif()
    elseif(${TYPE} strequal 103xG)
        set(RAM "96K")
    elseif(${TYPE} strequal 105xC)
        set(RAM "64K")
    elseif(${TYPE} strequal 107xC)
        set(RAM "64K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
    set(${CCRAM_SIZE} "0K")
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32F1 chip type: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32F1;STM32F${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32F1;STM32F${CHIP_TYPE}")
    endif()
    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
