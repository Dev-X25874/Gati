module interconnect_dram_data_aligner#(parameter QUANT_OP_FIFO = 1,
                                       parameter OPCODE_WIDTH = 4,
                                       parameter AXI_DATA_WIDTH = 256)
(
    input [OPCODE_WIDTH-1:0] opcode,
    input [QUANT_OP_FIFO*AXI_DATA_WIDTH-1:0] i_quant_fifo_data,
    input [QUANT_OP_FIFO-1 : 0] i_quant_fifo_wren,
    input [AXI_DATA_WIDTH-1 : 0] i_nms_fifo_data,
    input [QUANT_OP_FIFO-1 : 0] i_nms_fifo_wren,
    input [QUANT_OP_FIFO-1 : 0] i_rt_fifo_wren,
    input [AXI_DATA_WIDTH-1 : 0] i_rt_fifo_data,
    input i_shift_reg_enable,
    input i_acc_quant_enable,
    output reg o_op_fifo_enable = 0,
    output reg [AXI_DATA_WIDTH-1 : 0] o_op_fifo_data = 0,
    output reg [QUANT_OP_FIFO-1 : 0] o_op_fifo_wren = 0
);

`include "instructions.vh"
 
always @(*) begin
    case(opcode)
    `OP_TailBlock: begin
        o_op_fifo_data = i_quant_fifo_data;
        o_op_fifo_wren = i_quant_fifo_wren;
        o_op_fifo_enable = i_acc_quant_enable;
    end
    `OP_NMS: begin
        o_op_fifo_data = i_nms_fifo_data;
        o_op_fifo_wren = i_nms_fifo_wren;
        o_op_fifo_enable = i_shift_reg_enable;
    end
    `OP_TRANSPOSE: begin
        o_op_fifo_data = i_rt_fifo_data;
        o_op_fifo_wren = i_rt_fifo_wren;
        o_op_fifo_enable = i_shift_reg_enable;
    end
    default: begin
        o_op_fifo_data = 0;
        o_op_fifo_wren = 0;
        o_op_fifo_enable = 0;
    end
    endcase     
end

endmodule