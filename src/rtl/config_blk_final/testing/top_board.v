//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Top Board
// Project Name: Gati
// Description: Testing the config block with memory module.
//////////////////////////////////////////////////////////////////////////////////
// 
module top_board #(
    parameter  inst_w=256,
    parameter num_inst =7,
    parameter  addr_w=32
  )(
    input clkin,
    input user_start,
    output random
  );

  wire read_1_3;
  wire [7:0] address_1_2;
  wire [inst_w-1:0]instruct_2_1;
  wire valid_3_6;
  wire pulse_4_1;
  ;
  wire pulse_6_1;
  wire pulse_5_2;
  wire inst1_7_1;
  wire inst2_7_1;
  wire inst3_7_1;
  wire inst4_7_1;
  wire pulse_9_8;
  wire [num_inst:0]start_cmd_1_7;
  wire [inst_w-1:0]instruct_8_1;
  wire read_1_9;
  wire valid_8_1;
  wire [num_inst-1:0]ack_7_1;
  config_blk #(.inst_w(inst_w),.addr_w(addr_w),.num_instructions(num_inst))config_block_mod_1(
               .clkin(clkin),
               .user_start(pulse_4_1),
               .global_start(32'h00001000),
               .global_stop(32'h00001800),
               .valid(valid_8_1),
               .sel(1'b1),
               .instruction_data(instruct_8_1),
               .memory_read_r(read_1_3),
               .memory_valid(),
               .mem_address(address_1_2),
               .mem_last(random),
               .mem_burst_len(),
               .ack_signals(ack_7_1),
               .start_command(start_cmd_1_7)
             );

  /* what box_2(
      .re(pulse_5_2),
      .addr(address_1_2),
      .clk(clkin),
      .rdata_a(instruct_2_1)
  ); */

  burst_mem_module memory_module_8(
                     .clkin(clkin),
                     .burst_read_trigger(pulse_9_8),
                     .mem_instruction(instruct_8_1),
                     .valid_signal(valid_8_1)
                   );
  /* one_clock_delay box_3(
      .clkin(clkin),
      .i_data(read_1_3),
      .o_data(valid_3_6)
  );
   
  one_pulse_generator box_6(
      .clkin(clkin),
      .signal(valid_3_6),
      .pulse_signal(pulse_6_1)
  ); */

  one_pulse_generator one_pulse_generator_4(
                        .clkin(clkin),
                        .signal(user_start),
                        .pulse_signal(pulse_4_1)
                      );
  //one_pulse_generator box_5(
  //    .clkin(clkin),
  //    .signal(read_1_3),
  //    .pulse_signal(pulse_5_2)
  //);

  counter_ack_block #(.num_instructions(num_inst))ack_generator_mod_7(
                      .clkin(clkin),
                      .trigger_start(start_cmd_1_7),
                      .ack_signals(ack_7_1)
                    );

  one_pulse_generator pulse_gen_9(
                        .clkin(clkin),
                        .signal(read_1_3),
                        .pulse_signal(pulse_9_8)
                      );
endmodule
