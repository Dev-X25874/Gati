`include "sync_fifo_config.v"
module instruct_q(
    input clkin,
    input [255:0]instruct_mem,
    input read_req_inst,
    input instruct_valid,
    output [255:0]o_instruction,
    output o_status_dram,
    output o_status_inst
);
synchronous_fifo  instant(.clk(clkin),.rst_n(1'b1),.w_en(instruct_valid),.r_en(read_req_inst),.data_in(instruct_mem),.data_out(o_instruction),.full(),.empty(),.ten_trigg(o_status_dram),.not_empty(o_status_inst));
endmodule