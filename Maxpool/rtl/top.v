`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 16:56:15
// Design Name: top module
// Module Name: top
// Project Name: maxpool
// Target Devices: 
// Tool Versions: 
// Description: This design implements a multi-stage processing pipeline for max-pooling operations. The process begins with Counter1, which toggles the select line of Demux1 at every positive clock edge. Demux1 takes 1-byte inputs and sequentially assigns them to its outputs. These outputs are then processed by the Maxpool module, which compares the two values and outputs the maximum., 
//Counter2 toggles the select line of Demux2 after the final element of a matrix column,each element is of 1 byte, has been received. Demux2 directs the incoming data to either FIFO1 or FIFO2, using the select line. These FIFOs have memory blocks, storing batches of elements in each matrix column (the size of a matrix column can be varied). The outputs of FIFO1 and FIFO2 are then fed into a second Maxpool module, which performs max-pooling on the 1-byte data from each FIFO, producing the maximum of the two values as the final output.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module top_gen#(
    parameter N = 32
)(
input i_clk,
input [(N * 8)-1 : 0] i_data,
input i_rst,
input [N-1 : 0] i_dv,
output [(N * 8)-1 : 0] o_data,
output [N-1 : 0] o_dv
);

genvar i;
generate
for(i = 0; i < N; i = i + 1)begin
top dut_module(
  .clk(i_clk),
  .data_in(i_data[((N -i)*8)-1 -: 8]),
  .rst(i_rst),
  .datavalid(i_dv[i]),
  .maxvalue_o(o_data[((N-i)*8)-1 -: 8]),
  .datavalid_o(o_dv[i])
);
end
endgenerate

endmodule

module top(
  input clk,
  input [7:0] data_in,
  input rst,
  input datavalid,
  input [7:0] dynamic_threshold,
  output [7:0] maxvalue_o,
  output datavalid_o
    );
    
    
  wire re;    
  wire [8:0] demux1_o1;
  wire [8:0] demux1_o2;
  wire [8:0] maxpool_o;
  wire [8:0] demux2_o1;
  wire [8:0] demux2_o2;
  wire ne;
  wire [7:0] fifo1_out;
  wire [7:0] fifo2_out;
  wire selectline1;
  wire selectline2;
  wire data_valid1;
  wire data_valid2;
  wire [8:0] maxvalue;

counter1 c1(
.clk(clk),
.rst(rst),
.sel(selectline1)
);
      
demux1 dut0(
.clk(clk),
.din(data_in),
.sel(selectline1),
.datavalid(datavalid),
.a(),
.b(demux1_o2),
.c(demux1_o1)
);

maxpool dut1(
.clk(clk),
.datavalid(demux1_o1[8]), 
.dina(demux1_o1[7:0]),
.dinb(demux1_o2[7:0]),
.temp(maxpool_o)
);

counter2 c2(
.clk(clk),
.rst(rst),
.datavalid(maxpool_o[8]),
.sel(selectline2),
.dynamic_threshold(dynamic_threshold)
);

demux2 dut2(
.data_in(maxpool_o[7:0]),
.clk(clk),
.rst(rst),
.datavalid(maxpool_o[8]),
.sel(selectline2),
.fifo1(demux2_o1),
.fifo2(demux2_o2)
);

fifo_valid1 #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) dut3(
.clk(clk),
.rst_n(rst),
.we(demux2_o1[8]),
.re(re),
.data_in(demux2_o1[7:0]),
.occupants(occupants1),
.full(full1),
.empty(empty1),
.data_out(fifo1_out),
.data_valid(data_valid1)
);


fifo_valid2 #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) dut4(
.clk(clk),
.rst_n(rst),
.we(demux2_o2[8]),
.re(re),
.data_in(demux2_o2[7:0]),
.occupants(occupants2),
.full(full2),
.empty(empty2),
.data_out(fifo2_out),
.data_valid(data_valid2)
);

maxpool dut5(
.clk(clk),
.datavalid(data_valid1&data_valid2),
.dina(fifo1_out),
.dinb(fifo2_out),
.temp(maxvalue)
);

assign maxvalue_o = maxvalue[7:0];
assign datavalid_o = maxvalue[8];

assign re = ((~empty1) & (~empty2));
 
endmodule