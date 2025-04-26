module gen_mod_op #(
    parameter DATA_WIDTH = 8,
    parameter OH_WIDTH = 224,
    parameter POOL_WIDTH = 4
    )
    (
        // input [OH_WIDTH-1:0] crd, 
        // input [OH_WIDTH-1:0] lower_bound,
        input clk,
        input rst,
        input [OH_WIDTH-1:0] diff, //Dividend-OH-Image Dimension
        input  [POOL_WIDTH-1:0] pool_width, //Divisor-Pool_Height-Pool DImension
        output [DATA_WIDTH-1:0] o_partial //Remainder-mod_value
        //output [POOL_WIDTH-1:0] o_shift
    );

    wire [$clog2(POOL_WIDTH*64):0] theta;
    assign theta = pool_width*64;

    //wire [OH_WIDTH-1:0] diff; //Dividend-OH

    //assign diff = crd - lower_bound;
    
    // 7 blocks pipline architecture for calculating mod
    genvar i;
    generate
        for(i=0; i<7; i=i+1) begin: blocks

            wire [DATA_WIDTH-1:0] partial;
            wire [$clog2(POOL_WIDTH*64):0] shift;

            if(i == 0) begin
            mod_op #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(POOL_WIDTH)) modut1(
                .clk(clk),
                .rst(rst),
                .diff(diff),
                .theta(theta),
                .o_partial(partial),
                .o_shift(shift)
            );
        end

        else if (i == 6) begin
            mod_op #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(POOL_WIDTH)) modut7(
            .clk(clk),
            .rst(rst),
            .diff(blocks[i-1].partial),
            .theta(blocks[i-1].shift),
            .o_partial(o_partial),
            .o_shift(o_shift)
        );
        end

        else begin
            mod_op #(.DATA_WIDTH(DATA_WIDTH), .STRIDE(POOL_WIDTH)) modut(
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