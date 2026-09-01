#include "Vcounter_system.h"
#include "verilated.h"

#include <array>
#include <iostream>

static const std::array<unsigned, 16> SEGMENTS = {
    0b1000000, 0b1111001, 0b0100100, 0b0110000,
    0b0011001, 0b0010010, 0b0000010, 0b1111000,
    0b0000000, 0b0010000, 0b0001000, 0b0000011,
    0b1000110, 0b0100001, 0b0000110, 0b0001110
};

static void clock_cycle(Vcounter_system& dut)
{
    dut.clk = 0;
    dut.eval();

    dut.clk = 1;
    dut.eval();
}

static void run_cycles(Vcounter_system& dut, int cycles)
{
    for (int cycle = 0; cycle < cycles; ++cycle) {
        clock_cycle(dut);
    }
}

static bool check_outputs(
    const Vcounter_system& dut,
    unsigned expected_count,
    const char* test_name)
{
    const unsigned expected_segments = SEGMENTS[expected_count];

    if (dut.count != expected_count ||
        dut.segments != expected_segments) {

        std::cerr
            << "FAIL: " << test_name
            << " expected count=" << expected_count
            << ", received count="
            << static_cast<unsigned>(dut.count)
            << '\n';

        return false;
    }

    return true;
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vcounter_system dut;

    dut.clk = 0;
    dut.reset = 1;
    dut.enable = 0;
    dut.eval();

    // Apply synchronous reset.
    clock_cycle(dut);

    if (!check_outputs(dut, 0, "reset")) {
        dut.final();
        return 1;
    }

    dut.reset = 0;
    dut.enable = 1;

    // The registered tick appears after four cycles.
    run_cycles(dut, 4);

    if (!check_outputs(dut, 0, "before first tick is consumed")) {
        dut.final();
        return 1;
    }

    // The counter consumes the registered tick on the next edge.
    run_cycles(dut, 1);

    if (!check_outputs(dut, 1, "first increment")) {
        dut.final();
        return 1;
    }

    // Subsequent increments occur every four cycles.
    run_cycles(dut, 4);

    if (!check_outputs(dut, 2, "second increment")) {
        dut.final();
        return 1;
    }

    // Disable counting while the tick generator continues running.
    dut.enable = 0;
    run_cycles(dut, 8);

    if (!check_outputs(dut, 2, "disabled hold")) {
        dut.final();
        return 1;
    }

    // Re-enable and confirm counting resumes.
    dut.enable = 1;
    run_cycles(dut, 4);

    if (!check_outputs(dut, 3, "re-enabled increment")) {
        dut.final();
        return 1;
    }

    // Reset the complete system.
    dut.reset = 1;
    clock_cycle(dut);

    if (!check_outputs(dut, 0, "system reset")) {
        dut.final();
        return 1;
    }

    dut.final();

    std::cout << "PASS: integrated counter system works correctly.\n";

    return 0;
}