#include "Vseven_segment_decoder.h"
#include "verilated.h"

#include <array>
#include <iostream>

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vseven_segment_decoder dut;

    const std::array<unsigned, 16> expected_segments = {
        0b1000000, // 0
        0b1111001, // 1
        0b0100100, // 2
        0b0110000, // 3
        0b0011001, // 4
        0b0010010, // 5
        0b0000010, // 6
        0b1111000, // 7
        0b0000000, // 8
        0b0010000, // 9
        0b0001000, // A
        0b0000011, // B
        0b1000110, // C
        0b0100001, // D
        0b0000110, // E
        0b0001110  // F
    };

    for (unsigned value = 0; value < 16; ++value) {
        dut.value = value;
        dut.eval();

        if (dut.segments != expected_segments[value]) {
            std::cerr
                << "FAIL for hexadecimal value 0x"
                << std::hex << value
                << ": expected segments=0b"
                << expected_segments[value]
                << ", received="
                << static_cast<unsigned>(dut.segments)
                << '\n';

            dut.final();
            return 1;
        }
    }

    dut.final();

    std::cout
        << "PASS: all hexadecimal decoder patterns are correct.\n";

    return 0;
}