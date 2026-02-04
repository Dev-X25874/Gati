`include "./common/arch_param.vh"

module top_tailblock #(
  parameter OPCODE_WIDTH = 4,
  parameter N_SA = 4, 
  parameter DATA_WIDTH_OB = 32, // DW for vector add and bias blocks
  parameter DRAM_BW = 32,
  parameter ACC_FIFO_DEPTH = 512,
  parameter COL_SA = 4,
  parameter ACC_TOGGLE = 1,
  parameter ACC_FIFO = 8, // Number of accumulant FIFOs
  parameter NO_PORT_VA=2,
  parameter I_ACC_SIZE_WIDTH = 16, 
  parameter OutputBlock_OH_WIDTH = 10, 
  parameter OutputBlock_OW_WIDTH = 10, 
  parameter BIAS_FIFO_DEPTH = 512,
  parameter BIAS_FIFO = 8, // Number of Bias FIFOs
  parameter NO_PORT_BAC=2,
  parameter QUANT_SHIFT = 8,
  parameter DATA_WIDTH = 8,
  parameter QUANT_SCALE = 16,
  parameter BIAS_FIFO_FC=32, // Number of FC_bias FIFOs
  parameter NO_PORT_BAFC=8,
  parameter ACT_TYPE_WIDTH = 4,
  parameter RELU_CLIP_WIDTH = 8,
  parameter LR_NEG_ALPHA_WIDTH = 10,
  parameter LR_POS_ALPHA_WIDTH = 10,
  parameter POOLTYPE_WIDTH = 3,  
  
  `ifdef GLOBAL_POOL 
  parameter GBL_POOL_SCALE_WIDTH = 4,
  parameter GBL_POOL_SHIFT_WIDTH = 4,
  `endif

  `ifdef POOL
  parameter POOLWIDTH_WIDTH = 4,
  parameter POOLHEIGHT_WIDTH = 4,
  parameter POOLSTRIDE_WIDTH = 4,
  parameter POOLPAD_WIDTH = 4,
  parameter POOLCEIL_WIDTH = 4,
  parameter POOLMODCOUNT_WIDTH = 4,
  parameter POOLPADSIDES_WIDTH = 4,
  parameter POOL_SCALE_WIDTH = 4,
  parameter POOL_SHIFT_WIDTH = 4,
  `endif 

  parameter W_CONV_OP_IMAGE_DIM = 10,
  parameter DATA_WIDTH_ACC = 32, //data width of intermediate accumulants (SA)
  parameter I_OP_SIZE_WIDTH = 16,
  parameter MOD2 = DRAM_BW/N_SA,
  parameter MOD1 = 2,
  parameter SHFT_REG_X = DRAM_BW/N_SA,
  parameter QUANT_OP_FIFO = 1, // Number of quantized o/p fifos
  parameter ACC_DW = 32,
  parameter AXI_DATA_WIDTH = 256,
  parameter N_DMUX_PORTS = DRAM_BW/(N_SA*(ACC_DW/8)),
  parameter ACC_OP_FIFO = 2 // Number of accumulant o/p fifos
) (
  input i_clk,
  input rst,

  input [(N_SA*DATA_WIDTH_OB) -1:0] data_tail_blk_in,
  input [N_SA-1:0] data_tail_blk_vaild,

  // Vector Addition 
  input iteration_Done,
  input [(ACC_FIFO*DATA_WIDTH_ACC)-1:0] vector_add_values,
  input op_full,
  input sa_stall,

  input [I_ACC_SIZE_WIDTH-1:0] i_img_dim_Acc,
  input [ACC_FIFO-1:0] vector_add_wren,

  input [OutputBlock_OW_WIDTH-1 : 0] op_width,
  input [OutputBlock_OH_WIDTH-1 : 0] op_height,
  input vector_add_enable,

  output [(($clog2(ACC_FIFO_DEPTH)+1)*ACC_FIFO)-1:0] acc_fifo_occupants,

  // Bias Block 
  input [BIAS_FIFO -1:0] bias_wren,
  input CONV_FC,
  input channel_done,
  input [(BIAS_FIFO*DATA_WIDTH_OB)-1:0] bias_data_in,
  input bias_enable,
  output [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO)-1:0] bias_fifo_occupants,

  // From quant interconnect top_gati
  input [QUANT_SHIFT-1:0] fp_cast_shift,
  input fp_cast,

  // Quant Gen 
  input [(QUANT_SCALE)-1:0] quant_scale,
  input quant_enable,
  input [(QUANT_SHIFT) -1:0] shift_value,

  `ifdef BIAS_FC
  //bias_fc signals
  input bias_fc_enable,
  input [(BIAS_FIFO_FC*DATA_WIDTH)-1:0] bias_data_in_fc,
  input [BIAS_FIFO_FC -1:0] bias_wren_fc,
  output [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO_FC)-1:0] fc_bias_fifo_occupants,
  `endif //BIAS_FC


  // ReLU 
  input relu_enable,
  input [(RELU_CLIP_WIDTH)-1:0] relu_clip_value,
  input [ACT_TYPE_WIDTH-1:0] relu_act_type,
  input [LR_NEG_ALPHA_WIDTH-1:0] lr_neg_alpha,
  input [LR_POS_ALPHA_WIDTH-1:0] lr_pos_alpha,

  // signals for resize block 
  `ifdef RESIZE
  input [N_SA-1:0] resize_valid,
  input [N_SA*DATA_WIDTH-1:0] resize_op,
  `endif

  `ifdef POOL
  input maxpool_enable,
  input [POOLTYPE_WIDTH - 1 : 0] PoolType,
  input [POOLWIDTH_WIDTH - 1 : 0] PoolWidth,
  input [POOLHEIGHT_WIDTH - 1 : 0] PoolHeight,
  input [POOLSTRIDE_WIDTH - 1 : 0] PoolStride,
  input [POOLPAD_WIDTH - 1 : 0] PoolPadding,
  input [POOLCEIL_WIDTH - 1 : 0] PoolCeil,
  input [POOLMODCOUNT_WIDTH - 1 : 0] PoolModCount,
  input [POOLPADSIDES_WIDTH - 1 : 0] PoolPadSides,
  input [POOL_SCALE_WIDTH - 1 : 0] PoolScale,
  input [POOL_SHIFT_WIDTH - 1 : 0] PoolShift,
  `endif
  
  `ifdef GLOBAL_POOL
  input maxpool_enable, 
  input [GBL_POOL_SCALE_WIDTH-1:0] gbl_pool_scale,
  input [GBL_POOL_SHIFT_WIDTH-1:0] gbl_pool_shift,
  `endif

  `ifdef MEGA_POOL
  input [N_SA-1:0] pool_o_datavalid,
  input [(N_SA*DATA_WIDTH) -1:0] pool_o_data,
  `endif

  `ifdef FC
  input FC_layerdone,
  `endif

  `ifdef CONCAT
  input  [AXI_DATA_WIDTH-1:0] o_concat_data,
  input                       o_concat_dv,
  `endif // CONCAT

  input [OPCODE_WIDTH-1:0] opcode,
  input [I_OP_SIZE_WIDTH-1:0] i_img_dim_Op,
  input [(N_SA)-1:0] empty_sa, 
  input [(N_SA)-1:0] almost_empty_sa,

  input [I_ACC_SIZE_WIDTH-1:0] op_img_size,

  output [ACC_FIFO-1:0] empty_vector, 
  output [ACC_FIFO-1:0] almost_empty_vector,
  output Tail_done,
  output [(DATA_WIDTH*N_SA*SHFT_REG_X*(QUANT_OP_FIFO)) -1:0] quant_op_write_data,
  output [QUANT_OP_FIFO-1:0] quant_op_wren,
  output [ACC_OP_FIFO-1:0] acc_op_wren,
  output [ACC_OP_DATAWIDTH -1:0] acc_op_write_data
);

  localparam ACC_OP_DATAWIDTH = ((N_SA*DATA_WIDTH_ACC) < (DRAM_BW*DATA_WIDTH)) ? (N_SA*DATA_WIDTH_ACC*ACC_OP_FIFO) : (N_SA*DATA_WIDTH_ACC);

  wire [(DATA_WIDTH_OB*N_SA) -1:0] output_block_out; 
  wire [N_SA-1:0] vector_valid;

  // Vector Addition - Addition of PSUM accumulants
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
      .empty_sa(empty_sa),
      .almost_empty_sa(almost_empty_sa),
      .op_full(op_full),
      .sa_stall(sa_stall),
      .top_data_in_adder_tree(data_tail_blk_in), //interconnect data o/p
      .vector_add_enable(vector_add_enable),
      .top_in_data_valid(data_tail_blk_vaild), //interconnect datavalid

      .w_empty_flag(empty_vector), // MANTRA output
      .w_almost_empty_flag(almost_empty_vector), // MANTRA output
      .top_data_out(output_block_out), // MANTRA output
      .top_out_data_valid(vector_valid), // MANTRA output
      .fifo_occupants(acc_fifo_occupants) // MANTRA output
  );


  wire [(DATA_WIDTH_OB*N_SA) -1:0] bias_output;
  wire [N_SA-1:0] bias_valid;

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
      .top_data_in_adder_tree(output_block_out),
      .vector_add_enable(bias_enable), //from iteration cnter
      .top_in_data_valid(vector_valid),

      .top_data_out(bias_output), // MANTRA output
      .w_empty_flag(), // MANTRA output
      .top_out_data_valid(bias_valid), // MANTRA output
      .fifo_occupants(bias_fifo_occupants) // MANTRA output
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
      .top_i_data_valid(bias_valid),
      .top_i_bit_shift({N_SA{shift_value}}), //from tail inst.

      .top_o_data(quantized_output),
      .quantized_passthrough(unquantized_output),
      .top_o_data_valid(tail_valid),
      .unquantized_valid(unquantized_valid)
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
      .top_data_in_adder_tree(quantized_output),
      .vector_add_enable(bias_fc_enable), //from iteration cnter
      .top_in_data_valid(tail_valid),

      .w_empty_flag(),
      .top_data_out(bias_fc_out),
      .top_out_data_valid(bias_fc_valid),
      .fifo_occupants(fc_bias_fifo_occupants)
  );
  `else
  assign bias_fc_out = quantized_output;
  assign bias_fc_valid = tail_valid;
  `endif //BIAS_FC


  wire [N_SA -1:0] relu_valid;
  wire [(N_SA*DATA_WIDTH) -1:0] relu_output;

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
      .top_i_clip({N_SA{relu_clip_value}}), //from tail inst.
      .top_lr_neg_alpha({N_SA{lr_neg_alpha}}), //from tail inst.
      .top_lr_pos_alpha({N_SA{lr_pos_alpha}}), //from tail inst.
      .top_i_acttype({N_SA{relu_act_type}}),

      .top_o_data(relu_output),
      .top_o_valid(relu_valid)
  );


  /*
  For CONV opeartion, consider the conv_op_size for zero padder. 
  For FC operation, consider the size from instruction.
  */

  wire [I_ACC_SIZE_WIDTH-1:0] i_img_dim1; // Accumulant data_size
  wire [I_OP_SIZE_WIDTH-1:0] i_img_dim2; // Quantized op data_size

  assign i_img_dim1 = (CONV_FC)? i_img_dim_Acc : op_img_size;

  wire [(N_SA*DATA_WIDTH) -1:0] zp_quant_in;
  wire [N_SA -1:0] zp_quant_valid_in;

  wire [N_SA-1:0] maxpool_valid;
  wire [(N_SA*DATA_WIDTH) -1:0] maxpool_output;

  `ifdef MEGA_POOL 
    `ifdef GLOBAL_POOL
      global_avg_pool_gen #(
          .N_SA(N_SA),
          .DATA_WIDTH(DATA_WIDTH),
          .POOLING_TYPE_WIDTH(POOLTYPE_WIDTH),
          .POOL_SCALE_WIDTH(GBL_POOL_SCALE_WIDTH),
          .POOL_SHIFT_WIDTH(GBL_POOL_SHIFT_WIDTH),
          .OH_WIDTH(W_CONV_OP_IMAGE_DIM),
          .OW_WIDTH(W_CONV_OP_IMAGE_DIM)
      ) global_avg_pool_gen_inst (
          .clk(i_clk),
          .rst_n(rst&(~iteration_Done)),
          .ENABLE(maxpool_enable), 
          .din(relu_output), 
          .datavalid_in(relu_valid), 
          .PoolType('h02),  
          .PoolScale(gbl_pool_scale), 
          .PoolShift(gbl_pool_shift),   
          .PoolimageSize(op_img_size), 
          .dout(maxpool_output), 
          .datavalid_out(maxpool_valid)
      );

      assign zp_quant_in = (opcode == `OP_POOL) ? pool_o_data : maxpool_output;
      assign zp_quant_valid_in = (opcode == `OP_POOL) ? pool_o_datavalid : maxpool_valid;

      assign i_img_dim2 = (CONV_FC)? i_img_dim_Op : (maxpool_enable? (16'd1) : op_img_size);
    `else
      assign zp_quant_in = (opcode == `OP_POOL) ? pool_o_data : relu_output;
      assign zp_quant_valid_in = (opcode == `OP_POOL) ? pool_o_datavalid : relu_valid;

      assign i_img_dim2 = (CONV_FC)? i_img_dim_Op : op_img_size;
    `endif
  `else
    `ifdef POOL
      generalized_pool # (
          .N_SA(N_SA),
          .DATA_WIDTH(DATA_WIDTH),
          .POOL_HEIGHT(POOLHEIGHT_WIDTH), // width of kernal height
          .POOL_WIDTH(POOLWIDTH_WIDTH), // width of kernal width
          .POOLING_TYPE_WIDTH(POOLTYPE_WIDTH), //width of Pooling Type
          .POOL_SCALE_WIDTH(POOL_SCALE_WIDTH),
          .POOL_SHIFT_WIDTH(POOL_SHIFT_WIDTH),
          .OH_WIDTH(W_CONV_OP_IMAGE_DIM),
          .ADDR_WIDTH(9), //Synchronous Fifo depth
          .OW_WIDTH(W_CONV_OP_IMAGE_DIM)
      ) generalized_pool_inst (
          .clk(i_clk),
          .din(relu_output),
          .rst_n(rst&(~iteration_Done)),
          .ENABLE(maxpool_enable),
          .datavalid_in(relu_valid),
          .PoolType('h02), // Hardcoded for GblAvgPool
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

      assign zp_quant_in = maxpool_output;
      assign zp_quant_valid_in = maxpool_valid;
    `elsif GLOBAL_POOL
      global_avg_pool_gen #(
          .N_SA(N_SA),
          .DATA_WIDTH(DATA_WIDTH),
          .POOLING_TYPE_WIDTH(POOLTYPE_WIDTH),
          .POOL_SCALE_WIDTH(GBL_POOL_SCALE_WIDTH),
          .POOL_SHIFT_WIDTH(GBL_POOL_SHIFT_WIDTH),
          .OH_WIDTH(W_CONV_OP_IMAGE_DIM),
          .OW_WIDTH(W_CONV_OP_IMAGE_DIM)
      ) global_avg_pool_gen_inst (
          .clk(i_clk),
          .rst_n(rst&(~iteration_Done)),
          .ENABLE(maxpool_enable), 
          .din(relu_output), 
          .datavalid_in(relu_valid), 
          .PoolType('h02),  
          .PoolScale(gbl_pool_scale), 
          .PoolShift(gbl_pool_shift),   
          .PoolimageSize(op_img_size), 
          .dout(maxpool_output), 
          .datavalid_out(maxpool_valid)
      );

      assign zp_quant_in = maxpool_output;
      assign zp_quant_valid_in = maxpool_valid;

      assign i_img_dim2 = (CONV_FC)? i_img_dim_Op : (maxpool_enable? (16'd1) : op_img_size);
    `else
      assign zp_quant_in = relu_output;
      assign zp_quant_valid_in = relu_valid;

      assign i_img_dim2 = (CONV_FC)? i_img_dim_Op : op_img_size;
    `endif
  `endif


  wire [(DATA_WIDTH_ACC*N_SA)-1 : 0] zp_unquantized_din;
  wire [N_SA-1:0] zp_valid;
  wire [(N_SA*DATA_WIDTH) -1:0] zp_data;
  wire [(DATA_WIDTH_ACC*N_SA) -1:0] zp_unquant_data;
  wire [N_SA -1:0] zp_unquant_dv;

   wire [(N_SA*DATA_WIDTH) -1:0] zp_quant_in_mux;
  wire [N_SA -1:0] zp_quant_valid_in_mux; 
 
 
  `ifdef RESIZE
    assign zp_quant_in_mux       = (opcode == `OP_RESIZE) ? resize_op    : zp_quant_in;
    assign zp_quant_valid_in_mux = (opcode == `OP_RESIZE) ? resize_valid : zp_quant_valid_in;
  `else 
    assign zp_quant_in_mux       = zp_quant_in;
    assign zp_quant_valid_in_mux = zp_quant_valid_in;
  `endif

  // Zero Padding
  // QUANT
  top_zero # (
      .DW(DATA_WIDTH),
      .COL(N_SA),
      .I_SIZE_WIDTH(I_OP_SIZE_WIDTH), //width of image dimension
      .MOD(MOD2)
  ) zp_quant (
      .clk(i_clk),
      .rst(rst),
      .i_size(i_img_dim2), // image dimension of quantized o/p (from op block inst.)
      .data_in(zp_quant_in_mux), //maxpool_output
      .i_dv(zp_quant_valid_in_mux), //maxpool_valid
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


  // UNQUANT
  top_zero # (
      .DW(DATA_WIDTH_ACC),
      .COL(N_SA),
      .I_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .MOD(MOD1)
  ) zp_unquant(
      .clk(i_clk),
      .rst(rst),
      .i_size(i_img_dim1), // image dimension of accumlant o/p (from op block inst.)
      .data_in(zp_unquantized_din),
      .i_dv(unquantized_valid),
      .data_out(zp_unquant_data),
      .o_dv(zp_unquant_dv)
  );


  // Tail_done signal generation logic
  Tail_done_gen #(
      .N(N_SA),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH),
      .OPCODE_WIDTH(OPCODE_WIDTH)
  ) tail_done_gen_inst (
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
  

  /*
  Quantized output write logic - only qunatized output is passed through shift register whereas accumulant output is passed through demux separately.
  */

  wire [(N_SA*(SHFT_REG_X*DATA_WIDTH)) -1:0] x_final_data;
  wire [N_SA-1:0] x_final_valid;

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


  `ifdef CONCAT
  assign quant_op_write_data = (opcode == `OP_CONCAT) ? o_concat_data : x_final_data;
  assign quant_op_wren = (opcode == `OP_CONCAT) ? {QUANT_OP_FIFO{o_concat_dv}} : ((&(x_final_valid)) ? {QUANT_OP_FIFO{1'b1}} : 0);
  `else 
  assign quant_op_write_data = x_final_data;
  assign quant_op_wren = (&(x_final_valid)) ? {QUANT_OP_FIFO{1'b1}} : 0;
  `endif // CONCAT

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
      ) demux_sel_ctr (
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
  ) dmux_param_inst(
      .i_din(zp_unquant_data),
      .i_datavalid(&(zp_unquant_dv)),
      .i_sel(sel_dmx),
      .o_dout(acc_op_write_data),
      .o_datavalid(acc_op_write_datavalid)
  );


endmodule