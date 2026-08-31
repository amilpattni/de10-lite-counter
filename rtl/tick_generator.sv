// Generates a one-clock-cycle tick every CYCLES_PER_TICK input clock cycles

module tick_generator #(
    parameter integer CYCLES_PER_TICK = 50000000
)(
    input logic clk,
    input logic reset,
    output logic tick
);

localparam integer COUNT_WIDTH = $clog2(CYCLES_PER_TICK);
logic [COUNT_WIDTH-1:0] clk_count;
localparam logic [COUNT_WIDTH-1:0] TERMINAL_COUNT = COUNT_WIDTH'(CYCLES_PER_TICK - 1);

always_ff @(posedge clk) begin
    if (reset) begin
        clk_count <= 0;
        tick <= 0;
    end else if (clk_count == TERMINAL_COUNT) begin
        clk_count <= 0;
        tick <= 1;
    end else begin
        clk_count <= clk_count + 1;
        tick <= 0;
    end
end

endmodule