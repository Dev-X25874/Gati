`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Testebench for the ReLU  
// Module Name: tb_relu_0
// Project Name: CNN Acceleration. 
// Description: The below ReLU block replaces all negative values received as inputs by zeros. 



module tb_relu_0();
  reg [31:0]   i_data;
  reg          clk;
  wire [31:0]  o_data;
  integer      i;
  
relu_0 dut(
  .clk         (clk),
  .i_data      (i_data),
  .o_data      (o_data)
);
initial begin
  clk    = 0;
  i_data = 32'd0;
end
  
  always #5 clk = ~clk;
  
    initial begin
      for(i=0; i<65535; i=i+1)
        #10 i_data = i * 1;
    end
    
endmodule


