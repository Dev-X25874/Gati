`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Right shifter  
// Module Name: right_shifter_des2
// Project Name: CNN Acceleration- GATI
// Description: It is a shifter which shifts the multiplied output eight times.
// Revision 1: Sept 29, 2023 - Added feature - The design was parametrised and
//             the valid data was added.   
//////////////////////////////////////////////////////////////////////////////////


module right_shifter_des2(
  input            clk,
  input [35:0]     din_mul,
  output[36:0]     dout_shifted,
  input            data_valid
    );
    reg r_data_valid;
    reg [35:0] r_dout_shifted=36'd0;
    
    always @ (posedge clk) begin
      if(data_valid ==1) begin
        r_data_valid <= data_valid;
        r_dout_shifted <=  din_mul >> 1;
      end else begin
        r_data_valid <= 0;
        r_dout_shifted <= 0;
      end
    end
    assign dout_shifted = {r_data_valid,r_dout_shifted};
  endmodule

module top_right_shifter#(parameter n_shift=8,
                          parameter width = 36)(
  input[width-1:0]   din_mul_top,
  output[width-1:0]  dout_shifted_top,
  input clk 
);
genvar i;
  generate 
    for(i = 0; i < n_shift; i = i + 1) begin : RIGHT_SHIFT
     wire[35:0]  w_out; 
      
      if(i == 0) 
        right_shifter_des2 right_shift(.clk(clk),.din_mul(din_mul_top),
                                     .dout_shifted(w_out));
      else if(i == n_shift - 1)
        right_shifter_des2 right_shift(.clk(clk),.din_mul(RIGHT_SHIFT[i-1].w_out),
                                     .dout_shifted(dout_shifted_top));
      else
        right_shifter_des2 right_shift(.clk(clk),.din_mul(RIGHT_SHIFT[i-1].w_out),
                                     .dout_shifted(w_out));
    end
  endgenerate 
endmodule   
  
