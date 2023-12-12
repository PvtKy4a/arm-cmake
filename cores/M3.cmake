arm_util_create_family_target(M3)

target_compile_options(ARM::M3 INTERFACE 
    -mcpu=cortex-m3 -mthumb
)
target_link_options(ARM::M3 INTERFACE 
    -mcpu=cortex-m3 -mthumb
)
