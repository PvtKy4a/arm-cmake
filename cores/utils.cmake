set(CMAKE_USER_MAKE_RULES_OVERRIDE "cores/init_flags")

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

set(ARM_TARGET_TRIPLET "arm-none-eabi-")

set(TOOLCHAIN_SYSROOT  "${ARM_TOOLCHAIN_PATH}/${ARM_TARGET_TRIPLET}")
set(TOOLCHAIN_BIN_PATH "${ARM_TOOLCHAIN_PATH}/bin")

set(CMAKE_SYSROOT ${TOOLCHAIN_SYSROOT})

find_program(CMAKE_OBJCOPY NAMES ${ARM_TARGET_TRIPLET}objcopy HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_OBJDUMP NAMES ${ARM_TARGET_TRIPLET}objdump HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_SIZE NAMES ${ARM_TARGET_TRIPLET}size HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_DEBUGGER NAMES ${ARM_TARGET_TRIPLET}gdb HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_CPPFILT NAMES ${ARM_TARGET_TRIPLET}c++filt HINTS ${TOOLCHAIN_BIN_PATH})

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

function(_arm_add_ld TARGET VISIBILITY SCRIPT)
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

set(C_COMPILE_FLAGS -Wall -Wextra -Wpedantic -fdata-sections -ffunction-sections)

set(CXX_COMPILE_FLAGS ${C_COMPILE_FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics)

set(ASM_COMPILE_FLAGS ${C_COMPILE_FLAGS} -x assembler-with-cpp -MMD -MP)

set(C_LINK_FLAGS -Wl,-Map=${CMAKE_PROJECT_NAME}.map -Wl,--gc-sections)
set(C_LINK_FLAGS ${C_LINK_FLAGS} -Wl,--start-group -lc -lm -Wl,--end-group -Wl,--print-memory-usage)

set(CXX_LINK_FLAGS ${C_LINK_FLAGS} -Wl,--start-group -lstdc++ -lsupc++ -Wl,--end-group)

set(NANO_C_LINK_FLAGS --specs=nano.specs)

set(NANO_CXX_LINK_FLAGS ${NANO_C_LINK_FLAGS})

set(NOSYS_C_LINK_FLAGS --specs=nosys.specs)

set(NOSYS_CXX_LINK_FLAGS ${NOSYS_C_LINK_FLAGS})

function(_arm_create_core_target CORE)
    if(NOT (TARGET ARM::${CORE}))
        add_library(ARM::${CORE} INTERFACE IMPORTED)
        target_compile_options(ARM::${CORE} INTERFACE
            $<$<CONFIG:Debug>:-O0 -g3>
            $<$<CONFIG:Release>:-Os -g0>
            $<$<COMPILE_LANGUAGE:C>:${C_COMPILE_FLAGS}>
            $<$<COMPILE_LANGUAGE:ASM>:${ASM_COMPILE_FLAGS}>
            $<$<COMPILE_LANGUAGE:CXX>:${CXX_COMPILE_FLAGS}>
        )
        target_link_options(ARM::${CORE} INTERFACE
            $<$<LINK_LANGUAGE:C>:${C_LINK_FLAGS}>
            $<$<LINK_LANGUAGE:CXX>:${CXX_LINK_FLAGS}>
        )
        add_library(ARM::${CORE}::Nano INTERFACE IMPORTED)
        target_link_options(ARM::${CORE}::Nano INTERFACE
            $<$<LINK_LANGUAGE:C>:${NANO_C_LINK_FLAGS}>
            $<$<LINK_LANGUAGE:CXX>:${NANO_CXX_LINK_FLAGS}>
        )
        add_library(ARM::${CORE}::NoSys INTERFACE IMPORTED)
        target_link_options(ARM::${CORE}::NoSys INTERFACE
            $<$<LINK_LANGUAGE:C>:${NOSYS_C_LINK_FLAGS}>
            $<$<LINK_LANGUAGE:CXX>:${NOSYS_CXX_LINK_FLAGS}>
        )
    endif()
endfunction()

include(cores/M0)
include(cores/M3)
include(cores/M4)
include(cores/M7)
