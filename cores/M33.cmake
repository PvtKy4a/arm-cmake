_arm_create_core_target(M33)

target_compile_options(ARM::M33 INTERFACE 
    -mcpu=cortex-m33 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
)
target_link_options(ARM::M33 INTERFACE 
    -mcpu=cortex-m33 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
)
