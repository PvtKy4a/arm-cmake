arm_util_create_family_target(M0)

target_compile_options(ARM::M0 INTERFACE 
    -mcpu=cortex-m0
)
target_link_options(ARM::M0 INTERFACE 
    -mcpu=cortex-m0
)
