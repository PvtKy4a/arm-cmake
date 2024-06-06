set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  ARM)

set(CMAKE_C_COMPILER_ID     GNU)
set(CMAKE_CXX_COMPILER_ID   GNU)

get_filename_component(ARM_CMAKE_DIR ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
list(APPEND CMAKE_MODULE_PATH ${ARM_CMAKE_DIR})

include(cores/utils)

find_program(CMAKE_C_COMPILER NAMES ${ARM_TARGET_TRIPLET}gcc HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_CXX_COMPILER NAMES ${ARM_TARGET_TRIPLET}g++ HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_ASM_COMPILER NAMES ${ARM_TARGET_TRIPLET}gcc HINTS ${TOOLCHAIN_BIN_PATH})

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_EXECUTABLE_SUFFIX_C   .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)
set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)

set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_BIN_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

function(arm_add_linker_script TARGET VISIBILITY SCRIPT)
    _arm_add_ld(${TARGET} ${VISIBILITY} ${SCRIPT})
endfunction()

function(arm_generate_bin_file TARGET)
    _arm_generate_file(${TARGET} "bin" "binary")
endfunction()

function(arm_generate_hex_file TARGET)
    _arm_generate_file(${TARGET} "hex" "ihex")
endfunction()
