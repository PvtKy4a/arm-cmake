unset(CMAKE_ASM_FLAGS_DEBUG CACHE)
unset(CMAKE_ASM_FLAGS_RELEASE CACHE)
set(CMAKE_ASM_FLAGS_RELEASE "-DNDEBUG")

unset(CMAKE_CXX_FLAGS_DEBUG CACHE)
unset(CMAKE_CXX_FLAGS_RELEASE CACHE)
set(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG")

unset(CMAKE_C_FLAGS_DEBUG CACHE)
unset(CMAKE_C_FLAGS_RELEASE CACHE)
set(CMAKE_C_FLAGS_RELEASE "-DNDEBUG")
