//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Top Board
// Project Name: Gati
// Description: Testing the config block with memory module.
//////////////////////////////////////////////////////////////////////////////////
//
module top_board #(
    parameter  INST_W=256,
    parameter NUM_INSTRUCTIONS=4,
    parameter  ADDR_W=32,
    parameter OPCODE_W=4,
    parameter op_code_width = 4,
    parameter CNT = (data_in/data_out),
    parameter data_in = 256,
    parameter data_out = 8,
    parameter BURST_LEN_AXI = 7,
    parameter BURST_LEN_WIDTH=8,
    parameter LAY_N = 12,
    parameter DEPTH=100,
    parameter  STATUS_DRAM_LIM=10)
  (
    input clkin,
    input user_start,
    output test_output,
    output start_out
  );

  wire read_1_3;
  wire [7:0] address_1_2;
  wire [INST_W-1:0]instruct_2_1;
  wire valid_3_6;
  wire pulse_4_1;
  wire pulse_6_1;
  wire pulse_5_2;
  wire inst1_7_1;
  wire inst2_7_1;
  wire inst3_7_1;
  wire inst4_7_1;
  wire pulse_9_8;
  wire [NUM_INSTRUCTIONS-1:0]start_cmd_1_7;
  wire [INST_W-1:0]instruct_8_1;
  wire read_1_9;
  wire [BURST_LEN_WIDTH-1:0]burst_length;
  wire random;
  //wire valid_8_1;
  wire [NUM_INSTRUCTIONS-1:0]ack_7_1;
  config_blk #(.INST_W(INST_W),
               .ADDR_W(ADDR_W),
               .NUM_INSTRUCTIONS(NUM_INSTRUCTIONS),
               .BURST_LEN_AXI(BURST_LEN_AXI),
               .BURST_LEN_WIDTH(BURST_LEN_WIDTH),
               .OPCODE_W(OPCODE_W),
               .data_in(data_in),
               .data_out(data_out),
               .CNT(CNT),
               .LAY_N(LAY_N),
               .DEPTH(DEPTH),
               .STATUS_DRAM_LIM(STATUS_DRAM_LIM))
             config_block_mod_1(
               .clkin(clkin),
               .user_start(pulse_4_1),
               .valid(valid_8_1),
               .sel(1'b1),
               .instruction_data(instruct_8_1),
               .memory_read_r(read_1_3),
               .memory_valid(),
               .mem_address(address_1_2),
               .mem_last(random),
               .mem_burst_len(burst_length),
               .ack_signals(ack_7_1),
               .start_command(start_cmd_1_7),
               .start_out(start_out)
             );


  burst_mem_module memory_module_8(
                     .clkin(clkin),
                     .burst_read_trigger(random),
                     .burst_length(burst_length),
                     .mem_instruction(instruct_8_1),
                     .valid_signal(valid_8_1)
                   );

  one_pulse_generator one_pulse_generator_4(
                        .clkin(clkin),
                        .signal(user_start),
                        .pulse_signal(pulse_4_1)
                      );
  one_pulse_generator box_5(
                        .clkin(clkin),
                        .signal(user_start),
                        .pulse_signal(test_output)
                      );

  counter_ack_block #(.NUM_INSTRUCTIONS(NUM_INSTRUCTIONS))ack_generator_mod_7(
                      .clkin(clkin),
                      .trigger_start(start_cmd_1_7),
                      .ack_signals(ack_7_1)
                    );

endmodule
