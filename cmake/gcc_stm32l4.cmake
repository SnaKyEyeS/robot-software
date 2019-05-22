SET(CMAKE_C_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
SET(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
SET(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

SET(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "executable linker flags")
SET(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "module linker flags")
SET(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "shared linker flags")
SET(STM32_CHIP_TYPES 431xx 432xx 433xx 442xx 443xx 451xx 452xx 462xx 471xx 475xx 476xx 485xx 486xx 496xx 4a6xx 4r5xx 4r7xx 4r9xx 4s5xx 4s7xx 4s9xx CACHE INTERNAL "stm32l4 chip types")
SET(STM32_CODES "431.." "432.." "433.." "442.." "443.." "451.." "452.." "462.." "471.." "475.." "476.." "485.." "486.." "496.." "4a6.." "4r5.." "4r7.." "4r9.." "4s5.." "4s7.." "4s9..")

MACRO(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[lL](4[3456789ARS][1235679].[BCEGI]).*$" "\\1" STM32_CODE ${CHIP})
    SET(INDEX 0)
    FOREACH(C_TYPE ${STM32_CHIP_TYPES})
        LIST(GET STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)
        IF(STM32_CODE MATCHES ${CHIP_TYPE_REGEXP})
            SET(RESULT_TYPE ${C_TYPE})
        ENDIF()
        MATH(EXPR INDEX "${INDEX}+1")
    ENDFOREACH()
    SET(${CHIP_TYPE} ${RESULT_TYPE})
ENDMACRO()

MACRO(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE CCRAM_SIZE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[lL](4[3456789ARS][1235679].[BCEGI]]).*$" "\\1" STM32_CODE ${CHIP})
    STRING(REGEX REPLACE "^[sS][tT][mM]32[lL]4[3456789ARS][1235679].([BCEGI]).*$" "\\1" STM32_SIZE_CODE ${CHIP})
    
    IF(STM32_SIZE_CODE STREQUAL "B")
        SET(FLASH "128K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "C")
        SET(FLASH "256K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "E")
        SET(FLASH "512K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "G")
        SET(FLASH "1024K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "I")
        SET(FLASH "2048K")
    ENDIF()
    
    STM32_GET_CHIP_TYPE(${CHIP} TYPE)
    
    IF(${TYPE} STREQUAL "431xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "432xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "433xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "442xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "443xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "451xx")
        SET(RAM "160K")
    ELSEIF(${TYPE} STREQUAL "452xx")
        SET(RAM "160K")
    ELSEIF(${TYPE} STREQUAL "462xx")
        SET(RAM "160K")
    ELSEIF(${TYPE} STREQUAL "471xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "475xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "476xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "485xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "486xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "496xx")
        SET(RAM "320K")
    ELSEIF(${TYPE} STREQUAL "4a6xx")
        SET(RAM "320K")
    ELSEIF(${TYPE} STREQUAL "4r5xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4r7xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4r9xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4s5xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4s7xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4s9xx")
        SET(RAM "640K")
    ENDIF()
    
    SET(${FLASH_SIZE} ${FLASH})
    SET(${RAM_SIZE} ${RAM})
    SET(${CCRAM_SIZE} "64K")
ENDMACRO()

FUNCTION(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    LIST(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    IF(TYPE_INDEX EQUAL -1)
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32L4 chip type: ${CHIP_TYPE}")
    ENDIF()
    GET_TARGET_PROPERTY(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    IF(TARGET_DEFS)
        SET(TARGET_DEFS "STM32L4;STM32L${CHIP_TYPE};${TARGET_DEFS}")
    ELSE()
        SET(TARGET_DEFS "STM32L4;STM32L${CHIP_TYPE}")
    ENDIF()
        
    SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
ENDFUNCTION()
