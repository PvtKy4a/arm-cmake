cmake_minimum_required(VERSION 3.22)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/arm-cmake/arm-gcc-toolchain.cmake)

get_filename_component(FOLDER_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

project(${FOLDER_NAME} LANGUAGES C ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

add_executable(${PROJECT_NAME})

arm_add_linker_script(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/STM32F051R8Tx_FLASH.ld)

arm_generate_bin_file(${PROJECT_NAME})
arm_generate_hex_file(${PROJECT_NAME})

target_compile_definitions(${PROJECT_NAME} PRIVATE
    -DUSE_HAL_DRIVER
    -DSTM32F051x8)

add_library(CMSIS INTERFACE)
target_sources(CMSIS INTERFACE
    Drivers/CMSIS/Device/ST/STM32F0xx/Source/Templates/system_stm32f0xx.c
    Drivers/CMSIS/Device/ST/STM32F0xx/Source/Templates/gcc/startup_stm32f051x8.s)
target_include_directories(CMSIS INTERFACE
    Drivers/CMSIS/Device/ST/STM32F0xx/Include
    Drivers/CMSIS/Include)

add_library(HAL INTERFACE)
target_sources(HAL INTERFACE
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_tim.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_tim_ex.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_rcc.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_rcc_ex.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_i2c.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_i2c_ex.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_gpio.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_dma.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_cortex.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_pwr.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_pwr_ex.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_flash.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_flash_ex.c
    Drivers/STM32F0xx_HAL_Driver/Src/stm32f0xx_hal_exti.c)
target_include_directories(HAL INTERFACE
    Drivers/STM32F0xx_HAL_Driver/Inc
    Drivers/STM32F0xx_HAL_Driver/Inc/Legacy)

add_subdirectory(Core)

target_link_libraries(${PROJECT_NAME} PRIVATE
    ARM::M0
    ARM::M0::Nano
    #ARM::M0::NoSys
    ARM::M0::SysCalls
    CMSIS
    HAL)
