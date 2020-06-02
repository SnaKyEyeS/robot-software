# * Adds a compiler flag if it is supported by the compiler
#
# This function checks that the supplied compiler flag is supported and then adds it to the
# corresponding compiler flags
#
# add_c_compiler_flag(<FLAG> [<VARIANT>])
#
# * Example
#
# include(AddCCompilerFlag) add_c_compiler_flag(-Wall) add_c_compiler_flag(-no-strict-aliasing
# RELEASE) Requires CMake 2.6+

if(__add_c_compiler_flag)
    return()
endif()
set(__add_c_compiler_flag INCLUDED)

include(CheckCCompilerFlag)

function(mangle_compiler_flag FLAG OUTPUT)
    string(toupper "HAVE_C_FLAG_${FLAG}" SANITIZED_FLAG)
    string(replace "+" "X" SANITIZED_FLAG ${SANITIZED_FLAG})
    string(regex replace "[^A-Za-z_0-9]" "_" SANITIZED_FLAG ${SANITIZED_FLAG})
    string(regex replace "_+" "_" SANITIZED_FLAG ${SANITIZED_FLAG})
    set(${OUTPUT}
        "${SANITIZED_FLAG}"
        parent_scope
    )
endfunction(mangle_compiler_flag)

function(add_c_compiler_flag FLAG)
    mangle_compiler_flag("${FLAG}" MANGLED_FLAG)
    set(OLD_CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}")
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} ${FLAG}")
    check_c_compiler_flag("${FLAG}" ${MANGLED_FLAG})
    set(CMAKE_REQUIRED_FLAGS "${OLD_CMAKE_REQUIRED_FLAGS}")
    if(${MANGLED_FLAG})
        set(VARIANT ${ARGV1})
        if(ARGV1)
            string(toupper "_${VARIANT}" VARIANT)
        endif()
        set(CMAKE_C_FLAGS${VARIANT}
            "${CMAKE_C_FLAGS${VARIANT}} ${BENCHMARK_C_FLAGS${VARIANT}} ${FLAG}"
            parent_scope
        )
    endif()
endfunction()

function(add_required_c_compiler_flag FLAG)
    mangle_compiler_flag("${FLAG}" MANGLED_FLAG)
    set(OLD_CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}")
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} ${FLAG}")
    check_c_compiler_flag("${FLAG}" ${MANGLED_FLAG})
    set(CMAKE_REQUIRED_FLAGS "${OLD_CMAKE_REQUIRED_FLAGS}")
    if(${MANGLED_FLAG})
        set(VARIANT ${ARGV1})
        if(ARGV1)
            string(toupper "_${VARIANT}" VARIANT)
        endif()
        set(CMAKE_C_FLAGS${VARIANT}
            "${CMAKE_C_FLAGS${VARIANT}} ${FLAG}"
            parent_scope
        )
        set(CMAKE_EXE_LINKER_FLAGS
            "${CMAKE_EXE_LINKER_FLAGS} ${FLAG}"
            parent_scope
        )
        set(CMAKE_SHARED_LINKER_FLAGS
            "${CMAKE_SHARED_LINKER_FLAGS} ${FLAG}"
            parent_scope
        )
        set(CMAKE_MODULE_LINKER_FLAGS
            "${CMAKE_MODULE_LINKER_FLAGS} ${FLAG}"
            parent_scope
        )
        set(CMAKE_REQUIRED_FLAGS
            "${CMAKE_REQUIRED_FLAGS} ${FLAG}"
            parent_scope
        )
    else()
        message(fatal_error "Required flag '${FLAG}' is not supported by the compiler")
    endif()
endfunction()

function(check_c_warning_flag FLAG)
    mangle_compiler_flag("${FLAG}" MANGLED_FLAG)
    set(OLD_CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}")
    # Add -Werror to ensure the compiler generates an error if the warning flag doesn't exist.
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -Werror ${FLAG}")
    check_c_compiler_flag("${FLAG}" ${MANGLED_FLAG})
    set(CMAKE_REQUIRED_FLAGS "${OLD_CMAKE_REQUIRED_FLAGS}")
endfunction()
