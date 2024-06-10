cmake_minimum_required(VERSION 3.22)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/arm-cmake/arm-gcc-toolchain.cmake)

get_filename_component(FOLDER_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

project(${FOLDER_NAME} LANGUAGES C ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

add_executable(${PROJECT_NAME})

arm_add_linker_script(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/libraries/cmsis/cm4/device_support/startup/gcc/linker/AT32F437xM_FLASH.ld)

arm_generate_bin_file(${PROJECT_NAME})
arm_generate_hex_file(${PROJECT_NAME})

target_compile_definitions(${PROJECT_NAME} PRIVATE
    -DAT32F437ZMT7)

add_library(CMSIS INTERFACE)
target_sources(CMSIS INTERFACE
    libraries/cmsis/cm4/device_support/system_at32f435_437.c
    libraries/cmsis/cm4/device_support/startup/gcc/startup_at32f435_437.s)
target_include_directories(CMSIS INTERFACE
    libraries/cmsis/cm4/core_support
    libraries/cmsis/cm4/device_support)

add_library(McuDrivers INTERFACE)
aux_source_directory(libraries/drivers/src DRIVERS_SRC)
target_sources(McuDrivers INTERFACE ${DRIVERS_SRC})
target_include_directories(McuDrivers INTERFACE libraries/drivers/inc)

target_sources(${PROJECT_NAME} PRIVATE
    src/at32f435_437_clock.c
    src/at32f435_437_int.c
    src/main.c)

target_include_directories(${PROJECT_NAME} PRIVATE
    inc)

target_link_libraries(${PROJECT_NAME} PRIVATE
    ARM::M4
    ARM::M4::Nano
    ARM::M4::NoSys
    CMSIS
    McuDrivers)
