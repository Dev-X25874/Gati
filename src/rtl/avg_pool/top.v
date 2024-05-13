module top(
    input clk,
    input rst_n,
    input [7:0] din,
    input datavalid,
    input [2:0] pooling_type,
    input [KERNEL_SIZE -1 : 0] kernel_size,
    input [KERNEL_HEIGHT - 1 : 0] kernel_height,
    output [7:0] dout
);


pooling_first_stage #(.KERNEL_SIZE(KERNEL_SIZE)) pooling_first_stage_1 (
    .clk(clk),
    .rst_n(),
    .din(),
    .datavalid(),
    .pooling_type()
    .kernel_size(),
    .pooling_type(),
    .dout()
);

demux_for_fifo1 demux_for_fifo1_1 (
    .clk(),
    .rst_n(),
    .data_in(), 
    .data_out_fifo1(),
    .data_out_fifo2(),
    .datavalid_in(),
    .datavalid_out()
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) fifo_1 (
  .clk(clk),
  .rst_n(rst),
  .we(),
  .re(),
  .data_in(),
  .occupants(),
  .full(),
  .empty(),
  .data_out(),
  .data_valid()
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) fifo_2 (
  .clk(clk),
  .rst_n(rst),
  .we(),
  .re(),
  .data_in(),
  .occupants(),
  .full(),
  .empty(),
  .data_out(),
  .data_valid()
);

pooling_second_stage #(.KERNEL_HEIGHT(KERNEL_HEIGHT)) pooling_second_stage_1 (
    .clk(), 
    .rst_n(),
    .din_fifo_1(),
    .din_fifo_2(),
    .datavalid_in(),
    .pooling_type(),
    .kernel_height(),
    .dout(),
    .datavalid_out()
);

mux_final_pool mux_final_pool_1 (
    .clk(),
    .din_final_pool(),
    .din_demux_for_fifo1(),
    .datavalid_final_pool(),
    .datavalid_demux_for_fifo1(),
    .dout_fifo1()
);



endmodule