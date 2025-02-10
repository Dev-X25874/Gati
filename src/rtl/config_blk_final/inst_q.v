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
    parameter  STATUS_DRAM_LIM=10
  )(
    input clkin,
    input rst,
	  input [INSTRUCT_W-1:0]instruct_mem, //talking to inst q controller
    input read_req_inst, //talking to inst read controller
    input instruct_valid, //talking to isnt q controller
    output [INSTRUCT_W-1:0]o_instruction,
    output o_instruction_valid,
    output o_status_dram,
    output o_status_inst
  );
	wire [$clog2(DEPTH):0] fifo_occupants;
	wire empt;
  sync_fifo  #(.W_ADDR($clog2(DEPTH)),
	           .W_DATA(INSTRUCT_W))
	instant(.clk_i(clkin),
            .a_rst_i(~rst),
            .wr_en_i(instruct_valid),
            .rd_en_i(read_req_inst),
            .wdata(instruct_mem),
            .rdata(o_instruction),
            .o_valid(o_instruction_valid),
         	  .datacount_o(fifo_occupants), 
            .empty_o(empt)
  );


		   assign o_status_inst=~empt;

		   assign o_status_dram=(fifo_occupants<STATUS_DRAM_LIM);

endmodule
