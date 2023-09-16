`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2023 04:48:53 PM
// Design Name: 
// Module Name: single_port_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// This is an implementation of single port BRAM for storing the data that is written through the testbench

module single_port_memory(
  input              clk,
  input              wr_en, //write or read enable - (1--> write, 0--> read) 
  input              cs,    // chip select is like an enable signal, cs--> 0 then neither write nor read
  input [5:0]        addr, // address from the testbench
  input [7:0]        w_data,  //incoming write data from the testbench to be written to register
  output reg [7:0]   r_data=0 //output is the read data which should go to maxpooling 
   
);

  reg [7:0]          ram [63:0];
always @ (posedge clk) begin
  if (cs) begin
    if (wr_en == 1) begin //writing the data into the memory when wr_en--> 1 
      ram[addr] <= w_data; //data written into the memory
    end else if (wr_en == 0) begin 
      r_data <= ram[addr]; //reading the data that is written from the memory
    end
  end    
end   
endmodule   

    
