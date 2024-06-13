_arm_create_core_target(M3)

target_compile_options(ARM::M3 INTERFACE 
    -mcpu=cortex-m3
)
target_link_options(ARM::M3 INTERFACE 
    -mcpu=cortex-m3
)
