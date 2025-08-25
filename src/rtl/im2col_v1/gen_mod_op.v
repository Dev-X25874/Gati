module gen_mod_op_v1 #(
    parameter DATA_WIDTH = 8,
    parameter UPPER_BOUND = 224,
    parameter STRIDE = 3,
    parameter N_MOD_STAGES = 8
    )
    (
        input [(UPPER_BOUND)-1:0] crd,
        input [(DATA_WIDTH)-1:0] lower_bound,
        input clk,
        input rst,
        input  [$clog2(THETA_WIDTH)-1:0] theta,
        output [DATA_WIDTH-1:0] o_partial,
        output [$clog2(THETA_WIDTH)-1:0] o_shift
    );
       
    // wire [DATA_WIDTH-1:0] partial [5:0];
    // wire [9:0]            shift   [5:0];

    localparam THETA_WIDTH = STRIDE << (N_MOD_STAGES-2);

    wire [(UPPER_BOUND)-1:0] diff;

    assign diff = crd - lower_bound;
    
    // 7 blocks pipline architecture for calculating mod
    genvar i;
    generate
        for(i=0; i<N_MOD_STAGES-1; i=i+1) begin: blocks

            wire [DATA_WIDTH-1:0] partial;
            wire [$clog2(THETA_WIDTH)-1:0] shift;

            if(i == 0) begin
            mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(STRIDE), .N_MOD_STAGES(N_MOD_STAGES)) modut1(
                .clk(clk),
                .rst(rst),
                .diff(diff),
                .theta(theta),
                .o_partial(partial),
                .o_shift(shift)
            );
            end

        else if (i == N_MOD_STAGES-2) begin
            mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(STRIDE), .N_MOD_STAGES(N_MOD_STAGES)) modut7(
            .clk(clk),
            .rst(rst),
            .diff(blocks[i-1].partial),
            .theta(blocks[i-1].shift),
            .o_partial(o_partial),
            .o_shift(o_shift)
        );
        end

        else begin
            mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(STRIDE), .N_MOD_STAGES(N_MOD_STAGES)) modut(
            .clk(clk),
            .rst(rst),
            .diff(blocks[i-1].partial),
            .theta(blocks[i-1].shift),
            .o_partial(partial),
            .o_shift(shift)
        );
        end
    end
endgenerate

endmodule