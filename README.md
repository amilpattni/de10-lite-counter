## DE10-Lite FPGA Counter

A modular SystemVerilog counter built for the Terasic DE10-Lite FPGA board. It counts from `0` to `F` once per second, displays the hexadecimal value on `HEX0`, and shows the same value in binary on `LEDR[3:0]`.

## How it works

The design is divided into RTL modules:

- `tick_generator` converts the 50 MHz board clock into a one-cycle tick every second.
- `counter` is a 4-bit synchronous counter with reset priority. It increments when both `enable` and `tick` are high, and its natural overflow rolls `F` back to `0`.
- `seven_segment_decoder` converts the 4-bit count into the active-low signals required by the display.
- `counter_system` connects the tick generator, counter, and decoder.
- `de10_lite_top` passes the switches through two-stage synchronizers, then connects the design to the physical LEDs and displays.

## Board interface

| Component | Function |
| --- | --- |
| `SW0` | Enables or pauses counting |
| `SW1` | Resets the count to `0` |
| `HEX0` | Displays the hexadecimal count |
| `LEDR[3:0]` | Displays the binary count |

Unused LEDs and seven-segment displays are turned off.

## Verification

Each module has a C++ testbench run with Verilator. The Makefile performs RTL linting, individual module tests, and an integrated system test with `make test`.

The `quartus/` directory contains the DE10-Lite project, physical pin assignments, and 50 MHz timing constraint.


<img width="1470" height="1475" alt="image" src="https://github.com/user-attachments/assets/dd5a8058-3d1e-4971-a8e4-0d68ac903f87" />

<img width="1563" height="1460" alt="image" src="https://github.com/user-attachments/assets/26c5f410-f606-41ea-a5c5-ac9c7c601003" />

