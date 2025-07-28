`include "../common/instructions.vh"

module quant_interconnect #(
    parameter SHIFT_WIDTH = 8,
    parameter OPCODE_WIDTH = 4
)(
    input [OPCODE_WIDTH-1 : 0] opcode,
    input [SHIFT_WIDTH-1 : 0] EltWise_fp_cast_shift,

    output reg fp_cast,
    output reg [SHIFT_WIDTH-1 : 0] fp_cast_shift
);

    always @(*) begin
        case(opcode)
            `OP_CONV: begin
                fp_cast = 1'b0;
                fp_cast_shift = 0;
            end
            `OP_FC: begin
                fp_cast = 1'b0;
                fp_cast_shift = 0;
            end
            `OP_EltWise: begin
                fp_cast = 1'b1;
                fp_cast_shift = EltWise_fp_cast_shift;
            end
            default: begin
                fp_cast = 1'b0;
                fp_cast_shift = 0;
            end
        endcase
    end

endmodule