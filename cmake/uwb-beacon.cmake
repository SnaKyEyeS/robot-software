# Add cmake/ to the CMake path
get_filename_component(stm32_cmake_dir ${CMAKE_CURRENT_LIST_FILE} directory)
set(CMAKE_MODULE_PATH ${stm32_cmake_dir} ${CMAKE_MODULE_PATH})

set(STM32_CHIP
    "STM32F405GT"
    cache STRING "STM32 chip to build for"
)
set(STM32_FAMILY
    "F4"
    cache INTERNAL "stm32 family"
)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CVRA_BOARD_NAME uwb-beacon)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_C_COMPILER "arm-none-eabi-gcc")
set(CMAKE_CXX_COMPILER "arm-none-eabi-g++")
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

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Set flags common to C and C++ such as hardware platform, ABI and so on
set(HARDWARE_FLAGS
    "-mthumb -mcpu=cortex-m4 \
    -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs"
    cache INTERNAL "hardware related flags"
)

set(COMMON_FLAGS
    "${HARDWARE_FLAGS} \
    -fno-builtin \
    -ffunction-sections -fdata-sections \
    -fomit-frame-pointer \
    -fno-unroll-loops \
    -ffast-math \
    -ftree-vectorize \
    -Os \
    "
    cache INTERNAL "common C and C++ flags"
)

set(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} ${COMMON_FLAGS}"
    cache INTERNAL "c compiler flags"
)

# Set C++ specific options,m ostly disabling expensive features
set(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${COMMON_FLAGS} \
    -fno-exceptions -fno-unwind-tables \
    -fno-threadsafe-statics -fno-rtti -DEIGEN_NO_DEBUG \
    -fno-use-cxa-atexit \
    "
    cache INTERNAL "cxx compiler flags"
)

set(CMAKE_ASM_FLAGS
    "${HARDWARE_FLAGS} -x assembler-with-cpp"
    cache INTERNAL "asm compiler flags"
)

set(CMAKE_EXE_LINKER_FLAGS
    "-Wl,--gc-sections ${HARDWARE_FLAGS}"
    cache INTERNAL "executable linker flags"
)

set(CMAKE_MODULE_LINKER_FLAGS
    "${HARDWARE_FLAGS}"
    cache INTERNAL "module linker flags"
)

set(CMAKE_SHARED_LINKER_FLAGS
    "${HARDWARE_FLAGS}"
    cache INTERNAL "shared linker flags"
)

add_compile_definitions("CORTEX_USE_FPU=TRUE;THUMB")
add_compile_definitions("UAVCAN_STM32_TIMER_NUMBER=2")

# TODO: #define chip types

include(stm32_common)
