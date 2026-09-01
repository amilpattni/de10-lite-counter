module counter #(
    parameter integer WIDTH = 4
)(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic tick,
    output logic [WIDTH-1:0] count
);

always_ff @(posedge clk) begin
    if (reset) begin
        count <= '0;
    end else if (enable && tick) begin
        count <= count + 1'b1;
    end
end

endmodule