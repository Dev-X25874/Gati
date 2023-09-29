`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Multiplier  
// Module Name: multiplier_18_des2
// Project Name: CNN Acceleration- GATI
// Description: It is a multiplier which multiplies two numbers. 
// Revision 1:  Sept 29, 2023 - Added feature: The valid data input was added 
//////////////////////////////////////////////////////////////////////////////////


module multiplier_18_des2(
  input clk,
  input [17:0]  dina,
  input [17:0]  dinb,
  output [36:0] dout,
  input         data_valid
);

  reg [35:0] rdout=0;
  reg        r_data_valid=0;
always @ (posedge clk) begin
  if (data_valid == 1) begin
    rdout <= dina * dinb;
    r_data_valid <= data_valid;
  end else begin
    rdout <= 0;
    r_data_valid <= 0;
  end 
end
  assign dout = {r_data_valid,rdout};
endmodule



















