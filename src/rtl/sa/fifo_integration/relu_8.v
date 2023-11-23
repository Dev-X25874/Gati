`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Implementation of ReLU  
// Module Name: relu_8
// Project Name: CNN Acceleration. 
// Description: ReLU8: ReLU8 is a further variant that clips the output at 8 instead of 6. 
//              It operates similarly to ReLU6 but with a different clipping threshold.


module relu_8 #(
    parameter COL = 3,
    parameter W_DATA = 8
)(
    input[31:0]   i_data, // Input to the Relu from previous layer which is a unsigned number
    input         clk,
    output[W_DATA-1 : 0]   o_data, //Output of the Relu
    input [COL-1 : 0] i_data_valid,
    output [COL-1 : 0] o_data_valid
);

reg[7:0]      out_reg = 0;  //Internal reg to latch the output
reg [COL-1 : 0] dv = 0;

assign o_data_valid = dv;
assign o_data = out_reg;

always @(posedge clk)begin
    dv <= i_data_valid;
end


always @(posedge clk) begin
    if (i_data[31] == 1)
        out_reg <= 0;
    else if ((i_data > 0) && (i_data <= 3000))
        out_reg <= i_data;
    else if ( i_data > 3000)
        out_reg <= 3000;
end

endmodule
