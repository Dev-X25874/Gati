//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Configuration Block
// Project Name: Gati
// Description: Is the top module that integrates all the sub modules of the configuration block.
//////////////////////////////////////////////////////////////////////////////////
`include "instructions.vh"
module config_blk #(
    parameter  ADDR_W=32,
    parameter  INST_W=256,
    parameter NUM_INSTRUCTIONS =4,
    parameter BURST_LEN_AXI = 7, //is default burst length
    parameter BURST_LEN_WIDTH=8,
    parameter OPCODE_W=4,
    parameter LAY_N=12, //WIDTH OF LAYER NUMBER
    parameter TOTAL_LAY_N=12, //WIDTH OF TOTAL NO.OF LAYERS
    parameter DEPTH=100,
    parameter STATUS_DRAM_LIM=10)
  (
    input clkin,
    input rst,
    input user_start,
    input valid,
    input sel,
	//input [255:0] temp_data,
	//input temp_wren,
    input [INST_W-1:0]instruction_data,
    input done,//from bus master
    output  memory_read_r,memory_valid,
    output [7:0]mem_address,
    output mem_last,
    output  [BURST_LEN_WIDTH-1:0]mem_burst_len,
    input [NUM_INSTRUCTIONS-1:0]ack_signals, //acknowledgement signals from slave blocks
    output[NUM_INSTRUCTIONS-1:0]start_command,// start command to slave blocks after receiving start instruction
    output start_out,// start pulse that pulses for each start instruction
    output [INST_W-1:0]o_instruction_bus,//for bus master, we can use common for both opcode and data in ports of the bus master
    output o_instruction_bus_v,//for bus master
    output start_bus //for bus master
  );
  wire status_3_1;
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
  wire address_valid;
  wire [ADDR_W-1:0]global_start;
  wire [ADDR_W-1:0]global_stop;


//instantiation of DRAM Request Controller
  ctrl_dram_req #(.ADDR_W(ADDR_W),
                  .BURST_LEN_AXI(BURST_LEN_AXI),
                  .BURST_LEN_WIDTH(BURST_LEN_WIDTH))
                dram_controller_1
                (.clkin(clkin),
                 .user_start(user_start),
                 .status(status_3_1),
                 .global_reg_address_start(global_start),
                 .global_reg_address_stop(global_stop),
                 .address_valid(address_valid),
                 .read_req(memory_read_r),
                 .valid(memory_valid),
                 .o_address(mem_address),
                 .last(mem_last),
                 .burst_len(mem_burst_len));


////Instruction Queue Controller Instantiation                 
  controller_inst_q #(.INSTRUCT_W(INST_W),.ADDR_W(ADDR_W)) inst_q_controller_2(
                      .clkin(clkin),
                      .valid(valid),
                      .sel(sel),
                      .user_start(user_start),
                      .i_instruction_data(instruction_data),
                      .o_instruction(instruction_2_3),
                      .o_instruction_valid(instruction_v_2_3),
                      .o_address_valid(address_valid),
                      .o_global_start(global_start),
                      .o_global_stop(global_stop)
                    );

//Instruction Queue Instatiation                    
  instruct_q #(.INSTRUCT_W(INST_W),
               .DEPTH(DEPTH),
               .STATUS_DRAM_LIM(STATUS_DRAM_LIM))
             inst_q_3(
               .clkin(clkin),
               .rst(rst),
				.instruct_mem(instruction_2_3),
               .read_req_inst(read_req_3_4),
               .instruct_valid(instruction_v_2_3),
               .o_instruction(o_instruction_3_5),
               .o_instruction_valid(o_instruction_3_5_v),
               .o_status_dram(status_3_1),
               .o_status_inst(status_3_4)
             );
	

 
//Instruction Read Controller Instantiation             
  inst_read_ctrl #(.NUM_INSTRUCTIONS(NUM_INSTRUCTIONS),
                   .OPCODE_W(OPCODE_W),
                   .LAY_N(LAY_N),
                   .TOTAL_LAY_N(TOTAL_LAY_N))inst_read_ctrl_4(
                   .clkin(clkin),
                   .valid_ack(valid_6_4),
                   .prev_in(prev_6_4),
                   .ack_in(ack_6_4),
	  			   .valid_inst(o_instruction_3_5_v),
                   .layer_number(o_instruction_3_5[`START_LayerNumber]),
                   .total_layers(o_instruction_3_5[`START_TotalLayers]),
                   .status_inst_q(status_3_4),
                   .user_start(user_start),
                   .done_status(done),
                   .opcode(o_instruction_3_5[OPCODE_W-1:0]),
                   .bus_master_valid(start_bus),
                   .start_command(start_command),
                   .start_out(start_out),
                   .read_signal(read_req_3_4)
                 );

//Instantiation of Acknowledgment Controller
  ctrl_ack #(.NUM_INSTRUCTIONS(NUM_INSTRUCTIONS))ack_block_6(
             .clkin(clkin),
             .inst_signals(ack_signals),
             .status_ack(ack_6_4),
             .status_prev(prev_6_4),
             .o_valid_sig(valid_6_4)
           );
assign o_instruction_bus=o_instruction_3_5;
assign o_instruction_bus_v=o_instruction_3_5_v;

endmodule
