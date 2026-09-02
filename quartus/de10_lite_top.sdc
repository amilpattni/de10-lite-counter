# DE10-Lite 50 MHz clock
# 50 MHz corresponds to a 20 ns period.

create_clock \
    -name MAX10_CLK1_50 \
    -period 20.000 \
    [get_ports {MAX10_CLK1_50}]

# The slide switches are asynchronous human-controlled inputs.
# Their first synchronizer stages intentionally accept asynchronous timing.
set_false_path -from [get_ports {SW[*]}]

# LEDs and seven-segment displays are human-visible outputs.
# They do not communicate with an external synchronous device.
set_false_path -to [get_ports {
    LEDR[*]
    HEX0[*]
    HEX1[*]
    HEX2[*]
    HEX3[*]
    HEX4[*]
    HEX5[*]
}]

derive_clock_uncertainty
