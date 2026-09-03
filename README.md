# DE10-Lite FPGA Counter

A simple SystemVerilog counter for the Terasic DE10-Lite. It counts from `0` to `F` once per second and then returns to `0`.

## Controls

| Component | Function |
| --- | --- |
| `SW0` | Run or pause |
| `SW1` | Reset to `0` |
| `HEX0` | Hexadecimal count |
| `LEDR[3:0]` | Binary count |

## Test

Install Verilator, GNU Make, and a C++ compiler. Then run:

```bash
make test
```

## Program the board

1. Open `quartus/de10_lite_counter.qpf` in Quartus Prime Lite.
2. Compile the design.
3. Connect the board and open **Tools > Programmer**.
4. Select **USB-Blaster** and load `quartus/output_files/de10_lite_top.sof`.
5. Check **Program/Configure**, then click **Start**.
