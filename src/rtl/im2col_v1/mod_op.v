module mod_op_v1 #(
    parameter DATA_WIDTH = 8,
    parameter STRIDE = 3,
    parameter N_MOD_STAGES = 8
    )
    (
        input  [DATA_WIDTH-1:0] diff,
        input clk,
        input rst,
        input  [$clog2(THETA_WIDTH)-1:0] theta,
        output [DATA_WIDTH-1:0] o_partial,
        output [$clog2(THETA_WIDTH)-1:0] o_shift
    );

    localparam THETA_WIDTH = STRIDE << (N_MOD_STAGES-2);

    wire select;
    reg  [$clog2(THETA_WIDTH)-1:0] r_shift;
    wire cmp;
    wire non_zero;
    reg  [DATA_WIDTH-1:0] r_partial;
    wire [$clog2(THETA_WIDTH)-1:0] subtrahend;
   // wire [9:0] theta;

    //assign theta = stride * 64;
    assign cmp = (diff >= theta)? 1:0;
    assign non_zero = |(theta);
    assign select = cmp && non_zero;
    assign subtrahend = (select)? theta:0;

    always @ (posedge clk) begin
        if(!rst) begin
            r_partial <= 0;
            r_shift <= 0;
        end
        else begin
            r_partial <= diff - subtrahend;
            r_shift <= theta >> 1;
        end
    end
    
    assign o_partial = r_partial;
    assign o_shift = r_shift;

endmodule