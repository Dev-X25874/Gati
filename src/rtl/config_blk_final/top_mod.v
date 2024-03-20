`include "controller_inst_q.v"
`include "ctrl_ack.v"
`include "ctrl_dram_req.v"
`include "inst_read_ctrl.v"
`include "inst_q.v"
`include "status_reg.v"
`include "bus_master_fake.v"

module top_mod(
    input clkin,
    input user_start,
    input ctrl_q_valid,
    input ctrl_q_sel,
    input [255:0]instruction_data,
    input [31:0]global_start,
    input [31:0]global_stop,
    output memory_read_r,memory_valid,
    output [7:0]mem_address,
    output mem_last,
    output [7:0]mem_burst_len

  );
  wire [255:0]instruct_q_in;
  wire queue_valid;
  wire req_inst_q;
  controller_inst_q control_q(.clkin(clkin),.valid(ctrl_q_valid),.sel(ctrl_q_sel),.i_instruction_data(instruction_data),.o_instruction(instruct_q_in),.o_instruction_valid(queue_valid));

  wire [255:0]master_bus_ins;
  wire o_status_dram,o_status_inst;
  instruct_q queue(.clkin(clkin),.instruct_mem(instruct_q_in),.read_req_inst(req_inst_q),.instruct_valid(queue_valid),.o_instruction(master_bus_ins),.o_status_dram(o_status_dram),.o_status_inst(o_status_inst));

  wire [3:0]opcode_bus_master;
  wire bus_start;
  wire done_bus_master;
  wire inst_1, inst_1_valid;
  wire inst_2, inst_2_valid;
  wire bus_master_valid;
  wire opcode_valid;
  bus_master_fake bus_master(.clkin(clkin),.instruction_from_q(master_bus_ins),.opcode_valid(opcode_valid),.bus_master_valid(bus_master_valid),.done_status(done_bus_master),.ack_im2col(inst_1),.ack_im2col_valid(inst_1_valid),.ack_tail(inst_2),.ack_tail_valid(inst_2_valid),.opcode(opcode_bus_master),.start_blocks());
  status_reg status_block(.clkin(clkin),.opcode(opcode_bus_master),.opcode_valid(opcode_valid),.prev_in(prev_in_ack),.ack_in(ack_in_ack),.valid_ack(valid_ack_ack),.prev_out(),.ack_sig(),.next_out(),.bus_master_valid(bus_master_valid));
  ctrl_ack control_ack(.clkin(clkin),.inst_2(inst_2),.inst_1(inst_1),.inst_3(),.inst_4(),.inst_2_valid(inst_2_valid),.inst_1_valid(inst_1_valid),.inst_3_valid(),.inst_4_valid(),.status_ack(ack_in_ack),.status_prev(prev_in_ack),.o_valid_sig(valid_ack_ack));


  //wire [3:0]ack_set_status;
  wire [7:0]prev_in_ack;
  wire [3:0]ack_in_ack;
  wire [3:0]valid_ack_ack;
  //wire [7:0]prev_sent_display;
  //wire [7:0]next_status_reg;

  inst_read_ctrl read_inst(
                   .clkin(clkin),
                   .status_inst_q(o_status_inst),
                   .user_start(user_start),
                   .done_status(done_bus_master),
                   .read_signal(req_inst_q)
                 );
  ctrl_dram_req control_the_dram(.clkin(clkin),.user_start(user_start),.status(o_status_dram),.global_reg_address_start(global_start),.global_reg_address_stop(global_stop),.read_req(memory_read_r),.valid(memory_valid),.o_address(mem_address),.last(mem_last),.burst_len(mem_burst_len));
endmodule
