module top(
    input clk,
    input rst_n,
    input ENABLE,
    input [7:0] din,
    input datavalid_in,
    input [2:0] pooling_type,
    input [3:0] pool_width,
    input [3:0] pool_height,
    input [9:0] OH,
    input [9:0] OW,
    input rx_valid,
    output [7:0] dout,
    output done,
    output datavalid_out
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
wire we_mux;
wire enable_rowwise;
wire [7:0] dout_final_mux;
wire [7:0] dout_fifo1_mux;
wire [7:0] dout_fifo1;
wire sel;
wire dv_demux_counter;
wire we_fifo1;
wire we_fifo2;

pooling_first_stage pooling_first_stage (
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .ENABLE(ENABLE),
    .datavalid_in(datavalid_in),
    .pool_width(pool_width),
    .pooling_type(pooling_type),
    .dout(dout_pooling_first_stage),
    .datavalid_out(dv_pooling_first_stage)
);

counter_demux counter_demux (
    .clk(clk),
    .rst_n(rst_n),
    .datavalid_in(dv_demux_counter),
    .pool_height(pool_height),
    .rx_valid(rx_valid),
    .datavalid_out(),
    .sel(sel)
);

demux_for_fifo1 demux_for_fifo1 (
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .sel(sel),
    .data_in(dout_pooling_first_stage), 
    .data_out_fifo1(data_in_fifo1),
    .data_out_fifo2(data_in_fifo2),
    .datavalid_in(dv_pooling_first_stage),
    .datavalid_out_fifo1(we_fifo1),
    .datavalid_out_fifo2(we_fifo2)
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(5)) fifo_1 (
    .clk(clk),
    .rst_n(rst_n),
    .we(dv),
    .re(re),
    .data_in(dout_fifo1),
    .occupants(),
    .full(),
    .empty(empty1),
    .data_out(din_fifo_1),
    .data_valid()
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(5)) fifo_2 (
    .clk(clk),
    .rst_n(rst_n),
    .we(we_fifo2),
    .re(re),
    .data_in(data_in_fifo2),
    .occupants(),
    .full(),
    .empty(empty2),
    .data_out(din_fifo_2),
    .data_valid(dv_pooling_secong_satge)
);

pooling_second_stage pooling_second_stage (
    .clk(clk), 
    .rst_n(rst_n),
    .din_fifo_1(din_fifo_1),
    .din_fifo_2(din_fifo_2),
    .ENABLE(ENABLE),
    .datavalid_in(dv_pooling_secong_satge),
    .pooling_type(pooling_type),
    .dout(dout_pooling_second_stage),
    .datavalid_out(datavalid_final_pool)
);

counter_pooling_second counter_pooling_second (
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .datavalid_in(datavalid_final_pool),
    .dout_pooling_second_stage(dout_pooling_second_stage),
    .pool_height(pool_height),
    .datavalid_out_final(datavalid_out),
    .datavalid_out_fifo1(dv_mux),
    .dout_final(dout),
    .dout_fifo1(dout_fifo1_mux)
);

mux_final_pool mux_final_pool (
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .din_demux_for_fifo1(data_in_fifo1),
    .din_pooling_second_stage_fifo1(dout_fifo1_mux),
    .datavalid_out_final(dv_mux),
    .datavalid_out_fifo1(we_fifo1),
    .dv(dv),
    .dout_fifo1(dout_fifo1)
);

counter_rowwise_columnwise counter_rowwise_columnwise (
    .clk(clk),
    .rst_n(rst_n),
    .OW(OW),
    .OH(OH),
    .ENABLE(ENABLE),
    .rx_valid(rx_valid),
    .dv_demux_counter(dv_demux_counter),
    .done(done)  
);

assign re = ((~empty1) & (~empty2));

endmodule