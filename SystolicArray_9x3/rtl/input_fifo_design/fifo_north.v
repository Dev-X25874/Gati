/*
    Store weights column-wise into array of fifo, such that, 
    all the column's weights in systolic array gets loaded simultaneously
    from this array of fifo.
*/
module fifo_north#(
    parameter W_DATA = 8, 
    parameter W_ADDR = 10, 
    parameter RAM_DEPTH = 1 << W_ADDR,
    parameter ROW = 9,
    parameter COL = 3
)(
    input i_clk, 
    input [COL-1:0] we,
    input [COL-1:0]i_north_rden,
    input [W_DATA - 1 : 0] i_data,
    output [W_DATA - 1: 0] o_data1,
    output [W_DATA-1 :0] o_data2,
    output [W_DATA-1:0] o_data3,
    output [COL - 1 :0] o_north_empty,
    output [COL - 1 : 0] o_north_full,
    output o_dv1,
    output o_dv2,
    output o_dv3
);

wire [W_ADDR : 0] o_occupants1; 
wire [W_ADDR : 0] o_occupants2;
wire [W_ADDR : 0] o_occupants3; 

wire o_empty1; 
wire o_empty2; 
wire o_empty3; 

wire o_full1; 
wire o_full2; 
wire o_full3;  
wire o_we;   

assign o_north_empty = {o_empty1, o_empty2, o_empty3};
assign o_north_full = {o_full1, o_full2, o_full3};

genvar j; 
generate 
    for(j = 0; j < COL; j = j + 1) begin : FOR_COL

        if(j == 0) begin 
            fifo_valid #(
                .DATA_WIDTH(W_DATA),
                .ADDR_WIDTH(W_ADDR),
                .RAM_DEPTH(RAM_DEPTH)
            ) data_fifo (
                .clk (i_clk),
                .rst_n (1'b1) ,
                .data_in (i_data),
                .we (we[0]),
                .re (i_north_rden[0]),
                .data_out (o_data1),
                .occupants (o_occupants1),
                .empty (o_empty1),
                .full (o_full1),
                .data_valid(o_dv1)
            );  
            
        end else if(j == COL-1) begin
        
        fifo_valid #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[2]),
            .re (i_north_rden[2]),
            .data_out (o_data3),
            .occupants (o_occupants3),
            .empty (o_empty3),
            .full (o_full3),
            .data_valid(o_dv3)
        );  
        
        end else begin
        
        fifo_valid #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[1]),
            .re (i_north_rden[1]),
            .data_out (o_data2),
            .occupants (o_occupants2),
            .empty (o_empty2),
            .full (o_full2),
            .data_valid(o_dv2)
        );  
        end
    end 
endgenerate    

endmodule