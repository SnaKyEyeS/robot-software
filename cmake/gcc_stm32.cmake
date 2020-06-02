get_filename_component(STM32_CMAKE_DIR ${CMAKE_CURRENT_LIST_FILE} directory)
set(CMAKE_MODULE_PATH ${STM32_CMAKE_DIR} ${CMAKE_MODULE_PATH})

set(STM32_SUPPORTED_FAMILIES
    L0
    L1
    L4
    F0
    F1
    F2
    F3
    F4
    F7
    cache INTERNAL "stm32 supported families"
)
if(STM32_CHIP)
    set(STM32_CHIP
        "${STM32_CHIP}"
        cache STRING "STM32 chip to build for"
    )
endif()

if(not TARGET_TRIPLET)
    set(TARGET_TRIPLET "arm-none-eabi")
    message(status "No TARGET_TRIPLET specified, using default: " arm-none-eabi)
endif()

if(not STM32_FAMILY)
    message(status "No STM32_FAMILY specified, trying to get it from STM32_CHIP")
    if(not STM32_CHIP)
        set(STM32_FAMILY
            "F1"
            cache INTERNAL "stm32 family"
        )
        message(
            status
                "Neither STM32_FAMILY nor STM32_CHIP specified, using default STM32_FAMILY: ${STM32_FAMILY}"
        )
    else()
        string(regex replace "^[sS][tT][mM]32(([fF][0-47])|([lL][0-14])|([tT])|([wW])).+$" "\\1"
                             STM32_FAMILY ${STM32_CHIP}
        )
        string(toupper ${STM32_FAMILY} STM32_FAMILY)
        message(status "Selected STM32 family: ${STM32_FAMILY}")
    endif()
endif()

string(toupper "${STM32_FAMILY}" STM32_FAMILY)
list(find STM32_SUPPORTED_FAMILIES "${STM32_FAMILY}" FAMILY_INDEX)
if(FAMILY_INDEX equal -1)
    message(fatal_error "Invalid/unsupported STM32 family: ${STM32_FAMILY}")
endif()

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

if(WIN32)
    set(TOOL_EXECUTABLE_SUFFIX ".exe")
else()
    set(TOOL_EXECUTABLE_SUFFIX "")
endif()

if(${CMAKE_VERSION} version_less 3.6.0)
    include(CMakeForceCompiler)
    cmake_force_c_compiler("arm-none-eabi-gcc" GNU)
    cmake_force_cxx_compiler("arm-none-eabi-g++" GNU)
else()
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
    set(CMAKE_C_COMPILER "arm-none-eabi-gcc")
    set(CMAKE_CXX_COMPILER "arm-none-eabi-g++")
endif()
set(CMAKE_ASM_COMPILER "arm-none-eabi-gcc")

set(CMAKE_OBJCOPY
    "arm-none-eabi-objcopy"
    cache INTERNAL "objcopy tool"
)
set(CMAKE_OBJDUMP
    "arm-none-eabi-objdump"
    cache INTERNAL "objdump tool"
)
set(CMAKE_SIZE
    "arm-none-eabi-size"
    cache INTERNAL "size tool"
)
set(CMAKE_DEBUGER
    "arm-none-eabi-gdb"
    cache INTERNAL "debuger"
)
set(CMAKE_CPPFILT
    "arm-none-eabi-c++filt"
    cache INTERNAL "C++filt"
)
set(CMAKE_AR
    "arm-none-eabi-ar"
    cache INTERNAL "ar"
)
set(CMAKE_RANLIB
    "arm-none-eabi-ranlib"
    cache INTERNAL "ranlib"
)

set(CMAKE_C_FLAGS_DEBUG
    "-O2 -g -ffunction-sections -fdata-sections -fno-common -mfloat-abi=hard -mfpu=fpv4-sp-d16"
    cache INTERNAL "c compiler flags debug"
)
set(CMAKE_CXX_FLAGS_DEBUG
    "-O2 -g -ffunction-sections -fdata-sections -fno-common -fno-exceptions -fno-unwind-tables -fno-threadsafe-statics -fno-rtti -DEIGEN_NO_DEBUG -mfloat-abi=hard -mfpu=fpv4-sp-d16"
    cache INTERNAL "cxx compiler flags debug"
)
set(CMAKE_ASM_FLAGS_DEBUG
    "-g"
    cache INTERNAL "asm compiler flags debug"
)
set(CMAKE_EXE_LINKER_FLAGS_DEBUG
    ""
    cache INTERNAL "linker flags debug"
)

set(CMAKE_C_FLAGS_RELEASE
    "-O2 -ffunction-sections -fdata-sections -fno-common -mfloat-abi=hard -mfpu=fpv4-sp-d16"
    cache INTERNAL "c compiler flags release"
)
set(CMAKE_CXX_FLAGS_RELEASE
    "-O2 -ffunction-sections -fdata-sections -fno-common -fno-exceptions -fno-unwind-tables -fno-threadsafe-statics -fno-rtti -DEIGEN_NO_DEBUG -mfloat-abi=hard -mfpu=fpv4-sp-d16"
    cache INTERNAL "cxx compiler flags release"
)
set(CMAKE_ASM_FLAGS_RELEASE
    ""
    cache INTERNAL "asm compiler flags release"
)
set(CMAKE_EXE_LINKER_FLAGS_RELEASE
    ""
    cache INTERNAL "linker flags release"
)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

string(tolower ${STM32_FAMILY} STM32_FAMILY_LOWER)
include(gcc_stm32${STM32_FAMILY_LOWER})

function(STM32_SET_TARGET_PROPERTIES TARGET)
    if(not STM32_CHIP_TYPE)
        if(not STM32_CHIP)
            message(
                warning
                    "Neither STM32_CHIP_TYPE nor STM32_CHIP selected, you'll have to use STM32_SET_CHIP_DEFINITIONS directly"
            )
        else()
            stm32_get_chip_type(${STM32_CHIP} STM32_CHIP_TYPE)
        endif()
    endif()
    stm32_set_chip_definitions(${TARGET} ${STM32_CHIP_TYPE})
endfunction()

function(STM32_SET_HSE_VALUE TARGET STM32_HSE_VALUE)
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE}")
    endif()
    set_target_properties(${TARGET} properties COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()

macro(STM32_GENERATE_LIBRARIES NAME SOURCES LIBRARIES)
    string(tolower ${STM32_FAMILY} STM32_FAMILY_LOWER)
    foreach(CHIP_TYPE ${STM32_CHIP_TYPES})
        string(tolower ${CHIP_TYPE} CHIP_TYPE_LOWER)
        list(append ${LIBRARIES} ${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER})
        add_library(${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${SOURCES})
        stm32_set_chip_definitions(${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${CHIP_TYPE})
    endforeach()
endmacro()
