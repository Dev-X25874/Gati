module pass_region#(
    parameter DATA_WIDTH = 24
)
(
    input i_clk,
    input i_rst,

    input i_pass_region,
    input i_data_valid,
    
    output reg o_data_valid
);

    always @(posedge i_clk) begin
        if (!i_rst) o_data_valid <= 1'b0;
        else begin
            if (i_data_valid & i_pass_region) o_data_valid <= 1'b1;
            else o_data_valid <= 1'b0;
        end
    end

endmodule