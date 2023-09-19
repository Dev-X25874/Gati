/*
    Array of fifo that stores output of array of relu block
    in parallel fashion
*/
module o_col_fifo_array#(
    parameter ROW = 9,
    parameter COL = 3,
    parameter W_DATA = 8
)(  input i_clk,
    input [W_DATA-1:0] i_data1,
    input [W_DATA-1:0] i_data2,
    input [W_DATA-1:0] i_data3,
    input [COL-1:0] i_read_enable,
    input [COL-1:0] i_write_enable,
    output [W_DATA-1:0] o_data_1,
    output [W_DATA-1:0] o_data_2,
    output [W_DATA-1:0] o_data_3,
    output [COL-1:0] o_empty,
    output dv1,
    output dv2,
    output dv3
);

    wire empty1;
    wire empty2;
    wire empty3;
    
    assign o_empty = {empty1, empty2, empty3};

     genvar i;
     generate
        for(i = 0 ; i < ROW; i = i +1)begin : ROW_DATA_OUT        
            if(i == 0) begin
                fifo_valid 
                fifo_inst (
                    .clk (i_clk),
                    .rst_n (1'b1),
                    .data_in (i_data1),
                    .we(i_write_enable[2]),
                    .re(i_read_enable[2]),
                    .data_out(o_data_1),
                    .occupants(),
                    .empty(empty1),
                    .full(),
                    .data_valid(dv1)
                );
            end
            
            else if(i == 1) begin
                fifo_valid 
                fifo_inst (
                    .clk (i_clk),
                    .rst_n (1'b1),
                    .data_in (i_data2),
                    .we(i_write_enable[1]),
                    .re(i_read_enable[1]),
                    .data_out(o_data_2),
                    .occupants(),
                    .empty(empty2),
                    .full(),
                    .data_valid(dv2)
                );                
            end
            
            else if(i == 2) begin
                fifo_valid 
                fifo_inst (
                    .clk (i_clk),
                    .rst_n (1'b1),
                    .data_in (i_data3),
                    .we(i_write_enable[0]),
                    .re(i_read_enable[0]),
                    .data_out(o_data_3),
                    .occupants(),
                    .empty(empty3),
                    .full(),
                    .data_valid(dv3)
                );            
            end
        end       
     endgenerate
endmodule