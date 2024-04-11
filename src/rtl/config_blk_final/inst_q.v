//////////////////////////////////////////////////////////////////////////////////
// Design Name: Config Block
// Module Name: Instruction Queue
// Project Name: Gati
// Description: Stores instruction data from DRAM into synchronous FIFO.
// Sends the stored instruction data to bus master and inst read controller when a read enable is received.
//////////////////////////////////////////////////////////////////////////////////
//
module instruct_q #(
    parameter instruct_w=256
)(
    input clkin,
    input [instruct_w-1:0]instruct_mem, //talking to inst q controller
    input read_req_inst, //talking to inst read controller
    input instruct_valid, //talking to isnt q controller
    output [instruct_w-1:0]o_instruction,
    output o_instruction_valid,
    output o_status_dram,
    output o_status_inst
);
synchronous_fifo  instant(.clk(clkin),.rst_n(1'b1),.w_en(instruct_valid),.r_en(read_req_inst),.data_in(instruct_mem),.data_out(o_instruction),.data_out_valid(o_instruction_valid),.full(),.empty(),.ten_trigg(o_status_dram),.not_empty(o_status_inst));
endmodule