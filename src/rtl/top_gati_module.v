`include "common/instructions.vh"
`include "common/portid.vh"
//`include "instruction.mem"
module top_gati_module #(
   // FIFO Depth varies between operators to avoid overflow and underflow 
    parameter INST_QUEUE_DEPTH    = 256,
    parameter DRAM_IMG_FIFO_DEPTH = 512,
    parameter IM2COL_FIFO_DEPTH   = 1024,
    parameter WEIGHT_FIFO_DEPTH   = 512,
    parameter PSUM_FIFO_DEPTH     = 512,
    parameter ACC_FIFO_DEPTH      = 512,
    parameter BIAS_FIFO_DEPTH     = 512, //For both conv and FC
    parameter ACC_OP_FIFO_DEPTH   = 256,
    parameter QUANT_OP_FIFO_DEPTH = 256,
    parameter OP_WRITE_FIFO_DEPTH = 512,
    parameter ELTWISE_FIFO_DEPTH  = 512,

    //Default burst lenghts for various memory request controllers
    parameter CONFIG_REQ_BLEN       = 7,
    parameter IMG_REQ_BLEN          = 15,
    parameter WEIGHT_REQ_BLEN       = 15,
    parameter FC_WEIGHT_REQ_BLEN    = 63,
    parameter ACC_REQ_BLEN          = 15,
    parameter BIAS_REQ_BLEN         = 15,
    parameter OP_WRITE_REQ_ACC_BLEN = 15, //burst length for writng accumulants (32-bit) into the DRAM
    parameter OP_WRITE_REQ_QUA_BLEN = 15, //burst length for writng quantized output (8-bit) into the DRAM
    parameter ELEMENT_REQ_BLEN      = 15,
    //parameters related to DRAM controller
    parameter NUM_PORTS = 10, //Number of read and write requestors

    //parameters related to AXI
    parameter AXI_DATA_WIDTH        = 256,
    parameter AXI_DATA_BYTES        = 32,  // Axi Data width = 256 bit
    parameter AXI_ADDR_W            = `CONV_ImageStartAddress_WIDTH,   // Axi Address width
    parameter BURST_LENGTH_WIDTH    = 8,
   
    //Config blk param
    parameter NUM_INSTRUCTIONS      = 6,                   
    parameter INST_W                = 256,
    parameter CONFIG_FIFO_OCCUPANCY = 10,
    parameter LAYERCNT_WIDTH        = `START_LayerNumber_WIDTH,
    parameter TOTAL_LAYERCNT_WIDTH  = `START_TotalLayers_WIDTH,
    
    //CONV Parameters(inst related)
    parameter OPCODE_WIDTH      = `CONV_Opcode_WIDTH,
    parameter CONV_IW_WIDTH     = `CONV_IW_WIDTH,
    parameter CONV_IH_WIDTH     = `CONV_IH_WIDTH,
    parameter CONV_IC_WIDTH     = `CONV_IC_WIDTH,
    parameter CONV_KN_WIDTH     = `CONV_KN_WIDTH,
    parameter CONV_KW_WIDTH     = `CONV_KW_WIDTH,
    parameter CONV_KH_WIDTH     = `CONV_KH_WIDTH,
    parameter CONV_KC_WIDTH     = `CONV_KC_WIDTH,
    parameter CONV_ConvType_WIDTH = `CONV_ConvType_WIDTH,
    parameter OutputBlock_OH_WIDTH = `OutputBlock_OH_WIDTH, // Output block output height
    parameter OutputBlock_OW_WIDTH = `OutputBlock_OW_WIDTH, // Output block output width
    parameter CONV_STRIDE_WIDTH = `CONV_Stride_WIDTH,
    
    
    parameter CONV_PadLeft_WIDTH = `CONV_PadLeft_WIDTH,
    parameter CONV_PadRight_WIDTH = `CONV_PadRight_WIDTH,
    parameter CONV_PadTop_WIDTH = `CONV_PadTop_WIDTH,
    parameter CONV_PadBottom_WIDTH = `CONV_PadBottom_WIDTH,
    parameter CONV_StartRowSkip_WIDTH = `CONV_StartRowSkip_WIDTH, // Start row skip for im2col
    parameter CONV_EndRowSkip_WIDTH = `CONV_EndRowSkip_WIDTH, // End row skip for im2col

   
    parameter CONV_Im2colPrefetch_WIDTH = `CONV_Im2colPrefetch_WIDTH ,
    parameter CONV_CHANNELDUPLICATE_WIDTH = `CONV_ChannelDuplicate_WIDTH,

    //im2col related param 
    parameter STRIDE          =  1,        //`CONV_Stride,
    parameter KERNEL_SIZE     =  3,       //`CONV_KH,   
    //SA related param
    parameter POP_THRESHOLD = (AXI_DATA_BYTES/N_SA) - 3,
    parameter NSA_DSP       = 3, 
    parameter NSA_LUT       = 5,
    parameter N_SA          = NSA_DSP + NSA_LUT,
    parameter DATA_WIDTH    = 8,
    parameter COL_SA        = 8,
    parameter COL_FC        = 32,
    parameter ROW           = 9,
    parameter W_PSUM        = 20,
    parameter DATA_WIDTH_OB = 32,
    parameter DATA_WIDTH_ACC = 32,

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
    parameter ACC_DATA_REORDER  = ((COL_FC/(ACC_DW/8)) > COL_SA)? 1:0,
    parameter N_FC_MUX          = COL_SA, //number of muxes for FC output
    parameter NO_PORT_FC        = COL_FC/COL_SA, //FC mux size

    //Output block inst param
    parameter W_CITER_CNT       = `OutputBlock_ChannelItr_WIDTH,
    parameter W_KITER_CNT       = `OutputBlock_KernelItr_WIDTH,
    parameter I_ACC_SIZE_WIDTH  = `OutputBlock_ImageDimAcc_WIDTH, // bit width of input image dimension
    parameter I_OP_SIZE_WIDTH   = `OutputBlock_ImageDimOutput_WIDTH,
    parameter ACCEN_WIDTH       = `OutputBlock_AccEn_WIDTH,
    parameter DISPATCH_ID_WIDTH = `OutputBlock_DispatchID_WIDTH,
    parameter DISPATCHEN_WIDTH  = `OutputBlock_DispatchEn_WIDTH,
    parameter ACC_ONCHIP_WIDTH  = `OutputBlock_OnChipAcc_WIDTH,

    parameter OutputBlock_AccumulantReadFirst_WIDTH = `OutputBlock_AccumulantReadFirst_WIDTH, // Output block accumulant read first
    parameter MOD1 = 1,
    parameter MOD2 = AXI_DATA_BYTES/N_SA,
    parameter N_DMUX_PORTS = AXI_DATA_BYTES/(N_SA*(ACC_DW/8)),

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
    parameter W_POOL_CEIL       = `TailBlock_PoolCeil_WIDTH,
    parameter W_POOL_MODCOUNT   = `TailBlock_PoolModCount_WIDTH,
    parameter W_POOL_PADSIDES   = `TailBlock_PoolPadSides_WIDTH,
    parameter BNEN_WIDTH        = `TailBlock_BNEn_WIDTH,
    parameter ACTEN_WIDTH       = `TailBlock_ActEn_WIDTH,
    parameter QUANTEN_WIDTH     = `TailBlock_QuantEn_WIDTH,
    parameter POOLEN_WIDTH      = `TailBlock_PoolEn_WIDTH,
    parameter BIASEN_WIDTH      = `TailBlock_BiasEn_WIDTH,
    parameter BiasWidth_WIDTH   = `TailBlock_BiasWidth_WIDTH,

    //Other parameters
    parameter SHFT_REG_X    = AXI_DATA_BYTES/N_SA, // Number of shift register blocks
    parameter BIAS_FIFO     = 16, // Number of bias FIFOs
    parameter ACC_OP_FIFO   = 2, // Number of o/p accumulant FIFOs
    parameter QUANT_OP_FIFO = 1, // Number of quantized output FIFOs
    parameter OP_FIFO       = 1,  // Number of output write FIFOs
    parameter ACC_FIFO      = 16, // Number of accumulant FIFOs
    parameter BIAS_FIFO_FC  = 32, // Number of FC bias FIFOs
    parameter NO_PORT_VA    = 1,
    parameter NO_PORT_BAC   = 1,
    parameter ACC_TOGGLE    = 1,
    parameter NO_PORT_BAFC  = 2,

    //EltWise param
    parameter ELTWISE_FIFO = AXI_DATA_BYTES/N_SA, // Number of element wise fifos
    parameter ELTWISE_TYPE_WIDTH = `EltWise_EltType_WIDTH, // Width of the element wise
    parameter ELTWISE_IW_WIDTH = `EltWise_IW_WIDTH, // Width of the input width;
    parameter ELTWISE_IH_WIDTH = `EltWise_IH_WIDTH, // Width of the input height;
    parameter ELTWISE_IC_WIDTH = `EltWise_IC_WIDTH // Width of the output width;
    
) (
    ///global
    input i_clk,
    input s_clk,
    input i_rst,
  // 	input n_clk, 
    ///////config block input
    input user_start,
    input dispatcher_busy,
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

    ///////////////LeftOperand
    output [7:0] mc_LeftOperand_addr,
    output mc_LeftOperand_rdreq,
    output mc_LeftOperand_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_LeftOperand_bl,
    output mc_LeftOperand_last,

    ///////////////RightOperand
    output [7:0] mc_RightOperand_addr,
    output mc_RightOperand_rdreq, 
    output mc_RightOperand_valid,   
    output [BURST_LENGTH_WIDTH-1 : 0] mc_RightOperand_bl,
    output mc_RightOperand_last,
    
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
    input sel_op_write, // Todo: have to check , wheteher sel is common or not
    input [BURST_LENGTH_WIDTH-1 : 0] wr_burst_len,
    input wready,
    output dv_op_write,
    output o_data_last_op_write,
    output [(AXI_DATA_WIDTH)-1:0] op_dram_fifo,

    output layer_debug_pin,
    
    //fpga2cpu dispatch signals
    output start,
    output layer_done,
    output [DISPATCH_ID_WIDTH-1:0] dispatch_id,
    output [DISPATCHEN_WIDTH-1:0] dispatch_cpu_en,
    output [2*I_OP_SIZE_WIDTH-1:0] datasize_fpga2cpu,
    output [AXI_ADDR_W-1:0] fpga2cpu_start_address,
       
    //io signals
    output [6:0] kernal_count, // represents the current kernal iteration number 
    output [6:0] channel_count, // represents the current channel iteration number
    output [3:0] layer_count 
);

    // localparam NUM_QUEUE = NUM_PORTS; //number of Requestor queues in DRAM controller
    localparam BUS_DATA_OUT = 8;
    localparam CNT = INST_W/BUS_DATA_OUT;
    assign layer_count = layer_cntr;
      
    wire [NUM_INSTRUCTIONS-1:0] ack_signals; //Ack from various operators = number of instructions
    assign ack_signals[`OP_CONV] = Conv_Ack;
    assign ack_signals[`OP_FC] = FC_Ack;
    assign ack_signals[`OP_OutputBlock] = OpBlock_Ack;
    assign ack_signals[`OP_TailBlock] = Tail_Ack;
    assign ack_signals[`OP_EltWise] = EltWise_Ack;

    wire [INST_W-1 : 0] instruction;
    wire start_bus;   //start signal to bus master to dispatch inst. to the corresponding slave blocks
    wire [OPCODE_WIDTH-1:0] opcode_config; //opcode to bus master to select the appropriate slave
    wire Conv_Ack, OpBlock_Ack, Tail_Ack, FC_Ack, EltWise_Ack; // Acknowledgment signals to config blk to prefetch the inst.
    
    assign opcode_config = instruction[OPCODE_WIDTH-1:0];

    wire [NUM_INSTRUCTIONS-1:0] start_command;    

    wire start_out;
    reg start;
    // assign start = start_out;
    always@(posedge i_clk) begin //To sync. with start_SA and start_FC
      start <= start_out;
    end

    wire [NUM_INSTRUCTIONS-1 : 0] valid_inst;

	// wire  [BURST_LENGTH_WIDTH-1 : 0] mc_config_bl;
// wire mc_config_rdreq;
//    wire mc_config_valid;

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
	  //.temp_data(temp_data),
	  //.temp_wren(temp_wren),
      .clkin(i_clk),
      .rst(i_rst),
	    .user_start(user_start),
      .valid(dram_rd_datavalid),
      .data_last(dram_rd_data_last),
      .sel(select[`Config]),
      .instruction_data(dram_rd_data),
      .dispatch_busy(dispatcher_busy),

	    .memory_read_r(mc_config_rdreq),
      .memory_valid(mc_config_valid),
      .mem_address(mc_config_addr),
      .mem_last(mc_config_last),
      .mem_burst_len(mc_config_bl),
      .ack_signals(ack_opcode),
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
  wire [OutputBlock_OW_WIDTH-1 : 0] op_width;
  wire [OutputBlock_OH_WIDTH-1 : 0] op_height; 

  wire [CONV_KN_WIDTH-1:0] n_kernels;
  wire [CONV_KW_WIDTH-1:0] kernel_width;
  wire [CONV_KH_WIDTH-1:0] kernel_height;
  wire [CONV_KC_WIDTH-1:0] kernel_channels;
  wire [CONV_ConvType_WIDTH-1:0] conv_type;
  wire [CONV_STRIDE_WIDTH-1:0] stride;
  
  wire [CONV_PadLeft_WIDTH-1:0] conv_pad_left;
  wire [CONV_PadRight_WIDTH-1:0] conv_pad_right;
  wire [CONV_PadTop_WIDTH-1:0] conv_pad_top;
  wire [CONV_PadBottom_WIDTH-1:0] conv_pad_bottom;

  wire [CONV_CHANNELDUPLICATE_WIDTH-1:0] CONV_ChannelDuplicate;
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
  wire [ACC_ONCHIP_WIDTH-1 : 0] Acc_onchip;

  //Tail inst. signals
  wire [OPCODE_WIDTH-1:0] Op_code_TB;
  wire [RELU_CLIP_WIDTH-1:0] relu_clip_value;
  wire [ACT_TYPE_WIDTH-1:0] relu_act_type;
  wire [W_QUANT_SHIFT-1:0] tail_quantshift;
  wire [W_QUANT_SCALE-1:0] tail_quantscale;
  wire [ACTEN_WIDTH-1:0] ACT_EN;
  wire [QUANTEN_WIDTH-1:0] QUANT_EN;
  wire [BIASEN_WIDTH-1:0] BIAS_EN;
  wire [BiasWidth_WIDTH-1:0] BiasWidth;
  wire [POOLEN_WIDTH-1:0] POOL_EN;
  wire [AXI_ADDR_W-1:0] bias_start_address;
  wire [AXI_ADDR_W-1:0] bias_stop_address;

  //Elementwise inst. signals
  wire [OPCODE_WIDTH-1:0] ew_opcode;
  wire [ELTWISE_TYPE_WIDTH-1:0] EltWise_type;
  wire [CONV_IW_WIDTH-1 : 0]EltWise_IW;
  wire [CONV_IH_WIDTH-1 : 0]EltWise_IH;
  wire [CONV_IC_WIDTH-1 : 0]EltWise_IC;
  wire [AXI_ADDR_W-1:0] LeftOperand_start_address;
  wire [AXI_ADDR_W-1:0] RightOperand_start_address;
  wire [AXI_ADDR_W-1:0] LeftOperand_stop_address;
  wire [AXI_ADDR_W-1:0] RightOperand_stop_address;

  // start and end address signals for memory request controllers

  wire [AXI_ADDR_W-1:0] img_start_address;
  wire [W_CITER_CNT-1:0] channel_iteration; 
  wire [W_KITER_CNT-1:0] kernel_iteration; 
  wire [AXI_ADDR_W-1:0] img_stop_address;

  wire layer_done;
  wire FC_layerdone;
  reg valid_conv, valid_fc, valid_ew;

  // Valid signal genration for CONV
  

  reg [OPCODE_WIDTH-1:0] opcode;
  reg valid_inst_CONV_FC;
  reg CONV_FC;
  wire start_SA,start_FC,start_EW;
  wire [NUM_INSTRUCTIONS-1:0] start_block; 

  assign start_SA = start_block[`OP_CONV];
  assign start_FC = start_block[`OP_FC];
  assign start_EW = start_block[`OP_EltWise];

  //Generation of CONV_FC signal
  always@(posedge i_clk) begin
    if(!i_rst) begin
        valid_inst_CONV_FC <= 0;
        CONV_FC <= 0;
    end
    else begin
        if(start_command[`OP_CONV]) begin
          opcode <= conv_opcode;
          valid_inst_CONV_FC <= 1;
          CONV_FC <= 0;
        end
        else if(start_command[`OP_FC]) begin
          opcode <= fc_opcode;
          valid_inst_CONV_FC <= 1;
          CONV_FC <= 1;
        end
        else if(start_command[`OP_EltWise]) begin
          valid_inst_CONV_FC <= 0;
          opcode <= ew_opcode;

        end
        else begin
          opcode <= opcode;
          valid_inst_CONV_FC <= valid_inst_CONV_FC;
          CONV_FC <= CONV_FC;
        end
    end
  end

  //Generation of start_SA and start_FC
  // wire start_SA,start_FC;
  // assign start_SA = (CONV_FC==0)? start : 1'b0;
  // assign start_FC = (CONV_FC==1)? start : 1'b0;
  /*This is modified since, CONV_FC gets updated one cycle after recieving 'start' signal
  which causes one cycle delay in generation of 'start_SA' and 'start_FC' signals*/


   // the real_row and real_col are the counters that are used to calculate full image dimension instead of the row skip one for example if image is 224*224 the real_row and real_col will be till 224 where the row will be 224 - row_skips 
  wire  [CONV_IH_WIDTH-1:0] row;    
  wire  [CONV_IW_WIDTH-1:0] col;
  wire  [CONV_IH_WIDTH-1:0] real_row;  
  wire  [CONV_IW_WIDTH-1:0] real_col;

  
  reg Flattening_trigger=0;

  // Generate logic for stall_on signal 
  // stall_on signal is used to stall the systolic array when the image fifo is empty or psum fifo is full
  
  wire [AXI_DATA_BYTES-1:0] image_fifo_empty;
  reg stall_on=0;
  reg stall_enable=0;
  // wire stall_on; 

  always@(posedge i_clk) begin 
    if((&(image_fifo_empty) && stall_enable) | psum_full) begin
      stall_on <= 1;
    end
    else begin 
      stall_on <= 0;
    end

    if(input_img_height <= (AXI_DATA_BYTES/N_SA)) begin
      stall_enable <= 0;
    end
    else begin
      if(im2col_global_start) begin
        stall_enable <= 1;
      end
      else if((real_row == input_img_height + conv_pad_top)  
        && (real_col >= ((input_img_width + conv_pad_left) - (AXI_DATA_BYTES/N_SA)))) begin 
        stall_enable <= 0;
      end
      else begin 
        stall_enable <= stall_enable;
      end
    end
  end

 // logic for systolic array start and stalling sytolic array for stride more than 1 
 
  // the almost empty and almost full flags are used to control the start and stall of the systolic array these are genrated 15 and 24 address line before the actual empty and full of the fifo

  // thus the name might be confusing but they arent genrated only one cycle before the actual empty and full of the fifo but 15 and 24 address line before the actual empty and full of the fifo
  
    wire sa_image_fifo_almost_empty_flag ;
    wire sa_image_fifo_almost_full_flag;
    wire istolic_stall;
    wire systolic_array_trigger;

  // instantiation of sa_start_stall_ctrler

    sa_start_stall_ctrl #(
        .CONV_IH_WIDTH(CONV_IH_WIDTH),
        .CONV_PAD_WIDTH(CONV_PadRight_WIDTH), 

        .CONV_Im2colPrefetch_WIDTH(CONV_Im2colPrefetch_WIDTH),
        .CONV_STRIDE_WIDTH(CONV_STRIDE_WIDTH),
        .IMAGE_DIM(CONV_IW_WIDTH)
        )
    sa_start_stall (
        .sa_image_fifo_almost_empty_flag(sa_image_fifo_almost_empty_flag),
        .sa_image_fifo_almost_full_flag(sa_image_fifo_almost_full_flag),
        .im2col_global_start(im2col_global_start),
        .im2col_done( im2col_done),
        .SA_done(SA_done),
        .i_clk(i_clk),
        .i_rst(i_rst),
        .CONV_Im2colPrefetch(CONV_Im2colPrefetch),
        .input_img_height(input_img_height),  
        .conv_zeropad(conv_pad_right),
        .stride (stride),
        .istolic_stall(istolic_stall),
        .row(row),
        .col(col),
        .systolic_array_trigger(systolic_array_trigger)
  );

  // logic for flattening trigger
  always@(posedge i_clk) begin
    if(!i_rst) Flattening_trigger <= 1'b0;
    else begin
        if(start_FC) Flattening_trigger <= 1'b1;
        else if(FC_layerdone) Flattening_trigger <= 1'b0;
        else Flattening_trigger <= Flattening_trigger;
    end
  end

  wire [(POOL_TYPE_WIDTH - 1) : 0] pooltype;
  wire [(W_POOL_WIDTH - 1) : 0] poolwidth;
  wire [(W_POOL_HEIGHT - 1) : 0] poolheight;
  wire [(W_POOL_STRIDE - 1) : 0] poolstride;
  wire [(W_POOL_PAD - 1) : 0] poolpadding;
  wire [(W_POOL_CEIL - 1) : 0] poolceil;
  wire [(W_POOL_MODCOUNT - 1) : 0] poolModCount;
  wire [(W_POOL_PADSIDES - 1) : 0] poolpadsides;

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
    .OW_WIDTH(OutputBlock_OW_WIDTH),
    .OH_WIDTH(OutputBlock_OH_WIDTH),
    .IC_WIDTH(CONV_IC_WIDTH),
    .KN_WIDTH(CONV_KN_WIDTH),
    .KH_WIDTH(CONV_KH_WIDTH),
    .KW_WIDTH(CONV_KW_WIDTH),
    .KC_WIDTH(CONV_KC_WIDTH),
    .CONV_TYPE_WIDTH(CONV_ConvType_WIDTH),
    .STRIDE_WIDTH(CONV_STRIDE_WIDTH),
    .PAD_LEFT_WIDTH(CONV_PadLeft_WIDTH),
    .PAD_RIGHT_WIDTH(CONV_PadRight_WIDTH),
    .PAD_TOP_WIDTH(CONV_PadTop_WIDTH),
    .PAD_BOTTOM_WIDTH(CONV_PadBottom_WIDTH),
    .CONV_StartRowSkip_WIDTH(CONV_StartRowSkip_WIDTH),
    .CONV_EndRowSkip_WIDTH(CONV_EndRowSkip_WIDTH),
    .CONV_Im2colPrefetch_WIDTH(CONV_Im2colPrefetch_WIDTH),
    .CONV_CHANNELDUPLICATE_WIDTH(CONV_CHANNELDUPLICATE_WIDTH),
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
    .DISPATCH_ID_WIDTH(DISPATCH_ID_WIDTH),
    .DISPATCHEN_WIDTH(DISPATCHEN_WIDTH),
    .ACC_ONCHIP_WIDTH(ACC_ONCHIP_WIDTH),
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
    .POOLCEIL_WIDTH(W_POOL_CEIL),
    .POOLMODCOUNT_WIDTH(W_POOL_MODCOUNT),
    .POOLPADSIDES_WIDTH(W_POOL_PADSIDES),
    .BIASEN_WIDTH(BIASEN_WIDTH),
    .BNCHANNELS_WIDTH(BNCHANNEL_WIDTH),
    .BiasWidth_WIDTH(BiasWidth_WIDTH),
    .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH)
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

    .IC(),
    .KN(n_kernels),
    .KW(kernel_width),
    .KH(kernel_height),
    .KC(kernel_channels),
    .conv_type(conv_type),    
    .Stride(stride),

    .Pad_left(conv_pad_left),
    .Pad_right(conv_pad_right),
    .Pad_top(conv_pad_top),
    .Pad_bottom(conv_pad_bottom),
    .start_row_skip(start_row_skip),
    .end_row_skip(end_row_skip),
    .CONV_Im2colPrefetch(CONV_Im2colPrefetch),
    .CONV_ChannelDuplicate(CONV_ChannelDuplicate),
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

    //Elementwise inst. signals
    .opcode_EltWise(ew_opcode),
    .EltWise_type(EltWise_type),
    .EltWise_IW(EltWise_IW),
    .EltWise_IH(EltWise_IH),
    .EltWise_IC(EltWise_IC),
    .LeftOperand_StartAddress(LeftOperand_start_address),
    .LeftOperand_EndAddress(LeftOperand_stop_address),
    .RightOperand_StartAddress(RightOperand_start_address),
    .RightOperand_EndAddress(RightOperand_stop_address),

    //OP block inst. signals
    .opcode_OB(Op_code_OB),
    .accumulantaddr(acc_start_address),
    .outputaddr(op_start_address),
    .channelItr(channel_iteration),
    .kernelItr(kernel_iteration),
    .ImageDimOutput(img_dim_Op),
    .ImageDimAcc(img_dim_Acc),
    .AccEn(ACC_EN),
    .DispatchId(dispatch_id),
    .DispatchEn(dispatch_cpu_en),
    .Acc_onchip(Acc_onchip),
    .OB_OH(op_height),
    .OB_OW(op_width),
    .OutputBlock_AccumulantReadFirst(OutputBlock_AccumulantReadFirst),

    //Tail inst. signals
    .opcode_TB(Op_code_TB),
    .BNEn(),
    .BNchannels(),
    .BNStartAddress(),
    .BNEndAddress(),
    .ActEn(ACT_EN),
    .acttype(relu_act_type),
    .ActParam(relu_clip_value),
    .QuantEn(QUANT_EN), // goes to iteration cter
    .quantscale(tail_quantscale),
    .quantshift(tail_quantshift),
    .PoolEn(POOL_EN), //goes to iteration cter
    .pooltype(pooltype),
    .poolwidth(poolwidth),
    .poolheight(poolheight),
    .poolstride(poolstride),
    .poolpadding(poolpadding),
    .poolceil(poolceil),
    .poolModCount(poolModCount),
    .poolpadsides(poolpadsides),
    .BiasEn(BIAS_EN),  //goes to iteration cter and bias req ctrler
    .BiasWidth(BiasWidth),
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
  wire LeftOperand_fifo_status;
  wire RightOperand_fifo_status;
  // wire [(($clog2(OP_WRITE_FIFO_DEPTH)+1)*OP_FIFO)-1:0] op_write_dram_fifo_occupants;
  
  wire iter_done;
  wire channel_done;
  wire img_read_done;
  // Memory request controllers - img, weight, bias etc
  request_controller_img #(
      .BURST_LENGTH(IMG_REQ_BLEN),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),  
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .KERNELITR_WIDTH(W_KITER_CNT),
      .CHANNELITR_WIDTH(W_CITER_CNT),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .CONV_TYPE_WIDTH(CONV_ConvType_WIDTH)
  ) image_req_ctrl (
      .start_addr(img_start_address),
      .kernelitr(kernel_iteration),
      .channelitr(channel_iteration),
      .stop_addr(img_stop_address),
      .config_start(start_SA),
      .fifo_status(img_fifo_status),
      .clk(i_clk),
      .rst(i_rst),
      .iter_done(iter_done),
      .c_done(channel_done),
      .conv_type(conv_type),
      .conv_ack(ack_opcode[`OP_CONV]),
      .dup_flag(CONV_ChannelDuplicate),
      .img_rd_done(img_read_done),

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
      .BURST_LENGTH1(WEIGHT_REQ_BLEN), //burst length in CONV mode
      .BURST_LENGTH2(FC_WEIGHT_REQ_BLEN), //burst length in FC mode
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) weight_req_ctrl (
      .start_addr(start_address_weights),
      .stop_addr(stop_address_weights),
      .config_start(start_SA | start_FC),
      .CONV_FC(CONV_FC),
      .fifo_status(weight_fifo_status),
      //.data_last(weight_data_last),
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

  wire Bias_En;
  assign Bias_En = (BIAS_EN && BiasWidth > 8);
  request_controller_bias #(
      .BURST_LENGTH(BIAS_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) bias_req_ctrl (
      .start_addr(bias_start_address),
      .stop_addr(bias_stop_address),
      .config_start(start_SA | start_FC),
      .fifo_status(bias_fifo_status),
      .Biasen(Bias_En), 
      .clk(i_clk),
      .addr_out(mc_bias_addr),
      .wr_enable(mc_bias_rdreq),
      .valid(mc_bias_valid),
      .burst_length(mc_bias_bl),
      .last(mc_bias_last)
  );

  wire Bias8_EN;
  assign Bias8_EN = (BIAS_EN && BiasWidth==8);
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
      .FCbiasen(Bias8_EN), 
      .clk(i_clk),
      .addr_out(mc_fc_bias_addr),
      .wr_enable(mc_fc_bias_rdreq),
      .valid(mc_fc_bias_valid),
      .burst_length(mc_fc_bias_bl),
      .last(mc_fc_bias_last)
  );

  
  wire im2col_global_start;
  wire vector_add_enable;
  
  assign acc_stop_address = acc_start_address + (img_dim_Acc*N_SA)*(DATA_WIDTH_OB/DATA_WIDTH);

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
      .enable(ACC_EN & ~Acc_onchip), // ACC_EN comes from inst. whether is enabled in this layer or not
      .ENABLE(vector_add_enable), // acc_en comes from iteration cter to enable it in current iteration based on the instruction field
      .addr_out(mc_acc_addr),
      .wr_enable(mc_acc_rdreq),
      .valid(mc_acc_valid),
      .burst_length(mc_acc_bl),
      .last(mc_acc_last)
  );

  request_controller_EltWiseOperand #(
      .BURST_LENGTH(ELEMENT_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) LeftOperand_req_ctrl (
      .start_addr(LeftOperand_start_address),
      .stop_addr(LeftOperand_stop_address),
      .config_start(start_EW),
      .fifo_status(LeftOperand_fifo_status),
      .clk(i_clk),

      .addr_out(mc_LeftOperand_addr),
      .wr_enable(mc_LeftOperand_rdreq),
      .valid(mc_LeftOperand_valid),
      .burst_length(mc_LeftOperand_bl),
      .last(mc_LeftOperand_last)
  );
  
  request_controller_EltWiseOperand #(
      .BURST_LENGTH(ELEMENT_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) RightOperand_req_ctrl (
      .start_addr(RightOperand_start_address),
      .stop_addr(RightOperand_stop_address),
      .config_start(start_EW),
      .fifo_status(RightOperand_fifo_status),
      .clk(i_clk),

      .addr_out(mc_RightOperand_addr),
      .wr_enable(mc_RightOperand_rdreq),
      .valid(mc_RightOperand_valid),
      .burst_length(mc_RightOperand_bl),
      .last(mc_RightOperand_last)
  );

  wire [OP_FIFO-1:0] op_dram_fifo_empty;
  wire [(($clog2(OP_WRITE_FIFO_DEPTH)+1)*OP_FIFO)-1:0] op_write_dram_fifo_occupants;
  wire data_last_op_write;
  wire op_done;

  op_write_req_block#(
    .N(N_SA),
    .OP_FIFO(OP_FIFO),
    .DEPTH(OP_WRITE_FIFO_DEPTH),
    .BURST_LENGTH(OP_WRITE_REQ_ACC_BLEN),
    .BURST_LENGTH_1(ACC_REQ_BLEN),
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
    .i_data_last(o_data_last_op_write), //i-wire: data last signal from dram write controller
    .i_acc_address(acc_start_address), //i-wire: accumulant start address from inst.
    .i_op_start(op_start_address), //i-wire: start address of quantized o/p from inst.
    .i_channel_itr(channel_iteration),
    .i_kernel_itr(kernel_iteration),
    .i_imag_dim(img_dim_Acc),
    .i_imag_dim_2(img_dim_Op), //i-wire: above four from inst.
    .occupants(op_write_dram_fifo_occupants), // i-wire: op_write dram fifo occupants
    .acc_en(vector_add_enable),
    .Tail_done(Tail_done), //i-wire: Tail_done from TOP_CONV_FC
    .Acc_onchip(Acc_onchip), //i-wire: Enables Accumulant storage locally, comes from instruction
    .o_read_write_req(mc_op_writereq),
    .o_valid(mc_op_write_valid),
    .o_address(mc_op_write_addr),
    .o_burst_len(mc_op_write_bl),
    .o_last(mc_op_write_last),
    .op_done(op_done) //o-wire: op_done signal to Iteration_ctr
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
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] fifo_imgo_data;
  wire [(($clog2(DRAM_IMG_FIFO_DEPTH)+1)*(AXI_DATA_BYTES))-1:0] img_fifo_occupants; 

  wire [$clog2(DRAM_IMG_FIFO_DEPTH):0] img_fifo_occupants1 = img_fifo_occupants[$clog2(DRAM_IMG_FIFO_DEPTH):0];
  wire [$clog2(DRAM_IMG_FIFO_DEPTH):0] img_fifo_th;
  // assign img_fifo_th = input_img_width>>1;
  assign img_fifo_th = ((DRAM_IMG_FIFO_DEPTH[$clog2(DRAM_IMG_FIFO_DEPTH):0]))/2;

  /* Generation of img_fifo_status that controls the img read requests */
  reg [$clog2(DRAM_IMG_FIFO_DEPTH):0] req_occupants_img;
  wire [BURST_LENGTH_WIDTH : 0] mc_img_bl1;
  assign mc_img_bl1 = mc_img_bl + 1;
  always@(posedge i_clk) begin
    if(!i_rst) begin
      req_occupants_img <= 0;
    end
    else begin
      if(start_en) begin
        if(mc_img_last && select[`Image])                      req_occupants_img <= req_occupants_img + mc_img_bl;
        else if(mc_img_last)                                   req_occupants_img <= req_occupants_img + (mc_img_bl+1);
        else if(select[`Image])                                req_occupants_img <= req_occupants_img - 1;
        else                                                   req_occupants_img <= req_occupants_img;
      end
      else begin
        req_occupants_img <= 0;
      end
    end
  end

  reg [$clog2(DRAM_IMG_FIFO_DEPTH):0] r_img_fifo_occupants;
  always@(*) begin
    r_img_fifo_occupants = img_fifo_occupants1+req_occupants_img;
  end
  assign img_fifo_status = ((img_fifo_occupants[$clog2(DRAM_IMG_FIFO_DEPTH):0]+req_occupants_img)<=img_fifo_th)? 1 : 0;
  
  wire [AXI_DATA_WIDTH-1:0] image_data_out;
  wire image_data_out_dv;

  CONV_ip_data_handler # (
    .AXI_WIDTH(AXI_DATA_WIDTH),
    .N_FIFO(AXI_DATA_BYTES),
    .DATA_WIDTH(DATA_WIDTH),
    .N_SA(N_SA)
  )
  CONV_ip_data_handler_inst (
    .clk(i_clk),
    .rstn(i_rst),
    .i_data(image_fifo_in_data),
    .i_dv(&(image_wren)),
    .dup_flag(CONV_ChannelDuplicate),
    .iter_done(iter_done),
    .c_done(channel_done),
    .o_data(image_data_out),
    .o_dv(image_data_out_dv)
  );

  //fifo img
  dram_fifo #(
      .DIMENSION(AXI_DATA_BYTES),
      .W_DATA(DATA_WIDTH),
      .W_ADDR($clog2(DRAM_IMG_FIFO_DEPTH)),
      .OUTPUT_REG(0),
      .RAM_DEPTH(DRAM_IMG_FIFO_DEPTH)
  ) image_ddr_fifo (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data(image_data_out),
      .i_read_enable(image_rden),
      .i_write_enable({AXI_DATA_BYTES{image_data_out_dv}}),
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

  //Calculating the total number of FIFOs required for weights sharing between CONV and FC block
  localparam N_FIFOS = ((N_SA * COL_SA) > AXI_DATA_BYTES) ? (N_SA) : (AXI_DATA_BYTES/COL_SA);
  localparam N_FIFO_FC = AXI_DATA_BYTES/COL_SA; // number of FIFOS shared for FC Engine
  wire [(N_FIFOS * COL_SA * DATA_WIDTH)-1 : 0] weight_dram_fifosharing;
  wire [N_FIFOS-1 : 0] weight_write_en_fifosharing;

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
  wire [N_FIFO_FC-1 : 0] weight_read_en_fc;
  wire [(N_FIFO_FC * ($clog2(WEIGHT_FIFO_DEPTH) + 1))-1 : 0] weight_occupants_fc;
  wire weight_empty_fc;
  wire weight_almost_empty_fc;
  wire [N_FIFO_FC-1 : 0] weight_dv_fc;
  wire [(COL_FC * DATA_WIDTH)-1 : 0] weight_data_fc;

  //wire sel_sa_rden;
  wire [(N_SA)-1 : 0] weight_read_en_sa;
  wire [(N_SA)-1 : 0] weight_dv_sa;
  wire [(N_SA * (($clog2(WEIGHT_FIFO_DEPTH) + 1)))-1 : 0] weight_occupants_sa;
  wire [(N_SA)-1 : 0] weight_empty_sa;
  wire [(N_SA * COL_SA * DATA_WIDTH)-1 : 0] weight_data_sa;

  wire [(N_FIFOS* ($clog2(WEIGHT_FIFO_DEPTH) + 1))-1 : 0] weight_fifo_occupants;
  reg [$clog2(WEIGHT_FIFO_DEPTH):0] limit_c=0,limit_f;
  always @(*) begin 
	  limit_c = (2*ROW[$clog2(WEIGHT_FIFO_DEPTH):0]);
	  limit_f = (((WEIGHT_FIFO_DEPTH[$clog2(WEIGHT_FIFO_DEPTH):0])*3)/4);
  end

  //Virtual occupant logic for weights
  reg [$clog2(WEIGHT_FIFO_DEPTH):0] virtual_occ_weight;
  always@(posedge i_clk) begin
    if(!i_rst) virtual_occ_weight <= 0;
    else begin
      if(start_en) begin
        if(mc_wghts_last && select[`Weight])  virtual_occ_weight <= virtual_occ_weight + mc_wghts_bl;
        else if(mc_wghts_last)                virtual_occ_weight <= virtual_occ_weight + (mc_wghts_bl+1);
        else if(select[`Weight])              virtual_occ_weight <= virtual_occ_weight - 1;
        else                                  virtual_occ_weight <= virtual_occ_weight;
      end
      else begin
        virtual_occ_weight <= 0;
      end
    end
  end
  assign weight_fifo_status = (CONV_FC==0)? 
                              (((weight_fifo_occupants[$clog2(WEIGHT_FIFO_DEPTH):0]+virtual_occ_weight)<={{limit_c}})? 1 : 0) : 
                              (((weight_occupants_fc[$clog2(WEIGHT_FIFO_DEPTH):0]+virtual_occ_weight)<={{limit_f}})? 1 : 0);

  top_fifo_sharing#(
    .W_DATA(DATA_WIDTH),
    .N_SA(N_SA),
    .COL_SA(COL_SA),
    .ROW(ROW),
    .COL_FC(COL_FC),
    .WEIGHT_FF_DEPTH(WEIGHT_FIFO_DEPTH),
    .N_DRAM_BYTES(AXI_DATA_BYTES),
    .SA_OPCODE(`OP_CONV), // CONV opcode from instructions.vh
    .FC_OPCODE(`OP_FC), // FC opcode from instructions.vh
    .W_OPCODE(OPCODE_WIDTH)
  ) fifo_Sharing_controller(
    .clk(i_clk),
    .i_rstn(i_rst),
    .i_done(iter_done),
    //.i_sel_sa_rden_ctrl(sel_sa_rden), // i-wire: select signal (toggled/un-toggled) from sa
    .i_opcode(opcode), // i-wire - check it how to get this opcode from slave blocks
    .i_data_weight_ff_array(weight_dram_fifosharing),         //i-wire - from fifo sharing wren ctrler
    .i_write_en_weight_ff_array(weight_write_en_fifosharing), //i-wire - from fifo sharing wren ctrler
    .i_read_en_fc(weight_read_en_fc), // i-wire: wt readen from fc
    .i_read_en_sa(weight_read_en_sa), // i-wire: wt read en from SA
    .o_demux_select(fc_mux_Sel), // o-wire: goes to FC block for selecting the fifo array weights to FC block
    .o_occupants_mux_fc(weight_occupants_fc), //o-wire: fifo occupants applied to FC
    .o_empty_mux_fc(weight_empty_fc), //o-wire: fifo empty status to FC
    .o_almost_empty_mux_fc(weight_almost_empty_fc), //o-wire: fifo almost empty status to FC
    .o_dv_mux_fc(weight_dv_fc), //o-wire: wt datavalid to FC
    .o_data_mux_fc(weight_data_fc), //o-wire: weight inputs to FC
    .o_occupants_mux_sa(weight_occupants_sa), //o-wire: fifo occupants applied to SA
    .o_empty_mux_sa(weight_empty_sa), //o-wire: fifo empty status to SA
    .o_dv_mux_sa(weight_dv_sa), //o-wire: wt datavalid to SA
    .o_data_mux_sa(weight_data_sa), //o-wire: weight inputs to SA
    .o_weight_ff_array_occupants(weight_fifo_occupants) //o-wire: weight fifo occupants to weight req ctrler
  );

  assign fc_img_fifo_status = 1'b1;

  wire [(($clog2(ACC_FIFO_DEPTH)+1)*ACC_FIFO)-1:0] acc_fifo_occupants;
  wire [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO)-1:0] bias_fifo_occupants;
  wire [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO_FC)-1:0] fc_bias_fifo_occupants;
  wire [(($clog2(ELTWISE_FIFO_DEPTH)+1)*ELTWISE_FIFO)-1:0] LeftOperand_fifo_occupants;
  wire [(($clog2(ELTWISE_FIFO_DEPTH)+1)*ELTWISE_FIFO)-1:0] RightOperand_fifo_occupants;
  //occupants of acc_fifo,bias_fifo and fc_bias_fifo comes from top_conv_sa block
  wire [$clog2(ACC_FIFO_DEPTH):0] acc_fifo_th;
  wire [$clog2(BIAS_FIFO_DEPTH):0] bias_fifo_th;
  wire [$clog2(ELTWISE_FIFO_DEPTH):0] eltwise_fifo_th;

  assign acc_fifo_th = ((ACC_FIFO_DEPTH[$clog2(ACC_FIFO_DEPTH):0])/2);
  assign bias_fifo_th = ((3*(BIAS_FIFO_DEPTH[$clog2(BIAS_FIFO_DEPTH):0]))/4);
  assign eltwise_fifo_th = ((3*(ELTWISE_FIFO_DEPTH[$clog2(ELTWISE_FIFO_DEPTH):0]))/4);
  
	reg [$clog2(ACC_FIFO_DEPTH):0] virtual_occ;
  reg [$clog2(BIAS_FIFO_DEPTH):0] virtual_occ_bias;
  reg [$clog2(ELTWISE_FIFO_DEPTH):0] virtual_occ_LeftOperand;
  reg [$clog2(ELTWISE_FIFO_DEPTH):0] virtual_occ_RightOperand;

  always @ (posedge i_clk) begin
    if(!i_rst) virtual_occ <= 0;
    else begin
      if(start_en) begin
        if(mc_acc_last && select[`Acc]) virtual_occ <= virtual_occ + mc_acc_bl;
        else if(mc_acc_last)            virtual_occ <= virtual_occ + (mc_acc_bl+1);
        else if(select[`Acc])           virtual_occ <= virtual_occ-1;
        else                            virtual_occ <= virtual_occ;
      end
      else begin
        virtual_occ <= 0;
      end
    end
  end
  
  always @ (posedge i_clk) begin
    if(!i_rst) virtual_occ_bias <= 0;
    else begin
      if(start_en) begin
        if(mc_bias_last && select[`Bias]) virtual_occ_bias <= virtual_occ_bias + mc_bias_bl;
        else if(mc_bias_last)             virtual_occ_bias <= virtual_occ_bias + (mc_bias_bl+1);
        else if(select[`Bias])            virtual_occ_bias <= virtual_occ_bias-1;
        else                              virtual_occ_bias <= virtual_occ_bias;
      end
      else begin
        virtual_occ_bias <= 0;
      end
    end
  end

  always @ (posedge i_clk) begin
    if(!i_rst) virtual_occ_LeftOperand <= 0;
    else begin
      if(start_en) begin
        if(mc_LeftOperand_last && select[`LeftOperand]) virtual_occ_LeftOperand <= virtual_occ_LeftOperand + mc_LeftOperand_bl;
        else if(mc_LeftOperand_last)                    virtual_occ_LeftOperand <= virtual_occ_LeftOperand + (mc_LeftOperand_bl+1);
        else if(select[`LeftOperand])                   virtual_occ_LeftOperand <= virtual_occ_LeftOperand-1;
        else                                            virtual_occ_LeftOperand <= virtual_occ_LeftOperand;
      end
      else begin
        virtual_occ_LeftOperand <= 0;
      end
    end
  end

  always @ (posedge i_clk) begin
    if(!i_rst) virtual_occ_RightOperand <= 0;
    else begin
      if(start_en) begin
        if(mc_RightOperand_last && select[`RightOperand]) virtual_occ_RightOperand <= virtual_occ_RightOperand + mc_RightOperand_bl;
        else if(mc_RightOperand_last)                     virtual_occ_RightOperand <= virtual_occ_RightOperand + (mc_RightOperand_bl+1);
        else if(select[`RightOperand])                    virtual_occ_RightOperand <= virtual_occ_RightOperand-1;
        else                                              virtual_occ_RightOperand <= virtual_occ_RightOperand;
      end
      else begin
        virtual_occ_RightOperand <= 0;
      end
    end
  end

//  assign acc_fifo_status = (acc_fifo_occupants<={ACC_FIFO{acc_fifo_th}})? 1 : 0;
  assign acc_fifo_status = ((acc_fifo_occupants[$clog2(ACC_FIFO_DEPTH):0]+virtual_occ)<=acc_fifo_th)? 1 : 0;
  assign bias_fifo_status = ((bias_fifo_occupants[$clog2(BIAS_FIFO_DEPTH):0]+virtual_occ_bias)<=bias_fifo_th)? 1 : 0;
  assign fc_bias_fifo_status = (fc_bias_fifo_occupants<={BIAS_FIFO_FC{COL_FC[$clog2(BIAS_FIFO_DEPTH):0]}})? 1 : 0;
  assign LeftOperand_fifo_status = ((LeftOperand_fifo_occupants[$clog2(ELTWISE_FIFO_DEPTH):0]+virtual_occ_LeftOperand)<=eltwise_fifo_th)? 1 : 0;
  assign RightOperand_fifo_status = ((RightOperand_fifo_occupants[$clog2(ELTWISE_FIFO_DEPTH):0]+virtual_occ_RightOperand)<=eltwise_fifo_th)? 1 : 0;

  // Data from DRAM
  wire [(ACC_FIFO*DATA_WIDTH_ACC)-1:0] vector_add_values_dram;
  wire [ACC_FIFO-1:0] vector_add_wren_dram;
  // Data from DRAM_data_aligner
  wire [(ACC_FIFO*DATA_WIDTH_ACC)-1:0] vector_add_values_opfifo_acc; // accumulant values read from opfifo and write to input accumulant fifo
  wire [ACC_OP_FIFO-1:0] vector_add_wren_opfifo_acc; // write enable signal for input accumulant fifo

  wire [(ACC_FIFO*DATA_WIDTH_ACC)-1:0] vector_add_values;
  wire [ACC_FIFO-1:0] vector_add_wren;
  
  // DRAM Data write ctlers for accumulants, bias, fcbias

  /*For writing data to Accumulant FIFOs, there exists two paths:
    1. Data from DRAM (Acc_OnChip = 0)
    2. Data from DRAM_data_aligner has separate data path (Acc_OnChip = 1)
    The data from DRAM are written into input accumulant FIFOs in zig-zag fashion
    depends on the number of SA engines and AXI_DATA_WIDTH when Acc_OnChip = 0.
    Otherwise, the data from DRAM_data_aligner are written into input accumulant FIFOs continuously.
    
    The data from DRAM/DRAM_data_aligner are selected through a MUX based on the Acc_OnChip signal.
  */

  wire [AXI_DATA_WIDTH-1:0] acc_dram_data;
  wire acc_dram_data_dv;
  Mem_read_ctrl#(
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .N_FIFO(1) 
  ) Accumulant_blk_data_write_ctrl (
    .clk(i_clk),
    .rst(i_rst),
    .select(select[`Acc]), // select signal of acc fifo blk
    .i_data_valid(dram_rd_datavalid),
    .i_data_last(dram_rd_data_last),
    .i_dram_data(dram_rd_data),
    .o_dram_data(acc_dram_data),
    .o_dram_fifo_wren(acc_dram_data_dv),
    .o_data_last()
  );

  operator_fifo_wren_ctrl #(
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .N_FIFO(ACC_FIFO), //Accumulant FIFOs
    .DATA_WIDTH(DATA_WIDTH_ACC)
  ) Write_ctrl_dram_to_ACC_FIFO (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_dram_data(acc_dram_data),
    .i_datavalid_dram_data(acc_dram_data_dv),
    .o_fifo_wren(vector_add_wren_dram), //o-wire: to vector add fifo blk
    .o_data(vector_add_values_dram) //o-wire: to vector add fifo blk
  );

  // Mux to select between DRAM and OP_FIFO data for writing into input accumulant FIFOs
  vector_mux_param#(
    .PORT_SIZE(ACC_FIFO*DATA_WIDTH_ACC),
    .NO_PORT(2)
  ) Acc_FIFO_mux_data(
    .in({vector_add_values_opfifo_acc,vector_add_values_dram}),
    .sel(1<<Acc_onchip),
    .out(vector_add_values)
  );

  vector_mux_param#(
    .PORT_SIZE(ACC_FIFO),
    .NO_PORT(2)
  ) Acc_FIFO_mux_dv(
    .in({{ACC_FIFO{&vector_add_wren_opfifo_acc}},vector_add_wren_dram}),
    .sel(1<<Acc_onchip),
    .out(vector_add_wren)
  );
  
  wire [AXI_DATA_WIDTH-1:0] bias_dram_data;
  wire bias_dram_data_dv;

  wire [(BIAS_FIFO*DATA_WIDTH_OB)-1:0] bias_data_in;
  wire [BIAS_FIFO -1:0] bias_wren;
  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(1) 
  )Bias_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`Bias]), // select signal of bias fifo blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(bias_dram_data),   //o-wire: to bias fifo blk
        .o_dram_fifo_wren(bias_dram_data_dv), //o-wire: to bias fifo blk
        .o_data_last()
  );
  
  
  operator_fifo_wren_ctrl #(
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .N_FIFO(BIAS_FIFO), //Bias FIFOs
    .DATA_WIDTH(DATA_WIDTH_OB)
  ) Write_ctrl_bias_FIFO (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_dram_data(bias_dram_data),
    .i_datavalid_dram_data(bias_dram_data_dv),
    .o_fifo_wren(bias_wren), //o-wire: to bias fifo blk
    .o_data(bias_data_in) //o-wire: to bias fifo blk
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

  wire [AXI_DATA_WIDTH -1:0]LeftOperand_in_data;
  wire [AXI_DATA_WIDTH -1:0]RightOperand_in_data;
  wire [ELTWISE_FIFO -1:0] dv_LeftOperand_data;
  wire [ELTWISE_FIFO -1:0] dv_RightOperand_data;
  
  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(ELTWISE_FIFO) 
  )LeftOperand_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`LeftOperand]), 
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(LeftOperand_in_data),
        .o_dram_fifo_wren(dv_LeftOperand_data), 
        .o_data_last()
  );

  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(ELTWISE_FIFO) 
  )RightOperand_blk_data_write_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`RightOperand]), 
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(RightOperand_in_data), 
        .o_dram_fifo_wren(dv_RightOperand_data),
        .o_data_last()
  );
  // slicing of img_fifo o/p data to store it in data buffers of im2col
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] img_ip_conv;

  localparam ACC_OP_DATAWIDTH = ((N_SA*DATA_WIDTH_ACC) < (AXI_DATA_WIDTH)) ? (N_SA*DATA_WIDTH_ACC*ACC_OP_FIFO) : (N_SA*DATA_WIDTH_ACC);
  wire [ACC_OP_FIFO-1:0] acc_op_wren;
  wire [ACC_OP_DATAWIDTH-1:0] acc_op_write_data;

  wire [(AXI_DATA_WIDTH-1):0] quant_op_write_data;
  wire [QUANT_OP_FIFO-1:0] quant_op_wren;

  wire shift_reg_en;
  wire [N_SA-1:0] shift_reg_sel;
  assign shift_reg_sel = {N_SA{shift_reg_en}};

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
	wire psum_full;
  wire  op_full;

  wire  [CONV_StartRowSkip_WIDTH-1:0]   start_row_skip;
  wire  [CONV_EndRowSkip_WIDTH-1:0]   end_row_skip;



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
      .DATA_WIDTH_ACC(DATA_WIDTH_ACC),
      .W_CONV_IMAGE_DIM(CONV_IW_WIDTH),
      .W_CONV_OP_IMAGE_DIM(OutputBlock_OW_WIDTH),
      .SHFT_REG_X(SHFT_REG_X),
      .BIAS_FIFO(BIAS_FIFO),
      .ACC_OP_FIFO(ACC_OP_FIFO),
      .QUANT_OP_FIFO(QUANT_OP_FIFO),
      .ACC_FIFO(ACC_FIFO),
      .WEIGHT_FIFO_DEPTH(WEIGHT_FIFO_DEPTH),
      .IM2COL_FIFO_DEPTH(IM2COL_FIFO_DEPTH),
      .PSUM_FIFO_DEPTH(PSUM_FIFO_DEPTH),
      .ACC_FIFO_DEPTH(ACC_FIFO_DEPTH),
      .BIAS_FIFO_DEPTH(BIAS_FIFO_DEPTH),
      .NSA_DSP(NSA_DSP),
      .N_FC_MUX(N_FC_MUX),
      .NO_PORT_FC(NO_PORT_FC),
      .RELU_CLIP_WIDTH(RELU_CLIP_WIDTH),
      .ACT_TYPE_WIDTH(ACT_TYPE_WIDTH),
      .NSA_LUT(NSA_LUT),
      .BIAS_FIFO_FC(BIAS_FIFO_FC),
      .ACC_TOGGLE(ACC_TOGGLE),
      .NO_PORT_VA(NO_PORT_VA),
      .NO_PORT_BAC(NO_PORT_BAC),
      .NO_PORT_BAFC(NO_PORT_BAFC),
      .POP_THRESHOLD(POP_THRESHOLD),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
      .N_DMUX_PORTS(N_DMUX_PORTS),

      //general pool
      .POOLEN_WIDTH   (POOLEN_WIDTH),
      .POOLTYPE_WIDTH (POOL_TYPE_WIDTH),
      .POOLWIDTH_WIDTH (W_POOL_WIDTH),
      .POOLHEIGHT_WIDTH (W_POOL_HEIGHT),
      .POOLSTRIDE_WIDTH (W_POOL_STRIDE),
      .POOLPADDING_WIDTH (W_POOL_PAD),
      .POOLCEIL_WIDTH (W_POOL_CEIL),
      .POOLMODCOUNT_WIDTH (W_POOL_MODCOUNT),
      .POOLPADSIDES_WIDTH (W_POOL_PADSIDES),

      //FC realated parameters      
      .FC_IMAGE_ROWS_WIDTH(FC_IMAGE_ROWS_WIDTH), 
      .ACC_DW(ACC_DW),
      .N_BANK(N_BANK),
      .N_BRAM(N_BRAM),
      .W_FC_RW_COUNTER(W_FC_RW_COUNTER),
      .FC_BRAM_DEPTH(FC_BRAM_DEPTH),
      .W_KERNEL_CNT(W_KITER_CNT),
      .W_FC_IMAG_DIM(W_FC_IMAG_DIM),
      .ACC_DATA_REORDER(ACC_DATA_REORDER),
      // for im2col_v1
      .STRIDE(CONV_STRIDE_WIDTH),
      .KERNEL_SIZE(KERNEL_SIZE),
      .CONV_STRIDE_WIDTH(CONV_STRIDE_WIDTH),
      .CONV_KW_WIDTH(CONV_KW_WIDTH),
      .CONV_KH_WIDTH(CONV_KH_WIDTH),
      .OutputBlock_OH_WIDTH(OutputBlock_OH_WIDTH),
      .OutputBlock_OW_WIDTH(OutputBlock_OW_WIDTH),
      .CONV_IW_WIDTH(CONV_IW_WIDTH),
      .CONV_IH_WIDTH(CONV_IH_WIDTH),
      
      
      .CONV_PadLeft_WIDTH(CONV_PadLeft_WIDTH),
      .CONV_PadRight_WIDTH(CONV_PadRight_WIDTH),
      .CONV_PadTop_WIDTH(CONV_PadTop_WIDTH),
      .CONV_PadBottom_WIDTH(CONV_PadBottom_WIDTH),
      .CONV_StartRowSkip_WIDTH(CONV_StartRowSkip_WIDTH),
      .CONV_EndRowSkip_WIDTH(CONV_EndRowSkip_WIDTH),

      .ELTWISE_FIFO(ELTWISE_FIFO),
      .ELTWISE_FIFO_DEPTH(ELTWISE_FIFO_DEPTH),
      .ELTWISE_IW_WIDTH(ELTWISE_IW_WIDTH),
      .ELTWISE_IH_WIDTH(ELTWISE_IH_WIDTH),
      .ELTWISE_IC_WIDTH(ELTWISE_IC_WIDTH),
      .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
      .CONV_TYPE_WIDTH(CONV_ConvType_WIDTH)
  ) top_CONV_FC_Block (
      .i_clk(i_clk),
      .s_clk(s_clk),
      .i_img_dim_Acc(img_dim_Acc), // image dimension of accumulant o/p
      .i_img_dim_Op(img_dim_Op), // image dimension of quantized o/p
      .image_fifo_empty(image_fifo_empty),
      .CONV_FC(CONV_FC),
      .opcode(opcode),
      .fifo_o(fifo_imgo_data),
      .conv_type(conv_type),  //conv type from instruction
      //fifo sharing signals
      //.sel_sa_rden(sel_sa_rden),
      .stall_on(stall_on),
      .weight_read_en_fc(weight_read_en_fc),
      .weight_occupants_fc(weight_occupants_fc),
      .weight_empty_fc(weight_empty_fc),
      .weight_almost_empty_fc(weight_almost_empty_fc),
      .weight_dv_fc(weight_dv_fc),
      .weight_data_fc(weight_data_fc),
      .weight_read_en_sa(weight_read_en_sa),
      .weight_dv_sa(weight_dv_sa),
      .weight_occupants_sa(weight_occupants_sa),
      .weight_empty_sa(weight_empty_sa),
      .weight_data_sa(weight_data_sa),
      .p_full_output(psum_full),
	    //Flattening and FC signals
      .flatten_enable(flatten_enable), //comes from FC instruction
      .start_FC(Flattening_trigger),
      .start_SA(start_SA),
      .i_rw_addr_cnt_flatten(fc_rw_address_counter), //r/w address cnt from FC inst.
      .i_kernel_cnt_FC(fc_kernel_iter), //kernel cnt from FC inst.
      .i_img_dim_flatten(fc_imagedim), //img dim for flattening-comes from FC inst.
      .i_data_valid_flatten(dv_fc_image_data), //valid of data from DDR
      .i_data_FC(fc_image_in_data), //data from DDR
      .i_img_dim_fc(fc_image_rows), // image dim of FC i/p (input rows-FC inst.) goes to FC engine
      .i_sel_fc_fifosharing(fc_mux_Sel), //o-wire: select to signal to FC for reading weights from fifo sharing ctrl
      .op_full(op_full), 
      //vector addition and tail block signals    
      .vector_add_values(vector_add_values),
      .vector_add_wren(vector_add_wren),
      .maxpool_threshold(op_width), //output matrix width of SA engine
      .op_height(op_height),
      .op_width(op_width),
      .layer_done(layer_done),
      .iteration_Done(iter_done),
      .channel_done(channel_done),
      .shift_reg_sel(shift_reg_sel),
      .systolic_array_trigger(systolic_array_trigger),
      .i_rst(i_rst),
      .relu_clip_value(relu_clip_value),
      .relu_act_type(relu_act_type),
      .bias_enable(bias_enable),
      .quant_enable(quant_enable),
      .bias_fc_enable(bias_fc_enable),
      .conv_pad_left(conv_pad_left),
      .conv_pad_right(conv_pad_right),
      .conv_pad_top(conv_pad_top),
      .conv_pad_bottom(conv_pad_bottom),


      .image_width(input_img_width),
      .image_height(input_img_height),
      .valid_img_size_im2col(valid_opcode[`OP_CONV]), //valid inst conv
      .im2col_global_start(im2col_global_start),
      .img_read_done(img_read_done),
      .image_rden(image_rden),
      .row(row),
	    .col(col),
      .real_col(real_col),
      .real_row(real_row),
      .relu_enable(relu_enable),
      .bias_data_in(bias_data_in),
      .bias_wren(bias_wren),
      .bias_data_in_fc(bias_data_in_fc),
      .bias_wren_fc(bias_wren_fc),
      .shift_value(({COL_SA{tail_quantshift}})),
      .quant_scale(({COL_SA{tail_quantscale}})),
      .vector_add_enable(vector_add_enable),
      .maxpool_enable(maxpool_enable),
      
      .acc_op_write_data(acc_op_write_data),
      .acc_op_wren(acc_op_wren),
      .quant_op_write_data(quant_op_write_data),
      .quant_op_wren(quant_op_wren),

      .PoolType(pooltype),
      .PoolWidth(poolwidth),
      .PoolHeight(poolheight),
      .PoolStride(poolstride),
      .PoolPadding(poolpadding),
      .PoolCeil(poolceil),
      .PoolModCount(poolModCount),
      .PoolPadSides(poolpadsides),

      .im2col_done(im2col_done),
      .SA_psum_fifo_empty(SA_psum_fifo_empty),
      .Tail_done(Tail_done), // Generated in integration block
      .FC_done(FC_done), //accumulator valid signal of FC engine
      .FC_layerdone(FC_layerdone),
      .EW_done(EW_done),
      .acc_fifo_occupants(acc_fifo_occupants),
      .bias_fifo_occupants(bias_fifo_occupants),
      .fc_bias_fifo_occupants(fc_bias_fifo_occupants),
      .stride(stride),
      .kernel_width(kernel_width),
      .kernel_height(kernel_height),
      .o_image_fifo_almost_empty_flag(sa_image_fifo_almost_empty_flag),
      .o_image_fifo_almost_full_flag(sa_image_fifo_almost_full_flag),
      .istolic_stall(istolic_stall),
      
      .op_fifo_empty(op_done),
      .LeftOperand_data_in(LeftOperand_in_data),
      .RightOperand_data_in(RightOperand_in_data),
      .LeftOperand_wr_en(dv_LeftOperand_data),
      .RightOperand_wr_en(dv_RightOperand_data),
      .EltWise_type(EltWise_type),
      .EltWise_IW(EltWise_IW),
      .EltWise_IH(EltWise_IH),
      .EltWise_IC(EltWise_IC),
      .LeftOperand_fifo_occupants(LeftOperand_fifo_occupants),
      .RightOperand_fifo_occupants(RightOperand_fifo_occupants),
      .EltWise_op_en(valid_opcode[`OP_EltWise]),
      .start_row_skip(start_row_skip),
      .end_row_skip(end_row_skip)
  );

  wire [OP_FIFO-1:0] op_write_fifo_rden;
  wire [OP_FIFO-1:0] op_dram_rden;
  assign op_write_fifo_rden = op_dram_rden;

  //output block - data write to dram comes from tail blocks (pipelined o/p of mega blocks)
  dram_data_aligner # (
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .N_SA(N_SA),
    .DATA_WIDTH_ACC(DATA_WIDTH_ACC),
    .ACC_OP_FIFO(ACC_OP_FIFO),
    .ACC_OP_FIFO_DEPTH(ACC_OP_FIFO_DEPTH),
    .QUANT_OP_FIFO(QUANT_OP_FIFO),
    .QUANT_OP_FIFO_DEPTH(QUANT_OP_FIFO_DEPTH),
    .OP_FIFO_DEPTH(OP_WRITE_FIFO_DEPTH),
    .OP_FIFO(OP_FIFO),
    .OUTPUT_REG(0)
  )
  dram_data_aligner_inst (
    .i_clk(i_clk),
    .i_rst(i_rst&(~iter_done)),
    .i_acc_quant_enable(quant_enable),
    .i_Acc_Onchip(Acc_onchip),
    .i_acc_data(acc_op_write_data),
    .i_acc_data_wren(acc_op_wren),
    .i_quant_data(quant_op_write_data),
    .i_quant_data_wren(quant_op_wren),   
    .i_op_write_dram_fifo_rden(op_write_fifo_rden),
    .o_op_write_dram_fifo_occupants(op_write_dram_fifo_occupants),
    .o_op_write_dram_fifo_empty(op_dram_fifo_empty),
    .o_op_write_dram_fifo_data(op_dram_fifo),
    .o_op_write_dram_fifo_dv(op_write_fifo_dv),
    .o_op_full(op_full),
    .o_acc_onchip_data(vector_add_values_opfifo_acc),
    .o_acc_onchip_data_dv(vector_add_wren_opfifo_acc)
  );

  // DRAM write control for OP_FIFO  
  Mem_write_ctrl#(
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
    .N_FIFO(OP_FIFO)
  ) op_dram_fifo_rden_ctrl(
    .clk(i_clk),
    .rst(i_rst),
    .select(sel_op_write), //select signal from DRAM ctrler (WR_ID mger)
    .wready(wready), // from DRAM ctrler (WR_ID mger)
    .blen(wr_burst_len), // from DRAM ctler ()
    .o_data_valid(dv_op_write),
    .data_last(o_data_last_op_write),
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
    wire [OutputBlock_AccumulantReadFirst_WIDTH-1:0] OutputBlock_AccumulantReadFirst;

    assign op_fifo_empty = &(op_dram_fifo_empty);
    
    // wire Conv_Ack, OpBlock_Ack, Tail_Ack, FC_Ack;
    //o_done_rden_ctrl from flattening indicates data read from BRAM for k_iter times
    assign FC_Ack = FC_layerdone;  

  // iteration counter new 
    iteration_cnt_new #(
        .CITER_CNT_WIDTH(W_CITER_CNT), 
        .KITER_CNT_WIDTH(W_KITER_CNT),
        .OutputBlock_AccumulantReadFirst_WIDTH(OutputBlock_AccumulantReadFirst_WIDTH),
        .NUM_INSTRUCTIONS(NUM_INSTRUCTIONS)
    )
    iteration_counter_new_inst
    (
        .i_clk(i_clk),
        .rst(i_rst),
        .i_start(start),
        .CONV_FC(CONV_FC),
        .im2col_done(im2col_done), // i-wire : from im2col block
        .SA_psum_fifo_empty(SA_psum_fifo_empty),
        .Tail_done(Tail_done),
        .op_fifo_empty(op_done),
        .FC_done(FC_done),
        .EW_done(EW_done),
        .c_iter(channel_iteration), //channel iteration
        .k_iter(kernel_iteration), //kernel iteration

        .o_iter_done(iter_done),
        .o_c_done(channel_done),
        .o_layer_done(layer_done),

        .BIAS_EN(Bias_En),
        .RELU_EN(ACT_EN),
        .QUANT_EN(QUANT_EN),
        .POOL_EN(POOL_EN),
        .ACC_EN(ACC_EN),  
        .FC_BIAS_EN(Bias8_EN), //above six signals comes from instruction fields

        .acc_en(vector_add_enable),
        .relu_en(relu_enable),
        .quant_en(quant_enable),
        .bias_en(bias_enable),
        .fc_bias_en(bias_fc_enable), 
        .pool_en(maxpool_enable),
        .en(shift_reg_en),
        //for io signals
        .kernal_count(kernal_count), // represents the current kernal iteration number 
        .channel_count(channel_count), // represents the current channel iteration number 
        .OutputBlock_AccumulantReadFirst(OutputBlock_AccumulantReadFirst),
        .ack_opcode(ack_opcode),
        .valid_opcode(valid_opcode)
    );
   
  wire [NUM_INSTRUCTIONS-1:0] ack_opcode;
  wire [NUM_INSTRUCTIONS-1:0] valid_opcode;

  mega_block_start_ctrl # (.NUM_INSTRUCTIONS(NUM_INSTRUCTIONS))
  mega_block_start_ctrl_duu (.start_command(start_command),
    .i_clk(i_clk),
    .i_rst(i_rst),
    .start_out(start),
    .ack_opcode(ack_opcode),
    .valid_opcode(valid_opcode),
    .start_block(start_block));






/* 
    im2col needs start in each iteration.
    im2col soft start controller waits for 'iter_done' and generates a 
    next 'start_im2col' signal to im2col block in each iteration till 
    kernel counter reaches maximum. 
*/
    im2col_start_ctrler #(
      .CITER_CNT_WIDTH(W_CITER_CNT),
      .KITER_CNT_WIDTH(W_KITER_CNT),
      .CONV_TYPE_WIDTH(CONV_ConvType_WIDTH)
    )
    im2col_start_ctrler_inst
    (
      .clk(i_clk),
      .rst(i_rst),
      .start(start_SA), //start_SA
      .image_fifo_empty(&(image_fifo_empty)),
      .iter_done(iter_done),
      .c_iter(channel_iteration),
      .k_iter(kernel_iteration),
      .conv_type(conv_type),
      .dup_flag(CONV_ChannelDuplicate),

      .start_im2col(im2col_global_start)
    );

  reg [31:0] debug_counter;
  reg start_en;
  always@(posedge i_clk) begin
    if(!i_rst) debug_counter <= 0;
    else begin
      if(layer_done) debug_counter <= 0;
      else if(start_en) debug_counter <= debug_counter + 1;
      else debug_counter <= debug_counter;
    end
  end

  // reg [31:0] stall_cntr;
  // always@(posedge i_clk) begin
  //   if(!i_rst) stall_cntr <= 0;
  //   else begin
  //     if(OpBlock_Ack) stall_cntr <= 0;
  //     else if(start_en) begin
  //       if(stall_on) stall_cntr <= stall_cntr + 1;
  //     end
  //     else stall_cntr <= stall_cntr;
  //   end
  // end

  always@(posedge i_clk) begin
    if(!i_rst) start_en <= 0;
    else begin
      if(start) start_en <= 1;
      else if(layer_done) start_en <= 0;
      else start_en <= start_en;
    end
  end

  reg [LAYERCNT_WIDTH-1:0] layer_cntr;
  always@(posedge i_clk) begin
    if(!i_rst) layer_cntr <= 0;
    else begin
      if(layer_cntr==63) layer_cntr <= 0;
      else begin
        if(layer_done) layer_cntr <= layer_cntr + 1;
      end
    end
  end

  assign layer_debug_pin = (layer_cntr==4)? 1 : 0;

  (*syn_use_dsp = "no"*) wire [2*I_OP_SIZE_WIDTH-1:0] datasize_fpga2cpu; //number of bytes to be transferred from DRAM to CPU
  assign datasize_fpga2cpu = CONV_FC? img_dim_Op*N_SA[I_OP_SIZE_WIDTH-1:0]*fc_kernel_iter : img_dim_Op*kernel_iteration*N_SA;
  assign fpga2cpu_start_address = op_start_address;

  //Hard-coded logic for Acc_onchip flag: Deprecated after inclusion of support from sysim
  // assign Acc_onchip = (CONV_FC)? 0 : ((layer_cntr>=7)? 1 : 0);
  // assign Acc_onchip = (layer_cntr>=7)? 1 : 0;
  // assign Acc_onchip = 0;
endmodule
