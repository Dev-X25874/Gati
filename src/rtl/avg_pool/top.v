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

wire [7:0] dout_pooling_first_stage;  
wire dv_pooling_first_stage;
wire [7:0] data_in_fifo1;
wire [7:0] data_in_fifo2;
wire we_fifo;
wire [7:0] din_fifo_1;
wire [7:0] din_fifo_2;
wire re;
wire empty1;
wire empty2;
wire dv_pooling_secong_satge;
wire [7:0] dout_pooling_second_stage;
wire datavalid_final_pool;
wire [7:0] dout_fifo1;
wire we_mux;

pooling_first_stage #(.KERNEL_SIZE(KERNEL_SIZE)) pooling_first_stage_1 (
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .datavalid_in(datavalid),
    .pooling_type(pooling_type),
    .kernel_size(kernel_size),
    .datavalid_out(dv_pooling_first_stage)
    .dout(dout_pooling_first_stage)
);

demux_for_fifo1 demux_for_fifo1_1 (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(dout_pooling_first_stage), 
    .data_out_fifo1(data_in_fifo1),
    .data_out_fifo2(data_in_fifo2),
    .datavalid_in(dv_pooling_first_stage),
    .datavalid_out(we_fifo)
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) fifo_1 (
  .clk(clk),
  .rst_n(rst),
  .we(we_mux),
  .re(re),
  .data_in(dout_fifo1),
  .occupants(),
  .full(),
  .empty(empty1),
  .data_out(din_fifo_1),
  .data_valid()
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) fifo_2 (
  .clk(clk),
  .rst_n(rst),
  .we(we_fifo),
  .re(re),
  .data_in(data_in_fifo2),
  .occupants(),
  .full(),
  .empty(empty2),
  .data_out(din_fifo_2),
  .data_valid(dv_pooling_secong_satge)
);

pooling_second_stage #(.KERNEL_HEIGHT(KERNEL_HEIGHT)) pooling_second_stage_1 (
    .clk(clk), 
    .rst_n(rst_n),
    .din_fifo_1(din_fifo_1),
    .din_fifo_2(din_fifo_2),
    .datavalid_in(dv_pooling_secong_satge),
    .pooling_type(pooling_type),
    .kernel_height(kernel_height),
    .dout(dout_pooling_second_stage),
    .datavalid_out(datavalid_final_pool)
);

mux_final_pool mux_final_pool_1 (
    .clk(clk),
    .din_final_pool(dout_pooling_second_stage),
    .din_demux_for_fifo1(data_in_fifo1),
    .datavalid_final_pool(datavalid_final_pool),
    .datavalid_demux_for_fifo1(we_fifo),
    .dout_fifo1(dout_fifo1),
    .dv(we_mux)
);

assign re = ((~empty1) & (~empty2));


always @(posedge clk) begin
    if(counter == kernel_height) begin
        dout <= dout_fifo1;
    end
    else begin
        
    end
end

endmodule