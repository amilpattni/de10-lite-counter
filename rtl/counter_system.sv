// Connects the tick generator, counter, and seven-segment decoder.

module counter_system #(
    parameter integer CYCLES_PER_TICK = 50_000_000
) (
    input logic clk,
    input logic reset,
    input logic enable,
    output logic [3:0] count,
    output logic [6:0] segments
);

logic tick;

tick_generator #(
    .CYCLES_PER_TICK(CYCLES_PER_TICK)
) tick_generator_inst (
    .clk (clk),
    .reset (reset),
    .tick (tick)
);

counter #(
    .WIDTH(4)
) counter_inst (
    .clk (clk),
    .reset (reset),
    .enable (enable),
    .tick (tick),
    .count (count)
);

seven_segment_decoder decoder_inst (
    .value (count),
    .segments (segments)
);

endmodule