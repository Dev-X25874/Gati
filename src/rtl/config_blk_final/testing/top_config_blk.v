//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Configuration Block
// Project Name: Gati
// Description: Is the top module that integrates all the sub modules of the configuration block.
//////////////////////////////////////////////////////////////////////////////////
module config_blk #(
  parameter  ADDR_W=32,
  parameter  INST_W=256,
  parameter NUM_INSTRUCTIONS =4,
  parameter BURST_LEN_AXI = 7
)(
  input clkin,
  input user_start,
  input [ADDR_W-1:0]global_start,
  input [ADDR_W-1:0]global_stop,
  input valid,
  input sel,
  input [INST_W-1:0]instruction_data,
  output memory_read_r,memory_valid,
  output [7:0]mem_address,
  output mem_last,
  output [$clog2(BURST_LEN_AXI):0]mem_burst_len,
  input [NUM_INSTRUCTIONS-1:0]ack_signals,
  output[NUM_INSTRUCTIONS-1:0]start_command
);
wire status_1_3;
wire [INST_W-1:0]instruction_2_3;
wire instruction_v_2_3;
wire read_req_3_4;
wire status_3_4;
wire [INST_W-1:0]o_instruction_3_5;
wire o_instruction_3_5_v;
wire start_4_5;
wire done_5_4;
wire [NUM_INSTRUCTIONS-1:0]valid_6_4;
wire [2*NUM_INSTRUCTIONS-1:0]prev_6_4;
wire [NUM_INSTRUCTIONS-1:0]ack_6_4;



ctrl_dram_req #(.ADDR_W(ADDR_W),.BURST_LEN_AXI(BURST_LEN_AXI))dram_controller_1 (.clkin(clkin),
              .user_start(user_start),
              .status(status_1_3),
              .global_reg_address_start(global_start),
              .global_reg_address_stop(global_stop),
              .read_req(memory_read_r),
              .valid(memory_valid),
              .o_address(mem_address),
              .last(mem_last),
              .burst_len(mem_burst_len));

controller_inst_q #(.INSTRUCT_W(INST_W)) inst_q_controller_2(
                    .clkin(clkin),
                    .valid(valid),
                    .sel(sel),
                    .i_instruction_data(instruction_data),
                    .o_instruction(instruction_2_3),
                    .o_instruction_valid(instruction_v_2_3)
                  );

instruct_q #(.INSTRUCT_W(INST_W))inst_q_3(
             .clkin(clkin),
             .instruct_mem(instruction_2_3),
             .read_req_inst(read_req_3_4),
             .instruct_valid(instruction_v_2_3),
             .o_instruction(o_instruction_3_5),
             .o_instruction_valid(o_instruction_3_5_v),
             .o_status_dram(status_1_3),
             .o_status_inst(status_3_4)
           );

inst_read_ctrl #(.NUM_INSTRUCTIONS(NUM_INSTRUCTIONS))inst_read_ctrl_4(
                 .clkin(clkin),
                 .valid_ack(valid_6_4),
                 .prev_in(prev_6_4),
                 .ack_in(ack_6_4),
                 .layer_number(o_instruction_3_5[15:4]),
                 .total_layers(o_instruction_3_5[27:16]),
                 .status_inst_q(status_3_4),
                 .user_start(user_start),
                 .done_status(done_5_4),
                 .opcode(o_instruction_3_5[3:0]),
                 .bus_master_valid(start_4_5),
                 .start_command(start_command),
                 .read_signal(read_req_3_4)
               );

top_master master_controller_5(
             .din(o_instruction_3_5),
             .start(start_4_5),
             .clk(clkin),
             .op_code(o_instruction_3_5[3:0]),
             .ready_in(16'b11111111111), //for testing
             .dout(),
             .sel(),
             .write(),
             .done(done_5_4)
           );

ctrl_ack #(.NUM_INSTRUCTIONS(NUM_INSTRUCTIONS))ack_block_6(
           .clkin(clkin),
           .inst_signals(ack_signals),
           .status_ack(ack_6_4),
           .status_prev(prev_6_4),
           .o_valid_sig(valid_6_4)
         );

endmodule
