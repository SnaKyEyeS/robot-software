set(CMAKE_C_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "c compiler flags"
)
set(CMAKE_CXX_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "cxx compiler flags"
)
set(CMAKE_ASM_FLAGS
    "-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -g -Wa,--no-warn -x assembler-with-cpp"
    cache INTERNAL "asm compiler flags"
)

set(CMAKE_EXE_LINKER_FLAGS
    "-Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard"
    cache INTERNAL "executable linker flags"
)
set(CMAKE_MODULE_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16"
    cache INTERNAL "module linker flags"
)
set(CMAKE_SHARED_LINKER_FLAGS
    "-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16"
    cache INTERNAL "shared linker flags"
)
set(STM32_CHIP_TYPES
    301xx 302xx 303xx 334xx 373xx
    cache INTERNAL "stm32f3 chip types"
)
set(STM32_CODES "301.." "302.." "303.." "334.." "373..")

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(regex replace "^[sS][tT][mM]32[fF](3[037][1234].[68BC]).*$" "\\1" STM32_CODE ${CHIP})
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
    string(regex replace "^[sS][tT][mM]32[fF](3[037][1234].[68BC]).*$" "\\1" STM32_CODE ${CHIP})
    string(regex replace "^[sS][tT][mM]32[fF]3[037][1234].([68BC]).*$" "\\1" STM32_SIZE_CODE
                         ${CHIP}
    )

    if(STM32_SIZE_CODE strequal "6")
        set(FLASH "32K")
        set(CCRAM "4K")
    elseif(STM32_SIZE_CODE strequal "8")
        set(FLASH "64K")
        set(CCRAM "4K")
    elseif(STM32_SIZE_CODE strequal "B")
        set(FLASH "128K")
        set(CCRAM "8K")
    elseif(STM32_SIZE_CODE strequal "C")
        set(FLASH "256K")
        set(CCRAM "8K")
    endif()

    stm32_get_chip_type(${CHIP} TYPE)

    if(${TYPE} strequal "301xx")
        set(RAM "16K")
    elseif(${TYPE} strequal "302xx")
        set(RAM "256K")
    elseif(${TYPE} strequal "303xx")
        set(RAM "48K")
    elseif(${TYPE} strequal "334xx")
        set(RAM "16K")
    elseif(${TYPE} strequal "373xx")
        set(RAM "128K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
    set(${CCRAM_SIZE} ${CCRAM})
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32F3 chip type: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    string(regex replace "^(3..).(.)" "\\1x\\2" CHIP_TYPE_2 ${STM32_CODE})
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32F3;STM32F${CHIP_TYPE_2};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32F3;STM32F${CHIP_TYPE_2}")
    endif()

    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
