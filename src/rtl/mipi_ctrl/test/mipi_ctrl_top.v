module mipi_ctrl_top#(
    parameter N_FIFO = 8,
    parameter W_DATA = 32,
    parameter BURST_LEN = 15,
    parameter W_BURST_LEN = 8,
    parameter W_ADDR = 8,
    parameter AXI_BYTES = 32
)(
    input i_clk,
    input i_rstn,
    input i_data_valid,
    input dr_clk,
	input [W_DATA-1 : 0] i_data,
	input ddr_sel,
	input ddr_wready,
	input [W_BURST_LEN-1 : 0]ddr_blen,
    output [(W_DATA * N_FIFO)-1 : 0] o_fifo_data,  //comes from fifo array
    output final_o_data_last, //comes from dram wr ctrl
    output o_data_valid, //comes from dram wr ctrl
    output req_wr_req_ctrl,
    output [7:0] address_wr_req_ctrl,
    output [W_BURST_LEN-1 : 0] final_burst_len_wr_req_ctrl,
    output final_last_wr_req_ctrl,
    output valid_wr_req_ctrl,
	output soft_start,
	output eop
);
wire rd_en_size_address;
wire empty_size_address;
wire valid_size_address;
wire [W_DATA-1 : 0] rd_size_address;
wire [W_DATA-1 : 0] data_size;
wire [N_FIFO-1 : 0] ff_write_enable;
wire [W_DATA-1 : 0] data_ff_wr_ctrl;
wire dv_ff_wr_ctrl;
wire o_data_last;

	assign final_o_data_last=o_data_last;
	assign final_last_wr_req_ctrl=last_wr_req_ctrl;
	assign final_burst_len_wr_req_ctrl=burst_len_wr_req_ctrl;
  
fifo_wr_ctrl#(
    .W_DATA(W_DATA),
    .N_FIFO(N_FIFO)
)fifo_write_controller(
    .i_clk(i_clk),
    .i_rstn(i_rstn),           //Active low reset
    // .i_dlen(),           //TODO: check size of this input, and where does it comes from?
    .i_data_valid(i_data_valid),    //comes from mipi fifo
    .i_data(i_data),                //comes from mipi fifo
    .i_rd_en_size_address(rd_en_size_address),
    .o_empty_size_address(empty_size_address),
    .o_valid_size_address(valid_size_address),
    .o_rd_size_address(rd_size_address),
    .o_write_enable(ff_write_enable),       //sends write enable signal to fifo array
    .o_data(data_ff_wr_ctrl),               //sends data to store into fifo array
    .o_valid(dv_ff_wr_ctrl),
	.soft_start(w_start),
	.eop(eop)
);
wire w_start;
// wire req_wr_req_ctrl;
// wire [7:0] address_wr_req_ctrl;
wire [W_BURST_LEN-1 : 0] burst_len_wr_req_ctrl;
wire last_wr_req_ctrl;
reg last_dram_wr_req_ctrl;
// wire valid_wr_req_ctrl;
// wire data_last_wr_req_ctrl;
// assign data_last_wr_req_ctrl = o_data_last;

(* async_reg="true" *) reg f_o_data_last,s_o_data_last;
always @(posedge i_clk) begin
    f_o_data_last <= last_dram_wr_req_ctrl;
    s_o_data_last <= f_o_data_last;
end
wire ack_dram_wr_req_ctrl;
wr_req_ctrl#(
    .W_DATA(W_DATA),
    .W_BURST_LEN(W_BURST_LEN),
    .BURST_LEN(BURST_LEN),
    .W_ADDR(W_ADDR),
    .AXI_BYTES(AXI_BYTES)
)write_request_controller(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_data_last(s_o_data_last),   //burst last, comes from DDR write controller
    .i_data_valid(dv_ff_wr_ctrl),
    .i_fifo_occupants(ff_array_occ), //comes from fifo array
    .o_ack_dram_ctrl(ack_dram_wr_req_ctrl), //acknowledgment for last signal from dram_wr_ctrl

    .i_valid_size_address(valid_size_address),
    .i_empty_size_address(empty_size_address),
    .i_rd_size_address(rd_size_address),
    .o_rd_en_size_address(rd_en_size_address),

    .o_request(req_wr_req_ctrl),   //request goes to DDR ctrl
    .o_address(address_wr_req_ctrl), //requested address, goes to DDR ctrl
    .o_burst_len(burst_len_wr_req_ctrl),  //requested burst length, goes to DDR ctrl
    .o_last(last_wr_req_ctrl),
    .o_valid(valid_wr_req_ctrl)
);

wire [((N_FIFO * (W_ADDR + 1)))-1 : 0] ff_array_occ;
wire [N_FIFO-1 : 0] ff_array_empty;
wire [N_FIFO-1:0] dv;
image_fifo_array_async#(
    .DIMENSION(N_FIFO),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(1 << W_ADDR),
    .OUTPUT_REG(0)
)mul_fifo_array(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .dr_clk(dr_clk),
    .i_data(data_ff_wr_ctrl),
    .i_write_enable(ff_write_enable),
    .i_read_enable(ff_read_enable),
    .o_data(o_fifo_data),
    .o_fifo_empty(ff_array_empty),
    .o_fifo_dv(dv),
    .o_fifo_full(),
    .o_occupants(ff_array_occ)
);


wire [N_FIFO-1 : 0] ff_read_enable;
reg prev_w_start;
always@(posedge i_clk) prev_w_start <= w_start;

(* async_reg="true" *) reg f_w_start,s_w_start;
always @(posedge dr_clk) begin
    f_w_start <= (w_start | prev_w_start);
    s_w_start <= f_w_start;
end

//stretching data_last signal for 81MHz CDC and also stretch ack signal to sample in i_clk
reg r_ack_dram_wr_req_ctrl = 0;
always@(posedge i_clk) r_ack_dram_wr_req_ctrl <= ack_dram_wr_req_ctrl;

(*async_reg = "true"*) reg ack_dram_wr_req_ctrl1, ack_dram_wr_req_ctrl2;
always@(posedge dr_clk) begin
    ack_dram_wr_req_ctrl1 <= (ack_dram_wr_req_ctrl | r_ack_dram_wr_req_ctrl);
    ack_dram_wr_req_ctrl2 <= ack_dram_wr_req_ctrl1;
end
always@(posedge dr_clk) begin
    if(!i_rstn) last_dram_wr_req_ctrl <= 0;
    else begin
        if(o_data_last) last_dram_wr_req_ctrl <= 1;
        else if(ack_dram_wr_req_ctrl2) last_dram_wr_req_ctrl <= 0;
    end
end
//wire o_data_last;
dram_wr_ctrl#(
    .W_ADDR(W_ADDR),
    .N_FIFO(N_FIFO),
    .W_BURST_LEN(W_BURST_LEN)
)dram_write_controller(
    .i_clk(dr_clk),
	.i_dv(&dv),
	.s_start(s_w_start),
    .i_rstn(i_rstn),
    .i_select(ddr_sel),
    .i_write_ready(ddr_wready),
    .i_burst_length(ddr_blen),
    .o_fifo_read_enable(ff_read_enable),
    .o_data_last(o_data_last),
	.soft_start(soft_start),
    .o_data_valid(o_data_valid)
);
/*
wire ddr_sel;
wire ddr_wready;
wire [W_BURST_LEN-1 : 0]ddr_blen;

counters#(
    .W_BLEN(W_BURST_LEN)
)test_counters(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_last(last_wr_req_ctrl),
    .i_burst_len(burst_len_wr_req_ctrl), //comes from wr_req_ctl
    .o_select(ddr_sel),
    .o_burst_length(ddr_blen),
    .o_w_ready(ddr_wready)
);*/
endmodule
