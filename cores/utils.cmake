if(NOT ARM_TOOLCHAIN_PATH)
    if(DEFINED ENV{ARM_TOOLCHAIN_PATH})
        message(STATUS "Detected toolchain path ARM_TOOLCHAIN_PATH in environmental variables: ")
        message(STATUS "$ENV{ARM_TOOLCHAIN_PATH}")
        set(ARM_TOOLCHAIN_PATH $ENV{ARM_TOOLCHAIN_PATH})
    else()
        if(NOT CMAKE_C_COMPILER)
            set(ARM_TOOLCHAIN_PATH "/usr")
            message(STATUS "No ARM_TOOLCHAIN_PATH specified, using default: " ${ARM_TOOLCHAIN_PATH})
        else()
            # keep only directory of compiler
            get_filename_component(ARM_TOOLCHAIN_PATH ${CMAKE_C_COMPILER} DIRECTORY)
            # remove the last /bin directory
            get_filename_component(ARM_TOOLCHAIN_PATH ${ARM_TOOLCHAIN_PATH} DIRECTORY)
        endif()
    endif()
    file(TO_CMAKE_PATH "${ARM_TOOLCHAIN_PATH}" ARM_TOOLCHAIN_PATH)
endif()

set(TOOLCHAIN_SYSROOT  "${ARM_TOOLCHAIN_PATH}/${ARM_TARGET_TRIPLET}")
set(TOOLCHAIN_BIN_PATH "${ARM_TOOLCHAIN_PATH}/bin")

set(CMAKE_SYSROOT ${TOOLCHAIN_SYSROOT})

if(NOT ARM_TARGET_TRIPLET)
    if(DEFINED ENV{ARM_TARGET_TRIPLET})
        message(STATUS "Detected target triplet ARM_TARGET_TRIPLET in environmental variables: ")
        message(STATUS "$ENV{ARM_TARGET_TRIPLET}")
        set(ARM_TARGET_TRIPLET $ENV{ARM_TARGET_TRIPLET})
    else()
        set(ARM_TARGET_TRIPLET "arm-none-eabi-")
        message(STATUS "No ARM_TARGET_TRIPLET specified, using default: " ${ARM_TARGET_TRIPLET})
    endif()
endif()

find_program(CMAKE_OBJCOPY NAMES ${ARM_TARGET_TRIPLET}objcopy HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_OBJDUMP NAMES ${ARM_TARGET_TRIPLET}objdump HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_SIZE NAMES ${ARM_TARGET_TRIPLET}size HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_DEBUGGER NAMES ${ARM_TARGET_TRIPLET}gdb HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_CPPFILT NAMES ${ARM_TARGET_TRIPLET}c++filt HINTS ${TOOLCHAIN_BIN_PATH})

function(arm_print_size_of_target TARGET)
    add_custom_target(${TARGET}_always_display_size
        ALL COMMAND ${CMAKE_SIZE} "$<TARGET_FILE:${TARGET}>"
        COMMENT "Target Sizes: "
        DEPENDS ${TARGET}
    )
endfunction()

function(_arm_generate_file TARGET OUTPUT_EXTENSION OBJCOPY_BFD_OUTPUT)
    get_target_property(TARGET_OUTPUT_NAME ${TARGET} OUTPUT_NAME)
    if (TARGET_OUTPUT_NAME)
        set(OUTPUT_FILE_NAME "${TARGET_OUTPUT_NAME}.${OUTPUT_EXTENSION}")
    else()
        set(OUTPUT_FILE_NAME "${TARGET}.${OUTPUT_EXTENSION}")
    endif()

    get_target_property(RUNTIME_OUTPUT_DIRECTORY ${TARGET} RUNTIME_OUTPUT_DIRECTORY)
    if(RUNTIME_OUTPUT_DIRECTORY)
        set(OUTPUT_FILE_PATH "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_FILE_NAME}")
    else()
        set(OUTPUT_FILE_PATH "${OUTPUT_FILE_NAME}")
    endif()

    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ${OBJCOPY_BFD_OUTPUT} "$<TARGET_FILE:${TARGET}>" ${OUTPUT_FILE_PATH}
        BYPRODUCTS ${OUTPUT_FILE_PATH}
        COMMENT "Generating ${OBJCOPY_BFD_OUTPUT} file ${OUTPUT_FILE_NAME}"
    )
endfunction()

function(arm_generate_binary_file TARGET)
    _arm_generate_file(${TARGET} "bin" "binary")
endfunction()

function(arm_generate_hex_file TARGET)
    _arm_generate_file(${TARGET} "hex" "ihex")
endfunction()

function(arm_add_linker_script TARGET VISIBILITY SCRIPT)
    get_filename_component(SCRIPT "${SCRIPT}" ABSOLUTE)
    target_link_options(${TARGET} ${VISIBILITY} -T "${SCRIPT}")

    get_target_property(TARGET_TYPE ${TARGET} TYPE)
    if(TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
        set(INTERFACE_PREFIX "INTERFACE_")
    endif()

    get_target_property(LINK_DEPENDS ${TARGET} ${INTERFACE_PREFIX}LINK_DEPENDS)
    if(LINK_DEPENDS)
        list(APPEND LINK_DEPENDS "${SCRIPT}")
    else()
        set(LINK_DEPENDS "${SCRIPT}")
    endif()

    set_target_properties(${TARGET} PROPERTIES ${INTERFACE_PREFIX}LINK_DEPENDS "${LINK_DEPENDS}")
endfunction()

if(NOT (TARGET ARM::NoSys))
    add_library(ARM::NoSys INTERFACE IMPORTED)
    target_compile_options(ARM::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
    target_link_options(ARM::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
endif()

if(NOT (TARGET ARM::Nano))
    add_library(ARM::Nano INTERFACE IMPORTED)
    target_compile_options(ARM::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
    target_link_options(ARM::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
endif()

function(arm_util_create_family_target CORE)
    if(NOT (TARGET ARM::${CORE}))
        add_library(ARM::${CORE} INTERFACE IMPORTED)
        target_compile_options(ARM::${CORE} INTERFACE 
            -mthumb -Wall -ffunction-sections -fdata-sections
        )
        target_link_options(ARM::${CORE} INTERFACE 
            -mthumb -Wl,--gc-sections -Wl,--print-memory-usage
        )
    endif()
endfunction()

include(cores/M4)
