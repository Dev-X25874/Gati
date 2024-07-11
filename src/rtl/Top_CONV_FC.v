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
    parameter MOD1=2,
    parameter MOD2 = 8,
    parameter DATA_WIDTH_OB = 32, //data width for vector add and bias blocks
    parameter DATA_WIDTH_ACC = 16, //data width of intermediate accumulants(SA)
    // parameter IMAGE_DIM = 224,
    parameter W_CONV_IMAGE_DIM = 10,
    parameter W_CONV_OP_IMAGE_DIM = 10,
    parameter SHFT_REG_X = 4,
    parameter BIAS_FIFO = 8, // Number of bias fifos
    parameter OP_FIFO = 8, // Number of o/p fifos
    parameter ACC_FIFO = 8, // Number of accumulant fifos
    parameter WEIGHT_FIFO_DEPTH = 512,
    parameter IM2COL_FIFO_DEPTH = 1024,
    parameter PSUM_FIFO_DEPTH = 8192,
    parameter ACC_FIFO_DEPTH = 512,
    parameter BIAS_FIFO_DEPTH = 512,
    parameter NSA_DSP = 4,
    parameter N_FC_MUX = 4,
    parameter NO_PORT_FC = 8,
    parameter RELU_CLIP_WIDTH = 8,
    parameter NSA_LUT = 0,
    parameter BIAS_FIFO_FC=32, // Number of FC_bias fifos
    parameter NO_PORT_VA=2,
    parameter NO_PORT_BAC=2,
    parameter NO_PORT_BAFC=8,
    parameter POP_THRESHOLD=5	,
    // parameter I_SIZE_WIDTH=20, // input image data width
    parameter I_ACC_SIZE_WIDTH = 16, 
    parameter I_OP_SIZE_WIDTH = 16,
    parameter N_DMUX_PORTS = 2,
    //FC realated parameters
    parameter FC_IMAGE_ROWS_WIDTH = 16,
    parameter ACC_DW = 32,
    parameter N_BANK = 4,
    parameter N_BRAM = 8,
    parameter W_FC_RW_COUNTER = 10, // width of r/w address counter
    parameter FC_BRAM_DEPTH = 1024,
    parameter W_KERNEL_CNT = 16,
    parameter W_FC_IMAG_DIM = 20,
    parameter ACC_DATA_REORDER = 1 //parameter to specify FC o/p data reordering is required or not
) (

   
    input i_clk,
    input s_clk,
    input rst,
    input [DRAM_BW-1:0] image_fifo_empty,
    input CONV_FC,
    // input switch_enable,
//	input CONV_FC,  
	input [(DRAM_BW*DATA_WIDTH) -1:0] fifo_o, //Data from DRAM Image FIFO to im2col buffers and then to SA engines

    //weight fifo sharing signals
    output sel_sa_rden,
    output [COL_FC-1 : 0] weight_read_en_fc,
    input [(COL_FC * ($clog2(WEIGHT_FIFO_DEPTH) + 1))-1 : 0] weight_occupants_fc,
    input [COL_FC-1 : 0] weight_empty_fc,
    input [COL_FC-1 : 0] weight_dv_fc,
    input [(COL_FC * DATA_WIDTH)-1 : 0] weight_data_fc,
    
    output [(N_SA * COL_SA)-1 : 0] weight_read_en_sa,
    input [(N_SA * COL_SA)-1 : 0] weight_dv_sa,
    input [(N_SA * (COL_SA * ($clog2(WEIGHT_FIFO_DEPTH) + 1)))-1 : 0] weight_occupants_sa,
    input [(N_SA * COL_SA)-1 : 0] weight_empty_sa,
    input [(N_SA * COL_SA * DATA_WIDTH)-1 : 0] weight_data_sa,
    
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

    //vector addition signals
    input [(ACC_FIFO*DATA_WIDTH_ACC)-1:0] vector_add_values,
    input [ACC_FIFO-1:0] vector_add_wren,
    
    input [W_CONV_OP_IMAGE_DIM-1:0] maxpool_threshold, //CONV output (OW) width
    input layer_done,
    input iteration_Done,
    input channel_done,
    input [SHFT_REG_X-1:0] shift_reg_sel,
    input systolic_array_trigger,
    input [(RELU_CLIP_WIDTH)-1:0] relu_clip_value,
    input bias_enable,
    input quant_enable,
    input bias_fc_enable,
    input zero_pad_enable,
    
    //im2col signals
    input [W_CONV_IMAGE_DIM-1:0] image_size,
    input valid_img_size_im2col,
    input im2col_global_start,
    output [DRAM_BW-1:0] image_rden,

    //tail block signals
    input relu_enable,
    input [(BIAS_FIFO*DATA_WIDTH_OB)-1:0] bias_data_in,
    input [BIAS_FIFO -1:0] bias_wren,
    input [(BIAS_FIFO_FC*DATA_WIDTH)-1:0] bias_data_in_fc,
    input [BIAS_FIFO_FC -1:0] bias_wren_fc,
    input [(QUANT_SHIFT) -1:0] shift_value,
    input [(QUANT_SCALE)-1:0] quant_scale,
    input vector_add_enable,
    input maxpool_enable,
    input [I_ACC_SIZE_WIDTH-1:0] i_img_dim_Acc,
    input [I_OP_SIZE_WIDTH-1:0] i_img_dim_Op,
    
    // output write signals
    output [(DATA_WIDTH_ACC*(OP_FIFO)) -1:0] op_write_dmux_data,
    // output [(COL_SA*(SHFT_REG_X*8)) -1:0] data_b,
    // output [(COL_SA*(SHFT_REG_X*8)) -1:0] data_c,
    output [OP_FIFO-1:0] op_wren,

    //operator status signals
    output im2col_done,
    output SA_psum_fifo_empty,
    output Tail_done,
    output FC_done, //accumulator valid signal of FC computing engine
    output FC_layerdone,

    //FIFO status signals for memory request controllers
    output [(($clog2(ACC_FIFO_DEPTH)+1)*ACC_FIFO)-1:0] acc_fifo_occupants,
    output [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO)-1:0] bias_fifo_occupants,
    output [(($clog2(BIAS_FIFO_DEPTH)+1)*BIAS_FIFO_FC)-1:0] fc_bias_fifo_occupants

);

  localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;
 	wire [COL_SA -1:0] relu_valid;
	wire [(COL_SA*DATA_WIDTH) -1:0] relu_output;

  wire read_buf_data;
  wire [(N_SA*DATA_WIDTH) -1:0] buff_out;

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
    .rst(rst),
    .fifo_empty(image_fifo_empty),
    .count(element_poped),
    .rden(image_rden)
  );
    
  //Data buffers
  top_buffer #(
      .BUFFER_SIZE(8),
      .N_SA(N_SA),
      .DRAM_BW(32)
  ) buffers (
      .clk(i_clk),
      .rst(rst&(~im2col_done)),
      .data_in(fifo_o),
      .data_signal(read_buf_data),
      .data_out(buff_out),
      .elements_poped(element_poped)
  );

  wire [(DATA_WIDTH*N_SA) -1:0] mux_out;
  wire [ROW-1:0] o_valid_squares;


  reg  sel_mux;
  wire im2col_o_valid;
  wire [DATA_WIDTH -1:0] im2col_o_data;
  
  always @(*) begin
	   sel_mux = ((im2col_o_valid == 1'b1) && (im2col_o_data == 8'd0)) ? 1'b1 : 1'b0;
  end
  wire [COL_SA-1:0] maxpool_valid;
  wire [(COL_SA*DATA_WIDTH) -1:0] maxpool_output;
  wire  [(COL_SA*(SHFT_REG_X*DATA_WIDTH)) -1:0] x_final_data;

  wire [COL_SA-1:0] x_final_valid;



  wire [(N_SA*ROW) -1:0] fifo_image_wren;
  assign fifo_image_wren = {N_SA{o_valid_squares}};

  top_mux #(
      .N_SA(N_SA),
      .INPUT_SIZE(DATA_WIDTH)
  ) mux (
      .clk(i_clk),
      .sel(sel_mux),
      .data_a(buff_out),
      .out_mux(mux_out)
  );
  
  localparam IMAGE_DIM = (2**W_CONV_IMAGE_DIM);

  //im2col block
  top_im2col #(
      .UPPER_BOUND (IMAGE_DIM),
      .DATA_WIDTH  (DATA_WIDTH),
      .LOWER_BOUND (1),
      .MAX_VALID_SQ(ROW)
  ) im2col (
      .i_valid_mat_size(valid_img_size_im2col),
      .i_start_im2col_top(im2col_global_start),
      .i_im2col_data(8'hff),
      .i_clk(i_clk),
      .i_rstn(rst),
      .o_im2col_data(im2col_o_data),
      .o_valid_squares(o_valid_squares),
      .o_row1(),
      .o_row2(),
      .o_row3(),
      .o_row4(),
      .o_row5(),
      .o_row6(),
      .o_row7(),
      .o_row8(),
      .o_row9(),
      .i_mat_size(image_size),
      .i_zero_pad(zero_pad_enable),
      .o_valid_data(im2col_o_valid),
      .o_valid_buff(read_buf_data), //read signal to im2col buffers
      .i_valid_data(1'b1),
      .im2col_done(im2col_done)
  );

  //parameters will change for top_SA (for CONV opeartion)
  wire [OP_FIFO-1:0] empty_vector;
  wire [(N_SA*COL_SA)-1:0] empty_sa;
  wire [(N_SA*COL_SA)-1:0] opsum_rden;

  wire [(COL_SA*W_PSUM)*N_SA-1:0] o_psum_ff_array;
  wire [COL_SA*N_SA-1:0] valid_psum;

  top_sa #(
      .N_SA(N_SA),
      .W_DATA(DATA_WIDTH),
      .COL(COL_SA),
      .ROW(ROW),
      .W_PSUM(W_PSUM),
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
      .i_trigger_1(systolic_array_trigger), //start for CONV operation
      .i_data_weight_ff_sharing(weight_data_sa),
      .i_dv_weight_ff_sharing(weight_dv_sa),
      .i_empty_weight_ff_sharing(weight_empty_sa),
      .i_occupants_weight_ff_sharing(weight_occupants_sa),
      .i_image_ff_array_data(mux_out), //i-wire : from im2col
      .i_image_fifo_array_wren(fifo_image_wren), //i-wire: valid squares signal from im2col
      .i_psum_ff_array_read_en(opsum_rden),
      .o_psum_ff_array_partial_sums(o_psum_ff_array),
      .o_psum_ff_array_empty(empty_sa),
      .o_psum_ff_array_dv(valid_psum),
      .i_done(iteration_Done),
      .i_layer_done(layer_done),
      .o_mux_sel(sel_sa_rden), // goes to select sa rden in fifo sharing
      .o_read_en_weight_ff_sharing(weight_read_en_sa) //output: goes to fifo sharing controller
  );

  assign SA_psum_fifo_empty = &(empty_sa);
  //////////////////
  
  op_psum_rden #(
      .N_SA(N_SA),
      .COL (COL_SA),
      .FIFO(OP_FIFO)
  ) op_psum_rden_inst (
      .clk(i_clk),
      .empty_vector(empty_vector),
      .empty_sa(empty_sa),
      .vector_enable(vector_add_enable),
      .opsum_rden(opsum_rden)
  );

  

  //////////////////
  
  
  /// Adder Tree
  wire [COL_SA-1:0] valid_tree;
  wire [(COL_SA*DATA_WIDTH_OB)-1:0] result_tree;
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
      .o_psum_ff_array(o_psum_ff_array),
      .valid_in(valid_psum),
      .valid_out(valid_tree),
      .result_final(result_tree)
  );
 
  
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
    .IMG_FF_DEPTH(FC_BRAM_DEPTH) //Depth of BRAM
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
    .i_image_dimension(i_img_dim_flatten), //input: image dimension from FC instruction
    .i_data(i_data_FC),          //input: data coming from DDR
    .o_data_mux(data_flatten_FC),  //o-wire: goes to the data input of FC module
    .o_data_valid(dv_flatten_FC), //o-wire: valid of the data input to FC
    .weight_fifo_array_trigger(weight_rden_trigger_FC), //o-wire: trigger to read weights (goes to rden ctrler of weights in FC)
    .o_done_rden_ctrl(FC_layerdone) //ouput: done signal indicating the finish of FC layer. 
  );
  //wire FC_layerdone;
  
  
  wire [ACC_DW*COL_FC-1:0] FC_accumulator_op_data; // fully connected layer o/p
  wire [COL_FC-1:0] dv_FC_accumulator_data; //datavalid of FC o/p

 
  // FC Computing Engine
  wire [(DATA_WIDTH_OB*COL_SA)-1:0] data_SA_FC;
  wire [COL_SA-1:0] dv_SA_FC;
  //interconnect of SA and FC
 assign data_SA_FC = (CONV_FC) ? op_data_mux_FC : result_tree;
 assign dv_SA_FC = (CONV_FC) ? {COL_SA{valid_out_FC}} : valid_tree;

  wire [(ACC_DW*COL_FC)-1:0] reorder_data_FC;
  wire o_dv_reorder;
  wire [NO_PORT_FC-1:0] sel_FC_op_data_mux; //select signal for the instance FC_op_data_mux
  wire [(ACC_DW*N_FC_MUX)-1:0] op_data_mux_FC;
  wire valid_out_FC;
  top_fc#(
    .W_DATA(DATA_WIDTH),
    .COL(COL_FC),
    .ROW(1),
    .W_PSUM(W_PSUM),
    .N_SA(1),
    .W_ACC(ACC_DW),
    .W_IMG_DIM(FC_IMAGE_ROWS_WIDTH), // FC_IMAGEROW_WIDTH
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
    .i_weight_ff_array_dv(weight_dv_fc),
    .i_weight_ff_array_empty(weight_empty_fc),
    .o_weight_ff_array_rden(weight_read_en_fc), //output: weight fifo rden, goes to fifo sharing
    .i_weight_ff_array_occ(weight_occupants_fc), //input: weight fifo occupants from fifo sharing
    // .o_image_ff_array_rden(), //Todo: check it
    .accumulator_dv(dv_FC_accumulator_data),
    .accumulator_data(FC_accumulator_op_data)
  );

  assign FC_done = &(dv_FC_accumulator_data);
  
  
 
  //interconnect of SA and FC
  assign data_SA_FC = (CONV_FC==1'b1)? op_data_mux_FC : result_tree;
  assign dv_SA_FC = (CONV_FC==1'b1)? {COL_SA{valid_out_FC}} : valid_tree;
  
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
        .in(reorder_data_FC[(((ACC_DW*NO_PORT_FC)*(N_FC_MUX-i))-1) -: ACC_DW*NO_PORT_FC]),  //datawidth = port_size*no.of ports
        .out(op_data_mux_FC[((ACC_DW*(N_FC_MUX-i))-1) -:ACC_DW]), //datawidth = port_size
        .sel(sel_FC_op_data_mux)
      );
    end
  endgenerate
 
  
  wire [(DATA_WIDTH_OB*COL_SA) -1:0] output_block_out; // From here onwards COL_SA or N_SA?:Todo
  wire [N_SA-1:0] vector_valid;
  // Vector addition block for addition of psum accumulants
  top_output_block #(
      .DRAM_BW(DRAM_BW),
      .DATA_WIDTH(DATA_WIDTH_OB),
      .W_ADDR($clog2(ACC_FIFO_DEPTH)), //W_ADDR = $clog2(ACC_FIFO_DEPTH)
      .N(N_SA),
      .FIFO_NO(ACC_FIFO),
      .OUT_DATA_WIDTH(DATA_WIDTH_OB),
      .NO_PORT(NO_PORT_VA)
  ) vector_addition (
      .top_clk(i_clk),
      .top_wr_en(vector_add_wren), //input: comes from ddr
      .rst(rst&(~iteration_Done)),
      .top_data_in(vector_add_values), // input: comes from ddr
      .w_empty_flag(empty_vector),
      .top_data_out(output_block_out),
      .top_data_in_adder_tree(data_SA_FC), //interconnect data o/p
      .vector_add_enable(vector_add_enable),
      .top_in_data_valid(dv_SA_FC), //interconnect datavalid
      .top_out_data_valid(vector_valid),
      .fifo_occupants(acc_fifo_occupants)
  );

  
  wire [(DATA_WIDTH_OB*COL_SA) -1:0] bias_output;
  wire [N_SA-1:0] bias_valid;
  //CONV Bias addition block
  top_bias_block #(
      .DATA_WIDTH(DATA_WIDTH_OB),
      .W_ADDR($clog2(BIAS_FIFO_DEPTH)),
      .N(COL_SA),
      .BIAS(1),
      .TOGGLE(1),
      .FIFO_NO(BIAS_FIFO),
      .OUT_DATA_WIDTH(DATA_WIDTH_OB),
      .NO_PORT(NO_PORT_BAC)
  ) bias_addition (
      .top_clk(i_clk),
      .top_wr_en(bias_wren), //from ddr
      .rst(rst),
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
  
  
  wire [(DATA_WIDTH*COL_SA) -1:0] quantized_output;
  wire [(DATA_WIDTH_OB*COL_SA) -1:0] unquantized_output;
  wire [COL_SA -1:0] unquantized_valid;
  wire [COL_SA-1:0] tail_valid;
  top_quant_gen #(
      .DATA_WIDTH(DATA_WIDTH_OB),
      .SHIFT_WIDTH(QUANT_SHIFT),
      .SCALE_WIDTH(QUANT_SCALE),
      .OUT_DATA_WIDTH(DATA_WIDTH),
      .N(COL_SA)
  ) quant (
      .top_i_clk(i_clk),
      .top_i_data_quant(bias_output),
      .top_i_data_scale({COL_SA{quant_scale}}), //from tail inst.
      .enable_quant(quant_enable),  //from iteration cnter
      .top_o_data(quantized_output),
      .quantized_passthrough(unquantized_output),
      .top_i_data_valid(bias_valid),
      .unquantized_valid(unquantized_valid),
      .top_o_data_valid(tail_valid),
      .top_i_bit_shift({COL_SA{shift_value}}) //from tail inst.
  );
  
  
  wire [(DATA_WIDTH*COL_SA)-1:0] bias_fc_out ;
  wire [COL_SA-1:0] bias_fc_valid;

  top_bias_fc #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH($clog2(BIAS_FIFO_DEPTH)),
    .DRAM_BW(DRAM_BW),
    .N(COL_SA),    
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



  top_relu_gen #(
      .N(COL_SA),
      .DATA_WIDTH(DATA_WIDTH),
      .CLIP_WIDTH(RELU_CLIP_WIDTH)
  ) relu (
      .top_clk(i_clk),
      .top_i_data(bias_fc_out),
      .top_i_valid(bias_fc_valid),
      .relu_enable(relu_enable), //from iteration cnter
      .top_o_data(relu_output),
      .top_o_valid(relu_valid),
      .top_i_clip({COL_SA{relu_clip_value}}) //from tail inst.
  );
  
   maxpool_gen #(
      .N_SA(N_SA),
      .DATA_IN(DATA_WIDTH),
      .IMG_WIDTH(W_CONV_OP_IMAGE_DIM)
  ) maxpool (
      .clk(i_clk),
      .data_in(relu_output),
      .rst(rst),
      .maxpool_enable(maxpool_enable), //from iteration cnter
      .datavalid(relu_valid),
      .IW(maxpool_threshold), //from conv inst.
      .maxvalue_o(maxpool_output),
      .datavalid_o(maxpool_valid)
  );
  
  wire [(DATA_WIDTH_ACC*COL_SA)-1 : 0] zp_unquantized_din;
  wire [COL_SA-1:0] zp_valid;
  wire [(COL_SA*DATA_WIDTH) -1:0] zp_data;
  wire [(DATA_WIDTH_ACC*COL_SA) -1:0] zp_unquant_data;
  wire [COL_SA -1:0] zp_unquant_dv;

  //zero padding circuit
  top_zero # (
    .DW(DATA_WIDTH),
    .COL(COL_SA),
    .I_SIZE_WIDTH(I_OP_SIZE_WIDTH), //width of image dimension
    .MOD(MOD1)
  )
  zp_quant (
    .clk(i_clk),
    .rst(rst),
    .i_size(i_img_dim_Op), // image dimension of quantized o/p (from op block inst.)
    .data_in(maxpool_output),
    .i_dv(maxpool_valid),
    .data_out(zp_data),
    .o_dv(zp_valid)
  );
  
  localparam REMOVE = DATA_WIDTH_OB - DATA_WIDTH_ACC;
  
  genvar j;
  generate
    for(j=0;j<COL_SA;j=j+1) begin
      assign zp_unquantized_din[((DATA_WIDTH_ACC*(COL_SA-j))-1) -: DATA_WIDTH_ACC] = 
      unquantized_output[((DATA_WIDTH_OB*(COL_SA-j)-REMOVE)-1) -: DATA_WIDTH_ACC];
    end
  endgenerate

  top_zero # (
    .DW(DATA_WIDTH_ACC),
    .COL(COL_SA),
    .I_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
    .MOD(MOD2)
  )
  zp_unquant(
    .clk(i_clk),
    .rst(rst),
    .i_size(i_img_dim_Acc), // image dimension of accumlant o/p (from op block inst.)
    .data_in(zp_unquantized_din),
    .i_dv(unquantized_valid),
    .data_out(zp_unquant_data),
    .o_dv(zp_unquant_dv)
  );

  

  //Tail_done signal generation logic
  Tail_done_gen #(
      .N(COL_SA),
      .I_ACC_SIZE_WIDTH(I_ACC_SIZE_WIDTH),
      .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH)
  ) tail_done_inst(
      .i_clk(i_clk),
      .rst(rst),
      .datavalid_acc(zp_unquant_dv),
      .datavalid_pool(zp_valid),
      .pool_en(maxpool_enable),
      .img_dim_Acc(i_img_dim_Acc),
      .img_dim_Op(i_img_dim_Op),
      .Tail_done(Tail_done)
  );
  
  generate_shift_register #(
      .N(COL_SA),
      .NUM_SHIFT(SHFT_REG_X),
      .ACC_DATA_WIDTH(DATA_WIDTH_ACC),
      .QUANT_DATA_WIDTH(DATA_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) shift_register_x (
      .intermediate_result(zp_unquant_data),
      .quantized_result_in(zp_data),
      .sel(shift_reg_sel),  //from iteration cnter
      .valid_intermediate_result(zp_unquant_dv),
      .valid_quantized_result(zp_valid),
      .clk(i_clk),
      .valid_out_final(x_final_valid),
      .data_out(x_final_data)
  );

    
  
  wire [$clog2(N_DMUX_PORTS)-1 : 0] sel_dmx;
  wire [(N_DMUX_PORTS*COL_SA)-1 : 0] op_write_dmux_datavalid;

  Dmux_param #(
    .NUM_PORTS(N_DMUX_PORTS),
    .DATA_WIDTH(DATA_WIDTH_ACC),
    .COL_SA(COL_SA)
  )
  dmux_param_inst(
    .i_din(x_final_data),
    .i_datavalid(x_final_valid),
    .i_sel(sel_dmx),
    .o_dout(op_write_dmux_data),
    .o_datavalid(op_write_dmux_datavalid)
  );

  

  demux_controller_sel_op # (
    .COL(COL_SA),
    .NUM_PORTS(N_DMUX_PORTS),
    .OP_FIFO_WRITE(OP_FIFO)
  )
  demux_sel_ctr (
    .rst(rst&(~iteration_Done)),
    .clk(i_clk),
    .data_valid(x_final_valid),
    .op_wren(op_wren),
    .sel(sel_dmx)
  );
  
endmodule
