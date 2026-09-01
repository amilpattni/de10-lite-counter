// Physical top-level module for the Terasic DE10-Lite board.

module de10_lite_top #(
    parameter integer CYCLES_PER_TICK = 50_000_000
) (
    input  logic       MAX10_CLK1_50,
    input  logic [9:0] SW,

    output logic [9:0] LEDR,
    output logic [7:0] HEX0,
    output logic [7:0] HEX1,
    output logic [7:0] HEX2,
    output logic [7:0] HEX3,
    output logic [7:0] HEX4,
    output logic [7:0] HEX5
);

logic enable_meta;
logic enable_sync;
logic reset_meta;
logic reset_sync;

logic [3:0] count;
logic [6:0] segments;

// Two-stage synchronizers for the asynchronous switches.
always_ff @(posedge MAX10_CLK1_50) begin
    enable_meta <= SW[0];
    enable_sync <= enable_meta;

    reset_meta <= SW[1];
    reset_sync <= reset_meta;
end

counter_system #(
    .CYCLES_PER_TICK(CYCLES_PER_TICK)
) counter_system_inst (
    .clk      (MAX10_CLK1_50),
    .reset    (reset_sync),
    .enable   (enable_sync),
    .count    (count),
    .segments (segments)
);

// Board-output mapping.
always_comb begin
    // HEX0[7] is the decimal point. A 1 turns it off.
    HEX0 = {1'b1, segments};

    // Disable all unused displays.
    HEX1 = 8'hFF;
    HEX2 = 8'hFF;
    HEX3 = 8'hFF;
    HEX4 = 8'hFF;
    HEX5 = 8'hFF;

    // Show the same count in binary on four red LEDs for debugging.
    LEDR = 10'b0;
    LEDR[3:0] = count;
end

endmodule