module column_reg_gen#(
    parameter COL = 3
)(
    input i_clk,
    input i_data,
    output [COL-1:0] o_data
);

genvar i;
generate
    for(i = 0; i < COL; i = i + 1) begin : O_WREN_COL_FIFO_GEN
        
        wire data_out;
        
        if(i == 0) begin
            wren_register
            wren_reg (
                .i_clk (i_clk),
                .i_data (i_data),
                .o_data (data_out),
                .o_wren (o_data[i])
            );
        end

        else if(i < COL-1)begin
            wren_register
            wren_reg (
                .i_clk (i_clk),
                .i_data (O_WREN_COL_FIFO_GEN[i-1].data_out),
                .o_data (data_out),
                .o_wren (o_data[i])
            );
        end

        else begin
            wren_register
            wren_reg (
                .i_clk (i_clk),
                .i_data (O_WREN_COL_FIFO_GEN[i-1].data_out),
                .o_data (data_out),
                .o_wren (o_data[i])
            );
        end
    end
endgenerate

endmodule