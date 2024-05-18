//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Instruction Queue
// Project Name: Gati
// Description: Stores instruction data from DRAM into synchronous FIFO.
// Sends the stored instruction data to bus master and inst read controller when a read enable is received.
//////////////////////////////////////////////////////////////////////////////////
//
module instruct_q #(
    parameter INSTRUCT_W=256,
    parameter DEPTH=100,
    parameter DATA_WIDTH=256,
    parameter  STATUS_DRAM_LIM=10
  )(
    input clkin,
    input [INSTRUCT_W-1:0]instruct_mem, //talking to inst q controller
    input read_req_inst, //talking to inst read controller
    input instruct_valid, //talking to isnt q controller
    output [INSTRUCT_W-1:0]o_instruction,
    output [DATA_WIDTH-1:0]o_instruction_2,
    output o_instruction_valid,
    output o_instruction_valid_2,
    output o_status_dram,
    output o_status_inst
  );
  synchronous_fifo  #(.DEPTH(DEPTH),.DATA_WIDTH(DATA_WIDTH),.STATUS_DRAM_LIM(STATUS_DRAM_LIM))
                    instant(.clk(clkin),
                            .rst_n(1'b1),
                            .w_en(instruct_valid),
                            .r_en(read_req_inst),
                            .data_in(instruct_mem),
                            .data_out(o_instruction),
                            .data_out_2(o_instruction_2)
                            .data_out_valid(o_instruction_valid),
                            .data_out_valid_2(o_instruction_valid_2),
                            .full(),
                            .empty(),
                            .ten_trigg(o_status_dram),
                            .not_empty(o_status_inst));
endmodule
