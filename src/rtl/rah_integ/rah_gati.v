module rah_gati #(
//globalutput [(OP_FIFO*DATA_WIDTH_OB)-1:0] op_dram_fifo
	 parameter INST_QUEUE_DEPTH = 512,
	 parameter DRAM_IMG_FIFO_DEPTH = 512,
	 parameter IM2COL_FIFO_DEPTH = 1024,
	 parameter WEIGHT_FIFO_DEPTH = 512,
	 parameter PSUM_FIFO_DEPTH = 8192,
	 parameter ACC_FIFO_DEPTH = 512,
	 parameter BIAS_FIFO_DEPTH = 512, //For both conv and FC
	 parameter OP_WRITE_FIFO_DEPTH = 2048,
     //Default burst lenghts for various memory request controllers
	 parameter CONFIG_REQ_BLEN = 7,
	 parameter IMG_REQ_BLEN = 15,
	 parameter WEIGHT_REQ_BLEN = 15,
     parameter ACC_REQ_BLEN = 15,
     parameter OP_WRITE_REQ_ACC_BLEN = 31, //burst length for writng accumulants (32-bit) into the DRAM
     parameter OP_WRITE_REQ_QUA_BLEN = 15, //burst length for writng quantized wire (8-bit) into the DRAM

     parameter CONFIG_FIFO_OCCUPANCY = 10,
     parameter LAYERCNT_WIDTH = 12,
     //parameters related to DRAM controller
     parameter NUM_PORTS = 4, //Number of read and write requestors
     /*
     parameter PORT_ID_WIDTH = 4, 
     parameter ADDR_WIDTH_MEM_CTRL = 8, //address width to the wire of DRAM ctrl from operator mem request ctrlers
     parameter PORT_ID = {4'd10, 4'd11, 4'd12, 4'd13, 4'd14} // Depends on the port_id_width and number of requestors
     */

     parameter AXI_DATA_BYTES = 32,  // Axi Data width = 256 bit
     parameter AXI_ADDR_W = 32,          // Axi Address width
     parameter BURST_LENGTH_WIDTH =8,
    
     parameter NUM_INSTRUCTIONS = 4,
     parameter INST_W = 256,

     parameter OPCODE_WIDTH = 4,
     parameter N_SA = NSA_DSP + NSA_LUT,
     parameter DATA_WIDTH = 8,
     parameter COL_SA = 4,
     parameter COL_FC = 32,
     parameter W_QUANT_SHIFT = 5,
     parameter W_QUANT_SCALE = 16,
     parameter ROW = 9,
     parameter W_PSUM = 20,
     parameter MOD1 = 2,
     parameter MOD2 = 8,
     parameter DATA_WIDTH_OB = 32,
     parameter IMAGE_DIM = 224,
     parameter SHFT_REG_X = 4, // Number of shift register blocks
     parameter BIAS_FIFO = 8, // Number of bias FIFOs
     parameter OP_FIFO = 8,  // Number of wire write FIFOs
     parameter NSA_DSP = 4, 
     parameter N_FC_MUX = 4,
     parameter NO_PORT_FC = 8,
     parameter RELU_CLIP_WIDTH = 8,
     parameter NSA_LUT = 0,
     parameter BIAS_FIFO_FC = 32, // Number of FC bias FIFOs
     parameter NO_PORT_VA = 2,
     parameter NO_PORT_BAC = 2,
     parameter NO_PORT_BAFC = 8,
     parameter POP_THRESHOLD = 5,
     parameter I_SIZE_WIDTH=20, // bit width of wire image dimension
     parameter ACC_DW = 32,
     parameter N_BANK = 4,
     parameter N_BRAM = 8,
     parameter W_FC_RW_COUNTER = 10, //width of fc r/w address counter
     parameter FC_BRAM_DEPTH = 1024,
     parameter W_KERNEL_CNT = 16,
     parameter W_IMAG_DIM = 20,
	 parameter ACC_DATA_REORDER = 1,




)
	(
		input i_clk,
		input s_clk,
		input i_rst,
		input user_start,
	


		input empty,
		input [47:0] data,
		output rden
	)
	
	reg [47:0] r_data=0;
	reg valid_data=0;
	
	always @ (posedge i_clk) begin 
		
		if(!empty) begin 
			rden<=1;
		end
		else begin 
			rden<=0;
		end

		if(rden)  
			valid_data<=1;
		else
			valid_data<=0;
		
		if(valid_data) 
			r_data<=data;
	end


////////////////////////////MIPI controller rx
top#(
    .N_FIFO(N_FIFO),
    .W_DATA(W_DATA),
    .BURST_LEN(BURST_LEN),
    .W_BURST_LEN(W_BURST_LEN),
    .W_ADDR(W_ADDR),
    .AXI_BYTES(AXI_BYTES)
)(
    .i_clk(i_clk),
    .i_rstn (i_rstn),
    .i_trigger(i_trigger),
    .i_data_valid(i_data_valid),
    .i_data(i_data),
	.ddr_sel(ddr_sel),
	.ddr_wready(ddr_wready),
	.ddr_blen(ddr_blen),
    .o_fifo_data(o_fifo_data),  //comes from fifo array
    .final_o_data_last(final_o_data_last), //comes from dram wr ctrl
    .o_data_valid(o_data_valid), //comes from dram wr ctrl
    .req_wr_req_ctrl(req_wr_req_ctrl),
    .address_wr_req_ctrl(address_wr_req_ctrl),
    .final_burst_len_wr_req_ctrl(final_burst_len_wr_req_ctrl),
    .final_last_wr_req_ctrl(final_last_wr_req_ctrl),
    .valid_wr_req_ctrl(valid_wr_req_ctrl)
);

	wire [(W_DATA * N_FIFO)-1 : 0] o_fifo_data,  //comes from fifo array
    wire final_o_data_last, //comes from dram wr ctrl
    wire o_data_valid, //comes from dram wr ctrl
    wire req_wr_req_ctrl,
    wire [7:0] address_wr_req_ctrl,
    wire [W_BURST_LEN-1 : 0] final_burst_len_wr_req_ctrl,
    wire final_last_wr_req_ctrl,
    wire valid_wr_req_ctrl



//////////////////////////////
	

///////////////////////////////Memory Controller /////////////////////////////////
	
	

//////////////////////////////// gati module instatiation

    //signals to DRAM ctrler
    ////config
    wire [7:0] mc_config_addr,
    wire mc_config_rdreq,
    wire mc_config_valid,
    wire [BURST_LENGTH_WIDTH-1 : 0] mc_config_bl,
    wire mc_config_last,

    ////img
    wire [7:0] mc_img_addr,
    wire mc_img_rdreq,
    wire mc_img_valid,
    wire [BURST_LENGTH_WIDTH-1 : 0] mc_img_bl,
    wire mc_img_last,

    /////conv
    wire [7:0] mc_wghts_addr,
    wire mc_wghts_rdreq,
    wire mc_wghts_valid,
    wire [BURST_LENGTH_WIDTH-1 : 0] mc_wghts_bl,
    wire mc_wghts_last,
    
    ///////fc
    wire [7:0] mc_fc_addr,
    wire mc_fc_rdreq,
    wire mc_fc_valid,
    wire [BURST_LENGTH_WIDTH-1 : 0] mc_fc_bl,
    wire mc_fc_last,

    //////////bias 
    wire [7:0] mc_bias_addr,
    wire mc_bias_rdreq,
    wire mc_bias_valid,
    wire [BURST_LENGTH_WIDTH-1 : 0] mc_bias_bl,
    wire mc_bias_last,

    ///////////////fc_bias 
    wire [7:0] mc_fc_bias_addr,
    wire mc_fc_bias_rdreq,
    wire mc_fc_bias_valid,
    wire [BURST_LENGTH_WIDTH-1 : 0] mc_fc_bias_bl,
    wire mc_fc_bias_last,

    /////////////acc
    wire [7:0] mc_acc_addr,
    wire mc_acc_rdreq,
    wire mc_acc_valid,
    wire [BURST_LENGTH_WIDTH-1: 0] mc_acc_bl,
    wire mc_acc_last,

    /////////////wire write ctrl
    wire [7:0] mc_op_write_addr,
    wire mc_op_writereq,
    wire mc_op_write_valid,
    wire [BURST_LENGTH_WIDTH-1 : 0] mc_op_write_bl,
    wire mc_op_write_bl,
    
    ///////////////////////operators data
    
    //Signals from DRAM ctrl to internal operator blocks
    wire [NUM_PORTS-1:0] select;
    //Read block signals
    // wire sel_rd
    wire dram_rd_datavalid,
    wire dram_rd_data_last,
    wire [AXI_DATA_WIDTH - 1 : 0] dram_rd_data,

    //op_write block signals
    // wire sel_op_write, // Todo: have to check , wheteher sel is common or not
    wire [BURST_LENGTH_WIDTH-1 : 0] wr_burst_len,
    wire dv_op_write,
    wire data_last_op_write,
    wire [(OP_FIFO*DATA_WIDTH_OB)-1:0] op_dram_fifo


	top_gati_module # (
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
    .CONFIG_FIFO_OCCUPANCY(CONFIG_FIFO_OCCUPANCY),
    .LAYERCNT_WIDTH(LAYERCNT_WIDTH),
    .NUM_PORTS(NUM_PORTS),
    .AXI_DATA_BYTES(AXI_DATA_BYTES),
    .AXI_ADDR_W(AXI_ADDR_W),
    .BURST_LENGTH_WIDTH(BURST_LENGTH_WIDTH),
    .NUM_INSTRUCTIONS(NUM_INSTRUCTIONS),
    .INST_W(INST_W),
    .OPCODE_WIDTH(OPCODE_WIDTH),
    .N_SA(N_SA),
    .DATA_WIDTH(DATA_WIDTH),
    .COL_SA(COL_SA),
    .COL_FC(COL_FC),
    .W_QUANT_SHIFT(W_QUANT_SHIFT),
    .W_QUANT_SCALE(W_QUANT_SCALE),
    .ROW(ROW),
    .W_PSUM(W_PSUM),
    .MOD1(MOD1),
    .MOD2(MOD2),
    .DATA_WIDTH_OB(DATA_WIDTH_OB),
    .IMAGE_DIM(IMAGE_DIM),
    .SHFT_REG_X(SHFT_REG_X),
    .BIAS_FIFO(BIAS_FIFO),
    .OP_FIFO(OP_FIFO),
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
    .I_SIZE_WIDTH(I_SIZE_WIDTH),
    .ACC_DW(ACC_DW),
    .N_BANK(N_BANK),
    .N_BRAM(N_BRAM),
    .W_FC_RW_COUNTER(W_FC_RW_COUNTER),
    .FC_BRAM_DEPTH(FC_BRAM_DEPTH),
    .W_KERNEL_CNT(W_KERNEL_CNT),
    .W_IMAG_DIM(W_IMAG_DIM),
    .ACC_DATA_REORDER(ACC_DATA_REORDER)
  )
  top_gati_module_inst (
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
    .mc_op_write_bl(mc_op_write_bl),
    .select(select)
  );
///////////////////////////////	

//////////////////////////////////// MIPI controller tx

///////////////////////////////////



