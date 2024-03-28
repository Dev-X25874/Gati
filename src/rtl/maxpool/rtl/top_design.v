module top_design(
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
  .datavalid(datavalid),
  .sel(selectline1),
  .dynamic_threshold(dynamic_threshold)
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

assign re = ((~empty1) & (~empty2));

assign maxvalue_o = maxvalue[7:0];
assign datavalid_o = maxvalue[8];

endmodule