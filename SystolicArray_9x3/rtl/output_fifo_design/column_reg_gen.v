/*
    Array of register for storing and handling write enable signal of fifo array 
    that stores 32 bit output of systolic array
*/
module column_reg_gen#(
    parameter COL = 3
)(
    input i_clk,
    input i_data,
    output [COL-1:0] o_data
);

genvar i;
generate
    for(i = 0; i < COL; i = i +1)begin : O_WREN_COL_FIFO
        wire data_out;
        wire delay_data;
        
        if(i == 0) begin
        wren_register
        wren_reg (
            .i_clk (i_clk),
            .i_data (i_data),
            .o_data (data_out),
            .o_wren (o_data[2])
        );
        end
        
       else if(i ==1) begin
            wren_register
            wren_reg (
                .i_clk (i_clk),
                .i_data(O_WREN_COL_FIFO[i-1].data_out),
                .o_data (data_out),
                .o_wren (o_data[1])
            );
            
       end
       
       else if(i == 2)begin
            wren_register
            wren_reg (
                .i_clk (i_clk),
                .i_data (O_WREN_COL_FIFO[i-1].data_out),
                .o_data (data_out),
                .o_wren (o_data[0])
            );                
       end
    end
endgenerate

endmodule