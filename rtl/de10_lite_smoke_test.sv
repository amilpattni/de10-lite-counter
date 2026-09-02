// Minimal DE10-Lite output and pin-assignment test.

module de10_lite_smoke_test (
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

always_comb begin
    // Illuminate only LEDR0.
    LEDR = 10'b0000000001;

    // Display zero on HEX0 with its decimal point off.
    HEX0 = 8'b11000000;

    // Turn off every other display.
    HEX1 = 8'hFF;
    HEX2 = 8'hFF;
    HEX3 = 8'hFF;
    HEX4 = 8'hFF;
    HEX5 = 8'hFF;
end

endmodule
