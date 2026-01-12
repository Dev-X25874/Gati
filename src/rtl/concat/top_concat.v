module top_concat #(
    parameter OPCODE_WIDTH = 4,
    parameter AXI_DATA_WIDTH = 256,
    parameter CONCAT_FIFO_DEPTH = 512,
    parameter CONCAT_FIFO = 1,
    parameter DATA_WIDTH  = 8, 
    parameter CONCAT_Image1StartAddress_WIDTH = 32,
    parameter CONCAT_Image2StartAddress_WIDTH = 32,
    parameter CONCAT_Image3StartAddress_WIDTH = 32,
    parameter CONCAT_Image4StartAddress_WIDTH = 32,
    parameter CONCAT_IH1_WIDTH = 10,
    parameter CONCAT_IH2_WIDTH = 10,
    parameter CONCAT_IH3_WIDTH = 10,
    parameter CONCAT_IH4_WIDTH = 10,
    parameter CONCAT_IW1_WIDTH = 10,
    parameter CONCAT_IW2_WIDTH = 10,
    parameter CONCAT_IW3_WIDTH = 10,
    parameter CONCAT_IW4_WIDTH = 10,
    parameter CONCAT_KN1_WIDTH = 10,
    parameter CONCAT_KN2_WIDTH = 10,
    parameter CONCAT_KN3_WIDTH = 10,
    parameter CONCAT_KN4_WIDTH = 10,
    parameter CONCAT_InNum_WIDTH = 3,
    parameter AXI_ADDRESS_WIDTH = 32,
    parameter QUANT_OP_FIFO = 1 
    
) (
    input i_clk,
    input i_rst,
    input [OPCODE_WIDTH-1:0] opcode,
    input [CONCAT_Image1StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_1,
    input [CONCAT_Image2StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_2,
    input [CONCAT_Image3StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_3,
    input [CONCAT_Image4StartAddress_WIDTH -1 : 0] CONCAT_StartAdd_4,
    input [CONCAT_IH1_WIDTH -1 : 0]                CONCAT_IH_1,
    input [CONCAT_IH2_WIDTH -1 : 0]                CONCAT_IH_2,
    input [CONCAT_IH3_WIDTH -1 : 0]                CONCAT_IH_3,
    input [CONCAT_IH4_WIDTH -1 : 0]                CONCAT_IH_4,
    input [CONCAT_IW1_WIDTH -1 : 0]                CONCAT_IW_1,
    input [CONCAT_IW2_WIDTH -1 : 0]                CONCAT_IW_2,
    input [CONCAT_IW3_WIDTH -1 : 0]                CONCAT_IW_3,
    input [CONCAT_IW4_WIDTH -1 : 0]                CONCAT_IW_4,
    input [CONCAT_KN1_WIDTH -1 : 0]                CONCAT_KN_1,
    input [CONCAT_KN2_WIDTH -1 : 0]                CONCAT_KN_2,
    input [CONCAT_KN3_WIDTH -1 : 0]                CONCAT_KN_3,
    input [CONCAT_KN4_WIDTH -1 : 0]                CONCAT_KN_4,
    input [AXI_DATA_WIDTH -1:0]                    i_concat_data, 
    input                                          concat_write_enable,
    input                                          start_Concat,
    input [CONCAT_InNum_WIDTH -1 : 0]              CONCAT_InNum,
    input [QUANT_OP_FIFO -1 : 0]                   quant_op_fifo_full,
    (*syn_use_dsp = "no"*) output [STOP_ADD_WIDTH - 1 : 0] CONCAT_StopAdd_1,
    (*syn_use_dsp = "no"*) output [STOP_ADD_WIDTH - 1 : 0] CONCAT_StopAdd_2,
    (*syn_use_dsp = "no"*) output [STOP_ADD_WIDTH - 1 : 0] CONCAT_StopAdd_3,
    (*syn_use_dsp = "no"*) output [STOP_ADD_WIDTH - 1 : 0] CONCAT_StopAdd_4,
    output [(($clog2(CONCAT_FIFO_DEPTH)+1)*CONCAT_FIFO)-1:0]Concat_fifo_occupants,
    output  [AXI_DATA_WIDTH-1 :0] o_concat_data,
    output  o_concat_done,
    output  concat_dv,
    output  o_concat_dv
);


/* Address offset calculation for concat input */ 

  localparam STOP_ADD_WIDTH = AXI_ADDRESS_WIDTH;


    (*syn_use_dsp = "no"*) wire [STOP_ADD_WIDTH - 1 : 0] offset_1;
    (*syn_use_dsp = "no"*) wire [STOP_ADD_WIDTH - 1 : 0] offset_2;
    (*syn_use_dsp = "no"*) wire [STOP_ADD_WIDTH - 1 : 0] offset_3;
    (*syn_use_dsp = "no"*) wire [STOP_ADD_WIDTH - 1 : 0] offset_4;

    assign  offset_1 = CONCAT_KN_1 * CONCAT_IH_1 * CONCAT_IW_1;
    assign  offset_2 = CONCAT_KN_2 * CONCAT_IH_2 * CONCAT_IW_2;
    assign  offset_3 = CONCAT_KN_3 * CONCAT_IH_3 * CONCAT_IW_3;
    assign  offset_4 = CONCAT_KN_4 * CONCAT_IH_4 * CONCAT_IW_4;

    assign CONCAT_StopAdd_1 = offset_1 + CONCAT_StartAdd_1;
    assign CONCAT_StopAdd_2 = offset_2 + CONCAT_StartAdd_2;
    assign CONCAT_StopAdd_3 = offset_3 + CONCAT_StartAdd_3;
    assign CONCAT_StopAdd_4 = offset_4 + CONCAT_StartAdd_4;


    wire concat_fifo_empty;
    wire concat_fifo_full;
    wire concat_read_enable;

   // This is 256 bit concat dram fifo
    dram_fifo#(
      .DIMENSION(CONCAT_FIFO),
      .W_DATA(AXI_DATA_WIDTH),
      .W_ADDR($clog2(CONCAT_FIFO_DEPTH)),
      .OUTPUT_REG(0),
      .RAM_DEPTH(1 << ($clog2(CONCAT_FIFO_DEPTH)))
      )
    concat_dram_fifo
    ( .i_clk(i_clk),
      .i_rst(!i_rst),
      .i_data(i_concat_data),
      .i_read_enable(concat_read_enable),
      .i_write_enable(concat_write_enable),
      .o_data(w_concat_data),
      .o_fifo_empty(concat_fifo_empty),
      .o_fifo_almost_empty(),
      .o_fifo_full(concat_fifo_full),
      .o_fifo_almost_full(),
      .o_fifo_dv(concat_dv),
      .o_occupants(Concat_fifo_occupants)
    );

// concat data controller.
wire current_done;
wire next_start;
wire [STOP_ADD_WIDTH -1 :0] current_data_size;
wire [AXI_DATA_WIDTH -1:0] w_concat_data;

// concat_controller module instantiation 
  concat_controller #
  (
    .DATA_WIDTH(32) ,
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH) ,
    .AXI_ADDRESS_WIDTH(AXI_ADDRESS_WIDTH),
    .QUANT_OP_FIFO(QUANT_OP_FIFO)
  )
  concat_controller(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start(next_start),
    .i_data_size(current_data_size),    // image length in BYTES
    .i_concat_data(w_concat_data),
    .concat_fifo_empty(concat_fifo_empty),
    .concat_read_enable(concat_read_enable),
    .o_concat_data(o_concat_data),
    .o_concat_dv(o_concat_dv),
    .fifo32_full(),
    .o_done(current_done),
    .i_dram_fifo_dv(concat_dv),
    .quant_op_fifo_full(quant_op_fifo_full)
  );

// Concat Address switcher and start pulse generation 

  concat_length_switcher #
  (
    .MAX_INPUTS(4)
  )
  concat_length_switcher
  ( 
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start_seq(start_Concat),   // 1-cycle pulse to start sequence
    .i_input_num(CONCAT_InNum),   // number of valid inputs: 1..4
    .i_len0(offset_1),
    .i_len1(offset_2),
    .i_len2(offset_3),
    .i_len3(offset_4),
    .i_done(current_done),         // asserted when current length is done
    .o_start_en(next_start),      // 1-cycle pulse
    .o_length(current_data_size),        // latched length
    .o_all_done(o_concat_done)
  );

endmodule