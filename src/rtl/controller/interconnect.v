`include "../common/instructions.vh"

module interconnect #(
    DATA_WIDTH_OB = 32,
    N_SA = 4,
    OPCODE_WIDTH = 4
)(
    input [OPCODE_WIDTH-1:0]opcode,
    input [DATA_WIDTH_OB*N_SA-1:0] SA_data,
    input [N_SA-1:0] SA_data_valid,
    input [DATA_WIDTH_OB*N_SA-1:0] FC_data,
    input [N_SA-1:0] FC_data_valid,
    input [DATA_WIDTH_OB*N_SA-1:0] EltWise_data,
    input [N_SA-1:0] EltWise_data_valid,
    output reg [DATA_WIDTH_OB*N_SA-1:0] data_tail_blk_in,
    output reg [N_SA-1:0] data_tail_blk_vaild
);

    always @(*) begin
        case(opcode)
            `OP_CONV: begin
                data_tail_blk_in = SA_data;
                data_tail_blk_vaild = SA_data_valid;
            end
            `OP_FC: begin
                data_tail_blk_in = FC_data;
                data_tail_blk_vaild = FC_data_valid;
            end
            `OP_EltWise: begin
                data_tail_blk_in = EltWise_data;
                data_tail_blk_vaild = EltWise_data_valid;
            end
            default: begin
                data_tail_blk_in = 0;
                data_tail_blk_vaild = 0;
            end
        endcase
    end
endmodule