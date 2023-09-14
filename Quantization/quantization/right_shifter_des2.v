`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Right shifter  
// Module Name: right_shifter_des2
// Project Name: CNN Acceleration- GATI
// Description: It is a shifter which shifts the multiplied output eight times.  
//////////////////////////////////////////////////////////////////////////////////


module right_shifter_des2(
  input            clk,
  input [35:0]     din_mul,
  output [27:0]    dout_shifted
    );
    
  reg[27:0]        rdout_shifted;
  reg[34:0]        temp1=0;
  reg[33:0]        temp2=0;
  reg[32:0]        temp3=0;
  reg[31:0]        temp4=0;
  reg[30:0]        temp5=0;
  reg[29:0]        temp6=0;
  reg[28:0]        temp7=0;
  
    always @ (posedge clk) begin
      temp1 <= din_mul >> 1;
      temp2 <= temp1 >> 1;
      temp3 <= temp2 >> 1;
      temp4 <= temp3 >> 1;
      temp5 <= temp4 >> 1;
      temp6 <= temp5 >> 1;
      temp7 <= temp6 >> 1;
      rdout_shifted <= temp7 >> 1;
    end
      assign dout_shifted = rdout_shifted;
  endmodule

    
    