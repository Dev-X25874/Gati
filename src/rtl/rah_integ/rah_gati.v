`include "../common/portid.vh"
`include "../common/instructions.vh"
module rah_gati #(
     parameter   SYS_CLK_PERIOD    = 32'd100_000_000 ,             //System Clock Period
   // parameter   NUM_PORTS = 4,                                    // number of ports
   // parameter   BURST_LENGTH_WIDTH = 8,                           // burst length
    parameter NO_PORT_WR=2,
	parameter   ADDRESS_WIDTH = 32,                               // address width                 
    parameter   IN_ADDR = 8,                                      // input address width of port controller
    parameter   PORT_ID = {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001},   // only use for port controller 
    parameter   POINTER_COUNT = 10,                               // fifo depth
    parameter   RAM_DEPTH = (1 << POINTER_COUNT),                 // fifo depth
    parameter   PORT_ID_WIDTH = 4,                                // ID width before the arbiter module [port controller, fifo, arbiter and request manager]
    parameter   ID_WIDTH = 8,                                     // ID width after the arbiter module
    parameter   AXI_ID_BLEN_CON = 8 ,                             // burst length width for AXI
  //  parameter   AXI_DATA_WIDTH      = 256 ,                       // Axi data width 
    parameter   AXI_BYTE_NUMBER     = AXI_DATA_WIDTH/8  ,                                  
    parameter   ADW_C               = AXI_DATA_WIDTH    ,
    parameter   ABN_C               = AXI_BYTE_NUMBER ,
    // FIFO Depth varies between operators to avoid overflow and underflow 
    parameter INST_QUEUE_DEPTH = 512,
    parameter DRAM_IMG_FIFO_DEPTH = 512,
    parameter IM2COL_FIFO_DEPTH = 1024,
    parameter WEIGHT_FIFO_DEPTH = 512,
    parameter PSUM_FIFO_DEPTH = 1024,
    parameter ACC_FIFO_DEPTH = 512,
    parameter BIAS_FIFO_DEPTH = 512, //For both conv and FC
    parameter OP_WRITE_FIFO_DEPTH = 1024,
    
    //Default burst lenghts for various memory request controllers
    parameter CONFIG_REQ_BLEN = 7,
    parameter IMG_REQ_BLEN = 15,
    parameter WEIGHT_REQ_BLEN = 15,
    parameter ACC_REQ_BLEN = 15,
    parameter BIAS_REQ_BLEN = 15,
    parameter OP_WRITE_REQ_ACC_BLEN = 31, //burst length for writng accumulants (32-bit) into the DRAM
    parameter OP_WRITE_REQ_QUA_BLEN = 15, //burst length for writng quantized output (8-bit) into the DRAM

    //parameters related to DRAM controller
    parameter NUM_PORTS = 10, //Number of read and write requestors

    //parameters related to AXI
    parameter AXI_DATA_WIDTH = 256,
    parameter AXI_DATA_BYTES = 32,  // Axi Data width = 256 bit
    parameter AXI_ADDR_W = `CONV_ImageStartAddress_WIDTH,   // Axi Address width
    parameter BURST_LENGTH_WIDTH =8,
   
    //Config blk param
    parameter NUM_INSTRUCTIONS = 4,
    parameter INST_W = 256,
    parameter CONFIG_FIFO_OCCUPANCY = 10,
    parameter LAYERCNT_WIDTH = `START_LayerNumber_WIDTH,
    parameter TOTAL_LAYERCNT_WIDTH = `START_TotalLayers_WIDTH,
    
    //CONV Parameters(inst related)
    parameter OPCODE_WIDTH  = `CONV_Opcode_WIDTH,
    parameter CONV_IW_WIDTH = `CONV_IW_WIDTH,
    parameter CONV_IH_WIDTH = `CONV_IH_WIDTH,
    parameter CONV_OW_WIDTH = `CONV_OW_WIDTH,
    parameter CONV_OH_WIDTH = `CONV_OH_WIDTH,
    parameter CONV_IC_WIDTH = `CONV_IC_WIDTH,
    parameter CONV_KN_WIDTH = `CONV_KN_WIDTH,
    parameter CONV_KW_WIDTH = `CONV_KW_WIDTH,
    parameter CONV_KH_WIDTH = `CONV_KH_WIDTH,
    parameter CONV_STRIDE_WIDTH = `CONV_Stride_WIDTH,
    parameter CONV_PAD_WIDTH = `CONV_Pad_WIDTH,
    //SA related param
    parameter POP_THRESHOLD = 5,
    parameter NSA_DSP       = 4, 
    parameter NSA_LUT       = 0,
    parameter N_SA          = NSA_DSP + NSA_LUT,
    parameter DATA_WIDTH    = 8,
    parameter COL_SA        = 4,
    parameter COL_FC        = 32,
    parameter ROW           = 9,
    parameter W_PSUM        = 20,
    parameter DATA_WIDTH_OB = 32,
    parameter IMAGE_DIM     = 224,

    // FC inst. related params
    parameter FC_WEIGHTROW_WIDTH    = `FC_WeightRows_WIDTH,
    parameter FC_WEIGHTCOL_WIDTH    = `FC_WeightCols_WIDTH,
    parameter FC_IMAGE_ROWS_WIDTH   = `FC_InputRows_WIDTH,
    parameter FC_DROPOUT_WIDTH      = `FC_DropoutConstant_WIDTH,
    parameter W_FC_IMAG_DIM         = `FC_ImageDim_WIDTH,
    parameter W_FC_RW_COUNTER       = `FC_Vec2MatCols_WIDTH, //width of fc r/w address counter
    parameter FLATTEN_EN_WIDTH      = `FC_Flatten_WIDTH,
    // FC Engine related parameters
    parameter ACC_DW            = 32,
    parameter N_BANK            = 4,
    parameter N_BRAM            = 8,
    parameter FC_BRAM_DEPTH     = 1024,
    parameter ACC_DATA_REORDER  = 1,
    parameter N_FC_MUX          = 4, //number of muxes for FC output
    parameter NO_PORT_FC        = 8, //FC mux size

    //Output block inst param
    parameter W_CITER_CNT       = `OutputBlock_ChannelItr_WIDTH,
    parameter W_KITER_CNT       = `OutputBlock_KernelItr_WIDTH,
    parameter I_ACC_SIZE_WIDTH  = `OutputBlock_ImageDimAcc_WIDTH, // bit width of input image dimension
    parameter I_OP_SIZE_WIDTH   = `OutputBlock_ImageDimOutput_WIDTH,
    parameter ACCEN_WIDTH       = `OutputBlock_AccEn_WIDTH,
    parameter MOD1 = 2,
    parameter MOD2 = 8,
    parameter N_DMUX_PORTS = 2,

    //Tail block param
    parameter BNCHANNEL_WIDTH   = `TailBlock_BNChannels_WIDTH,
    parameter ACT_TYPE_WIDTH    = `TailBlock_ActType_WIDTH,
    parameter RELU_CLIP_WIDTH   = `TailBlock_ActParam_WIDTH,   
    parameter W_QUANT_SHIFT     = `TailBlock_QuantShift_WIDTH,
    parameter W_QUANT_SCALE     = `TailBlock_QuantScale_WIDTH, 
    parameter POOL_TYPE_WIDTH   = `TailBlock_PoolType_WIDTH,
    parameter W_POOL_WIDTH      = `TailBlock_PoolWidth_WIDTH,
    parameter W_POOL_HEIGHT     = `TailBlock_PoolHeight_WIDTH,
    parameter W_POOL_STRIDE     = `TailBlock_PoolStride_WIDTH,
    parameter W_POOL_PAD        = `TailBlock_PoolPadding_WIDTH,
    parameter BNEN_WIDTH        = `TailBlock_BNEn_WIDTH,
    parameter ACTEN_WIDTH       = `TailBlock_ActEn_WIDTH,
    parameter QUANTEN_WIDTH     = `TailBlock_QuantEn_WIDTH,
    parameter POOLEN_WIDTH      = `TailBlock_PoolEn_WIDTH,
    parameter BIASEN_WIDTH      = `TailBlock_BiasEn_WIDTH,
    parameter FCBIASEN_WIDTH    = `TailBlock_FCBiasEn_WIDTH,
    

    //Other parameters
    parameter SHFT_REG_X    = 4, // Number of shift register blocks
    parameter BIAS_FIFO     = 8, // Number of bias FIFOs
    parameter OP_FIFO       = 8,  // Number of output write FIFOs
    parameter BIAS_FIFO_FC  = 32, // Number of FC bias FIFOs
    parameter NO_PORT_VA    = 2,
    parameter NO_PORT_BAC   = 2,
    parameter NO_PORT_BAFC  = 8

) (
    input i_clk,
    input s_clk,
    input i_rst,
    input user_start,
    input empty,
    input [47:0] data,
    output  reg rden=0,
	////////////////
	input [1:0] PllLocked,
	output      DdrCtrl_CFG_RST_N     ,                        //(O)[Control]DDR Controner Reset(Low Active)     
    output      DdrCtrl_CFG_SEQ_RST   ,                       //(O)[Control]DDR Controner Sequencer Reset 
    output      DdrCtrl_CFG_SEQ_START ,   



	output  [      7:0] aid     ,
    
	output  [     31:0] aaddr   , 
    output  [      7:0] alen    , 
    output  [      2:0] asize   , 
    output  [      1:0] aburst  , 
    output  [      1:0] alock   , 
    output              avalid  , 
    input               aready  , 
    output              atype   ,
    output  [      7:0] wid     , 
    output  [ABN_C-1:0] wstrb   , 
    output              wlast   , 
    output              wvalid  , 
    input               wready  , 
    output  [ADW_C-1:0] wdata   , 
    input   [      7:0] rid     , 
    input               rlast   , 
    input               rvalid  , 
    output              rready  , 
    input   [      1:0] rresp   , 
    input   [ADW_C-1:0] rdata   , 
    input   [      7:0] bid     , 
    input               bvalid  , 
    output              bready  

);

  wire  [47:0] o_data ;
	assign o_data=data; 
  reg valid_data = 0;

  always @(posedge i_clk) begin

    if (!empty) begin
      rden <= 1;
    end else begin
      rden <= 0;
    end

    if (rden) valid_data <= 1;
    else valid_data <= 0;

    //if (valid_data) r_data <= data;
  end

  

  ////////////////////////////MIPI controller rx
  mipi_ctrl_top #(
      .N_FIFO(OP_FIFO ),
      .W_DATA(ACC_DW),
      .BURST_LEN(IMG_REQ_BLEN),
      .W_BURST_LEN(BURST_LENGTH_WIDTH) ,
      .W_ADDR(IN_ADDR),
      .AXI_BYTES(AXI_DATA_BYTES)
  ) mipi_ctrler_reciver (
      .i_clk(i_clk),
      .i_rstn(i_rst),
      .i_data_valid(valid_data),
      .i_data(o_data),
      .ddr_sel(select_wr[`MIPI_wr]),
      .ddr_wready(wr_id_o_wready),
      .ddr_blen(wr_burst_len),
      .o_fifo_data(o_fifo_data),
      .final_o_data_last(final_o_data_last),
      .o_data_valid(o_data_valid),
      .req_wr_req_ctrl(req_wr_req_ctrl),
      .address_wr_req_ctrl(address_wr_req_ctrl),
      .final_burst_len_wr_req_ctrl(final_burst_len_wr_req_ctrl),
      .final_last_wr_req_ctrl(final_last_wr_req_ctrl),
      .valid_wr_req_ctrl(valid_wr_req_ctrl)
  );
  wire         wr_id_o_wready ;                              
  wire [(ACC_DW * OP_FIFO)-1 : 0] o_fifo_data;  //comes from fifo array
  wire final_o_data_last;  //comes from dram wr ctrl
  wire o_data_valid;  //comes from dram wr ctrl
  wire req_wr_req_ctrl;
  wire [7:0] address_wr_req_ctrl;
  wire [BURST_LENGTH_WIDTH-1 : 0] final_burst_len_wr_req_ctrl;
  wire final_last_wr_req_ctrl;
  wire valid_wr_req_ctrl;


  //////////////////////////////


  ///////////////////////////////Memory Controller /////////////////////////////////
  Top_DRAM_controller # (
    .SYS_CLK_PERIOD(SYS_CLK_PERIOD),
    .NUM_PORTS(NUM_PORTS),
    .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .IN_ADDR(IN_ADDR),
    .PORT_ID(PORT_ID),
    .POINTER_COUNT(POINTER_COUNT),
    .RAM_DEPTH(RAM_DEPTH),
    .PORT_ID_WIDTH(PORT_ID_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .AXI_ID_BLEN_CON(AXI_ID_BLEN_CON),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_BYTE_NUMBER(AXI_BYTE_NUMBER),
    .ADW_C(ADW_C),
    .ABN_C(ABN_C)
  )
  Top_DRAM_controller_inst (
    .clk(i_clk),
    .rst(i_rst),
	.PllLocked(PllLocked),
    .DdrCtrl_CFG_RST_N(DdrCtrl_CFG_RST_N),
    .DdrCtrl_CFG_SEQ_RST(DdrCtrl_CFG_SEQ_RST),
    .DdrCtrl_CFG_SEQ_START(DdrCtrl_CFG_SEQ_START),
    .port_ctrl_i_valid(i_valid),
    .port_ctrl_i_address(in_adress),
    .port_ctrl_i_BLEN(in_BLEN),
    .port_ctrl_i_rw_enable(i_enable),
    .port_ctrl_i_last(i_last),
    .axi_read_o_delay_data(axi_read_o_delay_data),
    .rd_r_last(dram_rd_data_last),
    .rd_r_valid(dram_rd_datavalid),
    .wr_id_o_wready(wr_id_o_wready),
    .wr_axi_blen(wr_burst_len),
    .wr_axi_valid(dv_op_write),
    .wr_axi_last(data_last_op_write),
    .wr_axi_data(op_dram_fifo),
    .select_wr(select_wr),
    .select_rd(select_rd),
    .aid(aid),
    .aaddr(aaddr),
    .alen(alen),
    .asize(asize),
    .aburst(aburst),
    .alock(alock),
    .avalid(avalid),
    .aready(aready),
    .atype(atype),
    .wid(wid),
    .wstrb(wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),
    .wdata(wdata),
    .rid(rid),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),
    .rresp(rresp),
    .rdata(rdata),
    .bid(bid) ,
    .bvalid(bvalid),
    .bready(bready)
  );

 wire [NUM_PORTS-1:0] select_wr,select_rd;
  wire [(AXI_DATA_WIDTH*NO_PORT_WR)-1:0] in_wr_data_mux;
  assign in_wr_data_mux = {op_dram_fifo, o_fifo_data};
  wire [AXI_DATA_WIDTH-1:0] dram_in_wrdata;
  vector_mux_param #(
      .PORT_SIZE(AXI_DATA_WIDTH),
      .NO_PORT  (NO_PORT_WR)
  ) dram_write_data (
      .sel(select_wr[1:0]),
      .in (in_wr_data_mux),
      .out(dram_in_wrdata)

  );

  wire [(1*NO_PORT_WR)-1:0] in_wr_valid_mux;
  assign in_wr_valid_mux = {dv_op_write, o_data_valid};
  wire dram_in_wrvalid;



  vector_mux_param #(
      .PORT_SIZE(1'b1),
      .NO_PORT  (NO_PORT_WR)
  ) dram_write_valid (
	  .sel(select_wr[1:0]),
      .in (in_wr_valid_mux),
      .out(dram_in_wrvalid)

  );



  wire [(1*NO_PORT_WR)-1:0] in_wr_last_mux;
  assign in_wr_last_mux = {data_last_op_write, final_o_data_last};
  wire dram_in_wrlast;



  vector_mux_param #(
      .PORT_SIZE(1'b1),
      .NO_PORT  (NO_PORT_WR)
  ) dram_write_last (
      .sel(select_wr[1:0]),
	  .in (in_wr_last_mux),
      .out(dram_in_wrlast)

  );

  wire [NUM_PORTS-1:0] i_valid;
  wire [(NUM_PORTS*8)-1:0] in_address;
  wire [(NUM_PORTS*8)-1:0] in_BLEN;
  wire [NUM_PORTS-1:0] i_enable;
  wire [NUM_PORTS-1:0] i_last;

  assign i_valid = {
    valid_wr_req_ctrl,
    mc_config_valid,
    mc_img_valid,
    mc_wghts_valid,
    mc_fc_valid,
    mc_bias_valid,
    mc_fc_bias_valid,
    mc_acc_valid,
    mc_op_write_valid
  };

  assign in_adress = {
    address_wr_req_ctrl,
    mc_config_addr,
    mc_img_addr,
    mc_wghts_addr,
    mc_fc_addr,
    mc_bias_addr,
    mc_fc_bias_addr,
    mc_acc_addr,
    mc_op_write_addr
  };

  assign in_BLEN = {
    final_burst_len_wr_req_ctrl,
    mc_config_bl,
    mc_img_bl,
    mc_wghts_bl,
    mc_fc_bl,
    mc_bias_bl,
    mc_fc_bias_bl,
    mc_acc_bl,
    mc_op_write_bl
  };

  assign i_enable = {
    req_wr_req_ctrl,
    mc_config_rdreq,
    mc_img_rdreq,
    mc_wghts_rdreq,
    mc_fc_rdreq,
    mc_bias_rdreq,
    mc_fc_bias_rdreq,
    mc_acc_rdreq,
    mc_op_writereq
  };

  assign i_last = {
    final_last_wr_req_ctrl,
    mc_config_last,
    mc_img_last,
    mc_wghts_last,
    mc_fc_last,
    mc_bias_last,
    mc_fc_last,
    mc_bias_last,
    mc_fc_bias_last,
    mc_acc_last,
    mc_op_write_last
  };




  //////////////////////////////// gati module instatiation

  //signals to DRAM ctrler
  ////config
  wire [7:0] mc_config_addr;
  wire mc_config_rdreq;
  wire mc_config_valid;
  wire [BURST_LENGTH_WIDTH-1 : 0] mc_config_bl;
  wire mc_config_last;

  ////img
  wire [7:0] mc_img_addr;
  wire mc_img_rdreq;
  wire mc_img_valid;
  wire [BURST_LENGTH_WIDTH-1 : 0] mc_img_bl;
  wire mc_img_last;

  /////conv
  wire [7:0] mc_wghts_addr;
  wire mc_wghts_rdreq;
  wire mc_wghts_valid;
  wire [BURST_LENGTH_WIDTH-1 : 0] mc_wghts_bl;
  wire mc_wghts_last;

  ///////fc
  wire [7:0] mc_fc_addr;
  wire mc_fc_rdreq;
  wire mc_fc_valid;
  wire [BURST_LENGTH_WIDTH-1 : 0] mc_fc_bl;
  wire mc_fc_last;

  //////////bias 
  wire [7:0] mc_bias_addr;
  wire mc_bias_rdreq;
  wire mc_bias_valid;
  wire [BURST_LENGTH_WIDTH-1 : 0] mc_bias_bl;
  wire mc_bias_last;

  ///////////////fc_bias 
  wire [7:0] mc_fc_bias_addr;
  wire mc_fc_bias_rdreq;
  wire mc_fc_bias_valid;
  wire [BURST_LENGTH_WIDTH-1 : 0] mc_fc_bias_bl;
  wire mc_fc_bias_last;

  /////////////acc
  wire [7:0] mc_acc_addr;
  wire mc_acc_rdreq;
  wire mc_acc_valid;
  wire [BURST_LENGTH_WIDTH-1:0] mc_acc_bl;
  wire mc_acc_last;

  /////////////wire write ctrl
  wire [7:0] mc_op_write_addr;
  wire mc_op_writereq;
  wire mc_op_write_valid;
  wire [BURST_LENGTH_WIDTH-1 : 0] mc_op_write_bl;
  wire mc_op_write_last;

  ///////////////////////operators data

  //Signals from DRAM ctrl to internal operator blocks
  wire [NUM_PORTS-1:0] select;
  assign select = select_rd | select_wr;
  //Read block signals
  // wire sel_rd
  wire dram_rd_datavalid;
  wire dram_rd_data_last;
  wire [AXI_DATA_WIDTH - 1 : 0] dram_rd_data;

  //op_write block signals
  // wire sel_op_write; // Todo: have to check ; wheteher sel is common or not
  wire [BURST_LENGTH_WIDTH-1 : 0] wr_burst_len;
  wire dv_op_write;
  wire data_last_op_write;
  wire [(OP_FIFO*DATA_WIDTH_OB)-1:0] op_dram_fifo;


  top_gati_module #(
      .INST_QUEUE_DEPTH(INST_QUEUE_DEPTH),
      .DRAM_IMG_FIFO_DEPTH(DRAM_IMG_FIFO_DEPTH),
      .IM2COL_FIFO_DEPTH(IM2COL_FIFO_DEPTH),
      .WEIGHT_FIFO_DEPTH(WEIGHT_FIFO_DEPTH),
      .PSUM_FIFO_DEPTH(PSUM_FIFO_DEPTH),
      .ACC_FIFO_DEPTH(ACC_FIFO_DEPTH),
      .BIAS_FIFO_DEPTH(BIAS_FIFO_DEPTH),
      .OP_WRITE_FIFO_DEPTH(OP_WRITE_FIFO_DEPTH),
      .CONFIG_REQ_BLEN(CONFIG_REQ_BLEN),
      .IMG_REQ_BLEN(IMG_REQ_BLEN),
      .WEIGHT_REQ_BLEN(WEIGHT_REQ_BLEN),
      .ACC_REQ_BLEN(ACC_REQ_BLEN),
      .BIAS_REQ_BLEN(BIAS_REQ_BLEN),
      .OP_WRITE_REQ_ACC_BLEN(OP_WRITE_REQ_ACC_BLEN),
      .OP_WRITE_REQ_QUA_BLEN(OP_WRITE_REQ_QUA_BLEN),
      .NUM_PORTS(NUM_PORTS),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .AXI_ADDR_W(AXI_ADDR_W),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .NUM_INSTRUCTIONS(NUM_INSTRUCTIONS),
      .INST_W(INST_W),
      .CONFIG_FIFO_OCCUPANCY(CONFIG_FIFO_OCCUPANCY),
      .LAYERCNT_WIDTH(LAYERCNT_WIDTH),
      .TOTAL_LAYERCNT_WIDTH(TOTAL_LAYERCNT_WIDTH),
      .OPCODE_WIDTH(OPCODE_WIDTH),
      .CONV_IW_WIDTH(CONV_IW_WIDTH),
      .CONV_IH_WIDTH(CONV_IH_WIDTH),
      .CONV_OW_WIDTH(CONV_OW_WIDTH),
      .CONV_OH_WIDTH(CONV_OH_WIDTH),
      .CONV_IC_WIDTH(CONV_IC_WIDTH),
      .CONV_KN_WIDTH(CONV_KN_WIDTH),
      .CONV_KW_WIDTH(CONV_KW_WIDTH),
      .CONV_KH_WIDTH(CONV_KH_WIDTH),
      .CONV_STRIDE_WIDTH(CONV_STRIDE_WIDTH),
      .CONV_PAD_WIDTH(CONV_PAD_WIDTH),
      .POP_THRESHOLD(POP_THRESHOLD),
      .NSA_DSP(NSA_DSP),
      .NSA_LUT(NSA_LUT),
      .N_SA(N_SA),
      .DATA_WIDTH(DATA_WIDTH),
      .COL_SA(COL_SA),
      .COL_FC(COL_FC),
      .ROW(ROW),
      .W_PSUM(W_PSUM),
      .DATA_WIDTH_OB(DATA_WIDTH_OB),
      .IMAGE_DIM(IMAGE_DIM),
      .FC_WEIGHTROW_WIDTH(FC_WEIGHTROW_WIDTH),
      .FC_WEIGHTCOL_WIDTH(FC_WEIGHTCOL_WIDTH),
      .FC_IMAGE_ROWS_WIDTH(FC_IMAGE_ROWS_WIDTH),
      .FC_DROPOUT_WIDTH(FC_DROPOUT_WIDTH),
      .W_FC_IMAG_DIM(W_FC_IMAG_DIM),
      .W_FC_RW_COUNTER(W_FC_RW_COUNTER),
      .FLATTEN_EN_WIDTH(FLATTEN_EN_WIDTH),
      .ACC_DW(ACC_DW),
      .N_BANK(N_BANK),
      .N_BRAM(N_BRAM),
      .FC_BRAM_DEPTH(FC_BRAM_DEPTH),
      .ACC_DATA_REORDER(ACC_DATA_REORDER),
      .N_FC_MUX(N_FC_MUX),
      .NO_PORT_FC(NO_PORT_FC),
      .W_CITER_CNT(W_CITER_CNT),
      .W_KITER_CNT(W_KITER_CNT),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
      .ACCEN_WIDTH(ACCEN_WIDTH),
      .MOD1(MOD1),
      .MOD2(MOD2),
      .N_DMUX_PORTS(N_DMUX_PORTS),
      .BNCHANNEL_WIDTH(BNCHANNEL_WIDTH),
      .ACT_TYPE_WIDTH(ACT_TYPE_WIDTH),
      .RELU_CLIP_WIDTH(RELU_CLIP_WIDTH),
      .W_QUANT_SHIFT(W_QUANT_SHIFT),
      .W_QUANT_SCALE(W_QUANT_SCALE),
      .POOL_TYPE_WIDTH(POOL_TYPE_WIDTH),
      .W_POOL_WIDTH(W_POOL_WIDTH),
      .W_POOL_HEIGHT(W_POOL_HEIGHT),
      .W_POOL_STRIDE(W_POOL_STRIDE),
      .W_POOL_PAD(W_POOL_PAD),
      .BNEN_WIDTH(BNEN_WIDTH),
      .ACTEN_WIDTH(ACTEN_WIDTH),
      .QUANTEN_WIDTH(QUANTEN_WIDTH),
      .POOLEN_WIDTH(POOLEN_WIDTH),
      .BIASEN_WIDTH(BIASEN_WIDTH),
      .FCBIASEN_WIDTH(FCBIASEN_WIDTH),
      .SHFT_REG_X(SHFT_REG_X),
      .BIAS_FIFO(BIAS_FIFO),
      .OP_FIFO(OP_FIFO),
      .BIAS_FIFO_FC(BIAS_FIFO_FC),
      .NO_PORT_VA(NO_PORT_VA),
      .NO_PORT_BAC(NO_PORT_BAC),
      .NO_PORT_BAFC(NO_PORT_BAFC)
    ) top_gati_module (
      .i_clk(i_clk),
      .s_clk(s_clk),
      .i_rst(i_rst),
      .user_start(user_start),
      .mc_config_addr(mc_config_addr),
      .mc_config_rdreq(mc_config_rdreq),
      .mc_config_valid(mc_config_valid),
      .mc_config_bl(mc_config_bl),
      .mc_config_last(mc_config_last),
      .mc_img_addr(mc_img_addr),
      .mc_img_rdreq(mc_img_rdreq),
      .mc_img_valid(mc_img_valid),
      .mc_img_bl(mc_img_bl),
      .mc_img_last(mc_img_last),
      .mc_wghts_addr(mc_wghts_addr),
      .mc_wghts_rdreq(mc_wghts_rdreq),
      .mc_wghts_valid(mc_wghts_valid),
      .mc_wghts_bl(mc_wghts_bl),
      .mc_wghts_last(mc_wghts_last),
      .mc_fc_addr(mc_fc_addr),
      .mc_fc_rdreq(mc_fc_rdreq),
      .mc_fc_valid(mc_fc_valid),
      .mc_fc_bl(mc_fc_bl),
      .mc_fc_last(mc_fc_last),
      .mc_bias_addr(mc_bias_addr),
      .mc_bias_rdreq(mc_bias_rdreq),
      .mc_bias_valid(mc_bias_valid),
      .mc_bias_bl(mc_bias_bl),
      .mc_bias_last(mc_bias_last),
      .mc_fc_bias_addr(mc_fc_bias_addr),
      .mc_fc_bias_rdreq(mc_fc_bias_rdreq),
      .mc_fc_bias_valid(mc_fc_bias_valid),
      .mc_fc_bias_bl(mc_fc_bias_bl),
      .mc_fc_bias_last(mc_fc_bias_last),
      .mc_acc_addr(mc_acc_addr),
      .mc_acc_rdreq(mc_acc_rdreq),
      .mc_acc_valid(mc_acc_valid),
      .mc_acc_bl(mc_acc_bl),
      .mc_acc_last(mc_acc_last),
      .mc_op_write_addr(mc_op_write_addr),
      .mc_op_writereq(mc_op_writereq),
      .mc_op_write_valid(mc_op_write_valid),
      .mc_op_write_bl(mc_op_write_bl),
      .mc_op_write_last(mc_op_write_last),
      .select(select),
      .dram_rd_datavalid(dram_rd_datavalid),
      .dram_rd_data_last(dram_rd_data),
      .wr_burst_len(wr_burst_len),
      .dv_op_write(dv_op_write),
      .data_last_op_write(data_last_op_write),
      .op_dram_fifo(op_dram_fifo)
  );
  ///////////////////////////////	

  //////////////////////////////////// MIPI controller tx

  ///////////////////////////////////

endmodule




