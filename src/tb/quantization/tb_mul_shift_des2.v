`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2023 06:33:37 PM
// Design Name: 
// Module Name: tb_mul_shift_des2
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


module tb_mul_shift_des2();
reg i_clk=0;
reg[17:0] i_dina;
reg[17:0] i_dinb;
wire[27:0] o_dout;
integer i;
top_mul_shift_des2 
dut(
.i_clk(i_clk),
.i_dina(i_dina),
.i_dinb(i_dinb),
.o_dout(o_dout));

initial begin
    i_dina=18'b0;
    i_dinb=18'b0;
end

always #5 i_clk=~i_clk;

initial begin
    for(i=0;i<262143;i=i+1) begin
    #10 i_dina= i;
        i_dinb= 18'd10;

    end   
   end   
endmodule  
        

