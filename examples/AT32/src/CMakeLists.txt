cmake_minimum_required(VERSION 3.27)

target_sources(${PROJECT_NAME}
    PRIVATE
        at32f435_437_clock.c
        at32f435_437_int.c
        main.c
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR})
