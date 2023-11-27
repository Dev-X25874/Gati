`timescale 1ns / 1ps

/* relu - activation function
 * returns: 0 if the i_data is negative
 *          CLIP if i_data is greater than that
 *          i_data otherwise

 * in the ideal case, CLIP is the largest positive number
 * of DATA_WIDTH, this makes relu behave as if no CLIP
 * value was specified.
 */ 

module relu #(
    parameter DATA_WIDTH = 32,
    /* biggest possible signed DATA_WIDTH number */
    parameter CLIP = {1'b0,{DATA_WIDTH-1{1'b1}}}
)
(
    input clk,
    input signed [DATA_WIDTH-1:0] i_data,
    input i_valid,
    output signed [DATA_WIDTH-1:0] o_data,
    output o_valid
);

    reg signed [DATA_WIDTH-1:0] o_data_r = 0;
    assign o_data = o_data_r;

    reg o_valid_r = 0;
    assign o_valid = o_valid_r;

    always @(posedge clk) begin
        if (i_valid) begin
            if (i_data > CLIP) begin
                o_data_r <= CLIP;
            end else if (i_data[DATA_WIDTH-1] == 1) begin
                o_data_r <= 0;
            end else begin
                o_data_r <= i_data;
            end
        end
        o_valid_r <= i_valid;
    end
endmodule
