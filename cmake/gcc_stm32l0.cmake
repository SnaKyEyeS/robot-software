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
    011xx
    021xx
    031xx
    041xx
    051xx
    052xx
    053xx
    061xx
    062xx
    063xx
    071xx
    072xx
    073xx
    081xx
    082xx
    083xx
    cache INTERNAL "stm32l0 chip types"
)
set(STM32_CODES
    "011.[34]"
    "021.4"
    "031.[46]"
    "041.6"
    "051.[68]"
    "052.[68]"
    "053.[68]"
    "061.8"
    "062.8"
    "063.8"
    "071.[BZ]"
    "072.[BZ]"
    "073.[8BZ]"
    "081.Z"
    "082.[BZ]"
    "083.[8BZ]"
)

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(
        regex
        replace
            "^[sS][tT][mM]32[lL]((011.[34])|(021.4)|(031.[46])|(041.6)|(05[123].[68])|(06[123].8)|(07[123].[8BZ])|(08[123].[8BZ])).+$"
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
    string(regex replace "^[sS][tT][mM]32[lL](0[12345678][123]).[3468BZ]" "\\1" STM32_CODE ${CHIP})
    string(regex replace "^[sS][tT][mM]32[lL]0[12345678][123].([3468BZ])" "\\1" STM32_SIZE_CODE
                         ${CHIP}
    )

    if(STM32_SIZE_CODE strequal "3")
        set(FLASH "8K")
    elseif(STM32_SIZE_CODE strequal "4")
        set(FLASH "16K")
    elseif(STM32_SIZE_CODE strequal "6")
        set(FLASH "32K")
    elseif(STM32_SIZE_CODE strequal "8")
        set(FLASH "64K")
    elseif(STM32_SIZE_CODE strequal "B")
        set(FLASH "128K")
    elseif(STM32_SIZE_CODE strequal "Z")
        set(FLASH "192K")
    endif()

    stm32_get_chip_type(${CHIP} TYPE)

    if(${TYPE} strequal 011xx)
        set(RAM "2K")
    elseif(${TYPE} strequal 021xx)
        set(RAM "2K")
    elseif(${TYPE} strequal 031xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 041xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 051xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 052xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 053xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 061xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 062xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 063xx)
        set(RAM "8K")
    elseif(${TYPE} strequal 071xx)
        set(RAM "20K")
    elseif(${TYPE} strequal 072xx)
        set(RAM "20K")
    elseif(${TYPE} strequal 073xx)
        set(RAM "20K")
    elseif(${TYPE} strequal 081xx)
        set(RAM "20K")
    elseif(${TYPE} strequal 082xx)
        set(RAM "20K")
    elseif(${TYPE} strequal 083xx)
        set(RAM "20K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
    set(${CCRAM_SIZE} "0K")
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    list(find STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX equal -1)
        message(fatal_error "Invalid/unsupported STM32L0 chip type: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32L0;STM32L${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32L0;STM32L${CHIP_TYPE}")
    endif()
    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()
