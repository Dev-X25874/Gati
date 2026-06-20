`timescale 1ns / 1ps
`include "../common/instructions.vh"
`include "../common/arch_param.vh"

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
    parameter CLIP_WIDTH = 8,
    parameter LR_NEG_ALPHA_WIDTH = 10,
    parameter LR_POS_ALPHA_WIDTH = 10
)
(
    input                           clk,
    input                           enable,
    input [LR_NEG_ALPHA_WIDTH-1:0]  lr_neg_alpha,
    input [LR_POS_ALPHA_WIDTH-1:0]  lr_pos_alpha,
    input signed [DATA_WIDTH-1:0]   i_data,
    input                           i_valid,
    output signed [DATA_WIDTH-1:0]  o_data,   
    output                          o_valid,
    input  [CLIP_WIDTH-1:0]         i_clip,
    input  [ACT_TYPE_WIDTH-1 : 0]   i_act_type
);

    reg signed [DATA_WIDTH-1:0] o_data_r = 0;

    `ifdef GEN_LEAKY_RELU

    assign o_data = ((act_type_r == `ACT_LEAKYRELU) && o_valid) ? 
                    leaky_reg[DATA_WIDTH-1:0] : o_data_r;

    reg signed [(DATA_WIDTH + LR_NEG_ALPHA_WIDTH)-1:0] leaky_reg; 
    reg [ACT_TYPE_WIDTH-1:0] act_type_r = 0;
    wire [LR_NEG_ALPHA_WIDTH-1:0] selected_alpha;

    assign selected_alpha = (i_data[DATA_WIDTH-1] == 1) ? lr_neg_alpha : lr_pos_alpha;
    
    `else

    assign o_data = o_data_r;

    `endif

    reg o_valid_r = 0;
    assign o_valid = o_valid_r;

  always @(posedge clk) begin
    if (i_valid & enable) begin
      o_valid_r <= i_valid;
      `ifdef GEN_LEAKY_RELU
      act_type_r <= i_act_type;
      `endif
      case (i_act_type)
    
        `ifdef GEN_LEAKY_RELU  
        // 0 is added in MSB to prevent alpha inputs greater than 2^(LR_NEG_ALPHA_WIDTH-1) getting interpreted as negative value.
        // Ex.: PosAlpha 524 would turn into -500
        `ACT_LEAKYRELU:begin
            leaky_reg <= ($signed({1'b0, selected_alpha}) * i_data) >>> 8;
        end
        `endif
              
        `ACT_RELU:begin
          if (i_data[DATA_WIDTH-1] == 1) begin
            o_data_r <= 0;
          end else begin
            o_data_r <= i_data;
          end
        end

        `ACT_CLIP:begin
          if (i_data[DATA_WIDTH-1] == 1) begin
            o_data_r <= 0;
          end else begin
            if(i_data > i_clip) o_data_r <= i_clip;
            else o_data_r <= i_data;
          end
        end

        default: o_data_r <= i_data;
      endcase       
    end else if(i_valid & ~enable) begin
      o_data_r <= i_data;
      o_valid_r <= i_valid;
      `ifdef GEN_LEAKY_RELU
      act_type_r <= `ACT_RELU; // bypass result is plain passthrough, never leaky
      `endif
    end else begin
      o_valid_r <= 0;
    end
  end
  
endmodule

module top_relu_gen#(
    parameter                        N = 8,
    parameter                        DATA_WIDTH = 32,
    parameter                        ACT_TYPE_WIDTH = 4,
    parameter                        CLIP_WIDTH = 8,
    parameter                        LR_NEG_ALPHA_WIDTH = 10, 
    parameter                        LR_POS_ALPHA_WIDTH = 10
)(

    input                               top_clk,
    input  [N*DATA_WIDTH-1:0]           top_i_data,
    input  [N-1:0]                      top_i_valid,
    input                               relu_enable,
    input  signed [N*LR_NEG_ALPHA_WIDTH-1:0]      top_lr_neg_alpha,
    input  signed [N*LR_POS_ALPHA_WIDTH-1:0]      top_lr_pos_alpha,
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
        .CLIP_WIDTH(CLIP_WIDTH),
        .LR_NEG_ALPHA_WIDTH(LR_NEG_ALPHA_WIDTH),
        .LR_POS_ALPHA_WIDTH(LR_POS_ALPHA_WIDTH)	
        )
        top_relu_inst (
        .clk     (top_clk),
        .i_data  (top_i_data[i*DATA_WIDTH+:DATA_WIDTH]),
        .i_valid (top_i_valid[i]),
        .o_data  (top_o_data[i*DATA_WIDTH+:DATA_WIDTH]),
        .enable  (relu_enable),
        .lr_neg_alpha(top_lr_neg_alpha[i*LR_NEG_ALPHA_WIDTH+:LR_NEG_ALPHA_WIDTH]),
        .lr_pos_alpha(top_lr_pos_alpha[i*LR_POS_ALPHA_WIDTH+:LR_POS_ALPHA_WIDTH]),
        .o_valid (top_o_valid[i]),
        .i_clip  (top_i_clip[i*CLIP_WIDTH+:CLIP_WIDTH]),
        .i_act_type(top_i_acttype[i*ACT_TYPE_WIDTH+ :ACT_TYPE_WIDTH])
        );
    end
endgenerate
endmodule
