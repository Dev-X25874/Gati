/*
    Systolic array block along with the registers to provide delay 
    while sending data into rows of systolic array
*/
module systolic_array #(
    parameter ROW = 9, 
    parameter COL = 4, 
    parameter TOTAL_BYTES = ROW * COL,
    parameter W_DATA = 8,
    parameter W_PSUM = 19
)(  input in_clk,
    input i_rst,
    input [(COL * (W_DATA + 1)) - 1:0] in_north,  //8 bit weights 
    input [(ROW * (W_DATA + 1)) - 1:0] in_west,    //8 bit image 
    output [(ROW * (W_DATA + 1)) - 1:0] out_east,  //8 bit data output from the last column
    output [(COL * (W_PSUM + 1)) - 1:0] out_south    //partial sum output from last row
);

wire [(ROW * (W_DATA + 1)) - 1 : 0] data_to_be_passed;  //9 bits data output from registers (used for providing delay) going into rows of systolic array 

pe_grid#(
    .COL(COL),
    .ROW(ROW),
    .W_DATA(W_DATA),
    .W_PSUM(W_PSUM)
) sa(
    .i_clk(in_clk),
    .i_rst(i_rst),
    .i_weight(in_north),
    .in_data(data_to_be_passed),
    .o_partial_sum(out_south),
    .o_data(out_east)
);

delay_reg #(
    .ROW (ROW),
    .W_DATA(W_DATA)
) delay_reg_grid (
    .in_clk (in_clk),
    .i_rst(i_rst),
    .in_west (in_west) ,
    .data_to_be_passed (data_to_be_passed)
);

endmodule

//Registers to provide delay to image data going into rows of SA
module delay_reg #(
    parameter ROW = 9,
    parameter W_DATA = 8
)(  input in_clk,
    input i_rst,
    input [(ROW * (W_DATA + 1)) - 1 : 0] in_west,
    output [(ROW * (W_DATA + 1)) - 1 : 0] data_to_be_passed
);

//No delay is provided to the data going into first row of SA
assign data_to_be_passed [((W_DATA+1) * ROW)-1 :((W_DATA+1) * (ROW-1))] = in_west[((W_DATA+1) * ROW)-1 : ((W_DATA+1) * (ROW-1))];

genvar i , j;
    generate
    for (i = 0; i < ROW; i = i + 1) begin: FOR_ROW
        for (j = 0; j < i; j = j + 1) begin: FC_IN
        wire [W_DATA:0] data_out_reg;
            if (j == 0 && j == i - 1) begin
                data_reg#(
                    .W_DATA(W_DATA)
                )dr(
                    .clk(in_clk),
                    .rst(i_rst),
                    .o_data(data_to_be_passed[(ROW - i) * (W_DATA + 1) - 1 -: (W_DATA + 1)]),
                    .i_data(in_west[(ROW - i) * (W_DATA + 1) - 1 -: (W_DATA + 1)])
                );
            end else if (j == 0) begin
                data_reg#(
                    .W_DATA(W_DATA)
                )dr(
                    .clk(in_clk),
                    .rst(i_rst),
                    .o_data(data_out_reg),
                    .i_data(in_west[(ROW - i) * (W_DATA + 1) - 1 -: (W_DATA + 1)])
                );
            end else if (j == i - 1) begin
                data_reg#(
                    .W_DATA(W_DATA)
                )dr(
                    .clk(in_clk),
                    .rst(i_rst),
                    .o_data(data_to_be_passed[(ROW - i) * (W_DATA + 1) - 1 -: (W_DATA + 1)]),
                    .i_data(FOR_ROW[i].FC_IN[j-1].data_out_reg)
                );
            end else begin
                data_reg#(
                    .W_DATA(W_DATA)
                )dr(
                    .clk(in_clk),
                    .rst(i_rst),
                    .o_data(data_out_reg),
                    .i_data(FOR_ROW[i].FC_IN[j-1].data_out_reg)
                );
            end
        end
    end
endgenerate
endmodule    

//Delay is provided to the inputs of rows in systolic array by storing it into this register
module data_reg#(
    parameter W_DATA = 8
)(
    input clk, 
    input rst,
    input [W_DATA:0] i_data, 
    output reg [W_DATA:0] o_data= 0
); 
always @(posedge clk) begin
    if(rst)
        o_data <= 0;
    else
        o_data <= i_data; 
end 

endmodule
