`include "common/instructions.vh"
`include "common/arch_param.vh"
module Top_CONV_FC #(
    parameter OPCODE_WIDTH = 4,
    parameter N_SA = NSA_DSP + NSA_LUT,
	parameter DATA_WIDTH = 8,
    parameter COL_SA = 4,
    parameter COL_FC = 32,
    parameter QUANT_SHIFT = 8,
    parameter QUANT_SCALE = 16,
    parameter ROW = 9,
    parameter DRAM_BW = 32,
    parameter W_PSUM = 20,
    parameter MOD1 = 2,
    parameter MOD2 = DRAM_BW/N_SA,
    parameter DATA_WIDTH_OB = 32, //data width for vector add and bias blocks
    parameter DATA_WIDTH_ACC = 32, //data width of intermediate accumulants(SA)
    parameter W_CONV_IMAGE_DIM = 10,
    parameter W_CONV_OP_IMAGE_DIM = 10,
    parameter SHFT_REG_X = DRAM_BW/N_SA,
    parameter BIAS_FIFO = 8, // Number of bias fifos
    parameter ACC_OP_FIFO = 2, // Number of accumulant o/p fifos
    parameter QUANT_OP_FIFO = 1, // Number of quantized o/p fifos
    parameter ACC_FIFO = 8, // Number of accumulant fifos
    parameter WEIGHT_FIFO_DEPTH = 512,
    parameter IM2COL_FIFO_DEPTH = 1024,
    parameter PSUM_FIFO_DEPTH = 1024,
    parameter ACC_FIFO_DEPTH = 512,
    parameter BIAS_FIFO_DEPTH = 512,
    parameter ELTWISE_FIFO_DEPTH = 512,
    parameter NSA_DSP = 4,
    parameter N_FC_MUX = N_SA,
    parameter NO_PORT_FC = COL_FC/N_SA,
    parameter RELU_CLIP_WIDTH = 8,
    parameter ACT_TYPE_WIDTH = 4,
    parameter LR_NEG_ALPHA_WIDTH = 10,
    parameter LR_POS_ALPHA_WIDTH = 10,
    parameter NSA_LUT = 0,
    parameter BIAS_FIFO_FC=32, // Number of FC_bias fifos
    parameter ACC_TOGGLE = 1,
    parameter NO_PORT_VA=2,
    parameter NO_PORT_BAC=2,
    parameter NO_PORT_BAFC=8,
    parameter POP_THRESHOLD=(DRAM_BW/N_SA) - 2,
    // parameter I_SIZE_WIDTH=20, // input image data width
    parameter I_ACC_SIZE_WIDTH = 16, 
    parameter I_OP_SIZE_WIDTH = 16,
    parameter N_DMUX_PORTS = DRAM_BW/(N_SA*(ACC_DW/8)),
     //Generalized Pool Parameters
    parameter POOLEN_WIDTH = 1,
    parameter POOLTYPE_WIDTH = 3,
    parameter POOLWIDTH_WIDTH = 4,
    parameter POOLHEIGHT_WIDTH = 4,
    parameter POOLSTRIDE_WIDTH = 4,
    parameter POOLPADDING_WIDTH = 4,
    parameter POOLCEIL_WIDTH = 1,
    parameter POOLMODCOUNT_WIDTH = 4,
    parameter POOLPADSIDES_WIDTH = 4,
    parameter POOL_SCALE_WIDTH = 8,
    parameter POOL_SHIFT_WIDTH = 4,
    //FC realated parameters
    parameter FC_IMAGE_ROWS_WIDTH = 16,
    parameter ACC_DW = 32,
    parameter N_BANK = N_SA,
    parameter N_BRAM = DRAM_BW/N_SA,
    parameter W_FC_RW_COUNTER = 10, // width of r/w address counter
    parameter FC_BRAM_DEPTH = 1024,
    parameter W_KERNEL_CNT = 16,
    parameter W_FC_IMAG_DIM = 20,

    // im2col_v1 parameter

    parameter KERNEL_SIZE = 4,  // im2col kernal size
    parameter STRIDE      = 3,  // im2col MAX STRIDE parameter  
    parameter CONV_STRIDE_WIDTH = 2,
    parameter CONV_KW_WIDTH = 4,
    parameter CONV_KH_WIDTH = 4,
    parameter OutputBlock_OH_WIDTH = 10, // Output Block height width
    parameter OutputBlock_OW_WIDTH = 10, // Output Block width width
    parameter CONV_IW_WIDTH = 10,
    parameter CONV_IH_WIDTH = 10,
    parameter CONV_PadLeft_WIDTH = 3, // Left padding width
    parameter CONV_PadRight_WIDTH = 3, // Right padding width
    parameter CONV_PadTop_WIDTH = 3, // Top padding width
    parameter CONV_PadBottom_WIDTH = 3, // Bottom padding width
    parameter CONV_StartRowSkip_WIDTH = 4, // Start row skip for im2col
    parameter CONV_EndRowSkip_WIDTH = 4, // End row skip for im2col
    parameter IM2COL_BOUND_GEN_WIDTH = 16, // Data width for bound generation registers of Im2Col Engine
    parameter N_MOD_STAGES = 9, // Number of stages in mod operator in Im2Col stride handling block
    
    parameter ELTWISE_FIFO = 8, // Number of element wise fifos
    parameter ELTWISE_TYPE_WIDTH = 4, // Width of the element wise
    parameter ELTWISE_IW_WIDTH = 10, // Width of the input width;
    parameter ELTWISE_IH_WIDTH = 10, // Width of the input height;
    parameter ELTWISE_IC_WIDTH = 10, // Width of the output width;
    parameter ELTWISE_SCALE_WIDTH = 32, // Width of the scale value
    parameter ELTWISE_ZEROPOINT_WIDTH = 8, // Width of the zero point value
    parameter CONV_TYPE_WIDTH = 2, //CONV type width

    parameter ACC_DATA_REORDER = ((COL_FC/(ACC_DW/8)) > COL_SA)? 1:0 //parameter to specify FC o/p data reordering is required or not
) (

   
    input i_clk,
    input s_clk,
    input i_rst,
    input [DRAM_BW-1:0] image_fifo_empty,
    input CONV_FC,
    input [OPCODE_WIDTH-1:0]opcode,
    // input switch_enable,
    //	input CONV_FC,
    input op_full,
    input [(DRAM_BW*DATA_WIDTH) -1:0] fifo_o, //Data from DRAM Image FIFO to im2col buffers and then to SA engines
    input [CONV_TYPE_WIDTH-1:0] conv_type, //CONV type (regular 2D, depthwise, pointwise)
    
    //weight fifo sharing signals
    `ifdef FC
    output [(COL_FC/COL_SA)-1 : 0] weight_read_en_fc,
    input [((COL_FC/COL_SA) * ($clog2(WEIGHT_FIFO_DEPTH) + 1))-1 : 0] weight_occupants_fc,
    input weight_empty_fc,
    input weight_almost_empty_fc,
    input [(COL_FC/COL_SA)-1 : 0] weight_dv_fc,
    input [(COL_FC * DATA_WIDTH)-1 : 0] weight_data_fc,
    `endif //FC
    
    input start_SA,
    output [(N_SA)-1 : 0] weight_read_en_sa,
    input [(N_SA)-1 : 0] weight_dv_sa,
    input [(N_SA * (($clog2(WEIGHT_FIFO_DEPTH) + 1)))-1 : 0] weight_occupants_sa,
    input [(N_SA)-1 : 0] weight_empty_sa,
    input [(N_SA * COL_SA * DATA_WIDTH)-1 : 0] weight_data_sa,
    
    `ifdef FC
    //Flattening and FC signals
    input flatten_enable,
    input start_FC,
    input [W_FC_RW_COUNTER-1:0] i_rw_addr_cnt_flatten,
    input [W_KERNEL_CNT-1:0] i_kernel_cnt_FC,
    input [(N_BANK*N_BRAM)-1:0] i_data_valid_flatten,
    input [W_FC_IMAG_DIM-1:0] i_img_dim_flatten,
    input [(N_BANK*N_BRAM*DATA_WIDTH)-1:0] i_data_FC, //feature map input for FC (from DDR)
    input [FC_IMAGE_ROWS_WIDTH-1:0] i_img_dim_fc,
    input i_sel_fc_fifosharing,
    output FC_done, //accumulator valid signal of FC computing engine
    output FC_layerdone,
    `endif //FC

    //vector addition signals
    input [(ACC_FIFO*DATA_WIDTH_ACC)-1:0] vector_add_values,
    input [ACC_FIFO-1:0] vector_add_wren,
    
    input [W_CONV_OP_IMAGE_DIM-1:0] maxpool_threshold, //CONV output (OW) width
    input layer_done,
    input iteration_Done,
    input channel_done,
    input [N_SA-1:0] shift_reg_sel,
    input systolic_array_trigger,
    input [(RELU_CLIP_WIDTH)-1:0] relu_clip_value,
    input [ACT_TYPE_WIDTH-1:0] relu_act_type,
    input [LR_NEG_ALPHA_WIDTH-1:0] lr_neg_alpha,
    input [LR_POS_ALPHA_WIDTH-1:0] lr_pos_alpha,
    input bias_enable,
    input quant_enable,
    input [CONV_PadLeft_WIDTH-1:0] conv_pad_left,
    input [CONV_PadRight_WIDTH-1:0] conv_pad_right,
    input [CONV_PadTop_WIDTH-1:0] conv_pad_top,
    input [CONV_PadBottom_WIDTH-1:0] conv_pad_bottom,

    `ifdef BIAS_FC
    //bias_fc signals
    input bias_fc_enable,
    input [(BIAS_FIFO_FC*DATA_WIDTH)-1:0] bias_data_in_fc,
    input [BIAS_FIFO_FC -1:0] bias_wren_fc,
    output [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO_FC)-1:0] fc_bias_fifo_occupants,
    `endif //BIAS_FC

    //im2col signals
    input [CONV_IW_WIDTH-1:0] image_width,
    input [CONV_IH_WIDTH-1:0] image_height,
    input valid_img_size_im2col,
    input im2col_global_start,
    output [DRAM_BW-1:0] image_rden,
	input stall_on,
    input img_read_done,
    
    //tail block signals
    input relu_enable,
    input [(BIAS_FIFO*DATA_WIDTH_OB)-1:0] bias_data_in,
    input [BIAS_FIFO -1:0] bias_wren,
    input [(QUANT_SHIFT) -1:0] shift_value,
    input [(QUANT_SCALE)-1:0] quant_scale,
    input vector_add_enable,
    //input maxpool_enable,
    input [I_ACC_SIZE_WIDTH-1:0] i_img_dim_Acc,
    input [I_OP_SIZE_WIDTH-1:0] i_img_dim_Op,
    input [CONV_STRIDE_WIDTH-1:0] stride, // im2col input stride 
    input [CONV_KW_WIDTH-1:0] kernel_width,
    input [CONV_KH_WIDTH-1:0] kernel_height,
    input [OutputBlock_OW_WIDTH-1 : 0] op_width,
    input [OutputBlock_OH_WIDTH-1 : 0] op_height,
   
    //EltWise operation signals
    input op_fifo_empty,
    input [(ELTWISE_FIFO*DATA_WIDTH*N_SA)-1:0] LeftOperand_data_in,
    input [(ELTWISE_FIFO*DATA_WIDTH*N_SA)-1:0] RightOperand_data_in,
    input [(ELTWISE_TYPE_WIDTH-1):0] EltWise_type,
    input [ELTWISE_SCALE_WIDTH-1:0] LeftOperand_Scale,
    input [ELTWISE_SCALE_WIDTH-1:0] RightOperand_Scale,
    input [ELTWISE_ZEROPOINT_WIDTH-1:0] LeftOperand_zero_point,
    input [ELTWISE_ZEROPOINT_WIDTH-1:0] RightOperand_zero_point,
    input [ELTWISE_IW_WIDTH-1:0]EltWise_IW,
    input [ELTWISE_IH_WIDTH-1:0]EltWise_IH,
    input [ELTWISE_IC_WIDTH-1:0]EltWise_IC,
    input [ELTWISE_FIFO-1:0] LeftOperand_wr_en,
    input [ELTWISE_FIFO-1:0] RightOperand_wr_en,
    input EltWise_op_en,

    `ifdef POOL
    //Generalized Pool
    input maxpool_enable,
    input [POOLTYPE_WIDTH - 1 : 0] PoolType,
    input [POOLWIDTH_WIDTH - 1 : 0] PoolWidth,
    input [POOLHEIGHT_WIDTH - 1 : 0] PoolHeight,
    input [POOLSTRIDE_WIDTH - 1 : 0] PoolStride,
    input [POOLPADDING_WIDTH - 1 : 0] PoolPadding,
    input [POOLCEIL_WIDTH - 1 : 0] PoolCeil,
    input [POOLMODCOUNT_WIDTH - 1 : 0] PoolModCount,
    input [POOLPADSIDES_WIDTH - 1 : 0] PoolPadSides,
    input [POOL_SCALE_WIDTH - 1 : 0] PoolScale,
    input [POOL_SHIFT_WIDTH - 1 : 0] PoolShift,
    `endif //POOL

    // accumulant output write signals
    output [ACC_OP_DATAWIDTH -1:0] acc_op_write_data,
    output [ACC_OP_FIFO-1:0] acc_op_wren,
    // quantized output write signals
    output [(DATA_WIDTH*N_SA*SHFT_REG_X*(QUANT_OP_FIFO)) -1:0] quant_op_write_data,
    output [QUANT_OP_FIFO-1:0] quant_op_wren,
    
    //operator status signals
    output  [W_CONV_IMAGE_DIM-1:0]      row,    
    output  [W_CONV_IMAGE_DIM-1:0]      col,
    output  [W_CONV_IMAGE_DIM-1:0]      real_row,    
    output  [W_CONV_IMAGE_DIM-1:0]      real_col,
    output im2col_done,
    output pseudo_im2col_done, // output: pseudo im2col done signal
    output SA_psum_fifo_empty,
    output Tail_done,
	  output p_full_output,
  	output EW_done,
    //FIFO status signals for memory request controllers
    output [(($clog2(ACC_FIFO_DEPTH)+1)*ACC_FIFO)-1:0] acc_fifo_occupants,
    output [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO)-1:0] bias_fifo_occupants,
    output [(($clog2(ELTWISE_FIFO_DEPTH)+1)*ELTWISE_FIFO)-1:0] LeftOperand_fifo_occupants,
    output [(($clog2(ELTWISE_FIFO_DEPTH)+1)*ELTWISE_FIFO)-1:0] RightOperand_fifo_occupants,
    output o_image_fifo_almost_empty_flag,
    output o_image_fifo_almost_full_flag,
    input istolic_stall ,
    input  [CONV_StartRowSkip_WIDTH-1:0]   start_row_skip,
    input  [CONV_EndRowSkip_WIDTH-1:0]   end_row_skip

);

  localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;
  localparam ACC_OP_DATAWIDTH = ((N_SA*DATA_WIDTH_ACC) < (DRAM_BW*DATA_WIDTH)) ? (N_SA*DATA_WIDTH_ACC*ACC_OP_FIFO) : (N_SA*DATA_WIDTH_ACC);

  // Generation of local 'rst' signal
  wire rst;
  reg [1:0] r_rst = 0;
  always @(posedge i_clk) begin
    r_rst [0] <= i_rst;
    r_rst [1] <= r_rst [0];
  end
  assign rst = r_rst[1];

  wire [N_SA -1:0] relu_valid;
  wire [(N_SA*DATA_WIDTH) -1:0] relu_output;

  wire read_buf_data;
  wire [(N_SA*DATA_WIDTH) -1:0] buff_out;

  // Generation of im2col buffers based on DRAM_BW and N_SA
  /*
    If number of elements/engine = 1 then read the data directly from the img FIFO,
    otherwise, use the data buffers between DRAM image FIFO and im2col FIFOs. These
    data buffers read the data from img FIFO and when im2col requests the data, it
    will send to SA engines. 
  */
  generate
    if(DRAM_BW/N_SA == 1) begin
      assign image_rden = im2col_done ? 0 : ((~|image_fifo_empty & ~stall_on & read_buf_data)? {N_SA{1'b1}} : {N_SA{1'b0}}); // Read enable for image FIFO
      assign buff_out   = fifo_o;
    end
    
    else begin
      // Data buffers between DRAM image FIFO and im2col FIFOs 
      wire [($clog2(DRAM_BW/N_SA))-1:0] element_poped;
      // Write buffer controller
      im2col_buffer_write # (
        .N_SA(N_SA),
        .DRAM_BW(DRAM_BW),
        .POP_THRESHOLD(POP_THRESHOLD)
      )
      im2col_buffer_write_inst (
        .clk(i_clk),
        .rst(rst&(~img_read_done)),
        .im2col_done(im2col_done),
        .read_buf_data(read_buf_data),
        .stall_on(stall_on),
        .psum_full(p_full_output),
        .fifo_empty(image_fifo_empty),
        .count(element_poped),
        .rden(image_rden)
      );

      //Data buffers
      top_buffer #(
          .BUFFER_SIZE(DATA_WIDTH),
          .N_SA(N_SA),
          .DRAM_BW(DRAM_BW)
      ) buffers (
          .clk(i_clk),
          .stall_on(stall_on),
          .rst(rst&(~im2col_done)),              
          .data_in(fifo_o),
          .data_signal(read_buf_data),
          .data_out(buff_out),
          .elements_poped(element_poped)
      );
    end
  endgenerate

  wire [(DATA_WIDTH*N_SA) -1:0] mux_out;
  wire [ROW-1:0] o_valid_squares;

  wire im2col_o_valid;
  wire [DATA_WIDTH -1:0] im2col_o_data;
 
  wire [N_SA-1:0] maxpool_valid;
  wire [(N_SA*DATA_WIDTH) -1:0] maxpool_output;
  wire [(N_SA*(SHFT_REG_X*DATA_WIDTH)) -1:0] x_final_data;

  wire [N_SA-1:0] x_final_valid;

  wire [(N_SA*ROW) -1:0] fifo_image_wren;
  assign fifo_image_wren = {N_SA{o_valid_squares}}; 

  //Debug counter for img_rden
  reg [31:0] img_rden_counter = 0;
  always@(posedge i_clk) begin
    if(!rst) img_rden_counter <= 0;
    else begin
      if(im2col_done) img_rden_counter <= 0;
      else if(image_rden != 0) img_rden_counter <= img_rden_counter + 1;
    end
  end

  //Debug flag to check correctness of image_rden_counter
  localparam BYTES_PER_SA = DRAM_BW/N_SA;
  wire img_rden_counter_flag;
  assign img_rden_counter_flag = (im2col_done) ? ((img_rden_counter == (image_width * image_height)/(BYTES_PER_SA))? 1'b1 : 1'b0) : 1'b0;

//im2col block
// Generate block for delay the SA data to match delay of im2col
/*
  Number of delay registers is equal to number of pipeline stages used in 
  mod operator in im2col Engine. No.of pipeline stages(N) = W_CONV_IMAGE_DIM-1
*/
genvar f;
generate
  for (f = 0; f < N_MOD_STAGES-1; f = f + 1) begin : delay_stage
  reg [(DATA_WIDTH*N_SA) -1:0] delay_reg ;
    if (f == 0) begin
      always @(posedge i_clk ) delay_reg <= buff_out; 
    end 
    else begin
      always @(posedge i_clk ) delay_reg <= delay_stage[f-1].delay_reg;
    end
  end
endgenerate

// im2col version 1 instance 
  top_im2col_v1 # (.UPPER_BOUND(W_CONV_IMAGE_DIM),
                .LOWER_BOUND(1),
                .N_MOD_STAGES(N_MOD_STAGES),
                .DATA_WIDTH(IM2COL_BOUND_GEN_WIDTH),
                .CONV_KH_WIDTH(CONV_KH_WIDTH),
                .CONV_KW_WIDTH(CONV_KW_WIDTH),
                .STRIDE(STRIDE),
                .ROW(ROW),
                .CONV_PadLeft_WIDTH(CONV_PadLeft_WIDTH),
                .CONV_PadRight_WIDTH(CONV_PadRight_WIDTH),
                .CONV_PadTop_WIDTH(CONV_PadTop_WIDTH),
                .CONV_PadBottom_WIDTH(CONV_PadBottom_WIDTH),
                .CONV_StartRowSkip_WIDTH(CONV_StartRowSkip_WIDTH),
                .CONV_EndRowSkip_WIDTH(CONV_EndRowSkip_WIDTH)
    )
    im2col_v1 (
      .clk_in(i_clk),
      .rstn(rst),
      .valid_mat_size(valid_img_size_im2col),
      .i_data(0), // the data does not go throught the Im2col so it does not matter what you give here but zero should be prefered  
      .i_start_im2col_index(im2col_global_start),
      .kw(kernel_width),
      .kh(kernel_height),

      .conv_pad_left(conv_pad_left),
      .conv_pad_right(conv_pad_right),
      .conv_pad_top(conv_pad_top),
      .conv_pad_bottom(conv_pad_bottom),

      .i_mat_size_col(image_width),
      .i_mat_size_row(image_height),
      .valid_sq(o_valid_squares),
      .o_valid(im2col_o_valid),
      .stride(stride),       
      .o_valid_buff(read_buf_data),
      .o_im2col_done(im2col_done),
      .start_SA(start_SA),
      .i_stall_on (stall_on),
      .o_row(row), 
      .o_col(col),
      .start_row_skip(start_row_skip),
      .end_row_skip(end_row_skip),
      .real_col(real_col),
      .real_row(real_row),
      .pseudo_im2col_done(pseudo_im2col_done) // output: pseudo im2col done signal
    ); 

    


  //parameters will change for top_SA (for CONV opeartion)
  wire [ACC_FIFO-1:0] empty_vector, almost_empty_vector;
  wire [(N_SA)-1:0] empty_sa, almost_empty_sa;
  wire [(N_SA)-1:0] opsum_rden, psum_rden;

  wire [(COL_SA*W_PSUM)*N_SA-1:0] o_psum_ff_array;
  wire [N_SA-1:0] valid_psum;

  wire [(N_SA*COL_SA)-1:0] psum_fifo_almost_full, psum_fifo_almost_empty;

  wire [(N_SA*ROW) -1:0] sa_image_fifo_almost_empty; 
  // systolic array image fifo almost empty
  wire [(N_SA*ROW) -1:0] sa_image_fifo_almost_full;
  // systolic array image fifo almost full

  // generation of sa image fifo almost empty and almost full signals
  // conversion to one bit flag signal to be passed to top_gati_module 

  assign o_image_fifo_almost_empty_flag = |(sa_image_fifo_almost_empty);
  assign o_image_fifo_almost_full_flag = |(sa_image_fifo_almost_full);


  top_sa #(
    .N_SA(N_SA),
    .W_DATA(DATA_WIDTH),
    .COL(COL_SA),
    .ROW(ROW),
    .W_PSUM(W_PSUM),
    .CONV_TYPE_WIDTH(CONV_TYPE_WIDTH),
    .N_BRAM_BYTES(DRAM_BW),
    .PSUM_FF_DEPTH(PSUM_FIFO_DEPTH),
    .WEIGHT_FF_DEPTH(WEIGHT_FIFO_DEPTH),
    .IMG_FF_DEPTH(IM2COL_FIFO_DEPTH),
    .NSA_LUT  (NSA_LUT),
    .NSA_DSP  (NSA_DSP)
  ) systolic_convolution (
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rstn(rst),
    .i_conv_type(conv_type), //input: CONV type (regular 2D, depthwise, pointwise)
    .stall_on(stall_on),
    .istolic_stall(istolic_stall),
    .i_im2col_start(im2col_global_start),
	.i_trigger_1(systolic_array_trigger), //start for CONV operation
    .i_data_weight_ff_sharing(weight_data_sa),
    .i_dv_weight_ff_sharing({COL_SA{weight_dv_sa}}),
    .i_empty_weight_ff_sharing({COL_SA{weight_empty_sa}}),
    .i_occupants_weight_ff_sharing({COL_SA{weight_occupants_sa}}),
    .i_image_ff_array_data(delay_stage[N_MOD_STAGES-3].delay_reg), //i-wire : from im2col
    .i_image_fifo_array_wren(fifo_image_wren), //i-wire: valid squares signal from im2col
    .o_image_ff_array_almost_empty(sa_image_fifo_almost_empty),
    .o_image_ff_array_almost_full(sa_image_fifo_almost_full),
    
    .i_psum_ff_array_read_en(opsum_rden),
    .p_full_output(p_full_output),
    .o_psum_ff_array_partial_sums(o_psum_ff_array),
    .o_psum_ff_array_empty(empty_sa),
    .o_psum_ff_array_almost_empty(almost_empty_sa),
    .o_psum_ff_array_dv(valid_psum),
    .i_done(iteration_Done),
    .i_layer_done(layer_done),
    .o_mux_sel(), // goes to select sa rden in fifo sharing
    .o_read_en_weight_ff_sharing(weight_read_en_sa) //output: goes to fifo sharing controller
  );

  assign SA_psum_fifo_empty = &(empty_sa);

  generate
    if(!ACC_TOGGLE) begin
      assign opsum_rden = (vector_add_enable)? (|(empty_vector)? 0:psum_rden):psum_rden;
    end
    else begin
      assign opsum_rden = (vector_add_enable)? (&(empty_vector)? 0:psum_rden):psum_rden;
    end
  endgenerate

  //////////////////
  
  op_psum_rden #(
    .N_SA(N_SA),
    .COL (COL_SA),
    .FIFO(ACC_FIFO)
  ) op_psum_rden_inst (
    .clk(i_clk),
    .rst(rst),
    .empty_vector(empty_vector),
    .almost_empty_vector(almost_empty_vector),
    .empty_sa(empty_sa),
    .almost_empty_sa(almost_empty_sa),
    .op_full(op_full),
    .vector_enable(vector_add_enable),
    .opsum_rden(psum_rden)
  );

  
  //////// Adder Tree ///////////////
  wire [N_SA-1:0] valid_SA;
  wire [(N_SA*DATA_WIDTH_OB)-1:0] dataout_SA;
  
  genvar a;
  generate
    if(COL_SA>1) begin
      top_adder_tree_gen #(
        .W_PSUM(W_PSUM),
        .COL(COL_SA), 
        .N_SA(N_SA),
        .NSA_DSP(NSA_DSP),
        .NSA_LUT(NSA_LUT),
        .DATA_WIDTH_OB(DATA_WIDTH_OB)
      ) adder_tree (
        .clk(i_clk),
        .rst(rst),
        .i_psum_ff_array(o_psum_ff_array),
        .valid_in({COL_SA{valid_psum}}),
        .valid_out(valid_SA),
        .result_final(dataout_SA)
      );
    end
    else begin
      localparam EXT = DATA_WIDTH_OB - W_PSUM;
      for(a=0;a<N_SA;a=a+1) begin
        assign dataout_SA[(DATA_WIDTH_OB*(N_SA-a))-1 -: DATA_WIDTH_OB] = 
        {{EXT{o_psum_ff_array[(W_PSUM*(N_SA-a))-1]}}, o_psum_ff_array[(W_PSUM*(N_SA-a))-1 -: W_PSUM]};
      end
      assign valid_SA = valid_psum;
    end
  endgenerate
  
  `ifdef FC
  //Modules for FC layer computation starts here
  wire [DATA_WIDTH-1:0] data_flatten_FC;
  wire dv_flatten_FC;
  wire weight_rden_trigger_FC;
  // Flattening Module
  top_flattening #(
    .W_DATA(DATA_WIDTH),
    .N_BRAM(N_BRAM),
    .N_BANK(N_BANK),
    .W_KERNAL_CNT(W_KERNEL_CNT),
    .W_IMG_DIM(W_FC_IMAG_DIM),
    .W_IMG_BRAM_ADDR(W_FC_RW_COUNTER),
    .IMG_FF_DEPTH(FC_BRAM_DEPTH), //Depth of BRAM
    .SHFT_REG_X(SHFT_REG_X),
    .N_SA(N_SA),
    .DRAM_BW(DRAM_BW)
  )
  top_flattening_inst(
    .clk(i_clk),
    .rstn(rst),
    .flatten(flatten_enable), //input:flatten enable comes from instruction
    .start(start_FC), //input:start for flattening and FC
    .i_acc_valid(FC_done), //i-wire: valid of accumulator output from FC
    .i_addr_counter(i_rw_addr_cnt_flatten), //input: comes from inst. read/write add count for flattening
    .i_kernal_counter(i_kernel_cnt_FC),//input: kernel counter (from FC inst.)
    .i_data_valid(i_data_valid_flatten), //input: datavalid signal for the data coming from DDR
    .i_weight_ff_array_empty(weight_empty_fc),//input: weight empty signal from fifo sharing
    .i_weight_ff_array_almost_empty(weight_almost_empty_fc), //input: weight almost empty signal from fifo sharing
    .i_image_dimension(i_img_dim_flatten), //input: image dimension from FC instruction
    .i_data(i_data_FC),          //input: data coming from DDR
    .o_data_mux(data_flatten_FC),  //o-wire: goes to the data input of FC module
    .o_data_valid(dv_flatten_FC), //o-wire: valid of the data input to FC
    .weight_fifo_array_trigger(weight_rden_trigger_FC), //o-wire: trigger to read weights (goes to rden ctrler of weights in FC)
    .o_done_rden_ctrl(FC_layerdone) //ouput: done signal indicating the finish of FC layer. 
  );
  
  wire [ACC_DW*COL_FC-1:0] FC_accumulator_op_data; // fully connected layer o/p
  wire [COL_FC-1:0] dv_FC_accumulator_data; //datavalid of FC o/p

  // FC Computing Engine
  wire [(ACC_DW*N_FC_MUX)-1:0] op_data_mux_FC;
  wire valid_out_FC;

  wire [(ACC_DW*COL_FC)-1:0] reorder_data_FC;
  wire o_dv_reorder;
  wire [NO_PORT_FC-1:0] sel_FC_op_data_mux; //select signal for the instance FC_op_data_mux
  wire weight_read_en_fc1;

  top_fc#(
    .W_DATA(DATA_WIDTH),
    .COL(COL_FC),
    .ROW(1),
    .W_PSUM(W_PSUM),
    .N_SA(1),
    .W_ACC(ACC_DW),
    .W_IMG_DIM(FC_IMAGE_ROWS_WIDTH), // FC_IMAGEROW_WIDTH
    .W_KERNAL_CNT(W_KERNEL_CNT),
    .WEIGHT_FF_DEPTH(WEIGHT_FIFO_DEPTH),
    .IMAGE_FF_DEPTH(FC_BRAM_DEPTH)
  ) fully_connected_computing_engine(
    .i_clk(i_clk),
    .s_clk(s_clk),
    .i_rstn(rst),
    .i_sel_fifo_sharing_mux(i_sel_fc_fifosharing), //input: from fifo sharing ctrler
    .i_image_data_valid(dv_flatten_FC), //i-wire: dv signal from flatenning
    .i_image_data(data_flatten_FC), //i-wire: from flatenning
    .i_img_dim(i_img_dim_fc), //input: img dim (input rows) of FC layer - from inst.
    .i_weight_rden_trigger(weight_rden_trigger_FC), //i-wire: trigger signal to load weights into FC
    .i_weight_ff_array_data(weight_data_fc), //
    .i_weight_ff_array_dv({COL_FC{&weight_dv_fc}}),
    .i_weight_ff_array_empty(weight_empty_fc),
    .i_weight_ff_array_almost_empty(weight_almost_empty_fc),
    .o_weight_ff_array_rden(weight_read_en_fc1), //output: weight fifo rden, goes to fifo sharing
    .i_weight_ff_array_occ(weight_occupants_fc), //input: weight fifo occupants from fifo sharing
    // .o_image_ff_array_rden(), 
    .i_kernal_count(i_kernel_cnt_FC),
    .accumulator_dv(dv_FC_accumulator_data),
    .accumulator_data(FC_accumulator_op_data)
  );
  assign weight_read_en_fc = {(DRAM_BW/COL_SA){weight_read_en_fc1}};
  assign FC_done = &(dv_FC_accumulator_data);
    
  //Interconnect to pass SA output or FC ouput

  FC_OP_Data_reorder#(
    .ACC_DW(ACC_DW), //data width of accumulator output
    .COL_FC(COL_FC), //number of cols in FC engine
    .ACC_DATA_REORDER(ACC_DATA_REORDER), //param-If '0' pass the data as is and if '1' reorders the data to make it convenient for shift register
    .DRAM_BW(DRAM_BW),
    .N_SA(N_SA),
    .SHFT_REG_X(SHFT_REG_X)
  )
  FC_OP_Data_reorder_inst(
      .clk(i_clk),
      .rst(rst),
      .data_FC(FC_accumulator_op_data), //o-wire: o/p of FC engine - o_data_FC
      .dv_FC(&dv_FC_accumulator_data), //o-wire: datavalid of the o/p data of FC engine
      .reorder_data_FC(reorder_data_FC), //o-wire: reordered data of FC o/p goes to mux and then to interconnect
      .o_dv_reorder(o_dv_reorder) //o-wire: datavalid goes to ctrler that reads the data from mux.
  );

  //FC accumulator sel signal ctrler
  Accumulator_sel_ctrler#(
    .NO_PORT(NO_PORT_FC)
  )
  Accumulator_sel_ctrler_inst(
    .clk(i_clk),
    .rst(rst),
    .valid(o_dv_reorder),
    .sel(sel_FC_op_data_mux),
    .valid_out(valid_out_FC)
  );
  
  //N_FC_MUX number of multiplexers required at o/p of FC to couple it with Tail blocks
  
  genvar i;
  generate
    for(i=0;i<N_FC_MUX;i=i+1) begin
      mux_param#(
        .PORT_SIZE(ACC_DW),   //datawidth of inputs
        .NO_PORT(NO_PORT_FC)    //size of mux ex:NO_PORT=8 then it is 8x1
      ) FC_op_data_mux
      (
        .clk(i_clk),
        .in(reorder_data_FC[(((ACC_DW*NO_PORT_FC)*(N_FC_MUX-i))-1) -: ACC_DW*NO_PORT_FC]),  //datawidth = port_size*no.of ports
        .out(op_data_mux_FC[((ACC_DW*(N_FC_MUX-i))-1) -:ACC_DW]), //datawidth = port_size
        .sel(sel_FC_op_data_mux)
      );
    end
  endgenerate
  `else
  wire [(ACC_DW*N_FC_MUX)-1:0] op_data_mux_FC;
  wire valid_out_FC;

  assign op_data_mux_FC = 0;
  assign valid_out_FC = 0;
  `endif //FC
  
  wire [(N_SA*DATA_WIDTH_OB) -1:0] data_tail_blk_in;
  wire [N_SA-1:0] data_tail_blk_vaild;
  //EltWise Operation
  wire [(DATA_WIDTH_OB*N_SA)-1:0] EltWise_data_out;
  wire [N_SA-1:0] EltWise_data_out_valid;
  wire [QUANT_SHIFT-1:0] EltWise_fp_cast_shift;
  Top_element_wise  #(
    .DATA_WIDTH(DATA_WIDTH),   
    .N(N_SA),          
    .MOD(MOD2),
    .FIFO_NO(ELTWISE_FIFO),       
    .W_ADDR($clog2(ELTWISE_FIFO_DEPTH)),
    .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
    .ELTWISE_SCALE_WIDTH(ELTWISE_SCALE_WIDTH),
    .ELTWISE_ZEROPOINT_WIDTH(ELTWISE_ZEROPOINT_WIDTH),
    .ELTWISE_QUANT_SHIFT(QUANT_SHIFT),
    .DATA_WIDTH_OB(DATA_WIDTH_OB),
    .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
    .ELTWISE_IW_WIDTH(ELTWISE_IW_WIDTH),
    .ELTWISE_IH_WIDTH(ELTWISE_IH_WIDTH),
    .ELTWISE_IC_WIDTH(ELTWISE_IC_WIDTH)
  )top_element_wise(
    .clkin(i_clk),
    .rst(rst),
    .EltWise_op_en(EltWise_op_en), 
    .img_dim_Op(i_img_dim_Op), //input: image dimension of the output
    .LeftOperand_wr_en(LeftOperand_wr_en), //from ddr
    .RightOperand_wr_en(RightOperand_wr_en), //from ddr
    .LeftOperand_data_in(LeftOperand_data_in), //from ddr
    .RightOperand_data_in(RightOperand_data_in), //from ddr
    .EltWise_type(EltWise_type),
    .LeftOperand_Scale(LeftOperand_Scale),
    .LeftOperand_zero_point(LeftOperand_zero_point),
    .RightOperand_Scale(RightOperand_Scale),
    .RightOperand_zero_point(RightOperand_zero_point),
    .EltWise_IW(EltWise_IW),
    .EltWise_IH(EltWise_IH),
    .EltWise_IC(EltWise_IC),
    .EltWise_data_out(EltWise_data_out), //output
    .EltWise_data_out_valid(EltWise_data_out_valid), //output valid
    .LeftOperand_fifo_occupants(LeftOperand_fifo_occupants),
    .RightOperand_fifo_occupants(RightOperand_fifo_occupants),
    .EW_done(EW_done),
    .EltWise_fp_cast_shift(EltWise_fp_cast_shift),
    .op_fifo_empty(op_fifo_empty)
  );

  interconnect #(
    .DATA_WIDTH_OB(DATA_WIDTH_OB),
    .N_SA(N_SA),
    .OPCODE_WIDTH(OPCODE_WIDTH)
  )
  SA_FC_EltWise_interconnect(
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

  wire [(DATA_WIDTH_OB*N_SA) -1:0] output_block_out; // From here onwards COL_SA or N_SA?:Todo
  wire [N_SA-1:0] vector_valid;
  // Vector addition block for addition of psum accumulants
  top_output_block #(
      .DRAM_BW(DRAM_BW),
      .DATA_WIDTH_ACC(DATA_WIDTH_OB),
      .W_ADDR($clog2(ACC_FIFO_DEPTH)), //W_ADDR = $clog2(ACC_FIFO_DEPTH)
      .N(N_SA),
      .COL_SA(COL_SA),
      .TOGGLE(ACC_TOGGLE),
      .FIFO_NO(ACC_FIFO),
      .OUT_DATA_WIDTH(DATA_WIDTH_OB),
      .NO_PORT(NO_PORT_VA),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .OH_WIDTH(OutputBlock_OH_WIDTH),
      .OW_WIDTH(OutputBlock_OW_WIDTH)
  ) vector_addition (
      .top_clk(i_clk),
      .OH(op_height),
      .OW(op_width),
      .i_img_dim_Acc(i_img_dim_Acc),
      .top_wr_en(vector_add_wren), //input: comes from ddr
      .rst(rst),
      .Iteration_Done(iteration_Done), //input: for resetting the acc_fifo_rden_ctrl
      .top_data_in(vector_add_values), // input: comes from ddr
      .w_empty_flag(empty_vector),
      .w_almost_empty_flag(almost_empty_vector),
      .empty_sa(empty_sa),
      .almost_empty_sa(almost_empty_sa),
      .op_full(op_full),
      .top_data_out(output_block_out),
      .top_data_in_adder_tree(data_tail_blk_in), //interconnect data o/p
      .vector_add_enable(vector_add_enable),
      .top_in_data_valid(data_tail_blk_vaild), //interconnect datavalid
      .top_out_data_valid(vector_valid),
      .fifo_occupants(acc_fifo_occupants)
  );

  
  wire [(DATA_WIDTH_OB*N_SA) -1:0] bias_output;
  wire [N_SA-1:0] bias_valid;
  //CONV Bias addition block
  top_bias_block #(
      .DATA_WIDTH(DATA_WIDTH_OB),
      .W_ADDR($clog2(BIAS_FIFO_DEPTH)),
      .N(N_SA),
      .TOGGLE(ACC_TOGGLE),
      .FIFO_NO(BIAS_FIFO),
      .OUT_DATA_WIDTH(DATA_WIDTH_OB),
      .NO_PORT(NO_PORT_BAC)
  ) bias_addition (
      .top_clk(i_clk),
      .top_wr_en(bias_wren), //from ddr
      .rst(rst),
      .CONV_FC(CONV_FC),
      .channel_done(channel_done),
      .top_data_in(bias_data_in), //from ddr
      .top_data_out(bias_output),
      .top_data_in_adder_tree(output_block_out),
      .vector_add_enable(bias_enable), //from iteration cnter
      .top_in_data_valid(vector_valid),
      .w_empty_flag(),
      .top_out_data_valid(bias_valid),
      .fifo_occupants(bias_fifo_occupants)
  );
  
  // Quantization Block Interconnect
  
  wire [QUANT_SHIFT-1:0] fp_cast_shift;
  wire fp_cast;
  quant_interconnect # (
    .SHIFT_WIDTH(QUANT_SHIFT),
    .OPCODE_WIDTH(OPCODE_WIDTH)
  )
  quant_interconnect_inst (
    .opcode(opcode),
    .EltWise_fp_cast_shift(EltWise_fp_cast_shift),
    .fp_cast(fp_cast),
    .fp_cast_shift(fp_cast_shift)
  );

  wire [(DATA_WIDTH*N_SA) -1:0] quantized_output;
  wire [(DATA_WIDTH_OB*N_SA) -1:0] unquantized_output;
  wire [N_SA -1:0] unquantized_valid;
  wire [N_SA-1:0] tail_valid;
  top_quant_gen #(
      .DATA_WIDTH(DATA_WIDTH_OB),
      .SHIFT_WIDTH(QUANT_SHIFT),
      .SCALE_WIDTH(QUANT_SCALE),
      .OUT_DATA_WIDTH(DATA_WIDTH),
      .N(N_SA)
  ) quant (
      .top_i_clk(i_clk),
      .top_i_data_quant(bias_output),
      .top_i_data_scale({N_SA{quant_scale}}), //from tail inst.
      .enable_quant(quant_enable),  //from iteration cnter
      .top_i_fp_cast(fp_cast), //from quant interconnect
      .top_i_fp_cast_shift({N_SA{fp_cast_shift}}), //from quant interconnect
      .top_o_data(quantized_output),
      .quantized_passthrough(unquantized_output),
      .top_i_data_valid(bias_valid),
      .unquantized_valid(unquantized_valid),
      .top_o_data_valid(tail_valid),
      .top_i_bit_shift({N_SA{shift_value}}) //from tail inst.
  );
  
  
  wire [(DATA_WIDTH*N_SA)-1:0] bias_fc_out ;
  wire [N_SA-1:0] bias_fc_valid;

  `ifdef BIAS_FC
  top_bias_fc #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH($clog2(BIAS_FIFO_DEPTH)),
    .DRAM_BW(DRAM_BW),
    .N(N_SA),    
    .FIFO_NO(BIAS_FIFO_FC),
    .OUT_DATA_WIDTH(DATA_WIDTH),
    .NO_PORT(NO_PORT_BAFC)
  ) bias_addition_full_connected (
    .top_clk(i_clk),
    .top_wr_en(bias_wren_fc), //from ddr
    .rst(rst&(~FC_layerdone)),
    .top_data_in(bias_data_in_fc), //from ddr
    .top_data_out(bias_fc_out),
    .top_data_in_adder_tree(quantized_output),
    .vector_add_enable(bias_fc_enable), //from iteration cnter
    .top_in_data_valid(tail_valid),
    .w_empty_flag(),
    .top_out_data_valid(bias_fc_valid),
    .fifo_occupants(fc_bias_fifo_occupants)
  );
  `else
  assign bias_fc_out = quantized_output;
  assign bias_fc_valid = tail_valid;
  `endif //BIAS_FC

  top_relu_gen #(
      .N(N_SA),
      .DATA_WIDTH(DATA_WIDTH),
      .ACT_TYPE_WIDTH(ACT_TYPE_WIDTH),
      .CLIP_WIDTH(RELU_CLIP_WIDTH),
      .LR_NEG_ALPHA_WIDTH(LR_NEG_ALPHA_WIDTH),
      .LR_POS_ALPHA_WIDTH(LR_POS_ALPHA_WIDTH)
  ) relu (
      .top_clk(i_clk),
      .top_i_data(bias_fc_out),
      .top_i_valid(bias_fc_valid),
      .relu_enable(relu_enable), //from iteration cnter
      .top_o_data(relu_output),
      .top_o_valid(relu_valid),
      .top_i_clip({N_SA{relu_clip_value}}), //from tail inst.
      .top_lr_neg_alpha({N_SA{lr_neg_alpha}}), //from tail inst.
      .top_lr_pos_alpha({N_SA{lr_pos_alpha}}), //from tail inst.
      .top_i_acttype({N_SA{relu_act_type}})
  );
  
  /* maxpool_gen #(
      .N_SA(N_SA),
      .DATA_IN(DATA_WIDTH),
      .IMG_WIDTH(W_CONV_OP_IMAGE_DIM)
  ) maxpool (
      .clk(i_clk),
      .data_in(relu_output),
      .rst(rst&(~iteration_Done)),
      .maxpool_enable(maxpool_enable), //from iteration cnter
      .datavalid(relu_valid),
      .IW(maxpool_threshold), //from conv inst.
      .maxvalue_o(maxpool_output),
      .datavalid_o(maxpool_valid)
  );*/
  
  //Total data_size of CONV output. This is calculated to determine number of zeros to be generated by zero padder
  (* syn_use_dsp = "no" *) wire [I_ACC_SIZE_WIDTH-1:0] op_img_size;
  assign op_img_size = op_height * op_width;

  `ifdef POOL
  generalized_pool # (
    .N_SA(N_SA),
    .DATA_WIDTH(DATA_WIDTH),
    .POOL_HEIGHT(POOLHEIGHT_WIDTH), // width of kernal height
    .POOL_WIDTH(POOLWIDTH_WIDTH), // width of kernal width
    .POOLING_TYPE_WIDTH(POOLTYPE_WIDTH), //width of Pooling Type
    .POOLSTRIDE_WIDTH(POOLSTRIDE_WIDTH),
    .POOLPADDING_WIDTH(POOLPADDING_WIDTH),
    .POOLCEIL_WIDTH(POOLCEIL_WIDTH),
    .POOLMODCOUNT_WIDTH(POOLMODCOUNT_WIDTH),
    .POOLPADSIDES_WIDTH(POOLPADSIDES_WIDTH),
    .POOL_SCALE_WIDTH(POOL_SCALE_WIDTH),
    .POOL_SHIFT_WIDTH(POOL_SHIFT_WIDTH),
    .OH_WIDTH(W_CONV_OP_IMAGE_DIM),
    .ADDR_WIDTH(9), //Synchronous Fifo depth
    .OW_WIDTH(W_CONV_OP_IMAGE_DIM)
  )
  generalized_pool_inst (
    .clk(i_clk),
    .din(relu_output),
    .rst_n(rst&(~iteration_Done)),
    .ENABLE(maxpool_enable),
    .datavalid_in(relu_valid),
    .PoolType(PoolType), //3'b001
    .PoolStride(PoolStride),
    .PoolWidth(PoolWidth), //kernal width
    .PoolHeight(PoolHeight), //kernal height
    .PoolPadding(PoolPadding),
    .PoolCeil(PoolCeil),
    .PoolModCount(PoolModCount),
    .PoolPadSides(PoolPadSides),
    .PoolScale(PoolScale),
    .PoolShift(PoolShift),
    .PoolimageSize(op_img_size),
    .OH(op_height),
    .OW(op_width),
    .dout(maxpool_output),
    .done(),
    .datavalid_out(maxpool_valid)
  );

  wire [I_ACC_SIZE_WIDTH-1:0] intermediate_1;
  
  assign intermediate_1 = (maxpool_threshold-PoolModCount) * (maxpool_threshold-PoolModCount);
  assign i_img_dim2 = (CONV_FC)? i_img_dim_Op  : (maxpool_enable? ((PoolType == `POOL_GLOBAL_AVG)? (16'd1) : ((PoolModCount!=0)?intermediate_1:op_img_size)>>2) : op_img_size);
  `else
  assign maxpool_output = relu_output;
  assign maxpool_valid = relu_valid;
  assign i_img_dim2 = (CONV_FC)? i_img_dim_Op : op_img_size;
  `endif //POOL
  
  wire [(DATA_WIDTH_ACC*N_SA)-1 : 0] zp_unquantized_din;
  wire [N_SA-1:0] zp_valid;
  wire [(N_SA*DATA_WIDTH) -1:0] zp_data;
  wire [(DATA_WIDTH_ACC*N_SA) -1:0] zp_unquant_data;
  wire [N_SA -1:0] zp_unquant_dv;

  // For CONV opeartion, consider the conv_op_size for zero padder. For FC operation, consider the size from instruction
  wire [I_ACC_SIZE_WIDTH-1:0] i_img_dim1; // Accumulant data_size
  wire [I_OP_SIZE_WIDTH-1:0] i_img_dim2; // Quantized op data_size


  assign i_img_dim1 = (CONV_FC)? i_img_dim_Acc : op_img_size;

  //zero padding circuit
  top_zero # (
    .DW(DATA_WIDTH),
    .COL(N_SA),
    .I_SIZE_WIDTH(I_OP_SIZE_WIDTH), //width of image dimension
    .MOD(MOD2)
  )
  zp_quant (
    .clk(i_clk),
    .rst(rst),
    .i_size(i_img_dim2), // image dimension of quantized o/p (from op block inst.)
    .data_in(maxpool_output),
    .i_dv(maxpool_valid),
    .data_out(zp_data),
    .o_dv(zp_valid)
  );
  
  localparam REMOVE = DATA_WIDTH_OB - DATA_WIDTH_ACC;
  
  genvar j;
  generate
    for(j=0;j<N_SA;j=j+1) begin
      assign zp_unquantized_din[((DATA_WIDTH_ACC*(N_SA-j))-1) -: DATA_WIDTH_ACC] = 
      unquantized_output[((DATA_WIDTH_OB*(N_SA-j)-REMOVE)-1) -: DATA_WIDTH_ACC];
    end
  endgenerate

  top_zero # (
    .DW(DATA_WIDTH_ACC),
    .COL(N_SA),
    .I_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
    .MOD(MOD1)
  )
  zp_unquant(
    .clk(i_clk),
    .rst(rst),
    .i_size(i_img_dim1), // image dimension of accumlant o/p (from op block inst.)
    .data_in(zp_unquantized_din),
    .i_dv(unquantized_valid),
    .data_out(zp_unquant_data),
    .o_dv(zp_unquant_dv)
  );

  
  //Tail_done signal generation logic
  Tail_done_gen #(
      .N(N_SA),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
      .OPCODE_WIDTH(OPCODE_WIDTH)
  ) tail_done_inst(
      .i_clk(i_clk),
      .rst(rst),
      .opcode(opcode),
      .datavalid_acc(zp_unquant_dv),
      .datavalid_pool(zp_valid),
      .quant_en(quant_enable),
      .img_dim_Acc(i_img_dim_Acc),
      .img_dim_Op(i_img_dim_Op),
      .Tail_done(Tail_done)
  );
  
  /*Quantized output write logic - only qunatized output is passed through shift register
    whereas accumulant output is passed through demux separately
  */
  generate_shift_register #( 
      .N(N_SA),
      .NUM_SHIFT(SHFT_REG_X),
      .QUANT_DATA_WIDTH(DATA_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) shift_register_x (
      .quantized_result_in(zp_data),
      .valid_quantized_result(zp_valid),
      .clk(i_clk),
      .rst(rst&(~channel_done)),
      .valid_out_final(x_final_valid),
      .data_out(x_final_data)
  );

  assign quant_op_write_data = x_final_data;
  assign quant_op_wren = (&(x_final_valid)) ? {QUANT_OP_FIFO{1'b1}} : 0;

  // Accumulant output write logic
  localparam DMUX_SEL_WIDTH = (N_DMUX_PORTS > 1)? $clog2(N_DMUX_PORTS) : 1;
  wire [DMUX_SEL_WIDTH-1 : 0] sel_dmx;
  wire [(N_DMUX_PORTS)-1 : 0] acc_op_write_datavalid;

  generate
    if(N_DMUX_PORTS>1) begin
      demux_controller_sel_op # (
        .COL(1),
        .NUM_PORTS(N_DMUX_PORTS),
        .OP_FIFO_WRITE(ACC_OP_FIFO)
      )
      demux_sel_ctr (
        .rst(rst&(~iteration_Done)),
        .clk(i_clk),
        .data_valid(&(zp_unquant_dv)),
        .op_wren(acc_op_wren),
        .sel(sel_dmx)
      );
    end
    else begin
      assign acc_op_wren = (&(zp_unquant_dv))? {ACC_OP_FIFO{1'b1}} : {ACC_OP_FIFO{1'b0}};
      assign sel_dmx     = 0;
    end
  endgenerate  
  
  
  Dmux_param #(
    .NUM_PORTS(N_DMUX_PORTS),
    .DATA_WIDTH(N_SA*DATA_WIDTH_ACC),
    .COL_SA(1)
  )
  dmux_param_inst(
    .i_din(zp_unquant_data),
    .i_datavalid(&(zp_unquant_dv)),
    .i_sel(sel_dmx),
    .o_dout(acc_op_write_data),
    .o_datavalid(acc_op_write_datavalid)
  );
  
endmodule
