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

module top(
  input clk,
  input din,
  input rst,
  output dout
    );

  wire datavalid; 
  wire [7:0] data_in;
  wire re;    
  wire [8:0] demux1_o1;
  wire [8:0] demux1_o2;
  wire [8:0] maxpool_o;
  wire [8:0] demux2_o1;
  wire [8:0] demux2_o2;
  wire [8:0] demux1_valid;
  wire ne;
  wire [7:0] fifo1_out;
  wire [7:0] fifo2_out;
  wire selectline1;
  wire selectline2;
  wire data_valid1;
  wire data_valid2;
  wire [8:0] maxvalue;
  wire [7:0] dynamic_threshold1;
  wire [7:0] dmux_in;
  wire datavalid_con;
  wire [7:0] tx_in;
  wire tx_valid;
  wire empty1;
  wire empty2;
  wire empty3;
  wire done_tx;
  wire re_tx;

counter1 c1(
  .clk(clk),
  .rst(rst),
  .datavalid(datavalid),
  .sel(selectline1),
  .dynamic_threshold(dynamic_threshold1)
);

receiver rx(
  .clk(clk),
  .din(din),
  .dout(data_in),
  .valid(datavalid)
);

controller con(
  .clk(clk),
  .d_in(data_in),
  .rx_valid(datavalid),
  .dynamic_threshold(dynamic_threshold1),
  .d_out(dmux_in),
  .datavalid(datavalid_con)
);
    
demux1 dut0(
  .clk(clk),
  .din(dmux_in),
  .sel(selectline1),
  .rx_valid(datavalid),
  .datavalid(datavalid_con),
  .a(demux1_valid),
  .b(demux1_o2),
  .c(demux1_o1)
);

maxpool dut1(
  .clk(clk),
  .datavalid(demux1_o2[8]), 
  .dina(demux1_o1[7:0]),
  .dinb(demux1_o2[7:0]),
  .temp(maxpool_o)
);

counter2 c2(
  .clk(clk),
  .rst(rst),
  .datavalid(maxpool_o[8]),
  .sel(selectline2),
  .dynamic_threshold(dynamic_threshold1)
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

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) dut3(
  .clk(clk),
  .rst_n(rst),
  .we(demux2_o1[8]),
  .re(re),
  .data_in(demux2_o1[7:0]),
  .occupants(),
  .full(),
  .empty(empty1),
  .data_out(fifo1_out),
  .data_valid(data_valid1)
);


fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) dut4(
  .clk(clk),
  .rst_n(rst),
  .we(demux2_o2[8]),
  .re(re),
  .data_in(demux2_o2[7:0]),
  .occupants(),
  .full(),
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

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) dut6(
  .clk(clk),
  .rst_n(rst),
  .we(maxvalue[8]),
  .re(re_tx),
  .data_in(maxvalue[7:0]),
  .occupants(),
  .full(),
  .empty(empty3),
  .data_out(tx_in),
  .data_valid()
);

fifo_re_controller dut7(
  .i_clk(clk),
  .i_fifo_empty(empty3),
  .i_tx_done(done_tx),
  .o_fifo_read_enable(re_tx),
  .o_tx_data_valid(tx_valid)
);

uart_tx tx(
  .i_Rst_L(rst),
  .i_Clock(clk),
  .i_TX_DV(tx_valid),
  .i_TX_Byte(tx_in), 
  .o_TX_Active(),
  .o_TX_Serial(dout),
  .o_TX_Done(done_tx)
);

assign re = ((~empty1) & (~empty2));
 
endmodule