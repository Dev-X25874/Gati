module top_reshape_transpose #(
    parameter W_ADDR = 9,
    parameter DATA_WIDTH = 8,
    parameter IMG_HEIGHT = 16,
    parameter IMG_WIDTH = 16,
    parameter IMG_CHANNELS = 16,
    parameter AXI_DATA_WIDTH = 256,
    parameter N_SA = 16,
    parameter COL_SA = 1,
    parameter W_CITER_CNT = 12,
    parameter BURST_LEN = 10,
    parameter FIFO_DEPTH = 128,
    parameter AXI_DATA_BYTES = 32,
    parameter ADDR_OUT_CHUNCK_WIDTH = 8)
    (
        input  clk,
        input  rst,
        input  rd_start,                                                       //start for requesting data to be read from DDR
        input  i_select,                                                       //read select from DDR
        input  i_data_last,                                                    //read data last from DDR
        input  i_data_valid,                                                   //read data valid from DDR
        input  [IMG_HEIGHT-1:0] image_height,                                  //image dimensions from instructions
        input  [IMG_WIDTH-1:0] image_width,
        input  [IMG_CHANNELS-1:0] input_channels,                              // number of channels from instructions
        input  [AXI_DATA_BYTES - 1 : 0] start_addr_rd_req,                     //start address for reading data from DDR
        input  [AXI_DATA_WIDTH - 1 : 0] i_dram_data_read_requestor,            //read data from DDR
        output [(BURST_LEN - 1) : 0] burst_length_read_requestor,              //read burst length to DDR
        output [(ADDR_OUT_CHUNCK_WIDTH - 1) : 0] addr_out_read_requestor,      //requested read address to DDR
        output [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] op_fifo_data,
        output reshape_transpose_done,
        output op_fifo_wr_en,
        output rw_enable_rd_req,                                               //read-write signal to DDR
        output last_read_requestor,                                            //read address last to DDR
        output valid_read_requestor                                            //read address valid to DDR
    );

    localparam ELEMENTS = AXI_DATA_BYTES/N_SA;

    wire [AXI_DATA_BYTES-1:0] bram_rd_en;
    wire [(AXI_DATA_BYTES*W_ADDR)-1:0] bram_rd_addr;
    wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] bram_out;
    wire [AXI_DATA_BYTES-1:0] d_bram_rd_en;
    wire fifo_wr_en;
    wire d_fifo_wr_en;
    reg  [DATA_WIDTH-1:0] fifo_in;
    wire [DATA_WIDTH-1:0] d_bram_out;
    wire w_bram_rd_start;
    wire w_next_req;
    wire [AXI_DATA_BYTES-1:0] f_wen;
    wire [$clog2(AXI_DATA_BYTES)-1:0] fifo_counter;
    wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] rt_data_byte;
    wire [AXI_DATA_WIDTH-1:0] fifo_wr_data;
    wire [AXI_DATA_BYTES-1:0] rd_rq_offset;
    wire [AXI_DATA_BYTES-1:0] fifo_dv;
    wire [AXI_DATA_BYTES-1:0] fifo_rd_en;
    wire [AXI_DATA_BYTES-1:0] empty_flag;
    (*syn_use_dsp = "no"*) wire [(2*IMG_HEIGHT)-1:0] img_dim;
    wire [W_CITER_CNT - 1 : 0] channel_iter;

    assign rt_data_byte = {AXI_DATA_BYTES{fifo_in}};
    assign img_dim = image_height*image_width;
    assign op_fifo_wr_en = (&fifo_dv);
    assign rd_rq_offset = (img_dim % ELEMENTS == 0)? (img_dim/ELEMENTS):((img_dim/ELEMENTS) + 1);
    assign fifo_rd_en = (|empty_flag)? 0:{AXI_DATA_BYTES{1'b1}};
    assign channel_iter = (input_channels % N_SA == 0)? (input_channels/N_SA):((input_channels/N_SA) + 1);

    always @(posedge clk) begin
        if (!rst) fifo_in <= 0;
        else fifo_in <= d_bram_out;
    end

    TOP_W_BRAM #(.AXI_DATA_BYTES(AXI_DATA_BYTES), .AXI_DATA_WIDTH(AXI_DATA_WIDTH), .BURST_LENGTH_WIDTH(BURST_LEN), .IMG_HEIGHT(IMG_HEIGHT), .W_CITER_CNT(W_CITER_CNT), .DATA_WIDTH(DATA_WIDTH), .N_BRAM(AXI_DATA_BYTES), .W_ADDR(W_ADDR), .ELEMENTS(ELEMENTS), .COL_SA(COL_SA), .N_SA(N_SA), .ADDR_OUT_CHUNCK_WIDTH(ADDR_OUT_CHUNCK_WIDTH)) dut1(
        .clk(clk),
        .rst_n(rst),
        .rd_start(rd_start),
        .done(reshape_transpose_done),
        .empty(w_next_req | reshape_transpose_done),
        .i_select(i_select),
        .i_data_last(i_data_last),
        .i_data_valid(i_data_valid),
        .rd_addr(bram_rd_addr),
        .n_bram_rden(bram_rd_en),
        .rd_rq_offset(rd_rq_offset),
        .img_dimension(img_dim),
        .channel_itr_count(channel_iter),
        .start_addr_rd_req(start_addr_rd_req),
        .i_dram_data(i_dram_data_read_requestor),
        .burst_length_read_requestor(burst_length_read_requestor),
        .addr_out_read_requestor(addr_out_read_requestor),
        .o_data_final(bram_out),
        .rw_enable_rd_req(rw_enable_rd_req),
        .last_read_requestor(last_read_requestor),
        .valid_read_requestor(valid_read_requestor),
        .rd_bram_start(w_bram_rd_start)
    );

    bram_rd_ctrl #(.W_ADDR(W_ADDR), .W_DATA(DATA_WIDTH), .ELEMENTS(ELEMENTS), .N_BRAM(AXI_DATA_BYTES), .IMG_CHANNELS(IMG_CHANNELS), .IMG_HEIGHT(IMG_HEIGHT)) dut5(
        .clk(clk),
        .rst(rst),
        .image_size(img_dim),
        .next_req(w_next_req),
        .done(reshape_transpose_done),
        .input_channels(input_channels),
        .start(w_bram_rd_start),
        .rd_addr(bram_rd_addr),
        .rd_en(bram_rd_en),
        .valid(fifo_wr_en)
    );

    delay_reg_rt #(.N_BRAM(AXI_DATA_BYTES)) dut6(
        .clk(clk),
        .rst(rst),
        .i_rd_en(bram_rd_en),
        .i_valid(fifo_wr_en),
        .o_rd_en(d_bram_rd_en),
        .o_valid(d_fifo_wr_en)
    );

    vector_mux_param #(.NO_PORT(AXI_DATA_BYTES), .PORT_SIZE(DATA_WIDTH)) dut7(      //writing the selected data read from brams into fifios
        .in(bram_out),
        .out(d_bram_out),
        .sel(d_bram_rd_en)
    );

    fifo_wr_ctrl_rt #(.N_FIFO(AXI_DATA_BYTES), .IMG_CHANNELS(IMG_CHANNELS), .IMG_HEIGHT(IMG_HEIGHT)) dut8(
        .clk(clk),
        .rst(rst),
        .img_dimension(img_dim),
        .input_channels(input_channels),
        .fifo_counter(fifo_counter),
        .valid(d_fifo_wr_en),
        .wr_en(f_wen)
    );

    vector_mux_param # (
      .PORT_SIZE(AXI_DATA_WIDTH),
      .NO_PORT(2)
    )
    vector_mux_param_inst (
      .in({256'd0,rt_data_byte}),
      .out(fifo_wr_data),
      .sel(1<<((~d_fifo_wr_en) && (fifo_counter != 0)))
    );

    gen_fifo #(.W_ADDR($clog2(FIFO_DEPTH)), .W_DATA(DATA_WIDTH), .N_FIFO(AXI_DATA_BYTES)) dut9( //dram fifo array
        .clk(clk),
        .rst(~rst),
        .wen(f_wen),
        .ren(fifo_rd_en),
        .wdata(fifo_wr_data),
        .empty_o(empty_flag),
        .rdata(op_fifo_data),
        .valid_o(fifo_dv)
    );
endmodule