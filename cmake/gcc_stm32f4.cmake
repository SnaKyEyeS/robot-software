set(CMAKE_C_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=gnu11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize"
    cache INTERNAL "c compiler flags"
)
set(CMAKE_CXX_FLAGS
    "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=c++14 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize -fno-exceptions -fno-unwind-tables -fno-threadsafe-statics -fno-rtti -DEIGEN_NO_DEBUG"
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
    405xx
    415xx
    407xx
    417xx
    427xx
    437xx
    429xx
    439xx
    446xx
    401xC
    401xE
    411xE
    cache INTERNAL "stm32f4 chip types"
)
set(STM32_CODES
    "405.."
    "415.."
    "407.."
    "417.."
    "427.."
    "437.."
    "429.."
    "439.."
    "446.."
    "401.[CB]"
    "401.[ED]"
    "411.[CE]"
)

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(regex replace "^[sS][tT][mM]32[fF](4[01234][15679].[BCEGI]).*$" "\\1" STM32_CODE ${CHIP})
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

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32F4 chip type: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32F4;STM32F${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32F4;STM32F${CHIP_TYPE}")
    endif()

    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
