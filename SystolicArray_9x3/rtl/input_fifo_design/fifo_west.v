/*
    Store data row-wise into array of fifo, such that, 
    all the row's data in systolic array gets loaded simultaneously
    from this array of fifo.
*/
module fifo_west#(
    parameter W_DATA = 8, 
    parameter W_ADDR = 8, 
    parameter RAM_DEPTH = 1 << W_ADDR,
    parameter ROW = 9,
    parameter COL = 3
)(
    input i_clk, 
    input [ROW-1:0] we,
    input [ROW-1:0] i_west_rden,
    input [W_DATA - 1 : 0] i_data,
    output [W_DATA - 1: 0] o_data1,
    output [W_DATA-1 :0] o_data2,
    output [W_DATA-1:0] o_data3,
    output [W_DATA-1:0] o_data4,
    output [W_DATA-1:0] o_data5,
    output [W_DATA-1:0] o_data6,
    output [W_DATA-1:0] o_data7,
    output [W_DATA-1:0] o_data8,
    output [W_DATA-1:0] o_data9,
    output [ROW - 1 : 0] o_west_empty, 
    output [ROW - 1 : 0] o_west_full,
    output o_dv1,
    output o_dv2,
    output o_dv3,
    output o_dv4,
    output o_dv5,
    output o_dv6,
    output o_dv7,
    output o_dv8,
    output o_dv9
);
    
wire [W_ADDR : 0] o_occupants1; 
wire [W_ADDR : 0] o_occupants2;
wire [W_ADDR : 0] o_occupants3;
wire [W_ADDR : 0] o_occupants4; 
wire [W_ADDR : 0] o_occupants5;
wire [W_ADDR : 0] o_occupants6;
wire [W_ADDR : 0] o_occupants7; 
wire [W_ADDR : 0] o_occupants8;
wire [W_ADDR : 0] o_occupants9;

wire o_empty1; 
wire o_empty2; 
wire o_empty3; 
wire o_empty4; 
wire o_empty5; 
wire o_empty6;
wire o_empty7; 
wire o_empty8; 
wire o_empty9;

wire o_full1; 
wire o_full2; 
wire o_full3;
wire o_full4; 
wire o_full5; 
wire o_full6; 
wire o_full7; 
wire o_full8; 
wire o_full9;


assign o_west_empty = {o_empty1, o_empty2, o_empty3, o_empty4, o_empty5, o_empty6, o_empty7, o_empty8, o_empty9};
assign o_west_full = {o_full1, o_full2, o_full3, o_full4, o_full5, o_full6, o_full7, o_full8, o_full9}; 

genvar i; 
generate 
    for(i = 0; i < ROW; i = i + 1) begin : FOR_ROW
        if(i == 0) begin
            fifo_valid #(
                .DATA_WIDTH(W_DATA),
                .ADDR_WIDTH(W_ADDR),
                .RAM_DEPTH(RAM_DEPTH)
            ) valid_reg (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data),
                .we (we[0]),
                .re (i_west_rden[0]),
                .data_out (o_data1),
                .occupants (o_occupants1),
                .empty (o_empty1),
                .full (o_full1),
                .data_valid (o_dv1)
            );
        end 

        else if(i == 8) begin 
        fifo_valid  #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[8]),
            .re (i_west_rden[8]),
            .data_out (o_data9),
            .occupants (o_occupants9),
            .empty (o_empty9),
            .full (o_full9),
            .data_valid (o_dv9)
        );  
        end 

        else if(i == 1)  begin 
        fifo_valid  #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[1]),
            .re (i_west_rden[1]),
            .data_out (o_data2),
            .occupants (o_occupants2),
            .empty (o_empty2),
            .full (o_full2),
            .data_valid (o_dv2)
        );  
        end 

        else if(i == 2)  begin 
        fifo_valid  #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[2]),
            .re (i_west_rden[2]),
            .data_out (o_data3),
            .occupants (o_occupants3),
            .empty (o_empty3),
            .full (o_full3),
            .data_valid (o_dv3)
        );  
        end 

        else if(i == 3)  begin 
        fifo_valid  #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[3]),
            .re (i_west_rden[3]),
            .data_out (o_data4),
            .occupants (o_occupants4),
            .empty (o_empty4),
            .full (o_full4),
            .data_valid (o_dv4)
        );  
        end

        else if(i == 4)  begin 
        fifo_valid #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[4]),
            .re (i_west_rden[4]),
            .data_out (o_data5),
            .occupants (o_occupants5),
            .empty (o_empty5),
            .full (o_full5),
            .data_valid (o_dv5)
        );  
        end        

        else if(i == 5)  begin 
        fifo_valid #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[5]),
            .re (i_west_rden[5]),
            .data_out (o_data6),
            .occupants (o_occupants6),
            .empty (o_empty6),
            .full (o_full6),
            .data_valid (o_dv6)
        );  
        end  

        else if(i == 6)  begin 
        fifo_valid #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[6]),
            .re (i_west_rden[6]),
            .data_out (o_data7),
            .occupants (o_occupants7),
            .empty (o_empty7),
            .full (o_full7),
            .data_valid (o_dv7)
        );  
        end           

        else if(i == 7)  begin 
        fifo_valid #(
            .DATA_WIDTH(W_DATA),
            .ADDR_WIDTH(W_ADDR),
            .RAM_DEPTH(RAM_DEPTH)
        ) data_fifo (
            .clk (i_clk),
            .rst_n (1'b1) ,
            .data_in (i_data),
            .we (we[7]),
            .re (i_west_rden[7]),
            .data_out (o_data8),
            .occupants (o_occupants8),
            .empty (o_empty8),
            .full (o_full8),
            .data_valid (o_dv8)
        );  
        end         
    end 
endgenerate    

endmodule