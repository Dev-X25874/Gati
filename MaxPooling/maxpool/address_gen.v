`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/31/2023 09:44:57 AM
// Design Name: Address Generator
// Module Name: address_gen
// Project Name: CNN Acceleration - GATI
// Description: This is an address generator which increments the address for reading the data written 
//              through the tesetbench 
//////////////////////////////////////////////////////////////////////////////////             



module address_gen(
  input             flag, //Controlled through the testbench
  output reg        ag_cs=0,
  output reg        ag_wr_en=0,
  output reg [5:0]  addr_gen=0,
  input             clk
);
  reg [5:0]         addr =0;
always @(posedge clk) begin
  if (flag==1) begin
    addr <= addr +1;
    addr_gen <= addr;
    ag_cs <= 1'b1;
    ag_wr_en <= 1'b0;
  end
end   
endmodule
