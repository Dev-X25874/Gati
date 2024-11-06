
`timescale 1ns / 1ps
`include "../common/instructions.vh"
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
    parameter ACT_TYPE_WIDTH = 4,
    /* biggest possible signed DATA_WIDTH number */
    parameter CLIP_WIDTH = 8
)
(
    input                           clk,
    input                           enable,
    input signed [DATA_WIDTH-1:0]   i_data,
    input                           i_valid,
    output signed [DATA_WIDTH-1:0]  o_data,   
    output                          o_valid,
    input  [CLIP_WIDTH-1:0]         i_clip,
    input  [ACT_TYPE_WIDTH-1 : 0]   i_act_type
);

    reg signed [DATA_WIDTH-1:0] o_data_r = 0;
    assign o_data = o_data_r;

    reg o_valid_r = 0;
    assign o_valid = o_valid_r;
    
    //To check the freq
    
    // reg signed [DATA_WIDTH-1:0] r_i_data;
    // always @(posedge clk) begin
    //     r_i_data <= i_data;
    // end

    always @(posedge clk) begin
        if (i_valid & enable) begin
            if (i_data[DATA_WIDTH-1] == 1) begin
                o_data_r <= 0;
            end else begin
                case (i_act_type)
                   `ACT_RELU:
                    begin
                        o_data_r <= i_data;
                    end
                    
                    `ACT_CLIP:
                    begin
                        if(i_data > i_clip) o_data_r <= i_clip;
                        else o_data_r <= i_data;
                    end

                    default: o_data_r <= i_data;
                endcase
               
            end
        o_valid_r <= i_valid;
        end 
        else if(i_valid & ~enable)
        begin
            o_data_r <= i_data;
            o_valid_r <= i_valid;
        end
        else begin
            o_valid_r <= 0;
        end
    end
endmodule

module top_relu_gen#(
    parameter                        N = 8,
    parameter                        DATA_WIDTH = 32,
    parameter                        ACT_TYPE_WIDTH = 4,
    parameter                        CLIP_WIDTH = 8
)(

    input                               top_clk,
    input  [N*DATA_WIDTH-1:0]           top_i_data,
    input  [N-1:0]                      top_i_valid,
    input                               relu_enable,
    output [N*DATA_WIDTH-1:0]           top_o_data,
    output [N-1:0]                      top_o_valid,
    input  [N*CLIP_WIDTH-1:0]           top_i_clip,
    input  [N*ACT_TYPE_WIDTH-1:0]       top_i_acttype

);
generate 
    genvar i;
    for (i = 0; i < N ; i = i + 1) begin: RELU_INST
        relu #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACT_TYPE_WIDTH(ACT_TYPE_WIDTH),
        .CLIP_WIDTH(CLIP_WIDTH)	
        )
        top_relu_inst (
        .clk     (top_clk),
        .i_data  (top_i_data[i*DATA_WIDTH+:DATA_WIDTH]),
        .i_valid (top_i_valid[i]),
        .o_data  (top_o_data[i*DATA_WIDTH+:DATA_WIDTH]),
        .enable  (relu_enable),
        .o_valid (top_o_valid[i]),
        .i_clip  (top_i_clip[i*CLIP_WIDTH+:CLIP_WIDTH]),
        .i_act_type(top_i_acttype[i*ACT_TYPE_WIDTH+ :ACT_TYPE_WIDTH])
        );
    end
endgenerate
endmodule
