`include "common/instructions.vh"
`include "common/portid.vh"

module top_gati_module #(
    
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
    parameter NUM_PORTS = 9, //Number of read and write requestors

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
    ///global
    input i_clk,
    input s_clk,
    input i_rst,
    
    ///////config block input
    input user_start,

    //signals to DRAM ctrler
    ////config
    output [7:0] mc_config_addr,
    output mc_config_rdreq,
    output mc_config_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_config_bl,
    output mc_config_last,

    ////img
    output [7:0] mc_img_addr,
    output mc_img_rdreq,
    output mc_img_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_img_bl,
    output mc_img_last,

    /////conv
    output [7:0] mc_wghts_addr,
    output mc_wghts_rdreq,
    output mc_wghts_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_wghts_bl,
    output mc_wghts_last,
    
    ///////fc
    output [7:0] mc_fc_addr,
    output mc_fc_rdreq,
    output mc_fc_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_fc_bl,
    output mc_fc_last,

    //////////bias 
    output [7:0] mc_bias_addr,
    output mc_bias_rdreq,
    output mc_bias_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_bias_bl,
    output mc_bias_last,

    ///////////////fc_bias 
    output [7:0] mc_fc_bias_addr,
    output mc_fc_bias_rdreq,
    output mc_fc_bias_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_fc_bias_bl,
    output mc_fc_bias_last,

    /////////////acc
    output [7:0] mc_acc_addr,
    output mc_acc_rdreq,
    output mc_acc_valid,
    output [BURST_LENGTH_WIDTH-1: 0] mc_acc_bl,
    output mc_acc_last,

    /////////////output write ctrl
    output [7:0] mc_op_write_addr,
    output mc_op_writereq,
    output mc_op_write_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_op_write_bl,
    output mc_op_write_last,
    
    ///////////////////////operators data
    
    //Signals from DRAM ctrl to internal operator blocks
    input [NUM_PORTS-1:0] select,
    //Read block signals
    // input sel_rd
    input dram_rd_datavalid,
    input dram_rd_data_last,
    input [AXI_DATA_WIDTH - 1 : 0] dram_rd_data,

    //op_write block signals
    // input sel_op_write, // Todo: have to check , wheteher sel is common or not
    input [BURST_LENGTH_WIDTH-1 : 0] wr_burst_len,
    input wready,
    output dv_op_write,
    output data_last_op_write,
    output [(OP_FIFO*DATA_WIDTH_OB)-1:0] op_dram_fifo

);

    // localparam NUM_QUEUE = NUM_PORTS; //number of Requestor queues in DRAM controller
    localparam BUS_DATA_OUT = 8;
    localparam CNT = INST_W/BUS_DATA_OUT;

    /*
    Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(1) // Instruction queue in config blk
    ) Config_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`Config]), // select signal of config blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(instruction_config), //o-wire: to config blk
        .o_dram_fifo_wren(valid), //o-wire: to config blk
        .o_data_last()
    );

    wire [INST_W-1:0] instruction_config;
    wire valid_config;
    */
  
    wire [NUM_INSTRUCTIONS-1:0] ack_signals; //Ack from various operators = number of instructions
    assign ack_signals[`OP_CONV] = Conv_Ack;
    assign ack_signals[`OP_FC] = FC_Ack;
    assign ack_signals[`OP_OutputBlock] = OpBlock_Ack;
    assign ack_signals[`OP_TailBlock] = Tail_Ack;
  
    wire [INST_W-1 : 0] instruction;
    wire start_bus;   //start signal to bus master to dispatch inst. to the corresponding slave blocks
    wire [OPCODE_WIDTH-1:0] opcode_config; //opcode to bus master to select the appropriate slave
    wire Conv_Ack, OpBlock_Ack, Tail_Ack, FC_Ack; // Acknowledgment signals to config blk to prefetch the inst.
    
    assign opcode_config = instruction[OPCODE_WIDTH-1:0];

    wire [NUM_INSTRUCTIONS-1:0] start_command;

    wire start_out,start;
    assign start = start_out;

    wire [NUM_INSTRUCTIONS-1 : 0] valid_inst;

  config_blk#(
      .ADDR_W(AXI_ADDR_W),
      .INST_W(INST_W),
      .NUM_INSTRUCTIONS(NUM_INSTRUCTIONS),
      .BURST_LEN_AXI(CONFIG_REQ_BLEN),
      .BURST_LEN_WIDTH(BURST_LENGTH_WIDTH),
      .OPCODE_W(OPCODE_WIDTH),
      .DEPTH(INST_QUEUE_DEPTH),
      .STATUS_DRAM_LIM(CONFIG_FIFO_OCCUPANCY),
      .LAY_N(LAYERCNT_WIDTH),
      .TOTAL_LAY_N(TOTAL_LAYERCNT_WIDTH)
  ) config_blk_inst (
      .clkin(i_clk),
      .user_start(user_start),
      .valid(dram_rd_datavalid),
      .sel(select[`Config]),
      .instruction_data(dram_rd_data),
      .memory_read_r(mc_config_rdreq),
      .memory_valid(mc_config_valid),
      .mem_address(mc_config_addr),
      .mem_last(mc_config_last),
      .mem_burst_len(mc_config_bl),
      .ack_signals(ack_signals),
      .start_command(start_command),
      .start_out(start_out), //o-wire: start signal to the operators 
      .done(|(valid_inst)), //i-wire: from bus master
      .o_instruction_bus(instruction),
      .start_bus(start_bus), //o-wire: goes to bus master
      .o_instruction_bus_v() 
  );
  
  // localparam APPEND = ((1<<OP_CODE_WIDTH) - NUM_INSTRUCTIONS);
 
  
  //CONV inst. signals
  wire [OPCODE_WIDTH-1:0] conv_opcode;
  wire [CONV_IW_WIDTH-1 : 0] input_img_width; 
  wire [CONV_IH_WIDTH-1 : 0] input_img_height;
  wire [CONV_OW_WIDTH-1 : 0] conv_op_width;
  wire [CONV_OH_WIDTH-1 : 0] conv_op_height; 

  wire [CONV_KN_WIDTH-1:0] n_kernels;
  wire [CONV_KW_WIDTH-1:0] kernel_width;
  wire [CONV_KH_WIDTH-1:0] kernel_height;
  wire [CONV_STRIDE_WIDTH-1:0] stride;
  wire [CONV_PAD_WIDTH-1:0] conv_zeropad;

  wire [AXI_ADDR_W-1:0] start_address_weights;
  wire [AXI_ADDR_W-1:0] stop_address_weights;
  wire [AXI_ADDR_W-1:0] weight_start_addr_conv;
  wire [AXI_ADDR_W-1:0] weight_stop_addr_conv;
  wire [AXI_ADDR_W-1:0] weight_start_addr_fc;
  wire [AXI_ADDR_W-1:0] weight_stop_addr_fc;
  
  //FC inst. signals
  wire [OPCODE_WIDTH-1:0] fc_opcode;
  wire [FC_WEIGHTCOL_WIDTH-1:0] fc_weightcols;
  wire [FC_WEIGHTCOL_WIDTH-1:0] fc_weightrows;
  wire [W_FC_IMAG_DIM-1:0] fc_imagedim;  //goes to FC block
  wire [W_KITER_CNT-1:0] fc_kernel_iter;
  wire [W_FC_RW_COUNTER-1:0] fc_rw_address_counter; 
  wire [FC_IMAGE_ROWS_WIDTH-1:0] fc_image_rows; 
  wire [FLATTEN_EN_WIDTH-1:0] flatten_enable;
  wire [AXI_ADDR_W-1:0] fc_img_start_address;
  wire [AXI_ADDR_W-1:0] fc_img_stop_address;

  //OP block inst. signals
  wire [OPCODE_WIDTH-1:0] Op_code_OB;
  wire [I_ACC_SIZE_WIDTH-1:0] img_dim_Acc;
  wire [I_OP_SIZE_WIDTH-1:0] img_dim_Op;
  wire [ACCEN_WIDTH-1:0] ACC_EN;
  wire [AXI_ADDR_W-1:0] acc_start_address;
  wire [AXI_ADDR_W-1:0] acc_stop_address;
  wire [AXI_ADDR_W-1:0] op_start_address;

  //Tail inst. signals
  wire [OPCODE_WIDTH-1:0] Op_code_TB;
  wire [RELU_CLIP_WIDTH-1:0] relu_clip_value;
  wire [W_QUANT_SHIFT-1:0] tail_quantshift;
  wire [W_QUANT_SCALE-1:0] tail_quantscale;
  wire [ACTEN_WIDTH-1:0] ACT_EN;
  wire [QUANTEN_WIDTH-1:0] QUANT_EN;
  wire [BIASEN_WIDTH-1:0] BIAS_EN;
  wire [FCBIASEN_WIDTH-1:0] FC_BIAS_EN;
  wire [POOLEN_WIDTH-1:0] POOL_EN;
  wire [AXI_ADDR_W-1:0] bias_start_address;
  wire [AXI_ADDR_W-1:0] bias_stop_address;

  // start and end address signals for memory request controllers

  wire [AXI_ADDR_W-1:0] img_start_address;
  wire [W_CITER_CNT-1:0] channel_iteration; 
  wire [W_KITER_CNT-1:0] kernel_iteration; 
  wire [AXI_ADDR_W-1:0] img_stop_address;

  wire layer_done;
  wire FC_layerdone;
  reg valid_conv, valid_fc;

  always@(posedge i_clk) begin
    if(!i_rst) begin
        valid_conv <= 0;
    end 
    else begin
        if(valid_inst[`OP_CONV])
            valid_conv <= 1'b1;
        else if(layer_done)
            valid_conv <= 1'b0;
    end
  end
  
  always@(posedge i_clk) begin
    if(!i_rst) begin
        valid_fc <= 0;
    end 
    else begin
        if(valid_inst[`OP_FC])
            valid_fc <= 1'b1;
        else if(FC_layerdone)
            valid_fc <= 1'b0;
    end
  end

  reg [OPCODE_WIDTH-1:0] opcode;
  reg valid_inst_CONV_FC;
  reg CONV_FC;
  
//   assign valid_conv = valid_inst[`OP_CONV];
//   assign valid_fc   = valid_inst[`OP_FC];

  //Generation of CONV_FC signal
  always@(posedge i_clk) begin
    if(!i_rst) begin
        valid_inst_CONV_FC <= 0;
        CONV_FC <= 0;
    end
    else begin
        if(valid_conv) begin
            opcode <= conv_opcode;
            valid_inst_CONV_FC <= 1;
            CONV_FC <= 0;
        end
        else if(valid_fc) begin
            opcode <= fc_opcode;
            valid_inst_CONV_FC <= 1;
            CONV_FC <= 1;
        end
        else begin
            opcode <= opcode;
            valid_inst_CONV_FC <= 0;
            CONV_FC <= CONV_FC;
        end
    end
  end

  //Generation of start_SA and start_FC
  wire start_SA,start_FC;
  assign start_SA = (CONV_FC==0)? start : 1'b0;
  assign start_FC = (CONV_FC==1)? start : 1'b0;
//   assign {start_SA,start_FC} = (CONV_FC==0)? {start,1'b0} : {1'b0,start};
 
  reg systolic_array_trigger;
  reg Flattening_trigger;

  // Generation of systolic array and flattening module triggers
  always@(posedge i_clk) begin
    if(!i_rst) systolic_array_trigger <= 1'b0;
    else begin
        if(start_SA) systolic_array_trigger <= 1'b1;
        else if(layer_done) systolic_array_trigger <= 1'b0;
        else systolic_array_trigger <= systolic_array_trigger;
    end
  end

  always@(posedge i_clk) begin
    if(!i_rst) Flattening_trigger <= 1'b0;
    else begin
        if(start_FC) Flattening_trigger <= 1'b1;
        else if(FC_layerdone) Flattening_trigger <= 1'b0;
        else Flattening_trigger <= Flattening_trigger;
    end
  end

  // top_master_slave_integrate
  top_master_slave_integrate#(
    .OP_CODE_WIDTH(OPCODE_WIDTH),
    .INPUT_WIDTH(INST_W),
    .OUTPUT_WIDTH(BUS_DATA_OUT),
    .NO_OF_OPERATOR(NUM_INSTRUCTIONS),
    .CNT(CNT),
    .ADDRESS_WIDTH(AXI_ADDR_W),
    .IW_WIDTH(CONV_IW_WIDTH),
    .IH_WIDTH(CONV_IH_WIDTH),
    .OW_WIDTH(CONV_OW_WIDTH),
    .OH_WIDTH(CONV_OH_WIDTH),
    .IC_WIDTH(CONV_IC_WIDTH),
    .KN_WIDTH(CONV_KN_WIDTH),
    .KH_WIDTH(CONV_KH_WIDTH),
    .KW_WIDTH(CONV_KW_WIDTH),
    .STRIDE_WIDTH(CONV_STRIDE_WIDTH),
    .PAD_WIDTH(CONV_PAD_WIDTH),
    .WEIGHTROWS_WIDTH(FC_WEIGHTROW_WIDTH),
    .WEIGHTCOLS_WIDTH(FC_WEIGHTCOL_WIDTH),
    .INPUTROWS_WIDTH(FC_IMAGE_ROWS_WIDTH),
    .DROPOUTCONSTANT_WIDTH(FC_DROPOUT_WIDTH),
    .FLATTEN_WIDTH(FLATTEN_EN_WIDTH),
    .IMAGEDIN_WIDTH(W_FC_IMAG_DIM),
    .FC_VEC2MATCOL_WIDTH(W_FC_RW_COUNTER),
    .CHANNELITR_WIDTH(W_CITER_CNT),
    .KERNELITR_WIDTH(W_KITER_CNT),
    .IMAGEDIMOUTPUT_WIDTH(I_OP_SIZE_WIDTH),
    .IMAGEDIMACC_WIDTH(I_ACC_SIZE_WIDTH),
    .ACCEN_WIDTH(ACCEN_WIDTH),
    .BNEN_WIDTH(BNEN_WIDTH),
    .ACTEN_WIDTH(ACTEN_WIDTH),
    .ACTTYPE_WIDTH(ACT_TYPE_WIDTH),
    .ACTPARAM_WIDTH(RELU_CLIP_WIDTH),
    .QUANTEN_WIDTH(QUANTEN_WIDTH),
    .QUANTSCALE_WIDTH(W_QUANT_SCALE),
    .QUANTSHIFT_WIDTH(W_QUANT_SHIFT),
    .POOLEN_WIDTH(POOLEN_WIDTH),
    .POOLTYPE_WIDTH(POOL_TYPE_WIDTH),
    .POOLWIDTH_WIDTH(W_POOL_WIDTH),
    .POOLHEIGHT_WIDTH(W_POOL_HEIGHT),
    .POOLSTRIDE_WIDTH(W_POOL_STRIDE),
    .POOLPADDING_WIDTH(W_POOL_PAD),
    .BIASEN_WIDTH(BIASEN_WIDTH),
    .BNCHANNELS_WIDTH(BNCHANNEL_WIDTH),
    .FCBIASEN(FCBIASEN_WIDTH)
  )
  bus_inst(
    .din(instruction), //i-wire : instruction from config blk
    .start(start_bus), //i-wire: start from config blk
    .clk(i_clk),
    .opcode(opcode_config), //i-wire: opcode form config blk,
    .valid(valid_inst),

    //OP_CONV inst signals
    .opcode_conv(conv_opcode),
    .IW(input_img_width),
    .IH(input_img_height),
    .OW(conv_op_width),
    .OH(conv_op_height),
    .IC(),
    .KN(n_kernels),
    .KW(kernel_width),
    .KH(kernel_height),
    .Stride(stride),
    .Pad(conv_zeropad),
    .ImageStartAddress_conv(img_start_address),
    .ImageEndAddress_conv(img_stop_address),
    .WeightStartAddress_conv(weight_start_addr_conv),
    .WeightEndAddress_conv(weight_stop_addr_conv),

    //FC inst. signals
    .opcode_FC(fc_opcode),
    .weightrows(fc_weightrows),
    .weightcols(fc_weightcols),
    .inputrows(fc_image_rows), //o-wire: goes to FC
    .dropoutconstant(),
    .flatten(flatten_enable),
    .imagedim_FC(fc_imagedim), //o-wire: goes to flatten ctrler
    .ImageStartAddress_FC(fc_img_start_address),
    .ImageEndAddr_FC(fc_img_stop_address),
    .WeightStartAddress_FC(weight_start_addr_fc),
    .WeightEndAddress_FC(weight_stop_addr_fc),
    .FC_Vec2MatCols(fc_rw_address_counter), //read/write address cnt goes to flattening

    //OP block inst. signals
    .opcode_OB(Op_code_OB),
    .accumulantaddr(acc_start_address),
    .outputaddr(op_start_address),
    .channelItr(channel_iteration),
    .kernelItr(kernel_iteration),
    .ImageDimOutput(img_dim_Op),
    .ImageDimAcc(img_dim_Acc),
    .AccEn(ACC_EN),

    //Tail inst. signals
    .opcode_TB(Op_code_TB),
    .BNEn(),
    .BNchannels(),
    .BNStartAddress(),
    .BNEndAddress(),
    .ActEn(ACT_EN),
    .acttype(),
    .ActParam(relu_clip_value),
    .QuantEn(QUANT_EN), // goes to iteration cter
    .quantscale(tail_quantscale),
    .quantshift(tail_quantshift),
    .PoolEn(POOL_EN), //goes to iteration cter
    .pooltype(),
    .poolwidth(),
    .poolheight(),
    .poolstride(),
    .poolpadding(),
    .BiasEn(BIAS_EN),  //goes to iteration cter and bias req ctrler
    .FCBiasEn(FC_BIAS_EN), //goes to iteration cter and fc_bias req ctrler
    .BiasStartAddress(bias_start_address),
    .BiasEndAddress(bias_stop_address)
  );
  
  // fifo status signals for memory request controllers
  wire img_fifo_status;
  wire weight_fifo_status;
  wire acc_fifo_status;
  wire bias_fifo_status;
  wire fc_bias_fifo_status;
  wire fc_img_fifo_status;
  // wire [(($clog2(OP_WRITE_FIFO_DEPTH)+1)*OP_FIFO)-1:0] op_write_dram_fifo_occupants;
  
  wire iter_done;
  wire channel_done;

  // Memory request controllers - img, weight, bias etc
  request_controller_img #(
      .BURST_LENGTH(IMG_REQ_BLEN),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),  
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .KERNELITR_WIDTH(W_KITER_CNT),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH)
  ) image_req_ctrl (
      .start_addr(img_start_address),
      .kernelitr(kernel_iteration),
      .stop_addr(img_stop_address),
      .config_start(start_SA),
      .fifo_status(img_fifo_status),
      .clk(i_clk),
      .c_done(channel_done),
      
      //signals goes to memory controller
      .addr_out(mc_img_addr),
      .wr_enable(mc_img_rdreq),
      .valid(mc_img_valid),
      .burst_length(mc_img_bl),
      .last(mc_img_last)
  );
  
    
  //CONV_FC = 1 => FC mode , else CONV mode
  assign start_address_weights  = CONV_FC ? weight_start_addr_fc : weight_start_addr_conv;
  assign stop_address_weights   = CONV_FC ? weight_stop_addr_fc  : weight_stop_addr_conv;
  wire weight_data_last; 
  request_controller_weights #(
      .BURST_LENGTH(WEIGHT_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) weight_req_ctrl (
      .start_addr(start_address_weights),
      .stop_addr(stop_address_weights),
      .config_start(start),
      .fifo_status(weight_fifo_status),
      .data_last(weight_data_last),
      .clk(i_clk),
      .addr_out(mc_wghts_addr),
      .wr_enable(mc_wghts_rdreq),
      .valid(mc_wghts_valid),
      .burst_length(mc_wghts_bl),
      .last(mc_wghts_last)
  );

  
  request_controller_FC #(
      .BURST_LENGTH(IMG_REQ_BLEN),
      .AXI_DATA_BYTES  (AXI_DATA_BYTES),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) fc_image_req_ctrl (
      .start_addr(fc_img_start_address),
      .stop_addr(fc_img_stop_address),
      .config_start(start_FC),
      .fifo_status(fc_img_fifo_status),
      .clk(i_clk),
      .addr_out(mc_fc_addr),
      .wr_enable(mc_fc_rdreq),
      .valid(mc_fc_valid),
      .burst_length(mc_fc_bl),
      .last(mc_fc_last)
  );


  request_controller_bias #(
      .BURST_LENGTH(BIAS_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) bias_req_ctrl (
      .start_addr(bias_start_address),
      .stop_addr(bias_stop_address),
      .config_start(start_SA),
      .fifo_status(bias_fifo_status),
      .Biasen(BIAS_EN), 
      .clk(i_clk),
      .addr_out(mc_bias_addr),
      .wr_enable(mc_bias_rdreq),
      .valid(mc_bias_valid),
      .burst_length(mc_bias_bl),
      .last(mc_bias_last)
  );

  request_controller_FCbias #(
      .BURST_LENGTH(BIAS_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) FCbias_req_ctrl (
      .start_addr(bias_start_address),
      .stop_addr(bias_stop_address),
      .config_start(start_FC),
      .fifo_status(fc_bias_fifo_status),
      .FCbiasen(FC_BIAS_EN), 
      .clk(i_clk),
      .addr_out(mc_fc_bias_addr),
      .wr_enable(mc_fc_bias_rdreq),
      .valid(mc_fc_bias_valid),
      .burst_length(mc_fc_bias_bl),
      .last(mc_fc_bias_last)
  );

  
  wire im2col_global_start;
  wire vector_add_enable;

  assign acc_stop_address = acc_start_address + (img_dim_Acc*COL_SA)*(DATA_WIDTH_OB/DATA_WIDTH);

  request_controller_accumulator #(
      .BURST_LENGTH(ACC_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) acc_req_ctrl (
      .start_addr(acc_start_address),
      .stop_addr(acc_stop_address),
      .config_start(im2col_global_start), //start from im2col start ctrler
      .fifo_status(acc_fifo_status),
      .clk(i_clk),
      .enable(ACC_EN), // ACC_EN comes from inst. whether is enabled in this layer or not
      .ENABLE(vector_add_enable), // acc_en comes from iteration cter to enable it in current iteration based on the instruction field
      .addr_out(mc_acc_addr),
      .wr_enable(mc_acc_rdreq),
      .valid(mc_acc_valid),
      .burst_length(mc_acc_bl),
      .last(mc_acc_last)
  );

  wire [OP_FIFO-1:0] op_dram_fifo_empty;
  wire [(($clog2(OP_WRITE_FIFO_DEPTH)+1)*OP_FIFO)-1:0] op_write_dram_fifo_occupants;
  top_op_write_mem_req_ctrl#(
    .N(OP_FIFO),
    .DEPTH(OP_WRITE_FIFO_DEPTH),
    .BURST_LENGTH(OP_WRITE_REQ_ACC_BLEN),
    .BURST_LENGTH_2(OP_WRITE_REQ_QUA_BLEN),
    .NUMBER_ACC(MOD1),
    .NUMBER_OP(MOD2),
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .ADDR_WIDTH(AXI_ADDR_W),
    .W_KERNEL_CNT(W_KITER_CNT),
    .W_CHANNEL_CNT(W_CITER_CNT),
    .IMAGE_DIM_WIDTH_ACC(I_ACC_SIZE_WIDTH),
    .IMAGE_DIM_WIDTH_OP(I_OP_SIZE_WIDTH) 
  )
  op_write_mem_req_ctrler(
    .clkin(i_clk),
    .i_rstn(i_rst),
    .i_start(start),
    .i_data_last(data_last_op_write), //i-wire: data last signal from dram write controller
    .i_acc_address(acc_start_address), //i-wire: accumulant start address from inst.
    .i_op_start(op_start_address), //i-wire: start address of quantized o/p from inst.
    .i_channel_itr(channel_iteration),
    .i_kernel_itr(kernel_iteration),
    .i_imag_dim(img_dim_Acc),
    .i_imag_dim_2(img_dim_Op), //i-wire: above four from inst.
    .occupants(op_write_dram_fifo_occupants), // i-wire: op_write dram fifo occupants
    // .mem_req(), //not required
    // .img_done_acc(), //not required
    // .img_done_op(), //not required
    .o_read_write_req(mc_op_writereq),
    .o_valid(mc_op_write_valid),
    .o_address(mc_op_write_addr),
    .o_burst_len(mc_op_write_bl),
    .o_last(mc_op_write_last)
  );

  ////////////////////////////////FIFO FOR IMAGE FROM DDR////////////////
  
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] image_fifo_in_data;
  wire [AXI_DATA_BYTES-1:0] image_wren;

  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(AXI_DATA_BYTES) // Image FIFOs = 32
  )Image_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`Image]), // select signal of image fifo blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(image_fifo_in_data), //o-wire: to image fifo blk
        .o_dram_fifo_wren(image_wren),  //o-wire: to image fifo blk
        .o_data_last()
  );
   
  wire [AXI_DATA_BYTES-1:0] image_rden;
  wire [AXI_DATA_BYTES-1:0] image_fifo_empty;
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] fifo_imgo_data;
  wire [(($clog2(DRAM_IMG_FIFO_DEPTH)+1)*(AXI_DATA_BYTES))-1:0] img_fifo_occupants; 

  assign img_fifo_status = (img_fifo_occupants<={AXI_DATA_BYTES{input_img_width/8}})? 1 : 0;
  //fifo img
  
  dram_fifo #(
      .DIMENSION(AXI_DATA_BYTES),
      .W_DATA(DATA_WIDTH),
      .W_ADDR($clog2(DRAM_IMG_FIFO_DEPTH)),
      .RAM_DEPTH(DRAM_IMG_FIFO_DEPTH)
  ) image_ddr_fifo (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data(image_fifo_in_data),
      .i_read_enable(image_rden),
      .i_write_enable(image_wren),
      .o_data(fifo_imgo_data),
      .o_fifo_empty(image_fifo_empty),
      .o_fifo_full(),
      .o_fifo_dv(),
      .o_occupants(img_fifo_occupants)
  );
  
  //fifo weight 
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] weight_fifo_in_dram;
  wire [AXI_DATA_BYTES-1:0] dv_dram_weight;
  

  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(AXI_DATA_BYTES) 
  )Weight_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`Weight]), // select signal of weight fifo blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(weight_fifo_in_dram), //o-wire: to weight fifo blk
        .o_dram_fifo_wren(dv_dram_weight), //o-wire: to weight fifo blk
        .o_data_last(weight_data_last)
  );

  localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;
  wire [(COL * DATA_WIDTH)-1 : 0] weight_dram_fifosharing;
  wire [COL-1 : 0] weight_write_en_fifosharing;

  fifo_sharing_weight_wren_ctrl#(
    .SA_OPCODE(`OP_CONV),
    .FC_OPCODE(`OP_FC),
    .OPCODE_WIDTH(OPCODE_WIDTH),
    .N_SA(N_SA),
    .COL_SA(COL_SA),
    .COL_FC(COL_FC),
    .DRAM_BW(AXI_DATA_BYTES),
    .DATA_WIDTH(DATA_WIDTH)
  ) fifo_sharing_wren(
    .i_clk(i_clk),
    .rst(i_rst),
    .opcode(opcode),
    .valid_inst_CONV_FC(valid_inst_CONV_FC),
    .i_datavalid_dram_weight(dv_dram_weight), //i-wire: datavalid for weights from DDR
    .i_dram_weight(weight_fifo_in_dram), //i-wire: weights from DDR
    .weight_fifo_wren(weight_write_en_fifosharing), //o-wire: write enable signal to weight fifo array
    .o_dram_weight(weight_dram_fifosharing) //o-wire: weights to be written into weight fifo array 
  );

  //////////////FIFO SHARING FOR SYSTOLIC ARRAY AND FC//////////
  
   //Controller for FIFO sharing between Conv(SA) and FC
  
  // signals from Top_CONV_FC Block
  wire fc_mux_Sel;
  wire [COL_FC-1 : 0] weight_read_en_fc;
  wire [(COL_FC * ($clog2(WEIGHT_FIFO_DEPTH) + 1))-1 : 0] weight_occupants_fc;
  wire [COL_FC-1 : 0] weight_empty_fc;
  wire [COL_FC-1 : 0] weight_dv_fc;
  wire [(COL_FC * DATA_WIDTH)-1 : 0] weight_data_fc;

  wire sel_sa_rden;
  wire [(N_SA * COL_SA)-1 : 0] weight_read_en_sa;
  wire [(N_SA * COL_SA)-1 : 0] weight_dv_sa;
  wire [(N_SA * (COL_SA * ($clog2(WEIGHT_FIFO_DEPTH) + 1)))-1 : 0] weight_occupants_sa;
  wire [(N_SA * COL_SA)-1 : 0] weight_empty_sa;
  wire [(N_SA * COL_SA * DATA_WIDTH)-1 : 0] weight_data_sa;

  wire [(COL* ($clog2(WEIGHT_FIFO_DEPTH) + 1))-1 : 0] weight_fifo_occupants;

  assign weight_fifo_status = (CONV_FC==0)? 
                              ((weight_fifo_occupants<={AXI_DATA_BYTES{4*ROW}})? 1 : 0) : 
                              ((weight_fifo_occupants<={AXI_DATA_BYTES{(3/4)*(WEIGHT_FIFO_DEPTH)}})? 1 : 0);

  top_fifo_sharing#(
    .W_DATA(DATA_WIDTH),
    .N_SA(N_SA),
    .COL_SA(COL_SA),
    .COL_FC(COL_FC),
    .WEIGHT_FF_DEPTH(WEIGHT_FIFO_DEPTH),
    .N_DRAM_BYTES(AXI_DATA_BYTES),
    .SA_OPCODE(`OP_CONV), // CONV opcode from instructions.vh
    .FC_OPCODE(`OP_FC), // FC opcode from instructions.vh
    .W_OPCODE(OPCODE_WIDTH)
  ) fifo_Sharing_controller(
    .clk(i_clk),
    .i_rstn(i_rst),
    .i_sel_sa_rden_ctrl(sel_sa_rden), // i-wire: select signal (toggled/un-toggled) from sa
    .i_opcode(opcode), // i-wire - check it how to get this opcode from slave blocks
    .i_data_weight_ff_array(weight_dram_fifosharing),         //i-wire - from fifo sharing wren ctrler
    .i_write_en_weight_ff_array(weight_write_en_fifosharing), //i-wire - from fifo sharing wren ctrler
    .i_read_en_fc(weight_read_en_fc), // i-wire: wt readen from fc
    .i_read_en_sa(weight_read_en_sa), // i-wire: wt read en from SA
    .o_demux_select(fc_mux_Sel), // o-wire: goes to FC block for selecting the fifo array weights to FC block
    .o_occupants_mux_fc(weight_occupants_fc), //o-wire: fifo occupants applied to FC
    .o_empty_mux_fc(weight_empty_fc), //o-wire: fifo empty status to FC
    .o_dv_mux_fc(weight_dv_fc), //o-wire: wt datavalid to FC
    .o_data_mux_fc(weight_data_fc), //o-wire: weight inputs to FC
    .o_occupants_mux_sa(weight_occupants_sa), //o-wire: fifo occupants applied to SA
    .o_empty_mux_sa(weight_empty_sa), //o-wire: fifo empty status to SA
    .o_dv_mux_sa(weight_dv_sa), //o-wire: wt datavalid to SA
    .o_data_mux_sa(weight_data_sa), //o-wire: weight inputs to SA
    .o_weight_ff_array_occupants(weight_fifo_occupants) //o-wire: weight fifo occupants to weight req ctrler
  );

  assign fc_img_fifo_status = 1'b1;

  wire [(($clog2(ACC_FIFO_DEPTH)+1)*OP_FIFO)-1:0] acc_fifo_occupants;
  wire [(($clog2(BIAS_FIFO_DEPTH)+1)*OP_FIFO)-1:0] bias_fifo_occupants;
  wire [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO_FC)-1:0] fc_bias_fifo_occupants;

  //occupants of acc_fifo,bias_fifo and fc_bias_fifo comes from top_conv_sa block
  assign acc_fifo_status = (acc_fifo_occupants<={OP_FIFO{OP_FIFO}})? 1 : 0;
  assign bias_fifo_status = (bias_fifo_occupants<={OP_FIFO{COL_SA}})? 1 : 0;
  assign fc_bias_fifo_status = (fc_bias_fifo_occupants<={BIAS_FIFO_FC{COL_FC}})? 1 : 0;


  wire zero_pad_enable;

  assign zero_pad_enable = |(conv_zeropad);
  
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] vector_add_values;
  wire [OP_FIFO-1:0] vector_add_wren;
  // DRAM Data write ctlers for accumulants, bias, fcbias
  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(OP_FIFO) //Accumulant FIFOs = 8, each 32-bit 
  )Accumulant_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`Acc]), // select signal of vector add fifo blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(vector_add_values), //o-wire: to vector add fifo blk
        .o_dram_fifo_wren(vector_add_wren), //o-wire: to vector add fifo blk
        .o_data_last()
  ); 

  
  wire [(BIAS_FIFO*DATA_WIDTH_OB)-1:0] bias_data_in;
  wire [BIAS_FIFO -1:0] bias_wren;
  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(BIAS_FIFO) //Bias FIFOs = 8, each 32-bit 
  )Bias_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`Bias]), // select signal of bias fifo blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(bias_data_in),   //o-wire: to bias fifo blk
        .o_dram_fifo_wren(bias_wren), //o-wire: to bias fifo blk
        .o_data_last()
  );
  
  
  wire [(BIAS_FIFO_FC*DATA_WIDTH)-1:0] bias_data_in_fc;
  wire [BIAS_FIFO_FC -1:0] bias_wren_fc;
  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(BIAS_FIFO_FC) //FC_Bias FIFOs = 32, each 8-bit 
  )FC_Bias_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`FCBias]), // select signal of fc_bias fifo blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(bias_data_in_fc),   //o-wire: to fc_bias fifo blk
        .o_dram_fifo_wren(bias_wren_fc), //o-wire: to fc_bias fifo blk
        .o_data_last()
  );

  // DRAM Data write ctlers for FC image data
  wire [AXI_DATA_BYTES*DATA_WIDTH-1 : 0] fc_image_in_data;
  wire [AXI_DATA_BYTES-1 : 0] dv_fc_image_data;
  
  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(AXI_DATA_BYTES) //FC BRAMs = 32, each 8-bit 
  )FC_image_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`FullyConn]), // select signal of FC image (flattening) blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(fc_image_in_data), //o-wire: to FC flattening blk
        .o_dram_fifo_wren(dv_fc_image_data), //o-wire: to FC flattening blk
        .o_data_last()
  );

  
  // slicing of img_fifo o/p data to store it in data buffers of im2col
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] img_ip_conv;

  localparam OFFSET = N_SA;
  localparam UPPER_LOOP = N_SA;
  localparam LOWER_LOOP = (AXI_DATA_BYTES/(SHFT_REG_X*N_SA));

    
  genvar i,j;
  generate
  for(i=0;i<UPPER_LOOP;i=i+1) begin
    for (j=0;j<LOWER_LOOP;j=j+1) begin
        localparam k = i * LOWER_LOOP + j;
        assign img_ip_conv[(((SHFT_REG_X*DATA_WIDTH)*((AXI_DATA_BYTES/SHFT_REG_X)- k))-1) -: SHFT_REG_X*DATA_WIDTH] =
        fifo_imgo_data[(((SHFT_REG_X*DATA_WIDTH)*(((AXI_DATA_BYTES/SHFT_REG_X)-i)-(j*OFFSET)))-1) -: SHFT_REG_X*DATA_WIDTH];
    end
  end
  endgenerate

  wire [OP_FIFO-1:0] op_wren;
  wire [(DATA_WIDTH_OB*OP_FIFO)-1:0] data_op_write_dram_fifo;
  wire shift_reg_en;
  wire [SHFT_REG_X-1:0] shift_reg_sel;
  assign shift_reg_sel = {SHFT_REG_X{shift_reg_en}};

  wire bias_enable;
  wire quant_enable;
  wire bias_fc_enable;
  wire maxpool_enable;
  wire im2col_done;
  wire SA_psum_fifo_empty;
  wire relu_enable;
  wire Tail_done;
  wire FC_done;

  assign fc_kernel_iter = kernel_iteration;

  // Top module of CONV and FC Blocks
  Top_CONV_FC #(
      .OPCODE_WIDTH(OPCODE_WIDTH),
      .N_SA(N_SA),
      .DATA_WIDTH(DATA_WIDTH),
      .COL_SA(COL_SA),
      .COL_FC(COL_FC),
      .QUANT_SHIFT(W_QUANT_SHIFT),
      .QUANT_SCALE(W_QUANT_SCALE),
      .ROW(ROW),
      .DRAM_BW(AXI_DATA_BYTES),
      .W_PSUM(W_PSUM),
      .MOD1(MOD1),
      .MOD2(MOD2),
      .DATA_WIDTH_OB(DATA_WIDTH_OB),
      .W_CONV_IMAGE_DIM(CONV_IW_WIDTH),
      .W_CONV_OP_IMAGE_DIM(CONV_OW_WIDTH),
      .SHFT_REG_X(SHFT_REG_X),
      .BIAS_FIFO(BIAS_FIFO),
      .OP_FIFO(OP_FIFO),
      .WEIGHT_FIFO_DEPTH(WEIGHT_FIFO_DEPTH),
      .IM2COL_FIFO_DEPTH(IM2COL_FIFO_DEPTH),
      .PSUM_FIFO_DEPTH(PSUM_FIFO_DEPTH),
      .ACC_FIFO_DEPTH(ACC_FIFO_DEPTH),
      .BIAS_FIFO_DEPTH(BIAS_FIFO_DEPTH),
      .NSA_DSP(NSA_DSP),
      .N_FC_MUX(N_FC_MUX),
      .NO_PORT_FC(NO_PORT_FC),
      .RELU_CLIP_WIDTH(RELU_CLIP_WIDTH),
      .NSA_LUT(NSA_LUT),
      .BIAS_FIFO_FC(BIAS_FIFO_FC),
      .NO_PORT_VA(NO_PORT_VA),
      .NO_PORT_BAC(NO_PORT_BAC),
      .NO_PORT_BAFC(NO_PORT_BAFC),
      .POP_THRESHOLD(POP_THRESHOLD),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
      .N_DMUX_PORTS(N_DMUX_PORTS),
      //FC realated parameters
      .FC_IMAGE_ROWS_WIDTH(FC_IMAGE_ROWS_WIDTH), 
      .ACC_DW(ACC_DW),
      .N_BANK(N_BANK),
      .N_BRAM(N_BRAM),
      .W_FC_RW_COUNTER(W_FC_RW_COUNTER),
      .FC_BRAM_DEPTH(FC_BRAM_DEPTH),
      .W_KERNEL_CNT(W_KITER_CNT),
      .W_FC_IMAG_DIM(W_FC_IMAG_DIM),
      .ACC_DATA_REORDER(ACC_DATA_REORDER)
  ) top_CONV_FC_Block (
      .i_clk(i_clk),
      .s_clk(s_clk),
      .i_img_dim_Acc(img_dim_Acc), // image dimension of accumulant o/p
      .i_img_dim_Op(img_dim_Op), // image dimension of quantized o/p
      .image_fifo_empty(image_fifo_empty),
      .CONV_FC(CONV_FC),
    //   .switch_enable(switch_enable),
      .fifo_o(fifo_imgo_data),
      //fifo sharing signals
      .sel_sa_rden(sel_sa_rden),
      .weight_read_en_fc(weight_read_en_fc),
      .weight_occupants_fc(weight_occupants_fc),
      .weight_empty_fc(weight_empty_fc),
      .weight_dv_fc(weight_dv_fc),
      .weight_data_fc(weight_data_fc),
      .weight_read_en_sa(weight_read_en_sa),
      .weight_dv_sa(weight_dv_sa),
      .weight_occupants_sa(weight_occupants_sa),
      .weight_empty_sa(weight_empty_sa),
      .weight_data_sa(weight_data_sa),

      //Flattening and FC signals
      .flatten_enable(flatten_enable), //comes from FC instruction
      .start_FC(Flattening_trigger),
      .i_rw_addr_cnt_flatten(fc_rw_address_counter), //r/w address cnt from FC inst.
      .i_kernel_cnt_FC(fc_kernel_iter), //kernel cnt from FC inst.
      .i_img_dim_flatten(fc_imagedim), //img dim for flattening-comes from FC inst.
      .i_data_valid_flatten(dv_fc_image_data), //valid of data from DDR
      .i_data_FC(fc_image_in_data), //data from DDR
      .i_img_dim_fc(fc_image_rows), // image dim of FC i/p (input rows-FC inst.) goes to FC engine
      .i_sel_fc_fifosharing(fc_mux_Sel), //o-wire: select to signal to FC for reading weights from fifo sharing ctrl
      
      //vector addition and tail block signals    
      .vector_add_values(vector_add_values),
      .vector_add_wren(vector_add_wren),
      .maxpool_threshold(conv_op_width), //output matrix width of SA engine
      .layer_done(layer_done),
      .iteration_Done(iter_done),
      .channel_done(channel_done),
      .shift_reg_sel(shift_reg_sel),
      .systolic_array_trigger(systolic_array_trigger),
      .rst(i_rst),
      .relu_clip_value(relu_clip_value),
      .bias_enable(bias_enable),
      .quant_enable(quant_enable),
      .bias_fc_enable(bias_fc_enable),
      .zero_pad_enable(zero_pad_enable),
      .image_size(input_img_width),
      .valid_img_size_im2col(valid_conv), //valid inst conv
      .im2col_global_start(im2col_global_start),
      .image_rden(image_rden),

      .relu_enable(relu_enable),
      .bias_data_in(bias_data_in),
      .bias_wren(bias_wren),
      .bias_data_in_fc(bias_data_in_fc),
      .bias_wren_fc(bias_wren_fc),
      .shift_value(({COL_SA{tail_quantshift}})),
      .quant_scale(({COL_SA{tail_quantscale}})),
      .vector_add_enable(vector_add_enable),
      .maxpool_enable(maxpool_enable),
      
    //   .data_b(data_b),
    //   .data_c(data_c),
      .op_write_dmux_data(data_op_write_dram_fifo),
      .op_wren(op_wren),

      .im2col_done(im2col_done),
      .SA_psum_fifo_empty(SA_psum_fifo_empty),
      .Tail_done(Tail_done), // Generated in integration block
      .FC_done(FC_done), //accumulator valid signal of FC engine
      .FC_layerdone(FC_layerdone),

      .acc_fifo_occupants(acc_fifo_occupants),
      .bias_fifo_occupants(bias_fifo_occupants),
      .fc_bias_fifo_occupants(fc_bias_fifo_occupants)
  );

//   wire [(COL_SA*(SHFT_REG_X*8)) -1:0] data_b;
//   wire [(COL_SA*(SHFT_REG_X*8)) -1:0] data_c;
//   assign data_op_write_dram_fifo = switch_enable? {data_b, data_c} : data_b;

  
  //o/p write FIFO to DDR
  wire [OP_FIFO-1:0] op_dram_rden;
  dram_fifo #(
      .DIMENSION(OP_FIFO),
      .W_DATA(DATA_WIDTH_OB),
      .W_ADDR($clog2(OP_WRITE_FIFO_DEPTH)),
      .RAM_DEPTH(OP_WRITE_FIFO_DEPTH)
  ) op_write_dram_fifo (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data(data_op_write_dram_fifo),
      .i_read_enable(op_dram_rden),
      .i_write_enable(op_wren),
      .o_data(op_dram_fifo),
      .o_fifo_empty(op_dram_fifo_empty),
      .o_fifo_full(),
      .o_fifo_dv(),
      .o_occupants(op_write_dram_fifo_occupants) //o-wire: goes to op_write request controller
  );


  Mem_write_ctrl#(
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
    .N_FIFO(OP_FIFO)
  ) op_dram_fifo_rden_ctrl(
    .clk(i_clk),
    .rst(i_rst),
    .select(select[`OPWrite]), //select signal from DRAM ctrler (WR_ID mger)
    .wready(wready), // from DRAM ctrler (WR_ID mger)
    .blen(wr_burst_len), // from DRAM ctler ()
    .data_valid(dv_op_write),
    .data_last(data_last_op_write),
    .fifo_rd_en(op_dram_rden)
  );


 /* Iteration counter module that generates iteration 'done' signals based on the status
    of various operators. Also generates 'enable'signals to various tail blocks
    based on the instruction fields. Also generates 'acc_en' signal that specifies
    wheteher to add the accumulamts in current iteration.
    
    It also generates 'ack' signals for config blk in last channel and kernel iteration.
*/
  // Iteration counter module
    wire SA_done;
    wire op_fifo_empty;
    
    assign op_fifo_empty = &(op_dram_fifo_empty);
    
    iteration_cnt #(
        .CITER_CNT_WIDTH(W_CITER_CNT), 
        .KITER_CNT_WIDTH(W_KITER_CNT)
    )
    iteration_counter_inst
    (
        .i_clk(i_clk),
        .rst(i_rst),
        .i_start(start),
        .CONV_FC(CONV_FC),
        .im2col_done(im2col_done), // i-wire : from im2col block
        .SA_psum_fifo_empty(SA_psum_fifo_empty),
        .Tail_done(Tail_done),
        .op_fifo_empty(op_fifo_empty),
        .FC_done(FC_done),

        .c_iter(channel_iteration), //channel iteration
        .k_iter(kernel_iteration), //kernel iteration

        .o_iter_done(iter_done),
        .o_c_done(channel_done),
        .o_layer_done(layer_done),

        .BIAS_EN(BIAS_EN),
        .RELU_EN(ACT_EN),
        .QUANT_EN(QUANT_EN),
        .POOL_EN(POOL_EN),
        .ACC_EN(ACC_EN),  
        .FC_BIAS_EN(FC_BIAS_EN), //above six signals comes from instruction fields

        .acc_en(vector_add_enable),
        .relu_en(relu_enable),
        .quant_en(quant_enable),
        .bias_en(bias_enable),
        .fc_bias_en(bias_fc_enable), 
        .pool_en(maxpool_enable),
        .en(shift_reg_en),

        //Ack signals to config blk.
        .Conv_Ack(Conv_Ack),
        .OpBlock_Ack(OpBlock_Ack),
        .Tail_Ack(Tail_Ack)
        //.FC_Ack(FC_Ack)
    );

    // wire Conv_Ack, OpBlock_Ack, Tail_Ack, FC_Ack;
    //o_done_rden_ctrl from flattening indicates data read from BRAM for k_iter times
    assign FC_Ack = FC_layerdone;  

/* 
    im2col needs start in each iteration.
    im2col soft start controller waits for 'iter_done' and generates a 
    next 'start_im2col' signal to im2col block in each iteration till 
    kernel counter reaches maximum. 
*/
    im2col_start_ctrler #(
        .CITER_CNT_WIDTH(W_CITER_CNT),
        .KITER_CNT_WIDTH(W_KITER_CNT)
    )
    im2col_start_ctrler_inst
    (
        .clk(i_clk),
        .rst(i_rst),
        .start(start_SA), //start_SA

        .iter_done(iter_done),
        .c_iter(channel_iteration),
        .k_iter(kernel_iteration),

        .start_im2col(im2col_global_start)
    );


endmodule
