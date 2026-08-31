#include "Vtick_generator.h"
#include "verilated.h"

#include <iostream>

static void clock_cycle(Vtick_generator& dut)
{
    dut.clk = 0;
    dut.eval();

    dut.clk = 1;
    dut.eval();
}

static bool check_tick(
    const Vtick_generator& dut,
    int expected,
    int cycle)
{
    if (dut.tick != expected) {
        std::cerr
            << "FAIL at cycle " << cycle
            << ": expected tick=" << expected
            << ", received tick=" << static_cast<int>(dut.tick)
            << '\n';

        return false;
    }

    return true;
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vtick_generator dut;

    // Establish known initial inputs.
    dut.clk = 0;
    dut.reset = 1;
    dut.eval();

    // Apply the synchronous reset on a rising edge.
    clock_cycle(dut);

    if (!check_tick(dut, 0, 0)) {
        dut.final();
        return 1;
    }

    // Release reset and test two complete four-cycle periods.
    dut.reset = 0;

    for (int cycle = 1; cycle <= 8; ++cycle) {
        clock_cycle(dut);

        const int expected_tick =
            (cycle % 4 == 0) ? 1 : 0;

        if (!check_tick(dut, expected_tick, cycle)) {
            dut.final();
            return 1;
        }
    }

    // Reset partway through operation.
    dut.reset = 1;
    clock_cycle(dut);

    if (!check_tick(dut, 0, 9)) {
        dut.final();
        return 1;
    }

    // The next tick should occur four cycles after reset.
    dut.reset = 0;

    for (int cycle = 1; cycle <= 4; ++cycle) {
        clock_cycle(dut);

        const int expected_tick =
            (cycle == 4) ? 1 : 0;

        if (!check_tick(dut, expected_tick, cycle)) {
            dut.final();
            return 1;
        }
    }

    dut.final();

    std::cout
        << "PASS: tick_generator produced a one-cycle tick "
        << "every four clock cycles.\n";

    return 0;
}