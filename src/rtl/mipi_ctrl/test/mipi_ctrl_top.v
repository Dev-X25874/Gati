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
    output valid_wr_req_ctrl
);

wire [W_DATA-1 : 0] start_address;
wire [W_DATA-1 : 0] data_size;
wire [N_FIFO-1 : 0] ff_write_enable;
wire [W_DATA-1 : 0] data_ff_wr_ctrl;
wire dv_ff_wr_ctrl;
	assign final_o_data_last=o_data_last;
	assign final_last_wr_req_ctrl=last_wr_req_ctrl;
	assign finaL_burst_len_wr_req_ctrl=burst_len_wr_req_ctrl;

fifo_wr_ctrl#(
    .W_DATA(W_DATA),
    .N_FIFO(N_FIFO)
)fifo_write_controller(
    .i_clk(i_clk),
    .i_rstn(i_rstn),           //Active low reset
    // .i_dlen(),           //TODO: check size of this input, and where does it comes from?
    .i_data_valid(i_data_valid),     //comes from mipi fifo
    .i_data(i_data),           //comes from mipi fifo
    .o_start_address(start_address),  //sends initial address to write request controller
    .o_data_size(data_size),      //sends total number of bytes of data to write request controller, for eg, 98x4
    .o_write_enable(ff_write_enable),   //sends write enable signal to fifo array
    .o_data(data_ff_wr_ctrl),            //sends data to store into fifo array
    .o_valid(dv_ff_wr_ctrl)
);
// wire req_wr_req_ctrl;
// wire [7:0] address_wr_req_ctrl;
wire [W_BURST_LEN-1 : 0] burst_len_wr_req_ctrl;
wire last_wr_req_ctrl;
// wire valid_wr_req_ctrl;
// wire data_last_wr_req_ctrl;
// assign data_last_wr_req_ctrl = o_data_last;
wr_req_ctrl#(
    .W_DATA(W_DATA),
    .W_BURST_LEN(W_BURST_LEN),
    .BURST_LEN(BURST_LEN),
    .W_ADDR(W_ADDR),
    .AXI_BYTES(AXI_BYTES)
)write_request_controller(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_data_last(o_data_last),   //burst last, comes from DDR write controller
    .i_data_valid(dv_ff_wr_ctrl),
    .i_fifo_occupants(ff_array_occ), //comes from fifo array
    .i_start_address(start_address),   //comes from fifo_wr_ctrl
    .i_data_size(data_size),   //comes from fifo_wr_ctrl
    .o_request(req_wr_req_ctrl),   //request goes to DDR ctrl
    .o_address(address_wr_req_ctrl), //requested address, goes to DDR ctrl
    .o_burst_len(burst_len_wr_req_ctrl),  //requested burst length, goes to DDR ctrl
    .o_last(last_wr_req_ctrl),
    .o_valid(valid_wr_req_ctrl)
);

wire [((N_FIFO * (W_ADDR + 1)))-1 : 0] ff_array_occ;
wire [N_FIFO-1 : 0] ff_array_empty;

image_fifo_array#(
    .DIMENSION(N_FIFO),
    .W_DATA(W_DATA),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(1 << W_ADDR)
)mul_fifo_array(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_data(data_ff_wr_ctrl),
    .i_write_enable(ff_write_enable),
    .i_read_enable(ff_read_enable),
    .o_data(o_fifo_data),
    .o_fifo_empty(ff_array_empty),
    .o_fifo_dv(),
    .o_fifo_full(),
    .o_occupants(ff_array_occ)
);


wire [N_FIFO-1 : 0] ff_read_enable;
wire o_data_last;
dram_wr_ctrl#(
    .W_ADDR(W_ADDR),
    .N_FIFO(N_FIFO),
    .W_BURST_LEN(W_BURST_LEN)
)dram_write_controller(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_select(ddr_sel),
    .i_write_ready(ddr_wready),
    .i_burst_length(ddr_blen),
    .o_fifo_read_enable(ff_read_enable),
    .o_data_last(o_data_last),
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
);
   */ 
endmodule
