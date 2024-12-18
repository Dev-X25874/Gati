module gen_mod_op_v1 #(
    parameter DATA_WIDTH = 8,
    parameter UPPER_BOUND = 224,
    parameter STRIDE = 3)
    (
        input [$clog2(UPPER_BOUND)-1:0] crd,
        input [$clog2(UPPER_BOUND)-1:0] lower_bound,
        input clk,
        input rst,
        input  [$clog2(STRIDE*64):0] theta,
        output [DATA_WIDTH-1:0] o_partial,
        output [$clog2(STRIDE*64):0] o_shift
    );
       
    // wire [DATA_WIDTH-1:0] partial [5:0];
    // wire [9:0]            shift   [5:0];
    wire [$clog2(UPPER_BOUND)-1:0] diff;

    assign diff = crd - lower_bound;
    
    // 7 blocks pipline architecture for calculating mod
    genvar i;
    generate
        for(i=0; i<7; i=i+1) begin: blocks

            wire [DATA_WIDTH-1:0] partial;
            wire [$clog2(STRIDE*64):0] shift;

            if(i == 0) begin
            mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(STRIDE)) modut1(
                .clk(clk),
                .rst(rst),
                .diff(diff),
                .theta(theta),
                .o_partial(partial),
                .o_shift(shift)
            );
        end

        else if (i == 6) begin
            mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(STRIDE)) modut7(
            .clk(clk),
            .rst(rst),
            .diff(blocks[i-1].partial),
            .theta(blocks[i-1].shift),
            .o_partial(o_partial),
            .o_shift(o_shift)
        );
        end

        else begin
            mod_op_v1 #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(STRIDE)) modut(
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