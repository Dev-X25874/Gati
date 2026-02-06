`include "common/instructions.vh"
`include "common/portid.vh"
`include "common/arch_param.vh"

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
    parameter CONCAT_FIFO_DEPTH   = 512,

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
    parameter CONCAT_REQ_BLEN       = 15,
    //parameters related to DRAM controller
    parameter NUM_PORTS = 13, //Number of read and write requestors

    //parameters related to AXI
    parameter AXI_DATA_WIDTH        = 256,
    parameter AXI_DATA_BYTES        = 32,  // Axi Data width = 256 bit
    parameter AXI_ADDR_W            = `CONV_ImageStartAddress_WIDTH,   // Axi Address width
    parameter BURST_LENGTH_WIDTH    = 8,
   
    //Config blk param
    parameter NUM_INSTRUCTIONS      = 8,                   
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
    parameter CONV_STRIDE_WIDTH       = `CONV_Stride_WIDTH,
    parameter CONV_PadLeft_WIDTH      = `CONV_PadLeft_WIDTH,
    parameter CONV_PadRight_WIDTH     = `CONV_PadRight_WIDTH,
    parameter CONV_PadTop_WIDTH       = `CONV_PadTop_WIDTH,
    parameter CONV_PadBottom_WIDTH    = `CONV_PadBottom_WIDTH,
    parameter CONV_StartRowSkip_WIDTH = `CONV_StartRowSkip_WIDTH, // Start row skip for im2col
    parameter CONV_EndRowSkip_WIDTH = `CONV_EndRowSkip_WIDTH, // End row skip for im2col
    
    parameter CONV_Im2colPrefetch_WIDTH   = `CONV_Im2colPrefetch_WIDTH ,
    parameter CONV_CHANNELDUPLICATE_WIDTH = `CONV_ChannelDuplicate_WIDTH,

    //im2col related param 
    parameter STRIDE                 = `STRIDE, // From arch_param.vh
    parameter KERNEL_SIZE            = 3,       
    parameter IM2COL_BOUND_GEN_WIDTH = 16,
    parameter N_MOD_STAGES           = 9, // Number of stages in mod operator in Im2Col stride handling block   
    
    //SA related param
    parameter POP_THRESHOLD  = (AXI_DATA_BYTES/N_SA) - 3,
    parameter NSA_DSP        = 3, 
    parameter NSA_LUT        = 5,
    parameter N_SA           = NSA_DSP + NSA_LUT,
    parameter DATA_WIDTH     = 8,
    parameter COL_SA         = 8,
    parameter COL_FC         = 32,
    parameter ROW            = 9,
    parameter W_PSUM         = 20,
    parameter DATA_WIDTH_OB  = 32,
    parameter DATA_WIDTH_ACC = 32,

    // FC inst. related params
    parameter FC_WEIGHTROW_WIDTH    = `FC_WeightRows_WIDTH,
    parameter FC_WEIGHTCOL_WIDTH    = `FC_WeightCols_WIDTH,
    parameter FC_IMAGE_ROWS_WIDTH   = `FC_InputRows_WIDTH,
    parameter FC_DROPOUT_WIDTH      = `FC_DropoutConstant_WIDTH,
    parameter W_FC_IMAG_DIM         = `FC_ImageDim_WIDTH,
    parameter W_FC_RW_COUNTER       = `FC_Vec2MatCols_WIDTH, 
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
    parameter OutputBlock_OpWidth_WIDTH = `OutputBlock_OpWidth_WIDTH,
    parameter OutputBlock_FlatController_WIDTH = `OutputBlock_FlatController_WIDTH,
    parameter MOD1 = 1,
    parameter MOD2 = AXI_DATA_BYTES/N_SA,
    parameter N_DMUX_PORTS = AXI_DATA_BYTES/(N_SA*(ACC_DW/8)),

    //Tail block param
    parameter ACT_TYPE_WIDTH       = `TailBlock_ActType_WIDTH,
    parameter RELU_CLIP_WIDTH      = `TailBlock_ActParam_WIDTH, 
    parameter LR_NEG_ALPHA_WIDTH   = `TailBlock_NegAlpha_WIDTH,
    parameter LR_POS_ALPHA_WIDTH   = `TailBlock_PosAlpha_WIDTH,  
    parameter W_QUANT_SHIFT     = `TailBlock_QuantShift_WIDTH,
    parameter W_QUANT_SCALE     = `TailBlock_QuantScale_WIDTH, 

    `ifdef GLOBAL_POOL 
    parameter W_GBL_POOL_SCALE = `TailBlock_GblPoolScale_WIDTH,
    parameter W_GBL_POOL_SHIFT = `TailBlock_GblPoolShift_WIDTH,
    parameter W_GBL_POOL_EN    = `TailBlock_GblPoolEn_WIDTH,
    `endif

    `ifdef MEGA_POOL
    parameter W_POOL_IW         = `POOL_IW_WIDTH,
    parameter W_POOL_IH         = `POOL_IH_WIDTH,
    parameter W_POOL_IC         = `POOL_IC_WIDTH,
    parameter W_POOL_IMG_STA_ADD = `POOL_ImageStartAddress_WIDTH,
    parameter W_POOL_IMG_END_ADD = `POOL_ImageEndAddress_WIDTH,
    parameter W_POOL_TYPE       = `POOL_PoolType_WIDTH,
    parameter W_POOL_SCALE      = `POOL_PoolScale_WIDTH,
    parameter W_POOL_SHIFT      = `POOL_PoolShift_WIDTH,
    parameter W_POOL_WIDTH      = `POOL_PoolWidth_WIDTH,
    parameter W_POOL_HEIGHT     = `POOL_PoolHeight_WIDTH,
    parameter W_POOL_STRIDE_W   = `POOL_PoolStrideWidth_WIDTH,
    parameter W_POOL_STRIDE_H   = `POOL_PoolStrideHeight_WIDTH,
    parameter W_POOL_CEIL       = `POOL_PoolCeil_WIDTH,
    parameter W_POOL_PAD_L      = `POOL_PadLeft_WIDTH,
    parameter W_POOL_PAD_R      = `POOL_PadRight_WIDTH,
    parameter W_POOL_PAD_T      = `POOL_PadTop_WIDTH,
    parameter W_POOL_PAD_B      = `POOL_PadBottom_WIDTH,
    parameter W_POOL_PREFETCH   = `POOL_Im2colPrefetch_WIDTH,
    `elsif POOL
    parameter W_POOL_EN         = `TailBlock_PoolEn_WIDTH,
    parameter W_POOL_TYPE       = `TailBlock_PoolType_WIDTH,
    parameter W_POOL_WIDTH      = `TailBlock_PoolWidth_WIDTH,
    parameter W_POOL_HEIGHT     = `TailBlock_PoolHeight_WIDTH,
    parameter W_POOL_STRIDE     = `TailBlock_PoolStride_WIDTH,
    parameter W_POOL_PAD        = `TailBlock_PoolPadding_WIDTH,
    parameter W_POOL_CEIL       = `TailBlock_PoolCeil_WIDTH,
    parameter W_POOL_MODCOUNT   = `TailBlock_PoolModCount_WIDTH,
    parameter W_POOL_PADSIDES   = `TailBlock_PoolPadSides_WIDTH,
    parameter W_POOL_SCALE      = `TailBlock_PoolScale_WIDTH,
    parameter W_POOL_SHIFT      = `TailBlock_PoolShift_WIDTH,
    `endif

    parameter ACTEN_WIDTH       = `TailBlock_ActEn_WIDTH,
    parameter QUANTEN_WIDTH     = `TailBlock_QuantEn_WIDTH,
    parameter BIASEN_WIDTH      = `TailBlock_BiasEn_WIDTH,
    parameter BiasWidth_WIDTH   = `TailBlock_BiasWidth_WIDTH,


    //Reshape Transpose parameters
    parameter RT_BRAM_DEPTH = 512,
    parameter RT_FIFO_DEPTH = 128,
    parameter TRANSPOSE_IC_WIDTH = `TRANSPOSE_IC_WIDTH,
    parameter TRANSPOSE_IH_WIDTH = `TRANSPOSE_IH_WIDTH,
    parameter TRANSPOSE_IW_WIDTH = `TRANSPOSE_IW_WIDTH,
    
    `ifdef RESIZE
    parameter W_RESIZE_IW       = `RESIZE_IW_WIDTH,
    parameter W_RESIZE_IH       = `RESIZE_IH_WIDTH,
    parameter W_RESIZE_IC       = `RESIZE_IC_WIDTH,
    parameter W_RESIZE_IMG_STA_ADD = `RESIZE_ImageStartAddress_WIDTH,
    parameter W_RESIZE_IMG_END_ADD = `RESIZE_ImageEndAddress_WIDTH,      
    `endif
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
    parameter ELTWISE_FIFO = AXI_DATA_BYTES/N_SA, // Number of eltwise fifo
    parameter ELTWISE_TYPE_WIDTH      = `EltWise_EltType_WIDTH,  
    parameter ELTWISE_IW_WIDTH        = `EltWise_IW_WIDTH, 
    parameter ELTWISE_IH_WIDTH        = `EltWise_IH_WIDTH,  
    parameter ELTWISE_IC_WIDTH        = `EltWise_IC_WIDTH,  
    parameter ELTWISE_SCALE_WIDTH     = `EltWise_AScale_WIDTH,
    parameter ELTWISE_ZEROPOINT_WIDTH = `EltWise_AZeroPoint_WIDTH,
    // Concat operator 
    parameter CONCAT_FIFO = 1,
    parameter CONCAT_Image1StartAddress_WIDTH = `CONCAT_Image1StartAddress_WIDTH,
    parameter CONCAT_Image2StartAddress_WIDTH = `CONCAT_Image2StartAddress_WIDTH,
    parameter CONCAT_Image3StartAddress_WIDTH = `CONCAT_Image3StartAddress_WIDTH,
    parameter CONCAT_Image4StartAddress_WIDTH = `CONCAT_Image4StartAddress_WIDTH,
    parameter CONCAT_IH1_WIDTH = `CONCAT_IH1_WIDTH,
    parameter CONCAT_IH2_WIDTH = `CONCAT_IH2_WIDTH,
    parameter CONCAT_IH3_WIDTH = `CONCAT_IH3_WIDTH,
    parameter CONCAT_IH4_WIDTH = `CONCAT_IH4_WIDTH,
    parameter CONCAT_KN1_WIDTH = `CONCAT_KN1_WIDTH,
    parameter CONCAT_KN2_WIDTH = `CONCAT_KN2_WIDTH,
    parameter CONCAT_KN3_WIDTH = `CONCAT_KN3_WIDTH,
    parameter CONCAT_KN4_WIDTH = `CONCAT_KN4_WIDTH,
    parameter CONCAT_InNum_WIDTH = `CONCAT_InNum_WIDTH 

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
    
    `ifdef FC
    ///////fc
    output [7:0] mc_fc_addr,
    output mc_fc_rdreq,
    output mc_fc_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_fc_bl,
    output mc_fc_last,
    `endif //FC

    //////////bias 
    output [7:0] mc_bias_addr,
    output mc_bias_rdreq,
    output mc_bias_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_bias_bl,
    output mc_bias_last,

    `ifdef BIAS_FC
    ///////////////fc_bias 
    output [7:0] mc_fc_bias_addr,
    output mc_fc_bias_rdreq,
    output mc_fc_bias_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_fc_bias_bl,
    output mc_fc_bias_last,
    `endif //BIAS_FC

    /////////////acc
    output [7:0] mc_acc_addr,
    output mc_acc_rdreq,
    output mc_acc_valid,
    output [BURST_LENGTH_WIDTH-1: 0] mc_acc_bl,
    output mc_acc_last,

    `ifdef ELTWISE 
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
    `endif //ELTWISE

    `ifdef TRANSPOSE
    ///////////////ReshapeTranspose
    output [7:0] mc_ReshapeTranspose_addr,
    output mc_ReshapeTranspose_rdreq, 
    output mc_ReshapeTranspose_valid,   
    output [BURST_LENGTH_WIDTH-1 : 0] mc_ReshapeTranspose_bl,
    output mc_ReshapeTranspose_last,
    `endif //TRANSPOSE
    
    `ifdef CONCAT
    // Concat Operator
    output [7:0] mc_Concat_addr,
    output mc_Concat_rdreq,
    output mc_Concat_valid,
    output [BURST_LENGTH_WIDTH-1 : 0] mc_Concat_bl,
    output mc_Concat_last,
    `endif
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
    
    //dispatch dispatch signals
    output start,
    output layer_done,
    output [DISPATCH_ID_WIDTH-1:0] dispatch_id,
    output [DISPATCHEN_WIDTH-1:0] dispatch_cpu_en,
    output [2*I_OP_SIZE_WIDTH-1:0] datasize_dispatch,
    output [AXI_ADDR_W-1:0] dispatch_start_address,
       
    //io signals
    output [6:0] kernal_count, // represents the current kernal iteration number 
    output [6:0] channel_count, // represents the current channel iteration number
    output [3:0] layer_count,
    
    output [31:0] layer_cycles_count,
    output [59:0] stall_cycles_count
);

    // localparam NUM_QUEUE = NUM_PORTS; //number of Requestor queues in DRAM controller
    localparam BUS_DATA_OUT = 8;
    localparam CNT = INST_W/BUS_DATA_OUT;
    assign layer_count = layer_cntr;
      

    wire [INST_W-1 : 0] instruction;
    wire start_bus;   //start signal to bus master to dispatch inst. to the corresponding slave blocks
    wire [OPCODE_WIDTH-1:0] opcode_config; //opcode to bus master to select the appropriate slave
    assign opcode_config = instruction[OPCODE_WIDTH-1:0];
    wire [NUM_INSTRUCTIONS-1:0] start_command;    

    wire start_out;
    reg start;
    always@(posedge i_clk) begin //To sync. with start_SA and start_FC
      start <= start_out;
    end

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
  
  //CONV inst. signals
  wire [OPCODE_WIDTH-1:0]           conv_opcode;
  wire [CONV_IW_WIDTH-1 : 0]        input_img_width; 
  wire [CONV_IH_WIDTH-1 : 0]        input_img_height;
  wire [OutputBlock_OW_WIDTH-1 : 0] op_width;
  wire [OutputBlock_OH_WIDTH-1 : 0] op_height; 

  wire [CONV_KN_WIDTH-1:0]       n_kernels;
  wire [CONV_KW_WIDTH-1:0]       kernel_width;
  wire [CONV_KH_WIDTH-1:0]       kernel_height;
  wire [CONV_KC_WIDTH-1:0]       kernel_channels;
  wire [CONV_ConvType_WIDTH-1:0] conv_type;
  wire [CONV_STRIDE_WIDTH-1:0]   stride;
  
  wire [CONV_PadLeft_WIDTH-1:0]   conv_pad_left;
  wire [CONV_PadRight_WIDTH-1:0]  conv_pad_right;
  wire [CONV_PadTop_WIDTH-1:0]    conv_pad_top;
  wire [CONV_PadBottom_WIDTH-1:0] conv_pad_bottom;

  wire [CONV_CHANNELDUPLICATE_WIDTH-1:0] CONV_ChannelDuplicate;
  wire [AXI_ADDR_W-1:0] start_address_weights;
  wire [AXI_ADDR_W-1:0] stop_address_weights;
  wire [AXI_ADDR_W-1:0] weight_start_addr_conv;
  wire [AXI_ADDR_W-1:0] weight_stop_addr_conv;
  wire [AXI_ADDR_W-1:0] weight_start_addr_fc;
  wire [AXI_ADDR_W-1:0] weight_stop_addr_fc;
  
  `ifdef FC
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
  `endif //FC

  //OP block inst. signals
  wire [OPCODE_WIDTH-1:0]       Op_code_OB;
  wire [I_ACC_SIZE_WIDTH-1:0]   img_dim_Acc;
  wire [I_OP_SIZE_WIDTH-1:0]    img_dim_Op;
  wire [ACCEN_WIDTH-1:0]        ACC_EN;
  wire [AXI_ADDR_W-1:0]         acc_start_address;
  wire [AXI_ADDR_W-1:0]         acc_stop_address;
  wire [AXI_ADDR_W-1:0]         op_start_address;
  wire [ACC_ONCHIP_WIDTH-1 : 0] Acc_onchip;
  wire [OutputBlock_FlatController_WIDTH-1:0] OutputBlock_FlatController;

  //Tail inst. signals
  wire [OPCODE_WIDTH-1:0]       Op_code_TB;
  wire [RELU_CLIP_WIDTH-1:0]    relu_clip_value;
  wire [ACT_TYPE_WIDTH-1:0]     relu_act_type;
  wire [LR_NEG_ALPHA_WIDTH-1:0] LR_NegAlpha;  
  wire [LR_POS_ALPHA_WIDTH-1:0] LR_PosAlpha;
  wire [W_QUANT_SHIFT-1:0] tail_quantshift;
  wire [W_QUANT_SCALE-1:0] tail_quantscale;

  `ifdef GLOBAL_POOL
  wire [W_GBL_POOL_SCALE-1:0] gbl_pool_scale;
  wire [W_GBL_POOL_SHIFT-1:0] gbl_pool_shift;
  wire [W_GBL_POOL_EN-1:0] gbl_pool_en;
  `endif

  wire [ACTEN_WIDTH-1:0] ACT_EN;
  wire [QUANTEN_WIDTH-1:0] QUANT_EN;
  wire [BIASEN_WIDTH-1:0] BIAS_EN;
  wire [BiasWidth_WIDTH-1:0] BiasWidth;
  // wire [POOLEN_WIDTH-1:0] POOL_EN;
  // inster global pool here 
  // wire [G_POOLEN_WIDTH-1:0] G_POOL_EN;
  `ifdef RESIZE
  wire resize_done;
  wire [OPCODE_WIDTH-1:0] resize_opcode;
  wire [W_RESIZE_IW-1:0] resize_iw;
  wire [W_RESIZE_IH-1:0] resize_ih;
  wire [W_RESIZE_IC-1:0] resize_ic;
  wire [W_RESIZE_IMG_STA_ADD-1:0] resize_img_sta_add;
  wire [W_RESIZE_IMG_END_ADD-1:0] resize_img_end_add;
  `endif
  wire [AXI_ADDR_W-1:0] bias_start_address;
  wire [AXI_ADDR_W-1:0] bias_stop_address;

  //Elementwise inst. signals
  `ifdef ELTWISE 
  wire [OPCODE_WIDTH-1:0] ew_opcode;
  wire [ELTWISE_TYPE_WIDTH-1:0] EltWise_type;
  wire [ELTWISE_SCALE_WIDTH-1:0] LeftOperand_Scale;
  wire [ELTWISE_SCALE_WIDTH-1:0] RightOperand_Scale;
  wire [ELTWISE_ZEROPOINT_WIDTH-1:0] LeftOperand_zero_point;
  wire [ELTWISE_ZEROPOINT_WIDTH-1:0] RightOperand_zero_point;
  wire [CONV_IW_WIDTH-1 : 0] EltWise_IW;
  wire [CONV_IH_WIDTH-1 : 0] EltWise_IH;
  wire [CONV_IC_WIDTH-1 : 0] EltWise_IC;
  wire [AXI_ADDR_W-1:0] LeftOperand_start_address;
  wire [AXI_ADDR_W-1:0] RightOperand_start_address;
  wire [AXI_ADDR_W-1:0] LeftOperand_stop_address;
  wire [AXI_ADDR_W-1:0] RightOperand_stop_address;
  `endif //ELTWISE

  `ifdef TRANSPOSE
  //Reshape Transpose inst. signals
  wire [OPCODE_WIDTH-1:0] rt_opcode;
  wire [AXI_ADDR_W-1:0] ReshapeTranspose_start_address;
  wire [TRANSPOSE_IH_WIDTH-1:0] ReshapeTranspose_IH;
  wire [TRANSPOSE_IW_WIDTH-1:0] ReshapeTranspose_IW;
  wire [TRANSPOSE_IC_WIDTH-1:0] ReshapeTranspose_IC;
  `endif //TRANSPOSE

  // start and end address signals for memory request controllers

  wire [AXI_ADDR_W-1:0] img_start_address;
  wire [W_CITER_CNT-1:0] channel_iteration; 
  wire [W_KITER_CNT-1:0] kernel_iteration; 
  wire [AXI_ADDR_W-1:0] img_stop_address;

  wire layer_done;

  `ifdef FC
  wire FC_layerdone;
  wire FC_done;
  `endif //FC

  
  reg [OPCODE_WIDTH-1:0] opcode;
  reg valid_inst_CONV_FC;
  reg CONV_FC;
  wire start_SA, start_POOL, start_FC, start_RT, start_EW, start_RESIZE;
  wire [NUM_INSTRUCTIONS-1:0] start_block; 

  /* start signal for mega blocks can create new start from here using the mega block macro , the start_block signal is one cycle delayed signal of start commond to match with the start and conv_fc*/ 

  assign start_SA = start_block[`OP_CONV];
  assign start_POOL = start_block[`OP_POOL];  
  assign start_FC = start_block[`OP_FC];
  assign start_EW = start_block[`OP_EltWise];
  assign start_RT = start_block[`OP_TRANSPOSE];
  assign start_Concat = start_block[`OP_CONCAT];
  assign start_RESIZE = start_block[`OP_RESIZE];


  /* always block for the generation of the CONV_FC */

  // this block is created bcoz the conv fc needs to be high when fc layers are running for bias addition purposes
  // TODO - change the logic ins Bias Addition block to replace CONV_FC with start_FC 
  always @(posedge i_clk) begin 
    if(!i_rst)begin 
      valid_inst_CONV_FC <= 0;
      CONV_FC <= 0;
    end 
    if (start_command[`OP_CONV]) begin
      valid_inst_CONV_FC <= 1;
      CONV_FC <= 0; //CONV operation
    end 
    else if (start_command[`OP_FC]) begin
      valid_inst_CONV_FC <= 1;
      CONV_FC <= 1; //FC operation
    end 
    else if (start_command[`OP_EltWise]) begin
      valid_inst_CONV_FC <= 0;
      CONV_FC <= 0; //EltWise operation
    end
    else if (start_command[`OP_TRANSPOSE]) begin
      valid_inst_CONV_FC <= 0;
      CONV_FC <= 0; //Transpose operation
    end 
    else if (start_command[`OP_POOL]) begin
      valid_inst_CONV_FC <= 0;
      CONV_FC <= 0; //Maxpool operation
    end
    else begin
      valid_inst_CONV_FC <= valid_inst_CONV_FC;
      CONV_FC <= CONV_FC;
    end
  end 

  /* always block for the generation of the opcode */
  /* TODO - Generalization of this opcode generation logic is needed, I have written this logic for genraliing this however some macro compatibility is nedded */ 


  /* opcode generation this logic needs to be used however the start_command needs to be modified */ 

  wire [(NUM_INSTRUCTIONS*OPCODE_WIDTH)-1:0] opcode_hold;

  assign opcode_hold[(`OP_CONV*OPCODE_WIDTH) +:OPCODE_WIDTH] = conv_opcode;

  `ifdef ELTWISE 
  assign opcode_hold[(`OP_EltWise*OPCODE_WIDTH) +:OPCODE_WIDTH] = ew_opcode;
  `else
  assign opcode_hold[(`OP_EltWise*OPCODE_WIDTH) +:OPCODE_WIDTH] = 0;
  `endif //ELTWISE

  `ifdef CONCAT
  assign opcode_hold[(`OP_CONCAT*OPCODE_WIDTH) +:OPCODE_WIDTH] = opcode_CONCAT;
  `else
  assign opcode_hold[(`OP_CONCAT*OPCODE_WIDTH) +:OPCODE_WIDTH] = 0;
  `endif

  `ifdef TRANSPOSE
  assign opcode_hold[(`OP_TRANSPOSE*OPCODE_WIDTH) +:OPCODE_WIDTH] = rt_opcode;
  `else
  assign opcode_hold[(`OP_TRANSPOSE*OPCODE_WIDTH) +:OPCODE_WIDTH] = 0;
  `endif //TRANSPOSE

  `ifdef FC
  assign opcode_hold[(`OP_FC*OPCODE_WIDTH) +:OPCODE_WIDTH] = fc_opcode;
  `else
  assign opcode_hold[(`OP_FC*OPCODE_WIDTH) +:OPCODE_WIDTH] = 0;
  `endif //FC

  `ifdef MEGA_POOL
  assign opcode_hold[(`OP_POOL*OPCODE_WIDTH) +:OPCODE_WIDTH] = pool_opcode;
  `else 
  assign opcode_hold[(`OP_POOL*OPCODE_WIDTH) +:OPCODE_WIDTH] = 0;
  `endif
  
  `ifdef RESIZE
  assign opcode_hold[(`OP_RESIZE*OPCODE_WIDTH) +:OPCODE_WIDTH] = resize_opcode;
  `else 
  assign opcode_hold[(`OP_RESIZE*OPCODE_WIDTH) +:OPCODE_WIDTH] = 0;
  `endif

  integer i;
  
  always @(posedge i_clk) begin
    if (!i_rst) begin
      opcode <= 0;
    end else begin
      for (i = 0; i < NUM_INSTRUCTIONS; i = i + 1) begin
        if (start_command[i] && (i != 1) && (i != 2)) begin
          opcode <= opcode_hold[(i * OPCODE_WIDTH) +: OPCODE_WIDTH];
        end
      end
    end
  end


  /*
    The real_row and real_col are the counters that are used to calculate full image dimension 
    instead of the row skip one. Ex: if image is 224*224 the real_row and real_col will be till 224 where the 'row' register will be 224 - row_skips
  */ 
  wire  [CONV_IH_WIDTH-1:0] row;    
  wire  [CONV_IW_WIDTH-1:0] col;
  wire  [CONV_IH_WIDTH-1:0] real_row;  
  wire  [CONV_IW_WIDTH-1:0] real_col;

  

  // Generate logic for stall_on signal 
  // stall_on signal is used to stall the systolic array when the image fifo is empty or psum fifo is full
  
  wire [AXI_DATA_BYTES-1:0] image_fifo_empty;
  reg stall_on=0;
  reg stall_enable=0;

  wire [CONV_PadTop_WIDTH-1:0] pad_top;
  wire [CONV_PadLeft_WIDTH-1:0] pad_left;

  `ifdef MEGA_POOL
  assign pad_top = (opcode == `OP_POOL) ? pool_pad_t : conv_pad_top;
  assign pad_left = (opcode == `OP_POOL) ? pool_pad_l : conv_pad_left;
  `else 
  assign pad_top = conv_pad_top;
  assign pad_left = conv_pad_left;
  `endif

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
        else if((real_row == input_img_height + pad_top)  
            && (real_col >= ((input_img_width + pad_left) - (AXI_DATA_BYTES/N_SA)))) begin 
            stall_enable <= 0;
        end
        else begin 
            stall_enable <= stall_enable;
        end
    end
  end

  
  /*
    The almost empty and almost full flags are used to control the start and stall of the systolic array.
    NOte that these are prog. full and prog. empty status of the SA i/p image FIFOs.
  */
  
    wire sa_image_fifo_almost_empty_flag ;
    wire sa_image_fifo_almost_full_flag;
    wire sa_stall;
    wire systolic_array_trigger;

    `ifdef MEGA_POOL
    reg sa_start_ctrl_sa_done;
    reg sa_start_ctrl_prefetch;
    reg [CONV_IH_WIDTH-1 : 0] sa_start_ctrl_img_h;
    reg [CONV_IW_WIDTH-1 : 0] sa_start_ctrl_img_w;
    reg [CONV_PadTop_WIDTH-1:0] sa_start_ctrl_zeropad;
    reg [CONV_STRIDE_WIDTH-1:0] sa_start_ctrl_stride_width;
    reg [CONV_STRIDE_WIDTH-1:0] sa_start_ctrl_stride_height;
    reg [CONV_ConvType_WIDTH-1:0] sa_start_ctrl_conv_type;
    reg [CONV_KW_WIDTH-1:0] sa_start_ctrl_kernel_w;
    reg [CONV_KH_WIDTH-1:0] sa_start_ctrl_kernel_h;

    always @(posedge i_clk) begin
      if (opcode == `OP_POOL) begin
        sa_start_ctrl_sa_done <= pool_done;
        sa_start_ctrl_prefetch <= pool_prefetch;
        sa_start_ctrl_img_h <= pool_ih;
        sa_start_ctrl_img_w <= pool_iw;
        sa_start_ctrl_zeropad <= pool_pad_t;
        sa_start_ctrl_stride_width <= poolstride_w;
        sa_start_ctrl_stride_height <= poolstride_h;
        sa_start_ctrl_conv_type <= 2'b01; // DW Conv Type
        sa_start_ctrl_kernel_w <= poolwidth;
        sa_start_ctrl_kernel_h <= poolheight;
      end
      else begin
        sa_start_ctrl_sa_done <= SA_done;
        sa_start_ctrl_prefetch <= CONV_Im2colPrefetch;
        sa_start_ctrl_img_h <= input_img_height;
        sa_start_ctrl_img_w <= input_img_width;
        sa_start_ctrl_zeropad <= conv_pad_top;
        sa_start_ctrl_stride_width <= stride;
        sa_start_ctrl_stride_height <= stride;
        sa_start_ctrl_conv_type <= conv_type;
        sa_start_ctrl_kernel_w <= kernel_width;
        sa_start_ctrl_kernel_h <= kernel_height;
      end
    end

    sa_start_stall_ctrl #(
        .CONV_IH_WIDTH(CONV_IH_WIDTH),
        .CONV_IW_WIDTH(CONV_IW_WIDTH),
        .CONV_PAD_WIDTH(CONV_PadRight_WIDTH), 
        .CONV_STRIDE_WIDTH(CONV_STRIDE_WIDTH),
        .IMAGE_DIM(CONV_IW_WIDTH),
        .CONV_Pfetch_WIDTH(CONV_Im2colPrefetch_WIDTH),
        .CONV_TYPE_WIDTH(CONV_ConvType_WIDTH),
        .COL_SA(COL_SA),
        .CONV_KW_WIDTH(CONV_KW_WIDTH),
        .CONV_KH_WIDTH(CONV_KH_WIDTH),
        .IM2COL_FIFO_DEPTH(IM2COL_FIFO_DEPTH)
        )
    sa_start_stall_ctrl_inst (
        .sa_image_fifo_almost_empty_flag(sa_image_fifo_almost_empty_flag),
        .sa_image_fifo_almost_full_flag(sa_image_fifo_almost_full_flag),
        .im2col_global_start(im2col_global_start),
        .im2col_done(im2col_done),
        .SA_done(sa_start_ctrl_sa_done),
        .i_clk(i_clk),
        .i_rst(i_rst),
        .CONV_Im2colPrefetch(sa_start_ctrl_prefetch),
        .conv_type(sa_start_ctrl_conv_type),
        .input_img_height(sa_start_ctrl_img_h), 
        .input_img_width(sa_start_ctrl_img_w), 
        .conv_zeropad(sa_start_ctrl_zeropad),
        .stride_width(sa_start_ctrl_stride_width),
        .stride_height(sa_start_ctrl_stride_height),
        .sa_stall(sa_stall),
        .row(row),
        .col(col),
        .kernel_width(sa_start_ctrl_kernel_w),
        .kernel_height(sa_start_ctrl_kernel_h),
        .systolic_array_trigger(systolic_array_trigger)
  );

    wire pool_done;
    wire pool_start;
    wire pool_stall;

    assign pool_start = (opcode == `OP_POOL) ? systolic_array_trigger : 0;
    assign pool_stall = (opcode == `OP_POOL) ? sa_stall : 0;

    `else

    sa_start_stall_ctrl #(
        .CONV_IH_WIDTH(CONV_IH_WIDTH),
        .CONV_IW_WIDTH(CONV_IW_WIDTH),
        .CONV_PAD_WIDTH(CONV_PadRight_WIDTH), 
        .CONV_STRIDE_WIDTH(CONV_STRIDE_WIDTH),
        .IMAGE_DIM(CONV_IW_WIDTH),
        .CONV_Pfetch_WIDTH(CONV_Im2colPrefetch_WIDTH),
        .CONV_TYPE_WIDTH(CONV_ConvType_WIDTH),
        .COL_SA(COL_SA),
        .CONV_KW_WIDTH(CONV_KW_WIDTH),
        .CONV_KH_WIDTH(CONV_KH_WIDTH),
        .IM2COL_FIFO_DEPTH(IM2COL_FIFO_DEPTH)
        )
    sa_start_stall_ctrl_inst (
        .sa_image_fifo_almost_empty_flag(sa_image_fifo_almost_empty_flag),
        .sa_image_fifo_almost_full_flag(sa_image_fifo_almost_full_flag),
        .im2col_global_start(im2col_global_start),
        .im2col_done(im2col_done),
        .SA_done(SA_done),
        .i_clk(i_clk),
        .i_rst(i_rst),
        .CONV_Im2colPrefetch(CONV_Im2colPrefetch),
        .conv_type(conv_type),
        .input_img_height(input_img_height), 
        .input_img_width(input_img_width), 
        .conv_zeropad(conv_pad_top),
        .stride_width(stride),
        .stride_height(stride),
        .sa_stall(sa_stall),
        .row(row),
        .col(col),
        .kernel_width(kernel_width),
        .kernel_height(kernel_height),
        .systolic_array_trigger(systolic_array_trigger)
    );
    `endif

  `ifdef FC
  // logic for flattening trigger
  reg Flattening_trigger=0;

  always@(posedge i_clk) begin
    if(!i_rst) Flattening_trigger <= 1'b0;
    else begin
        if(start_FC) Flattening_trigger <= 1'b1;
        else if(FC_layerdone) Flattening_trigger <= 1'b0;
        else Flattening_trigger <= Flattening_trigger;
    end
  end
  `endif //FC

  `ifdef MEGA_POOL
  wire [(OPCODE_WIDTH - 1) : 0] pool_opcode;
  wire [(W_POOL_IW - 1 ): 0] pool_iw;
  wire [(W_POOL_IH - 1) : 0] pool_ih;
  wire [(W_POOL_IC - 1) : 0] pool_ic;
  wire [(W_POOL_IMG_STA_ADD - 1) : 0] pool_img_sta_add;
  wire [(W_POOL_IMG_END_ADD - 1) : 0] pool_img_end_add;
  wire [(W_POOL_TYPE - 1) : 0] pooltype;
  wire [(W_POOL_SCALE - 1) : 0] poolscale;
  wire [(W_POOL_SHIFT - 1) : 0]  poolshift;
  wire [(W_POOL_WIDTH - 1) : 0] poolwidth;
  wire [(W_POOL_HEIGHT - 1) : 0] poolheight;
  wire [(W_POOL_STRIDE_W - 1) : 0] poolstride_w;
  wire [(W_POOL_STRIDE_H - 1) : 0] poolstride_h;
  wire [(W_POOL_CEIL - 1) : 0] poolceil;
  wire [(W_POOL_PAD_L - 1) : 0] pool_pad_l;
  wire [(W_POOL_PAD_R - 1) : 0] pool_pad_r;
  wire [(W_POOL_PAD_T - 1) : 0] pool_pad_t;
  wire [(W_POOL_PAD_B - 1) : 0] pool_pad_b;
  wire [(W_POOL_PREFETCH - 1) : 0] pool_prefetch;
  `elsif POOL
  wire [(W_POOL_EN - 1) : 0] POOL_EN;
  wire [(W_POOL_TYPE - 1) : 0] pooltype;
  wire [(W_POOL_WIDTH - 1) : 0] poolwidth;
  wire [(W_POOL_HEIGHT - 1) : 0] poolheight;
  wire [(W_POOL_STRIDE - 1) : 0] poolstride;
  wire [(W_POOL_PAD - 1) : 0] poolpadding;
  wire [(W_POOL_CEIL - 1) : 0] poolceil;
  wire [(W_POOL_MODCOUNT - 1) : 0] poolModCount;
  wire [(W_POOL_PADSIDES - 1) : 0] poolpadsides;
  wire [(W_POOL_SCALE - 1) : 0] poolscale;
  wire [(W_POOL_SHIFT - 1) : 0] poolshift;
  `endif

  wire [OutputBlock_OpWidth_WIDTH-1:0] OB_OpWidth; // output dram data width in bytes

  `ifdef CONCAT
  wire [CONCAT_InNum_WIDTH -1 : 0] CONCAT_InNum;
  wire [OPCODE_WIDTH-1:0]          opcode_CONCAT;
  wire [CONCAT_Image1StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_1;
  wire [CONCAT_Image2StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_2;
  wire [CONCAT_Image3StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_3;
  wire [CONCAT_Image4StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_4;
  wire [CONCAT_IH1_WIDTH -1 : 0] CONCAT_IH_1;
  wire [CONCAT_IH2_WIDTH -1 : 0] CONCAT_IH_2;
  wire [CONCAT_IH3_WIDTH -1 : 0] CONCAT_IH_3;
  wire [CONCAT_IH4_WIDTH -1 : 0] CONCAT_IH_4;
  wire [CONCAT_KN1_WIDTH -1 : 0] CONCAT_KN_1;
  wire [CONCAT_KN2_WIDTH -1 : 0] CONCAT_KN_2;
  wire [CONCAT_KN3_WIDTH -1 : 0] CONCAT_KN_3;
  wire [CONCAT_KN4_WIDTH -1 : 0] CONCAT_KN_4;
  `endif

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
    .ACTEN_WIDTH(ACTEN_WIDTH),
    .ACTTYPE_WIDTH(ACT_TYPE_WIDTH),
    .ACTPARAM_WIDTH(RELU_CLIP_WIDTH),
    .LR_NEG_ALPHA_WIDTH(LR_NEG_ALPHA_WIDTH),
    .LR_POS_ALPHA_WIDTH(LR_POS_ALPHA_WIDTH),
    .QUANTEN_WIDTH(QUANTEN_WIDTH),
    .QUANTSCALE_WIDTH(W_QUANT_SCALE),
    .QUANTSHIFT_WIDTH(W_QUANT_SHIFT),

    `ifdef GLOBAL_POOL 
    .GBL_POOL_SCALE_WIDTH(W_GBL_POOL_SCALE),
    .GBL_POOL_SHIFT_WIDTH(W_GBL_POOL_SHIFT),
    .GBL_POOL_EN_WIDTH(W_GBL_POOL_EN), 
    `endif

    `ifdef MEGA_POOL
    .POOL_IW_WIDTH(W_POOL_IW),
    .POOL_IH_WIDTH(W_POOL_IH),
    .POOL_IC_WIDTH(W_POOL_IC),
    .POOL_IMG_STA_ADD_WIDTH(W_POOL_IMG_STA_ADD),
    .POOL_IMG_END_ADD_WIDTH(W_POOL_IMG_END_ADD),
    .POOLTYPE_WIDTH(W_POOL_TYPE),
    .POOLSCALE_WIDTH(W_POOL_SCALE),
    .POOLSHIFT_WIDTH(W_POOL_SHIFT),
    .POOLWIDTH_WIDTH(W_POOL_WIDTH),
    .POOLHEIGHT_WIDTH(W_POOL_HEIGHT),
    .POOLSTRIDE_W_WIDTH(W_POOL_STRIDE_W),
    .POOLSTRIDE_H_WIDTH(W_POOL_STRIDE_H),
    .POOLCEIL_WIDTH(W_POOL_CEIL),
    .POOLPAD_L_WIDTH(W_POOL_PAD_L),
    .POOLPAD_R_WIDTH(W_POOL_PAD_R),
    .POOLPAD_T_WIDTH(W_POOL_PAD_T),
    .POOLPAD_B_WIDTH(W_POOL_PAD_B),
    .POOL_PREFETCH_WIDTH(W_POOL_PREFETCH),
    `elsif POOL
    .POOLTYPE_WIDTH(W_POOL_TYPE),
    .POOLWIDTH_WIDTH(W_POOL_WIDTH),
    .POOLHEIGHT_WIDTH(W_POOL_HEIGHT),
    .POOLSTRIDE_WIDTH(W_POOL_STRIDE),
    .POOLPAD_WIDTH(W_POOL_PAD),
    .POOLCEIL_WIDTH(W_POOL_CEIL),
    .POOLMODCOUNT_WIDTH(W_POOL_MODCOUNT),
    .POOLPADSIDES_WIDTH(W_POOL_PADSIDES),
    .POOLSCALE_WIDTH(W_POOL_SCALE),
    .POOLSHIFT_WIDTH(W_POOL_SHIFT),
    `endif

    .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
    .ELTWISE_SCALE_WIDTH(ELTWISE_SCALE_WIDTH),
    .ELTWISE_ZEROPOINT_WIDTH(ELTWISE_ZEROPOINT_WIDTH),
    .TRANSPOSE_IC_WIDTH(TRANSPOSE_IC_WIDTH),
    .TRANSPOSE_IH_WIDTH(TRANSPOSE_IH_WIDTH),
    .TRANSPOSE_IW_WIDTH(TRANSPOSE_IW_WIDTH),
    `ifdef RESIZE
    .RESIZE_IW_WIDTH(W_RESIZE_IW),
    .RESIZE_IH_WIDTH(W_RESIZE_IH),
    .RESIZE_IC_WIDTH(W_RESIZE_IC),
    .RESIZE_IMG_STA_ADD_WIDTH(W_RESIZE_IMG_STA_ADD),
    .RESIZE_IMG_END_ADD_WIDTH(W_RESIZE_IMG_END_ADD),
    `endif
    .OutputBlock_AccumulantReadFirst_WIDTH(OutputBlock_AccumulantReadFirst_WIDTH),
    .OutputBlock_OpWidth_WIDTH(OutputBlock_OpWidth_WIDTH),
    .OutputBlock_FlatController_WIDTH(OutputBlock_FlatController_WIDTH),
    .CONCAT_Image1StartAddress_WIDTH(CONCAT_Image1StartAddress_WIDTH),
    .CONCAT_Image2StartAddress_WIDTH(CONCAT_Image2StartAddress_WIDTH),
    .CONCAT_Image3StartAddress_WIDTH(CONCAT_Image3StartAddress_WIDTH),
    .CONCAT_Image4StartAddress_WIDTH(CONCAT_Image4StartAddress_WIDTH),
    .CONCAT_IH1_WIDTH(CONCAT_IH1_WIDTH),
    .CONCAT_IH2_WIDTH(CONCAT_IH2_WIDTH),
    .CONCAT_IH3_WIDTH(CONCAT_IH3_WIDTH),
    .CONCAT_IH4_WIDTH(CONCAT_IH4_WIDTH),
    .CONCAT_KN1_WIDTH(CONCAT_KN1_WIDTH),
    .CONCAT_KN2_WIDTH(CONCAT_KN2_WIDTH),
    .CONCAT_KN3_WIDTH(CONCAT_KN3_WIDTH),
    .CONCAT_KN4_WIDTH(CONCAT_KN4_WIDTH),
    .CONCAT_InNum_WIDTH(CONCAT_InNum_WIDTH)
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

    `ifdef FC
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
    `endif //FC

    //Elementwise inst. signals
    `ifdef ELTWISE
    .opcode_EltWise(ew_opcode),
    .EltWise_type(EltWise_type),
    .LeftOperand_Scale(LeftOperand_Scale),
    .RightOperand_Scale(RightOperand_Scale),
    .LeftOperand_zero_point(LeftOperand_zero_point),
    .RightOperand_zero_point(RightOperand_zero_point),
    .EltWise_IW(EltWise_IW),
    .EltWise_IH(EltWise_IH),
    .EltWise_IC(EltWise_IC),
    .LeftOperand_StartAddress(LeftOperand_start_address),
    .LeftOperand_EndAddress(LeftOperand_stop_address),
    .RightOperand_StartAddress(RightOperand_start_address),
    .RightOperand_EndAddress(RightOperand_stop_address),
    `endif //ELTWISE

    `ifdef TRANSPOSE
    //Reshape Transpose inst. signals
    .rt_opcode(rt_opcode),
    .ReshapeTranspose_start_address(ReshapeTranspose_start_address),
    .ReshapeTranspose_IH(ReshapeTranspose_IH),
    .ReshapeTranspose_IW(ReshapeTranspose_IW),
    .ReshapeTranspose_IC(ReshapeTranspose_IC),
    `endif //TRANSPOSE
    //Resize
    `ifdef RESIZE
    .opcode_resize(resize_opcode),
    .resize_iw(resize_iw),
    .resize_ih(resize_ih),
    .resize_ic(resize_ic),
    .resize_img_sta_add(resize_img_sta_add),
    .resize_img_end_add(resize_img_end_add),
    `endif

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
    .OB_OpWidth(OB_OpWidth),
    .OutputBlock_AccumulantReadFirst(OutputBlock_AccumulantReadFirst),
    .OutputBlock_FlatController(OutputBlock_FlatController),

    `ifdef GLOBAL_POOL
    .gbl_pool_scale(gbl_pool_scale),
    .gbl_pool_shift(gbl_pool_shift),
    .gbl_pool_en(gbl_pool_en),
    `endif

    `ifdef MEGA_POOL
    .opcode_pool(pool_opcode), 
    .pool_iw(pool_iw),
    .pool_ih(pool_ih),
    .pool_ic(pool_ic),
    .pool_img_sta_add(pool_img_sta_add),
    .pool_img_end_add(pool_img_end_add),
    .pooltype(pooltype),
    .poolscale(poolscale),
    .poolshift(poolshift),
    .poolwidth(poolwidth),
    .poolheight(poolheight),
    .poolstride_w(poolstride_w),
    .poolstride_h(poolstride_h),
    .poolceil(poolceil),
    .pool_pad_l(pool_pad_l),
    .pool_pad_r(pool_pad_r),
    .pool_pad_t(pool_pad_t),
    .pool_pad_b(pool_pad_b),
    .pool_prefetch(pool_prefetch),
    `elsif POOL
    .PoolEn(POOL_EN), //goes to iteration cter
    .pooltype(pooltype),
    .poolwidth(poolwidth),
    .poolheight(poolheight),
    .poolstride(poolstride),
    .poolpadding(poolpadding),
    .poolceil(poolceil),
    .poolModCount(poolModCount),
    .poolpadsides(poolpadsides),
    .poolscale(poolscale),
    .poolshift(poolshift),
    `endif

    //Tail inst. signals
    .opcode_TB(Op_code_TB),
    .ActEn(ACT_EN),
    .acttype(relu_act_type),
    .ActParam(relu_clip_value),
    .LR_NegAlpha(LR_NegAlpha),
    .LR_PosAlpha(LR_PosAlpha),
    .QuantEn(QUANT_EN), // goes to iteration cter
    .quantscale(tail_quantscale),
    .quantshift(tail_quantshift),
    .BiasEn(BIAS_EN),  //goes to iteration cter and bias req ctrler
    .BiasWidth(BiasWidth),
    .BiasStartAddress(bias_start_address),
     `ifdef CONCAT
    .BiasEndAddress(bias_stop_address),
    // Concat operator 
    .opcode_CONCAT(opcode_CONCAT),
    .CONCAT_InNum(CONCAT_InNum),
    .CONCAT_StartAdd_1(CONCAT_StartAdd_1),
    .CONCAT_StartAdd_2(CONCAT_StartAdd_2),
    .CONCAT_StartAdd_3(CONCAT_StartAdd_3),
    .CONCAT_StartAdd_4(CONCAT_StartAdd_4),
    .CONCAT_IH_1(CONCAT_IH_1),
    .CONCAT_IH_2(CONCAT_IH_2),
    .CONCAT_IH_3(CONCAT_IH_3),
    .CONCAT_IH_4(CONCAT_IH_4),
    .CONCAT_KN_1(CONCAT_KN_1),
    .CONCAT_KN_2(CONCAT_KN_2),
    .CONCAT_KN_3(CONCAT_KN_3),
    .CONCAT_KN_4(CONCAT_KN_4)
    `else
    .BiasEndAddress(bias_stop_address)
    `endif 
  );
  

  // fifo status signals for memory request controllers
  wire img_fifo_status;
  wire weight_fifo_status;
  wire acc_fifo_status;
  wire bias_fifo_status;

  `ifdef BIAS_FC
  wire fc_bias_fifo_status;
  `endif //BIAS_FC

  `ifdef FC
  wire fc_img_fifo_status;
  `endif //FC

  `ifdef ELTWISE 
  wire LeftOperand_fifo_status;
  wire RightOperand_fifo_status;
  `endif
  
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
      .CONV_TYPE_WIDTH(CONV_ConvType_WIDTH),
      .MOD(MOD2),
      .CONV_IH_WIDTH(CONV_IH_WIDTH),
      .CONV_IW_WIDTH(CONV_IW_WIDTH),
      .N_SA(N_SA)
  ) image_req_ctrl (
      .start_addr(img_start_address),
      .kernelitr(kernel_iteration),
      .channelitr(channel_iteration),
      .stop_addr(img_stop_address),
      .input_img_width(input_img_width),
      .input_img_height(input_img_height),
      .config_start(start_SA),
      .fifo_status(img_fifo_status),
      .clk(i_clk),
      .rst(i_rst),
      .iter_done(iter_done),
      .c_done(Tail_done),
      .conv_type(conv_type),
      .conv_ack(ack_opcode[`OP_CONV]),
      .dup_flag(CONV_ChannelDuplicate),

      .img_rd_done(img_read_done_conv),

      //signals goes to memory controller
      .addr_out(mc_img_addr_conv),
      .wr_enable(mc_img_rdreq_conv),
      .valid(mc_img_valid_conv),
      .burst_length(mc_img_bl_conv),
      .last(mc_img_last_conv)
  );

wire img_read_done_pool_resize;
wire [7:0] mc_img_addr_pool_resize;
wire mc_img_rdreq_pool_resize;
wire mc_img_valid_pool_resize;
wire [BURST_LENGTH_WIDTH-1 : 0] mc_img_bl_pool_resize;
wire mc_img_last_pool_resize;

wire img_read_done_conv;
wire [7:0] mc_img_addr_conv;
wire mc_img_rdreq_conv;
wire mc_img_valid_conv;
wire [BURST_LENGTH_WIDTH-1 : 0] mc_img_bl_conv;
wire mc_img_last_conv;

// mux for image request controller output
assign img_read_done = ((opcode == `OP_POOL) | (opcode == `OP_RESIZE)) ? img_read_done_pool_resize : img_read_done_conv; 
assign mc_img_addr   = ((opcode == `OP_POOL) | (opcode == `OP_RESIZE)) ? mc_img_addr_pool_resize   : mc_img_addr_conv; 
assign mc_img_rdreq  = ((opcode == `OP_POOL) | (opcode == `OP_RESIZE)) ? mc_img_rdreq_pool_resize  : mc_img_rdreq_conv; 
assign mc_img_valid  = ((opcode == `OP_POOL) | (opcode == `OP_RESIZE)) ? mc_img_valid_pool_resize  : mc_img_valid_conv; 
assign mc_img_bl     = ((opcode == `OP_POOL) | (opcode == `OP_RESIZE)) ? mc_img_bl_pool_resize     : mc_img_bl_conv; 
assign mc_img_last   = ((opcode == `OP_POOL) | (opcode == `OP_RESIZE)) ? mc_img_last_pool_resize   : mc_img_last_conv; 



  `ifdef MEGA_POOL
  `ifdef RESIZE
  wire [(W_POOL_IMG_STA_ADD - 1) : 0] pool_resize_img_sta_add;
  wire [(W_POOL_IH - 1 ): 0] pool_resize_ih;
  wire [(W_POOL_IW - 1 ): 0] pool_resize_iw;
  wire w_resize_kernel_start;
  wire w_kernel_update;
  assign pool_resize_img_sta_add = (opcode == `OP_RESIZE) ? resize_img_sta_add : pool_img_sta_add ; 
  assign pool_resize_ih          = (opcode == `OP_RESIZE) ? resize_ih          : pool_ih; 
  assign pool_resize_iw          = (opcode == `OP_RESIZE) ? resize_iw          : pool_iw ; 
  // used to give start signal to resize after every kernel iteration
  assign w_resize_kernel_start   = (opcode == `OP_RESIZE) ? w_kernel_update    : 1'b0;
  
  request_controller_img_pool_resize#(
    .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH), 
    .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
    .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT),
    .KERNELITR_WIDTH(W_KITER_CNT),
    .CHANNELITR_WIDTH(W_CITER_CNT),
    .BURST_LENGTH(IMG_REQ_BLEN),
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .MOD(MOD2),
    .N_SA(N_SA),
    .W_POOL_IW(W_POOL_IW),
    .W_POOL_IH(W_POOL_IH)
  ) image_req_ctrl_pool_resize (
    .clk(i_clk),
    .rst(i_rst),
    .start_addr(pool_resize_img_sta_add),
    .kernelitr(kernel_iteration),
    .input_img_height(pool_resize_ih),
    .input_img_width(pool_resize_iw),
    .config_start(start_POOL | start_RESIZE),
    .fifo_status(img_fifo_status),
    .c_done(channel_done),

    .img_rd_done(img_read_done_pool_resize),
    .addr_out(mc_img_addr_pool_resize),
    .wr_enable(mc_img_rdreq_pool_resize),
    .valid(mc_img_valid_pool_resize),
    .last(mc_img_last_pool_resize),
    .burst_length(mc_img_bl_pool_resize),
    .o_kernel_update(w_kernel_update)
  );
   `else 
  request_controller_img_pool_resize#(
    .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH), 
    .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
    .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT),
    .KERNELITR_WIDTH(W_KITER_CNT),
    .CHANNELITR_WIDTH(W_CITER_CNT),
    .BURST_LENGTH(IMG_REQ_BLEN),
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .MOD(MOD2),
    .N_SA(N_SA),
    .W_POOL_IW(W_POOL_IW),
    .W_POOL_IH(W_POOL_IH)
  ) image_req_ctrl_pool_resize (
    .clk(i_clk),
    .rst(i_rst),
    .start_addr(pool_img_sta_add),
    .kernelitr(kernel_iteration),
    .input_img_height(pool_ih),
    .input_img_width(pool_iw),
    .config_start(start_POOL),
    .fifo_status(img_fifo_status),
    .c_done(channel_done),

    .img_rd_done(img_read_done_pool_resize),
    .addr_out(mc_img_addr_pool_resize),
    .wr_enable(mc_img_rdreq_pool_resize),
    .valid(mc_img_valid_pool_resize),
    .last(mc_img_last_pool_resize),
    .burst_length(mc_img_bl_pool_resize),
    .o_kernel_update(w_kernel_update)
  );
  `endif
 `elsif RESIZE 
  wire w_resize_kernel_start;
  wire w_kernel_update;
  assign w_resize_kernel_start   = (opcode == `OP_RESIZE) ? w_kernel_update    : 1'b0;
  
  request_controller_img_pool_resize#(
    .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH), 
    .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
    .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT),
    .KERNELITR_WIDTH(W_KITER_CNT),
    .CHANNELITR_WIDTH(W_CITER_CNT),
    .BURST_LENGTH(IMG_REQ_BLEN),
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .MOD(MOD2),
    .N_SA(N_SA),
    .W_POOL_IW(W_RESIZE_IW),
    .W_POOL_IH(W_RESIZE_IH)
  ) image_req_ctrl_pool_resize (
    .clk(i_clk),
    .rst(i_rst),
    .start_addr(resize_img_sta_add),
    .kernelitr(kernel_iteration),
    .input_img_height(resize_ih),
    .input_img_width(resize_iw),
    .config_start(start_RESIZE),
    .fifo_status(img_fifo_status),
    .c_done(channel_done),

    .img_rd_done(img_read_done_pool_resize),
    .addr_out(mc_img_addr_pool_resize),
    .wr_enable(mc_img_rdreq_pool_resize), //write-read enable
    .valid(mc_img_valid_pool_resize),
    .last(mc_img_last_pool_resize),
    .burst_length(mc_img_bl_pool_resize),
    .o_kernel_update(w_kernel_update)
);
 `endif

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

  `ifdef FC
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
  `endif //FC

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

  `ifdef BIAS_FC
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
  `endif //BIAS_FC


  wire [AXI_ADDR_W-1:0] r_acc_start_add;
  wire [AXI_ADDR_W-1:0] r_acc_stop_add;
  
  wire im2col_global_start;
  wire vector_add_enable;
  
  /*
    Masked acc on chip for kernal split convolution as the Accumulant addition output in case of k_split 
    needs to be written to the dram irrespective of the acc_onchip or not
  */
  wire Acc_onchip_masked ;
  assign Acc_onchip_masked = (kernel_width >= 4)? (1'b0) :(Acc_onchip);

  wire ksplit ;
  `ifdef MEGA_POOL
  assign ksplit = (opcode == `OP_POOL)? 0 : ((kernel_width >= 4)? (1'b1) : (1'b0));
  `else
  assign ksplit = (kernel_width >= 4)? (1'b1) : (1'b0);
  `endif

  request_controller_accumulator #(
      .BURST_LENGTH(ACC_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT)
  ) acc_req_ctrl (
      .start_addr(r_acc_start_add),
      .stop_addr(r_acc_stop_add),
      .config_start(im2col_global_start), //start from im2col start ctrler
      .fifo_status(acc_fifo_status),
      .clk(i_clk),
      .enable(ACC_EN & ~Acc_onchip_masked), // ACC_EN comes from inst. whether is enabled in this layer or not
      .ENABLE(vector_add_enable), // acc_en comes from iteration cter to enable it in current iteration based on the instruction field
      .addr_out(mc_acc_addr),
      .wr_enable(mc_acc_rdreq),
      .valid(mc_acc_valid),
      .burst_length(mc_acc_bl),
      .last(mc_acc_last)
  );

  `ifdef ELTWISE 
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
  `endif

  /* ------------ Concat operator -----------------*/
  `ifdef CONCAT
  // request controller for concat.

  // CONCAT : request_controller DRAM 

  localparam STOP_ADD_WIDTH = 32;

    (*syn_use_dsp = "no"*) wire [STOP_ADD_WIDTH - 1 : 0] CONCAT_StopAdd_1;
    (*syn_use_dsp = "no"*) wire [STOP_ADD_WIDTH - 1 : 0] CONCAT_StopAdd_2;
    (*syn_use_dsp = "no"*) wire [STOP_ADD_WIDTH - 1 : 0] CONCAT_StopAdd_3;
    (*syn_use_dsp = "no"*) wire [STOP_ADD_WIDTH - 1 : 0] CONCAT_StopAdd_4;

    wire [AXI_ADDR_W- 1 : 0] concat_req_start_add;
    wire [AXI_ADDR_W- 1 : 0] concat_req_stop_add;
    wire req_done;

  request_controller_concat #(
      .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH), 
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .ADDR_OUT_CHUNK_WIDTH(BUS_DATA_OUT),
      .BURST_LENGTH(CONCAT_REQ_BLEN),
      .AXI_DATA_BYTES(AXI_DATA_BYTES),
      .CONCAT_InNum_WIDTH(CONCAT_InNum_WIDTH)
  ) request_controller_concat (
      .start_addr_1(concat_req_start_add),
      .stop_addr_1(concat_req_stop_add),
      .config_start(o_start_en),
      .fifo_status(Concat_fifo_status), //occupancy check
      .clk(i_clk),
      .data_last(),
      .CONCAT_InNum(CONCAT_InNum), 
      .addr_out(mc_Concat_addr),
      .wr_enable(mc_Concat_rdreq), //write-read enable
      .valid(mc_Concat_valid),
      .last(mc_Concat_last),
      .req_done(req_done),
      .burst_length(mc_Concat_bl)
  );


    concat_address_switcher #( 
      .ADD_WIDTH(AXI_ADDR_W)
    )
    concat_address_switcher(
    .i_clk(i_clk),
    .i_rst(!i_rst),
    .i_start_seq(start_Concat),   // 1-cycle pulse to start sequence
    .i_input_num(CONCAT_InNum),//TODO:Number of valid inputs: 1..4
    .i_start_add0(CONCAT_StartAdd_1),
    .i_start_add1(CONCAT_StartAdd_2),
    .i_start_add2(CONCAT_StartAdd_3),
    .i_start_add3(CONCAT_StartAdd_4),
    .i_stop_add0(CONCAT_StopAdd_1),
    .i_stop_add1(CONCAT_StopAdd_2),
    .i_stop_add2(CONCAT_StopAdd_3),
    .i_stop_add3(CONCAT_StopAdd_4),
    .i_done(req_done), // asserted when current length is done
    .o_start_en(o_start_en), // 1-cycle pulse
    .o_start_add(concat_req_start_add),
    .o_stop_add(concat_req_stop_add),   // latched address 
    .o_all_done(o_all_done)
  );

  // CONCAT : top_concat instantiation 


  wire concat_write_enable;
  wire concat_dv;

  top_concat #( 
      .OPCODE_WIDTH(OPCODE_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .CONCAT_FIFO_DEPTH(CONCAT_FIFO_DEPTH),
      .CONCAT_FIFO(CONCAT_FIFO),
      .DATA_WIDTH(DATA_WIDTH),
      .CONCAT_Image1StartAddress_WIDTH(CONCAT_Image1StartAddress_WIDTH),
      .CONCAT_Image2StartAddress_WIDTH(CONCAT_Image2StartAddress_WIDTH),
      .CONCAT_Image3StartAddress_WIDTH(CONCAT_Image3StartAddress_WIDTH),
      .CONCAT_Image4StartAddress_WIDTH(CONCAT_Image4StartAddress_WIDTH),
      .CONCAT_IH1_WIDTH(CONCAT_IH1_WIDTH),
      .CONCAT_IH2_WIDTH(CONCAT_IH2_WIDTH),
      .CONCAT_IH3_WIDTH(CONCAT_IH3_WIDTH),
      .CONCAT_IH4_WIDTH(CONCAT_IH4_WIDTH),
      .CONCAT_IW1_WIDTH(CONCAT_IH1_WIDTH),
      .CONCAT_IW2_WIDTH(CONCAT_IH2_WIDTH),
      .CONCAT_IW3_WIDTH(CONCAT_IH3_WIDTH),
      .CONCAT_IW4_WIDTH(CONCAT_IH4_WIDTH),
      .CONCAT_KN1_WIDTH(CONCAT_KN1_WIDTH),
      .CONCAT_KN2_WIDTH(CONCAT_KN2_WIDTH),
      .CONCAT_KN3_WIDTH(CONCAT_KN3_WIDTH),
      .CONCAT_KN4_WIDTH(CONCAT_KN4_WIDTH),
      .CONCAT_InNum_WIDTH(CONCAT_InNum_WIDTH),
      .AXI_ADDRESS_WIDTH(AXI_ADDR_W),
      .QUANT_OP_FIFO(QUANT_OP_FIFO)

  ) Concat_Operator 
  (
      .i_clk(i_clk),
      .i_rst(!i_rst),
      .opcode(opcode),
      .CONCAT_StartAdd_1(CONCAT_StartAdd_1),
      .CONCAT_StartAdd_2(CONCAT_StartAdd_2),
      .CONCAT_StartAdd_3(CONCAT_StartAdd_3),
      .CONCAT_StartAdd_4(CONCAT_StartAdd_4),
      .CONCAT_IH_1(CONCAT_IH_1),
      .CONCAT_IH_2(CONCAT_IH_2),
      .CONCAT_IH_3(CONCAT_IH_3),
      .CONCAT_IH_4(CONCAT_IH_4),
      .CONCAT_IW_1(CONCAT_IH_1),
      .CONCAT_IW_2(CONCAT_IH_2),
      .CONCAT_IW_3(CONCAT_IH_3),
      .CONCAT_IW_4(CONCAT_IH_4),
      .CONCAT_KN_1(CONCAT_KN_1),
      .CONCAT_KN_2(CONCAT_KN_2),
      .CONCAT_KN_3(CONCAT_KN_3),
      .CONCAT_KN_4(CONCAT_KN_4),
      .i_concat_data(i_concat_data),
      .concat_write_enable(concat_write_enable),
      .start_Concat(start_Concat),
      .CONCAT_InNum(CONCAT_InNum),
      .quant_op_fifo_full(quant_op_fifo_full),
      .CONCAT_StopAdd_1(CONCAT_StopAdd_1),
      .CONCAT_StopAdd_2(CONCAT_StopAdd_2),
      .CONCAT_StopAdd_3(CONCAT_StopAdd_3),    
      .CONCAT_StopAdd_4(CONCAT_StopAdd_4),
      .Concat_fifo_occupants(Concat_fifo_occupants),
      .concat_dv(concat_dv),
      .o_concat_data(o_concat_data),
      .o_concat_dv(o_concat_dv),
      .o_concat_done(w_concat_done)

  );

  wire [AXI_DATA_WIDTH-1:0] o_concat_data ;
  wire        o_concat_dv;
  wire        w_concat_done;

 `endif

  
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
    .OutputBlock_FlatController_WIDTH(OutputBlock_FlatController_WIDTH),
    .IMAGE_DIM_WIDTH_ACC(I_ACC_SIZE_WIDTH),
    .IMAGE_DIM_WIDTH_OP(I_OP_SIZE_WIDTH),
    .OutputBlock_OpWidth_WIDTH(OutputBlock_OpWidth_WIDTH)
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
    .OutputBlock_FlatController(OutputBlock_FlatController),
    .occupants(op_write_dram_fifo_occupants), // i-wire: op_write dram fifo occupants
    .acc_en(vector_add_enable),
    .Tail_done(Tail_done), //i-wire: Tail_done from TOP_CONV_FC
    .Acc_onchip(Acc_onchip_masked), //i-wire: Enables Accumulant storage locally, comes from instruction
    .OB_OpWidth(OB_OpWidth),
    .o_read_write_req(mc_op_writereq),
    .o_valid(mc_op_write_valid),
    .o_address(mc_op_write_addr),
    .o_burst_len(mc_op_write_bl),
    .o_last(mc_op_write_last),
    .op_done(op_done),
    .ksplit(ksplit),
    .r_acc_stop_add(r_acc_stop_add),
    .r_acc_start_add(r_acc_start_add) //o-wire: op_done signal to Iteration_ctr
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
        if(mc_img_last && select[`Image])   req_occupants_img <= req_occupants_img + mc_img_bl;
        else if(mc_img_last)                req_occupants_img <= req_occupants_img + (mc_img_bl+1);
        else if(select[`Image])             req_occupants_img <= req_occupants_img - 1;
        else                                req_occupants_img <= req_occupants_img;
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


  wire [AXI_DATA_BYTES-1:0] img_fifo_rden;
  wire [($clog2(DRAM_IMG_FIFO_DEPTH)):0] img_fifo_occ;
  wire [AXI_DATA_BYTES -1:0] img_fifo_dv;

  assign img_fifo_occ         = img_fifo_occupants[(($clog2(DRAM_IMG_FIFO_DEPTH)+1)*AXI_DATA_BYTES)-1-:($clog2(DRAM_IMG_FIFO_DEPTH)+1)];

  
  `ifdef RESIZE
  wire [($clog2(DRAM_IMG_FIFO_DEPTH)):0] img_fifo_occ_resize;
  wire [AXI_DATA_BYTES-1:0] img_fifo_dv_resize;
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] fifo_img_data_resize;

  assign img_fifo_occ_resize  = (opcode == `OP_RESIZE) ? img_fifo_occ     : 0;
  assign fifo_img_data_resize = (opcode == `OP_RESIZE) ? fifo_imgo_data   : 0;
  assign img_fifo_dv_resize   = (opcode == `OP_RESIZE) ? img_fifo_dv      : 0;
  assign img_fifo_rden        = (opcode == `OP_RESIZE) ? resize_fifo_rden : image_rden;
  `else 
  assign img_fifo_rden        = image_rden;
  `endif
  
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
      .i_read_enable(img_fifo_rden),
      .i_write_enable({AXI_DATA_BYTES{image_data_out_dv}}),
      .o_data(fifo_imgo_data),
      .o_fifo_empty(image_fifo_empty),
      .o_fifo_full(),
      .o_fifo_dv(img_fifo_dv),
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
  `ifdef FC
  wire fc_mux_Sel;
  wire [N_FIFO_FC-1 : 0] weight_read_en_fc;
  wire [(N_FIFO_FC * ($clog2(WEIGHT_FIFO_DEPTH) + 1))-1 : 0] weight_occupants_fc;
  wire weight_empty_fc;
  wire weight_almost_empty_fc;
  wire [N_FIFO_FC-1 : 0] weight_dv_fc;
  wire [(COL_FC * DATA_WIDTH)-1 : 0] weight_data_fc;
  `endif //FC

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

  `ifdef FC
  assign weight_fifo_status = (CONV_FC==0)? 
                              (((weight_fifo_occupants[$clog2(WEIGHT_FIFO_DEPTH):0]+virtual_occ_weight)<={{limit_c}})? 1 : 0) : 
                              (((weight_occupants_fc[$clog2(WEIGHT_FIFO_DEPTH):0]+virtual_occ_weight)<={{limit_f}})? 1 : 0);
  `else
  assign weight_fifo_status = ((weight_fifo_occupants[$clog2(WEIGHT_FIFO_DEPTH):0]+virtual_occ_weight)<={{limit_c}})? 1 : 0;
  `endif //FC

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
    .i_opcode(opcode), // i-wire - check it how to get this opcode from slave blocks
    .i_data_weight_ff_array(weight_dram_fifosharing),         //i-wire - from fifo sharing wren ctrler
    .i_write_en_weight_ff_array(weight_write_en_fifosharing), //i-wire - from fifo sharing wren ctrler
    .i_read_en_sa(weight_read_en_sa), // i-wire: wt read en from SA
    
    `ifdef FC
    .i_read_en_fc(weight_read_en_fc), // i-wire: wt readen from fc
    .o_demux_select(fc_mux_Sel), // o-wire: goes to FC block for selecting the fifo array weights to FC block
    .o_occupants_mux_fc(weight_occupants_fc), //o-wire: fifo occupants applied to FC
    .o_empty_mux_fc(weight_empty_fc), //o-wire: fifo empty status to FC
    .o_almost_empty_mux_fc(weight_almost_empty_fc), //o-wire: fifo almost empty status to FC
    .o_dv_mux_fc(weight_dv_fc), //o-wire: wt datavalid to FC
    .o_data_mux_fc(weight_data_fc), //o-wire: weight inputs to FC
    `endif //FC

    .o_occupants_mux_sa(weight_occupants_sa), //o-wire: fifo occupants applied to SA
    .o_empty_mux_sa(weight_empty_sa), //o-wire: fifo empty status to SA
    .o_dv_mux_sa(weight_dv_sa), //o-wire: wt datavalid to SA
    .o_data_mux_sa(weight_data_sa), //o-wire: weight inputs to SA
    .o_weight_ff_array_occupants(weight_fifo_occupants) //o-wire: weight fifo occupants to weight req ctrler
  );

  `ifdef FC
  assign fc_img_fifo_status = 1'b1;
  `endif //FC

  wire [(($clog2(ACC_FIFO_DEPTH)+1)*ACC_FIFO)-1:0] acc_fifo_occupants;
  wire [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO)-1:0] bias_fifo_occupants;

  `ifdef BIAS_FC
  wire [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO_FC)-1:0] fc_bias_fifo_occupants;
  `endif //BIAS_FC

  `ifdef ELTWISE 
  wire [(($clog2(ELTWISE_FIFO_DEPTH)+1)*ELTWISE_FIFO)-1:0] LeftOperand_fifo_occupants;
  wire [(($clog2(ELTWISE_FIFO_DEPTH)+1)*ELTWISE_FIFO)-1:0] RightOperand_fifo_occupants;
  `endif //ELTWISE

  //occupants of acc_fifo,bias_fifo and fc_bias_fifo comes from top_conv_sa block
  wire [$clog2(ACC_FIFO_DEPTH):0] acc_fifo_th;
  wire [$clog2(BIAS_FIFO_DEPTH):0] bias_fifo_th;

  assign acc_fifo_th = ((ACC_FIFO_DEPTH[$clog2(ACC_FIFO_DEPTH):0])/2);
  assign bias_fifo_th = ((3*(BIAS_FIFO_DEPTH[$clog2(BIAS_FIFO_DEPTH):0]))/4);

  `ifdef ELTWISE 
  wire [$clog2(ELTWISE_FIFO_DEPTH):0] eltwise_fifo_th;
  assign eltwise_fifo_th = ((3*(ELTWISE_FIFO_DEPTH[$clog2(ELTWISE_FIFO_DEPTH):0]))/4);
  `endif  //ELTWISE
  
  reg [$clog2(ACC_FIFO_DEPTH):0] virtual_occ;
  reg [$clog2(BIAS_FIFO_DEPTH):0] virtual_occ_bias;

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

  `ifdef ELTWISE 
  reg [$clog2(ELTWISE_FIFO_DEPTH):0] virtual_occ_LeftOperand;
  reg [$clog2(ELTWISE_FIFO_DEPTH):0] virtual_occ_RightOperand;

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
  `endif //ELTWISE


  // assign bias_fifo_th = ((3*(BIAS_FIFO_DEPTH[$clog2(BIAS_FIFO_DEPTH):0]))/4);
  // wire [$clog2(BIAS_FIFO_DEPTH):0] bias_fifo_th;

  // TODO : add documentation here.
  assign acc_fifo_status = ((acc_fifo_occupants[$clog2(ACC_FIFO_DEPTH):0]+virtual_occ)<=acc_fifo_th)? 1 : 0;
  assign bias_fifo_status = ((bias_fifo_occupants[$clog2(BIAS_FIFO_DEPTH):0]+virtual_occ_bias)<=bias_fifo_th)? 1 : 0;

  `ifdef BIAS_FC
  assign fc_bias_fifo_status = (fc_bias_fifo_occupants<={BIAS_FIFO_FC{COL_FC[$clog2(BIAS_FIFO_DEPTH):0]}})? 1 : 0;
  `endif //BIAS_FC

  `ifdef ELTWISE 
  assign LeftOperand_fifo_status = ((LeftOperand_fifo_occupants[$clog2(ELTWISE_FIFO_DEPTH):0]+virtual_occ_LeftOperand)<=eltwise_fifo_th)? 1 : 0;
  assign RightOperand_fifo_status = ((RightOperand_fifo_occupants[$clog2(ELTWISE_FIFO_DEPTH):0]+virtual_occ_RightOperand)<=eltwise_fifo_th)? 1 : 0;
  `endif //ELTWISE

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
    .sel(1<<Acc_onchip_masked),
    .out(vector_add_values)
  );

  vector_mux_param#(
    .PORT_SIZE(ACC_FIFO),
    .NO_PORT(2)
  ) Acc_FIFO_mux_dv(
    .in({{ACC_FIFO{&vector_add_wren_opfifo_acc}},vector_add_wren_dram}),
    .sel(1<<Acc_onchip_masked),
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

  `ifdef BIAS_FC
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
  `endif //BIAS_FC

  `ifdef FC
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
  `endif //FC

  `ifdef ELTWISE 
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
  `endif //ELTWISE


  `ifdef CONCAT

  // CONCAT : virtual ocupents 

    reg [$clog2(CONCAT_FIFO_DEPTH):0] virtual_occ_Concat;
    wire Concat_fifo_status;


    always @ (posedge i_clk) begin
    if(!i_rst) virtual_occ_Concat <= 0;
    else begin
      if(start_en) begin
        if(mc_Concat_last && select[`Concat]) virtual_occ_Concat <= virtual_occ_Concat + mc_Concat_bl;
        else if(mc_Concat_last)                     virtual_occ_Concat <= virtual_occ_Concat + (mc_Concat_bl+1);
        else if(select[`Concat])                    virtual_occ_Concat <= virtual_occ_Concat-1;
        else   virtual_occ_Concat <= virtual_occ_Concat;
      end
      else begin
        virtual_occ_Concat <= 0;
      end
    end
  end

   
  wire [(($clog2(CONCAT_FIFO_DEPTH)+1)*CONCAT_FIFO)-1:0]Concat_fifo_occupants;
  wire [$clog2(CONCAT_FIFO_DEPTH):0] Concate_fifo_th;

  assign Concate_fifo_th = ((3*(CONCAT_FIFO_DEPTH[$clog2(CONCAT_FIFO_DEPTH):0]))/4);

  assign Concat_fifo_status = ((Concat_fifo_occupants[$clog2(CONCAT_FIFO_DEPTH):0]+virtual_occ_Concat)<=Concate_fifo_th )? 1 : 0;

  // CONCAT : mem_read_ctrl 

  wire [AXI_DATA_WIDTH -1:0]i_concat_data;
  wire [CONCAT_FIFO -1:0] dv_Concat_data;

  Mem_read_ctrl#(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .N_FIFO(CONCAT_FIFO) // Image FIFOs = 32
  )concat_read_ctrl(
        .clk(i_clk),
        .rst(i_rst),
        .select(select[`Concat]), // select signal of image fifo blk
        .i_data_valid(dram_rd_datavalid),
        .i_data_last(dram_rd_data_last),
        .i_dram_data(dram_rd_data),
        .o_dram_data(i_concat_data), 
        .o_dram_fifo_wren(concat_write_enable),  // to concat Dram fifo
        .o_data_last()
  ); 

  `endif

  // slicing of img_fifo o/p data to store it in data buffers of im2col
  wire [(AXI_DATA_BYTES*DATA_WIDTH)-1:0] img_ip_conv;

  localparam ACC_OP_DATAWIDTH = ((N_SA*DATA_WIDTH_ACC) < (AXI_DATA_WIDTH)) ? (N_SA*DATA_WIDTH_ACC*ACC_OP_FIFO) : (N_SA*DATA_WIDTH_ACC);
  wire [ACC_OP_FIFO-1:0] acc_op_wren;
  wire [ACC_OP_DATAWIDTH-1:0] acc_op_write_data;

  wire [(AXI_DATA_WIDTH-1):0] quant_op_write_data;
  wire [QUANT_OP_FIFO-1:0] quant_op_wren;

  wire last_c_itr;
  wire [N_SA-1:0] shift_reg_sel;
  assign shift_reg_sel = {N_SA{last_c_itr}};

  wire bias_enable;
  wire quant_enable;

  `ifdef BIAS_FC
  wire bias_fc_enable;
  `endif

  wire maxpool_enable;
  wire im2col_done;
  wire pseudo_im2col_done;
  wire SA_psum_fifo_empty;
  wire relu_enable;
  wire Tail_done;

  `ifdef FC
  assign fc_kernel_iter = kernel_iteration;
  `endif //FC

	wire psum_full;
  wire  op_full;

  wire  [CONV_StartRowSkip_WIDTH-1:0]   start_row_skip;
  wire  [CONV_EndRowSkip_WIDTH-1:0]   end_row_skip;

  wire [N_SA-1:0] pool_o_datavalid;
  wire [(N_SA*DATA_WIDTH) -1:0] pool_o_data;

    wire [ACC_FIFO-1:0] empty_vector; 
    wire [ACC_FIFO-1:0] almost_empty_vector;
    wire [(N_SA)-1:0] empty_sa;
    wire [(N_SA)-1:0] almost_empty_sa;

    //Total data_size of CONV output. This is calculated to determine number of zeros to be generated by zero padder
  (* syn_use_dsp = "no" *) wire [I_ACC_SIZE_WIDTH-1:0] op_img_size; 
  assign op_img_size = op_height * op_width;

  // Top module of CONV and FC Blocks
  top_conv_pool_fc #(
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

      .NSA_LUT(NSA_LUT),
      .BIAS_FIFO_FC(BIAS_FIFO_FC),
      .ACC_TOGGLE(ACC_TOGGLE),
      .POP_THRESHOLD(POP_THRESHOLD),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),

      `ifdef MEGA_POOL
      .POOL_IW_WIDTH(W_POOL_IW),
      .POOL_IH_WIDTH(W_POOL_IH),
      .POOLTYPE_WIDTH(W_POOL_TYPE),
      .POOL_SCALE_WIDTH(W_POOL_SCALE),
      .POOL_SHIFT_WIDTH(W_POOL_SHIFT),
      .POOLWIDTH_WIDTH(W_POOL_WIDTH),
      .POOLHEIGHT_WIDTH(W_POOL_HEIGHT),
      .POOLSTRIDE_W_WIDTH(W_POOL_STRIDE_W),
      .POOLSTRIDE_H_WIDTH(W_POOL_STRIDE_H),
      .POOLPAD_L_WIDTH(W_POOL_PAD_L),
      .POOLPAD_R_WIDTH(W_POOL_PAD_R),
      .POOLPAD_T_WIDTH(W_POOL_PAD_T),
      .POOLPAD_B_WIDTH(W_POOL_PAD_B),
      `endif

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
      .STRIDE(STRIDE),
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
      .IM2COL_BOUND_GEN_WIDTH(IM2COL_BOUND_GEN_WIDTH),
      .N_MOD_STAGES(N_MOD_STAGES),

      .ELTWISE_FIFO(ELTWISE_FIFO),
      .ELTWISE_FIFO_DEPTH(ELTWISE_FIFO_DEPTH),
      .ELTWISE_IW_WIDTH(ELTWISE_IW_WIDTH),
      .ELTWISE_IH_WIDTH(ELTWISE_IH_WIDTH),
      .ELTWISE_IC_WIDTH(ELTWISE_IC_WIDTH),
      .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
      .ELTWISE_SCALE_WIDTH(ELTWISE_SCALE_WIDTH),
      .ELTWISE_ZEROPOINT_WIDTH(ELTWISE_ZEROPOINT_WIDTH),
      .CONV_TYPE_WIDTH(CONV_ConvType_WIDTH)
  ) top_conv_pool_fc_inst (
      .i_clk(i_clk),
      .s_clk(s_clk),
      .i_img_dim_Op(img_dim_Op), // image dimension of quantized o/p
      .image_fifo_empty(image_fifo_empty),
      .opcode(opcode),
      .op_full(op_full),
      .fifo_o(fifo_imgo_data),
      .conv_type(conv_type),  //conv type from instruction
      //fifo sharing signals
      //.sel_sa_rden(sel_sa_rden),
      .stall_on(stall_on),

      `ifdef FC
      .weight_read_en_fc(weight_read_en_fc),
      .weight_occupants_fc(weight_occupants_fc),
      .weight_empty_fc(weight_empty_fc),
      .weight_almost_empty_fc(weight_almost_empty_fc),
      .weight_dv_fc(weight_dv_fc),
      .weight_data_fc(weight_data_fc),
      `endif //FC

      .weight_read_en_sa(weight_read_en_sa),
      .weight_dv_sa(weight_dv_sa),
      .weight_occupants_sa(weight_occupants_sa),
      .weight_empty_sa(weight_empty_sa),
      .weight_data_sa(weight_data_sa),
      .start_SA(start_SA),
      .p_full_output(psum_full),

      `ifdef FC
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
      .FC_done(FC_done), //accumulator valid signal of FC engine
      .FC_layerdone(FC_layerdone),
      `endif //FC 

      .op_img_size(op_img_size),
      .layer_done(layer_done),
      .iteration_Done(iter_done),
      .systolic_array_trigger(systolic_array_trigger),
      .i_rst(i_rst),
      .conv_pad_left(conv_pad_left),
      .conv_pad_right(conv_pad_right),
      .conv_pad_top(conv_pad_top),
      .conv_pad_bottom(conv_pad_bottom),


      .image_width(input_img_width),
      .image_height(input_img_height),

      `ifdef MEGA_POOL
      .start_POOL(start_POOL),
      .valid_img_size_im2col(valid_opcode[`OP_CONV] | valid_opcode[`OP_POOL]), //valid inst conv
      `else
      .valid_img_size_im2col(valid_opcode[`OP_CONV]),
      `endif 

      .im2col_global_start(im2col_global_start),
      .img_read_done(img_read_done),
      .image_rden(image_rden),
      .row(row),
      .col(col),
      .real_col(real_col),
      .real_row(real_row),

      `ifdef BIAS_FC
      .bias_fc_enable(bias_fc_enable),
      .bias_data_in_fc(bias_data_in_fc),
      .bias_wren_fc(bias_wren_fc),
      .fc_bias_fifo_occupants(fc_bias_fifo_occupants),
      `endif //BIAS_FC

      .vector_add_enable(vector_add_enable),

      `ifdef MEGA_POOL
      .pool_start(pool_start),
      .pool_stall(pool_stall),
      .PoolIW(pool_iw),
      .PoolIH(pool_ih),
      .PoolType(pooltype),
      .PoolScale(poolscale),
      .PoolShift(poolshift),
      .PoolWidth(poolwidth),
      .PoolHeight(poolheight),
      .PoolStrideW(poolstride_w),
      .PoolStrideH(poolstride_h),
      .PoolPadL(pool_pad_l),
      .PoolPadR(pool_pad_r),
      .PoolPadT(pool_pad_t),
      .PoolPadB(pool_pad_b),
      .pool_o_datavalid(pool_o_datavalid),
      .pool_o_data(pool_o_data),
      `endif

      .im2col_done(im2col_done),
      .pseudo_im2col_done(pseudo_im2col_done),
      .SA_psum_fifo_empty(SA_psum_fifo_empty),

      `ifdef MEGA_POOL
      .pool_done(pool_done),
      `endif

      .stride(stride),
      .kernel_width(kernel_width),
      .kernel_height(kernel_height),
      .o_image_fifo_almost_empty_flag(sa_image_fifo_almost_empty_flag),
      .o_image_fifo_almost_full_flag(sa_image_fifo_almost_full_flag),
      .sa_stall(sa_stall),
      
      .start_row_skip(start_row_skip),

      .valid_SA(valid_SA),
      .dataout_SA(dataout_SA),
      .op_data_mux_FC(op_data_mux_FC),
      .valid_out_FC(valid_out_FC),

      .empty_vector(empty_vector),
      .almost_empty_vector(almost_empty_vector),
      .empty_sa(empty_sa),
      .almost_empty_sa(almost_empty_sa),

      .end_row_skip(end_row_skip)
      
  );


  `ifdef TRANSPOSE
  wire RT_done;
  wire [QUANT_OP_FIFO-1:0] rt_op_fifo_wren;
  wire [AXI_DATA_WIDTH-1:0] reshape_transpose_data;

  top_reshape_transpose # (
    .W_ADDR($clog2(RT_BRAM_DEPTH)),
    .DATA_WIDTH(DATA_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .N_SA(N_SA),
    .FIFO_DEPTH(RT_FIFO_DEPTH),
    .W_CITER_CNT(W_CITER_CNT),
    .BURST_LEN(BURST_LENGTH_WIDTH),
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .IMG_WIDTH(TRANSPOSE_IW_WIDTH),
    .IMG_HEIGHT(TRANSPOSE_IH_WIDTH),
    .IMG_CHANNELS(TRANSPOSE_IC_WIDTH)
  )
  top_reshape_transpose_inst (
    .clk(i_clk),
    .rst(i_rst),
    .image_height(ReshapeTranspose_IH),
    .image_width(ReshapeTranspose_IW),
    .input_channels(ReshapeTranspose_IC),
    .rd_start(start_RT),
    .i_select(select[`ReshapeTranspose]),
    .i_data_last(dram_rd_data_last),
    .i_data_valid(dram_rd_datavalid),
    .start_addr_rd_req(ReshapeTranspose_start_address),
    .i_dram_data_read_requestor(dram_rd_data),
    .burst_length_read_requestor(mc_ReshapeTranspose_bl),
    .addr_out_read_requestor(mc_ReshapeTranspose_addr),
    .op_fifo_data(reshape_transpose_data),
    .reshape_transpose_done(RT_done),
    .op_fifo_wr_en(rt_op_fifo_wren),
    .rw_enable_rd_req(mc_ReshapeTranspose_rdreq),
    .last_read_requestor(mc_ReshapeTranspose_last),
    .valid_read_requestor(mc_ReshapeTranspose_valid)
  );
  `endif //TRANSPOSE


   // Generation of local 'rst' signal
  wire rst;
  reg [1:0] r_rst = 0;
  always @(posedge i_clk) begin
    r_rst [0] <= i_rst;
    r_rst [1] <= r_rst [0];
  end
  assign rst = r_rst[1];

  `ifdef ELTWISE 
  wire [(DATA_WIDTH_OB*N_SA)-1:0] EltWise_data_out;
  wire [N_SA-1:0] EltWise_data_out_valid;
  wire [W_QUANT_SHIFT-1:0] EltWise_fp_cast_shift;
  wire EW_done;

  top_element_wise #(
      .DATA_WIDTH(DATA_WIDTH),   
      .N(N_SA),          
      .MOD(MOD2),
      .FIFO_NO(ELTWISE_FIFO),       
      .W_ADDR($clog2(ELTWISE_FIFO_DEPTH)),
      .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
      .ELTWISE_SCALE_WIDTH(ELTWISE_SCALE_WIDTH),
      .ELTWISE_ZEROPOINT_WIDTH(ELTWISE_ZEROPOINT_WIDTH),
      .ELTWISE_QUANT_SHIFT(W_QUANT_SHIFT),
      .DATA_WIDTH_OB(DATA_WIDTH_OB),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
      .ELTWISE_IW_WIDTH(ELTWISE_IW_WIDTH),
      .ELTWISE_IH_WIDTH(ELTWISE_IH_WIDTH),
      .ELTWISE_IC_WIDTH(ELTWISE_IC_WIDTH)
  ) top_element_wise_inst (
      .clkin(i_clk),
      .rst(rst),
      .EltWise_op_en(valid_opcode[`OP_EltWise]), 
      .img_dim_Op(img_dim_Op), 
      .LeftOperand_wr_en(dv_LeftOperand_data), 
      .RightOperand_wr_en(dv_RightOperand_data), 
      .LeftOperand_data_in(LeftOperand_in_data), 
      .RightOperand_data_in(RightOperand_in_data), 
      .EltWise_type(EltWise_type),
      .LeftOperand_Scale(LeftOperand_Scale),
      .LeftOperand_zero_point(LeftOperand_zero_point),
      .RightOperand_Scale(RightOperand_Scale),
      .RightOperand_zero_point(RightOperand_zero_point),
      .EltWise_IW(EltWise_IW),
      .EltWise_IH(EltWise_IH),
      .EltWise_IC(EltWise_IC),
      .op_fifo_empty(op_done),

      .EltWise_data_out(EltWise_data_out), 
      .EltWise_data_out_valid(EltWise_data_out_valid), 
      .LeftOperand_fifo_occupants(LeftOperand_fifo_occupants),
      .RightOperand_fifo_occupants(RightOperand_fifo_occupants),
      .EW_done(EW_done),
      .EltWise_fp_cast_shift(EltWise_fp_cast_shift)
  );
  `endif

  wire [N_SA-1:0] valid_SA;
  wire [(N_SA*DATA_WIDTH_OB)-1:0] dataout_SA;
  wire [(ACC_DW*N_FC_MUX)-1:0] op_data_mux_FC;
  wire valid_out_FC;
  wire [(N_SA*DATA_WIDTH_OB) -1:0] data_tail_blk_in;
  wire [N_SA-1:0] data_tail_blk_vaild;

  interconnect #(
      .DATA_WIDTH_OB(DATA_WIDTH_OB),
      .N_SA(N_SA),
      .OPCODE_WIDTH(OPCODE_WIDTH)
  ) SA_FC_EltWise_interconnect (
      .opcode(opcode),
      .SA_data(dataout_SA),
      .SA_data_valid(valid_SA),
      .FC_data(op_data_mux_FC),
      .FC_data_valid({N_SA{valid_out_FC}}),
      .EltWise_data(EltWise_data_out),
      .EltWise_data_valid(EltWise_data_out_valid),
      .data_tail_blk_in(data_tail_blk_in),
      .data_tail_blk_vaild(data_tail_blk_vaild)
  ); 


  wire [W_QUANT_SHIFT-1:0] fp_cast_shift;
  wire fp_cast;
  
  quant_interconnect # (
    .SHIFT_WIDTH(W_QUANT_SHIFT),
    .OPCODE_WIDTH(OPCODE_WIDTH)
  ) quant_interconnect_inst (
    .opcode(opcode),

    `ifdef ELTWISE 
    .EltWise_fp_cast_shift(EltWise_fp_cast_shift),
    `else
    .EltWise_fp_cast_shift(0),
    `endif

    .fp_cast(fp_cast),
    .fp_cast_shift(fp_cast_shift)
  );

  top_tailblock#(
      .OPCODE_WIDTH(OPCODE_WIDTH),
      .N_SA(N_SA),
      .ACC_DW(ACC_DW),
      .DATA_WIDTH_OB(DATA_WIDTH_OB),
      .DRAM_BW(AXI_DATA_BYTES),
      .ACC_FIFO_DEPTH(ACC_FIFO_DEPTH),
      .COL_SA(COL_SA),
      .ACC_TOGGLE(ACC_TOGGLE),
      .ACC_FIFO(ACC_FIFO),
      .NO_PORT_VA(NO_PORT_VA),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .W_CONV_OP_IMAGE_DIM(OutputBlock_OW_WIDTH), 
      .OutputBlock_OH_WIDTH(OutputBlock_OH_WIDTH),
      .OutputBlock_OW_WIDTH(OutputBlock_OW_WIDTH),
      .BIAS_FIFO_DEPTH(BIAS_FIFO_DEPTH),
      .BIAS_FIFO(BIAS_FIFO),
      .NO_PORT_BAC(NO_PORT_BAC),
      .QUANT_SHIFT(W_QUANT_SHIFT),
      .DATA_WIDTH(DATA_WIDTH),
      .QUANT_SCALE(W_QUANT_SCALE),
      .BIAS_FIFO_FC(BIAS_FIFO_FC),
      .NO_PORT_BAFC(NO_PORT_BAFC),
      .ACT_TYPE_WIDTH(ACT_TYPE_WIDTH),
      .RELU_CLIP_WIDTH(RELU_CLIP_WIDTH),
      .LR_NEG_ALPHA_WIDTH(LR_NEG_ALPHA_WIDTH),
      .LR_POS_ALPHA_WIDTH(LR_POS_ALPHA_WIDTH),
      
      `ifdef GLOBAL_POOL 
      .POOLTYPE_WIDTH(3),
      .GBL_POOL_SCALE_WIDTH(W_GBL_POOL_SCALE),
      .GBL_POOL_SHIFT_WIDTH(W_GBL_POOL_SHIFT),
      `endif

      `ifdef POOL
      .POOLTYPE_WIDTH(W_POOL_TYPE),
      .POOLWIDTH_WIDTH(W_POOL_WIDTH),
      .POOLHEIGHT_WIDTH(W_POOL_HEIGHT),
      .POOLSTRIDE_WIDTH(W_POOL_STRIDE),
      .POOLPAD_WIDTH(W_POOL_PAD),
      .POOLCEIL_WIDTH(W_POOL_CEIL),
      .POOLMODCOUNT_WIDTH(W_POOL_MODCOUNT),
      .POOLPADSIDES_WIDTH(W_POOL_PADSIDES),
      .POOL_SCALE_WIDTH(W_POOL_SCALE),
      .POOL_SHIFT_WIDTH(W_POOL_SHIFT),
      `endif

      .DATA_WIDTH_ACC(DATA_WIDTH_ACC),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
      .MOD2(MOD2),
      .MOD1(MOD1),
      .SHFT_REG_X(SHFT_REG_X),
      .QUANT_OP_FIFO(QUANT_OP_FIFO),
      .N_DMUX_PORTS(N_DMUX_PORTS),
      .ACC_OP_FIFO(ACC_OP_FIFO)
  ) top_tailblock_inst (
      .i_clk(i_clk),
      .rst(rst),

      .opcode(opcode),
      .i_img_dim_Op(img_dim_Op),
      .Tail_done(Tail_done),
      .op_img_size(op_img_size),


      .data_tail_blk_in(data_tail_blk_in),  
      .data_tail_blk_vaild(data_tail_blk_vaild), 
      .iteration_Done(iter_done),
      .vector_add_values(vector_add_values),
      .op_full(op_full),
      .sa_stall(sa_stall),
      .i_img_dim_Acc(img_dim_Acc),
      .vector_add_wren(vector_add_wren),
      .op_width(op_width),
      .op_height(op_height),
      .vector_add_enable(vector_add_enable),
      .bias_wren(bias_wren),
      .CONV_FC(CONV_FC),
      .channel_done(channel_done),
      .bias_data_in(bias_data_in),
      .bias_enable(bias_enable),

      .fp_cast_shift(fp_cast_shift),
      .fp_cast(fp_cast),

      .quant_scale(({COL_SA{tail_quantscale}})),
      .quant_enable(quant_enable),
      .shift_value(({COL_SA{tail_quantshift}})),
      
      `ifdef BIAS_FC 
      .bias_fc_enable(bias_fc_enable),
      .bias_data_in_fc(bias_data_in_fc),
      .bias_wren_fc(bias_wren_fc),
      .fc_bias_fifo_occupants(fc_bias_fifo_occupants)
      `endif // BIAS_FC

      `ifdef FC
      .FC_layerdone(FC_layerdone),
      `endif

      .relu_enable(relu_enable),
      .relu_clip_value(relu_clip_value),
      .relu_act_type(relu_act_type),
      .lr_neg_alpha(LR_NegAlpha),
      .lr_pos_alpha(LR_PosAlpha),

      `ifdef MEGA_POOL 
      .pool_o_datavalid(pool_o_datavalid),
      .pool_o_data(pool_o_data),
      `endif

      `ifdef POOL
      .maxpool_enable(maxpool_enable),
      .PoolType(pooltype),
      .PoolWidth(poolwidth),
      .PoolHeight(poolheight),
      .PoolStride(poolstride),
      .PoolPadding(poolpadding),
      .PoolCeil(poolceil),
      .PoolModCount(poolModCount),
      .PoolPadSides(poolpadsides),
      .PoolScale(poolscale),
      .PoolShift(poolshift),
      `endif

      `ifdef GLOBAL_POOL 
      .maxpool_enable(maxpool_enable),
      .gbl_pool_scale(gbl_pool_scale),
      .gbl_pool_shift(gbl_pool_shift),
      `endif

      `ifdef CONCAT
      .o_concat_data(o_concat_data),
      .o_concat_dv(o_concat_dv),
      `endif

      .empty_vector(empty_vector),
      .almost_empty_vector(almost_empty_vector),
      .empty_sa(empty_sa),
      .almost_empty_sa(almost_empty_sa),

      .acc_fifo_occupants(acc_fifo_occupants),
      .bias_fifo_occupants(bias_fifo_occupants),
      .quant_op_write_data(quant_op_write_data),
      .quant_op_wren(quant_op_wren),
      .acc_op_wren(acc_op_wren),
      .acc_op_write_data(acc_op_write_data)

      `ifdef RESIZE
      ,
      .resize_valid(resize_valid),
      .resize_op(resize_op)
      `endif
  );


  //op_write fifo rden ctrl(with Acc_onchip flag) - added on 25-11-24
  wire [OP_FIFO-1:0] op_write_fifo_rden;
  wire [OP_FIFO-1:0] op_dram_rden;
  assign op_write_fifo_rden = op_dram_rden;
  wire [QUANT_OP_FIFO-1:0] quant_op_fifo_full;

  interconnect_dram_data_aligner # (
    .QUANT_OP_FIFO(QUANT_OP_FIFO),
    .OPCODE_WIDTH(OPCODE_WIDTH),
    .NUM_INSTRUCTIONS(NUM_INSTRUCTIONS),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
  )
  interconnect_dram_data_aligner_inst (
    .clk(i_clk),
    .valid_opcode(valid_opcode),
    .i_quant_fifo_data(quant_op_write_data),
    .i_quant_fifo_wren(quant_op_wren),
    .i_nms_fifo_data(0),
    .i_nms_fifo_wren(0),
    
    `ifdef TRANSPOSE
    .i_rt_fifo_data(reshape_transpose_data),
    .i_rt_fifo_wren(rt_op_fifo_wren),
    `else
    .i_rt_fifo_data(0),
    .i_rt_fifo_wren(0),
    `endif //TRANSPOSE

    .o_op_fifo_data(i_op_fifo_data),
    .o_op_fifo_wren(i_op_fifo_wren)
  );

  wire [QUANT_OP_FIFO*AXI_DATA_WIDTH-1:0] i_op_fifo_data;
  wire [QUANT_OP_FIFO-1 : 0] i_op_fifo_wren;

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
    .OUTPUT_REG(0),
    .OutputBlock_OpWidth_WIDTH(OutputBlock_OpWidth_WIDTH)
  )
  dram_data_aligner_inst (
    .i_clk(i_clk),
    .i_rst(i_rst&(~iter_done)),
    .i_start(start),
    .i_Acc_Onchip(Acc_onchip_masked),
    .i_acc_data(acc_op_write_data),
    .i_acc_data_wren(acc_op_wren),
    .i_op_fifo_data(i_op_fifo_data),
    .i_op_fifo_wren(i_op_fifo_wren),   
    .i_op_write_dram_fifo_rden(op_write_fifo_rden),
    .i_last_c_itr(last_c_itr),
    .i_OB_OpWidth(OB_OpWidth),
    .o_op_write_dram_fifo_occupants(op_write_dram_fifo_occupants),
    .o_op_write_dram_fifo_empty(op_dram_fifo_empty),
    .o_op_write_dram_fifo_data(op_dram_fifo),
    .o_op_write_dram_fifo_dv(op_write_fifo_dv),
    .o_op_full(op_full),
    .o_acc_onchip_data(vector_add_values_opfifo_acc),
    .o_acc_onchip_data_dv(vector_add_wren_opfifo_acc),
    .quant_op_fifo_full(quant_op_fifo_full)
  );
 
  `ifdef RESIZE
  wire [AXI_DATA_BYTES-1:0] resize_fifo_rden;
  wire [N_SA-1:0] resize_valid;
  wire [AXI_DATA_BYTES*DATA_WIDTH-1:0] resize_op;

  gen_top_resize#(
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_NO(AXI_DATA_BYTES),
    .N_SA(N_SA),
    .RESIZE_IW_WIDTH(W_RESIZE_IW),
    .RESIZE_IH_WIDTH(W_RESIZE_IH),
    .RESIZE_IC_WIDTH(W_RESIZE_IC),
    .MOD2(MOD2),
    .W_ADDR($clog2(DRAM_IMG_FIFO_DEPTH))
  ) resize_inst(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_resize_IW(resize_iw),
    .i_resize_IH(resize_ih),
    .i_fifo_occupants(img_fifo_occ_resize),
    .i_fifo_data(fifo_img_data_resize),
    .i_fifo_data_valid(img_fifo_dv_resize),
    .i_fifo_empty(image_fifo_empty),
    .o_valid(resize_valid),
    .o_data_out(resize_op),
    .o_busy(),
    .o_fifo_rden(resize_fifo_rden),
    .o_done(resize_done),
    // w_resize_kernel_start provides a pulse for every kernel iteration
    .i_resize_start(w_resize_kernel_start | start_RESIZE)
  );
  `endif
  
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
    
    
   // iteration counter new 
    iteration_cnt #(
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
        

        `ifdef FC
        .FC_done(FC_done),
        `endif //FC

        `ifdef ELTWISE 
        .EW_done(EW_done),
        `endif //ELTWISE

        `ifdef TRANSPOSE
        .RT_done(RT_done),
        `endif //TRANSPOSE

        `ifdef MEGA_POOL
        .pool_done(pool_done),
        `endif

        `ifdef CONCAT
        .i_concat_done(w_concat_done),
        `endif //CONCAT

        .c_iter(channel_iteration), 
        .k_iter(kernel_iteration),
        .o_iter_done(iter_done),
        .o_c_done(channel_done),
        .o_layer_done(layer_done),
        .o_SA_done(SA_done), 
        .BIAS_EN(Bias_En),
        .RELU_EN(ACT_EN),
        .QUANT_EN(QUANT_EN),

        `ifdef GLOBAL_POOL
        .POOL_EN(gbl_pool_en),
        `elsif POOL
        .POOL_EN(POOL_EN),
        `else
        .POOL_EN(1'b0),
        `endif

        .ACC_EN(ACC_EN),
        
        `ifdef BIAS_FC
        .FC_BIAS_EN(Bias8_EN), //above six signals comes from instruction fields
        `endif //BIAS_FC

        .acc_en(vector_add_enable),
        .relu_en(relu_enable),
        .quant_en(quant_enable),
        .bias_en(bias_enable),

        `ifdef BIAS_FC
        .fc_bias_en(bias_fc_enable),
        `endif //BIAS_FC
 
        `ifdef RESIZE
        .resize_done(resize_done),
        `endif
        
        .pool_en(maxpool_enable),
        .en(last_c_itr),
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
    .start_block(start_block)
  );


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

      `ifdef MEGA_POOL
      .start(start_SA | start_POOL), 
      `else
      .start(start_SA),
      `endif

      .image_fifo_empty(&(image_fifo_empty)),
      .iter_done(iter_done),
      .c_iter(channel_iteration),
      .k_iter(kernel_iteration),

      .start_im2col(im2col_global_start)
    );

  // TODO : add these into a debug ifdef 

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

  always@(posedge i_clk) begin
    if(!i_rst) start_en <= 0;
    else begin
      if(start) start_en <= 1;
      else if(layer_done) start_en <= 0;
      else start_en <= start_en;
    end
  end
  
  // TODO : add these into a debug ifdef 
  reg [LAYERCNT_WIDTH-1:0] layer_cntr;
  always@(posedge i_clk) begin
    if(!i_rst) layer_cntr <= 0;
    else begin
      if(layer_cntr==108) layer_cntr <= 0;
      else begin
        if(layer_done) layer_cntr <= layer_cntr + 1;
      end
    end
  end

  // TODO : add this to the below available ifdef 
  reg inference_done;
  always@(posedge i_clk) begin
    if(!i_rst) inference_done <= 1'b0;
    else begin
        if(user_start) inference_done <= 1'b0;
        else if(layer_cntr == 96) inference_done <= 1'b1;
    end
  end

  assign layer_debug_pin = (layer_cntr==4)? 1 : 0;

  (*syn_use_dsp = "no"*) wire [2*I_OP_SIZE_WIDTH-1:0] datasize_dispatch; //number of bytes to be transferred from DRAM to CPU

  `ifdef FC
  assign datasize_dispatch = (OutputBlock_FlatController)? img_dim_Op : ((CONV_FC)? img_dim_Op*N_SA[I_OP_SIZE_WIDTH-1:0]*fc_kernel_iter : img_dim_Op*kernel_iteration*N_SA*OB_OpWidth);
  `else
  assign datasize_dispatch = (OutputBlock_FlatController)? img_dim_Op : img_dim_Op*kernel_iteration*N_SA*OB_OpWidth;
  `endif //FC

  assign dispatch_start_address = op_start_address;
  
  /* ----- Additional logic to monitor compute cycles and stall cycles for each layer ----- */

  `ifdef MONITOR_LAYER_CYCLES

    wire layer_monitor_fifo_empty;
    wire layer_monitor_fifo_rden;

    /* 
        Write the FIFO debug count value on layer_done and
        read it after layer_ctr reaches to maximum value
    */

    sync_fifo #(.W_DATA(32),
                .W_ADDR(7) // Change the FIFO depth if necessary based on the maximum number of layers
    )
    layer_monitor_fifo (
        .clk_i(i_clk),
        .wr_en_i(layer_done),
        .rd_en_i(layer_monitor_fifo_rden),
        .full_o(),
        .empty_o(layer_monitor_fifo_empty),
        .wdata(debug_counter),
        .datacount_o(),
        .rst_busy(),
        .rdata(layer_cycles_count),
        .a_rst_i(~i_rst),
        .o_valid()
    );

    assign layer_monitor_fifo_rden = inference_done ? ~layer_monitor_fifo_empty : 1'b0;

  `endif

  `ifdef MONITOR_STALL_CYLES
    reg [19:0] im2col_stall_cycles;
    reg [19:0] sa_stall_cycles;
    reg [19:0] layer_done_wait_cycles;

    always@(posedge i_clk) begin
        if(!i_rst) im2col_stall_cycles <= 0;
        else begin
            if(layer_done) im2col_stall_cycles <= 0;
            else if(stall_on) im2col_stall_cycles <= im2col_stall_cycles + 1;
            else im2col_stall_cycles <= im2col_stall_cycles;
        end
    end

    always@(posedge i_clk) begin
        if(!i_rst) sa_stall_cycles <= 0;
        else begin
            if(layer_done) sa_stall_cycles <= 0;
            else if(sa_stall) sa_stall_cycles <= sa_stall_cycles + 1;
            else sa_stall_cycles <= sa_stall_cycles;
        end
    end

    // layer_done_wait_cycles
    reg r_tail_done;
    always@(posedge i_clk) begin
        if(Tail_done) r_tail_done <= 1'b1;
        else if(op_done) r_tail_done <= 1'b0;
    end
    always@(posedge i_clk) begin
        if(!i_rst) layer_done_wait_cycles <= 0;
        else begin
            if(layer_done) layer_done_wait_cycles <= 0;
            else if(r_tail_done) layer_done_wait_cycles <= layer_done_wait_cycles + 1;
        end
    end

    wire stall_monitor_fifo_empty;
    wire stall_monitor_fifo_rden;
    
    sync_fifo #(.W_DATA(60),
                .W_ADDR(7) // Change the FIFO depth if necessary based on the maximum number of layers
    )
    stall_monitor_fifo (
        .clk_i(i_clk),
        .wr_en_i(layer_done),
        .rd_en_i(stall_monitor_fifo_rden),
        .full_o(),
        .empty_o(stall_monitor_fifo_empty),
        .wdata({layer_done_wait_cycles, sa_stall_cycles, im2col_stall_cycles}),
        .datacount_o(),
        .rst_busy(),
        .rdata(stall_cycles_count),
        .a_rst_i(~i_rst),
        .o_valid()
    );

    assign stall_monitor_fifo_rden = inference_done ? ~stall_monitor_fifo_empty : 1'b0;

  `endif

endmodule
