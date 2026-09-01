#include "Vcounter.h"
#include "verilated.h"

#include <iostream>

static void clock_cycle(Vcounter& dut)
{
    dut.clk = 0;
    dut.eval();

    dut.clk = 1;
    dut.eval();
}

static bool check_count(
    const Vcounter& dut,
    unsigned expected,
    const char* test_name)
{
    if (dut.count != expected) {
        std::cerr
            << "FAIL: " << test_name
            << " expected count=" << expected
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

    Vcounter dut;

    // Initialize all inputs.
    dut.clk = 0;
    dut.reset = 1;
    dut.enable = 0;
    dut.tick = 0;
    dut.eval();

    // Apply synchronous reset.
    clock_cycle(dut);

    if (!check_count(dut, 0, "reset")) {
        dut.final();
        return 1;
    }

    // Both enable and tick are high: increment to 1.
    dut.reset = 0;
    dut.enable = 1;
    dut.tick = 1;
    clock_cycle(dut);

    if (!check_count(dut, 1, "increment")) {
        dut.final();
        return 1;
    }

    // Enable is high, but tick is low: hold at 1.
    dut.tick = 0;
    clock_cycle(dut);

    if (!check_count(dut, 1, "tick low")) {
        dut.final();
        return 1;
    }

    // Tick is high, but enable is low: hold at 1.
    dut.enable = 0;
    dut.tick = 1;
    clock_cycle(dut);

    if (!check_count(dut, 1, "enable low")) {
        dut.final();
        return 1;
    }

    // Increment through 2, 3, and then wrap to 0.
    dut.enable = 1;

    clock_cycle(dut);

    if (!check_count(dut, 2, "increment to 2")) {
        dut.final();
        return 1;
    }

    clock_cycle(dut);

    if (!check_count(dut, 3, "increment to 3")) {
        dut.final();
        return 1;
    }

    clock_cycle(dut);

    if (!check_count(dut, 0, "wraparound")) {
        dut.final();
        return 1;
    }

    // Reset must win even when enable and tick are high.
    dut.reset = 1;
    clock_cycle(dut);

    if (!check_count(dut, 0, "reset priority")) {
        dut.final();
        return 1;
    }

    dut.final();

    std::cout << "PASS: counter tests completed successfully.\n";

    return 0;
}