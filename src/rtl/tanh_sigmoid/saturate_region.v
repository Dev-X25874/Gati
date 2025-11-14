module saturate_region#(
    parameter DATA_WIDTH = 24
)
(
    input i_clk,
    input i_rst,

    input i_saturate,
    output reg [DATA_WIDTH-1 : 0] o_saturate_data,
    output reg o_saturate_data_valid
);

    always @(posedge i_clk) begin
        if (!i_rst) begin
            o_saturate_data <= 'h0;
            o_saturate_data_valid <= 1'b0;
        end else if (i_saturate) begin
            o_saturate_data <= 24'h 01_00_00; // Saturate to maximum value 1.0
            o_saturate_data_valid <= 1'b1;
        end else begin
            o_saturate_data_valid <= 1'b0;
        end
    end
    
endmodule
