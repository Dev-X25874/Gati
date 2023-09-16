`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2023 04:16:50 PM
// Design Name: 
// Module Name: tb_top_maxpool
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench of the top_maxpool module which gives the address, 
//              data and value of control signals like i_cs, i_write_en. i_flag 
//////////////////////////////////////////////////////////////////////////////////

module tb_top_maxpool();
  reg i_clk;
  reg i_write_en;
  reg i_cs;
  reg[5:0] i_addr;
  reg[7:0] i_data;
  reg i_flag;
  wire[7:0] o_data;
  integer i; 
  
top_maxpool dut(
  .i_clk(i_clk),
  .i_write_en(i_write_en),
  .i_cs(i_cs),
  .i_addr(i_addr),
  .i_data(i_data),
  .i_flag(i_flag),
  .o_data(o_data));
                 
initial begin
  i_write_en=0;
  i_clk=0;
  i_cs=0;
  i_data=0;
  i_flag=0;
  i_addr=0;
  i=0;
end
  always #5 i_clk = ~i_clk;
    initial begin  
      for(i=0; i<63; i=i+1) begin
        #10 i_data= i*1; 
         i_addr=i_addr+1'b1;          
         i_cs=1'b1; 
         i_flag=0;
         i_write_en=1;
      end 
         i_flag=1;
    end                 
endmodule

