_arm_create_core_target(M7)

target_compile_options(ARM::M7 INTERFACE 
    -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=hard
)
target_link_options(ARM::M7 INTERFACE 
    -mcpu=cortex-m7 -mfpu=fpv5-sp-d16 -mfloat-abi=hard
)
