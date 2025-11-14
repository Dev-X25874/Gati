module top_Tanh_Sigmoid_Engine#(
    parameter DATA_WIDTH    = 8,
    parameter SCALE_WIDTH   = 32,
    parameter FP_BITS       = 16,
    parameter LUT_SIZE      = 128,
    parameter OUT_DATA_WIDTH = 32
)(
    input i_clk,
    input i_rst,

    input i_data_valid,
    input signed [SCALE_WIDTH-1:0] scaled_data_in,
    input i_tanh_sigmoid, // 0 for Tanh, 1 for Sigmoid

    output reg o_data_valid,
    output reg [OUT_DATA_WIDTH-1:0] o_data_out
);

    wire is_sign;
    assign is_sign = r_tanh_data_in[OUT_DATA_WIDTH-1];

    reg signed [OUT_DATA_WIDTH-1 : 0] r_tanh_data_in;
    reg r_i_datavalid;
    always@(posedge i_clk) begin
        if(i_data_valid) begin
            r_tanh_data_in <= i_tanh_sigmoid ? (scaled_data_in >>> 1) : scaled_data_in;
            r_i_datavalid <= 1'b1;
        end
        else r_i_datavalid <= 1'b0;
    end 
    reg signed [OUT_DATA_WIDTH-1 : 0] r_tanh_data_in1;
    reg r_tanh_datavalid;
    always@(posedge i_clk) begin
        if(r_i_datavalid) begin
            r_tanh_data_in1 <= is_sign ? (~(r_tanh_data_in)+1) : r_tanh_data_in; 
            r_tanh_datavalid <= 1'b1;
        end
        else r_tanh_datavalid <= 1'b0;
    end
    wire [OUT_DATA_WIDTH-1 : 0] w_tanh_interpolated_out;
    wire w_tanh_data_valid;
    tanh_interpolator_engine #(
        .DATA_WIDTH(OUT_DATA_WIDTH),
        .LUT_SIZE(LUT_SIZE),
        .FP_BITS(FP_BITS)
    ) tanh_engine(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data_valid(r_tanh_datavalid),
        .i_data(r_tanh_data_in1),
        .o_data_valid(w_tanh_data_valid),
        .o_data(w_tanh_interpolated_out)
    );

    // Pipeline registers for sign bit
    reg r_sign;
    genvar i;
    generate
        for (i = 0; i <= 7; i = i + 1) begin : pipeline_regs_sign
            reg sign;
            if(i == 0) begin
                always @(posedge i_clk) sign <= is_sign; 
            end 
            else if(i==7) begin
                always @(posedge i_clk) r_sign <= pipeline_regs_sign[i-1].sign;
            end
            else begin
                always @(posedge i_clk) sign <= pipeline_regs_sign[i-1].sign;
            end
        end
    endgenerate

    // Post-processing of tanh interpolator engine output
    wire signed [OUT_DATA_WIDTH - 1 : 0] w_tanh_data_out;
    assign w_tanh_data_out = r_sign ? (~(w_tanh_interpolated_out)+1) : w_tanh_interpolated_out;
    always@(posedge i_clk) begin
        if(w_tanh_data_valid) begin
            o_data_out <= i_tanh_sigmoid ? (w_tanh_data_out+65535)>>>1 : w_tanh_data_out;
            o_data_valid <= 1;
        end
        else o_data_valid <= 0;
    end

endmodule



module top_Tanh_Sigmoid_Engine_lut#(
    parameter DATA_WIDTH    = 8,
    parameter SCALE_WIDTH   = 32,
    parameter FP_BITS       = 16,
    parameter LUT_SIZE      = 128,
    parameter OUT_DATA_WIDTH = 32
)(
    input i_clk,
    input i_rst,

    input i_data_valid,
    input signed [OUT_DATA_WIDTH-1:0] scaled_data_in, //increased width
    input i_tanh_sigmoid, // 0 for Tanh, 1 for Sigmoid

    output reg o_data_valid,
    output reg [OUT_DATA_WIDTH-1:0] o_data_out
);

    wire is_sign;
    assign is_sign = r_tanh_data_in[OUT_DATA_WIDTH-1];

    reg signed [OUT_DATA_WIDTH-1 : 0] r_tanh_data_in;
    reg r_i_datavalid;
    always@(posedge i_clk) begin
        if(i_data_valid) begin
            r_tanh_data_in <= i_tanh_sigmoid ? (scaled_data_in >>> 1) : scaled_data_in;
            r_i_datavalid <= 1'b1;
        end
        else r_i_datavalid <= 1'b0;
    end 
    reg signed [OUT_DATA_WIDTH-1 : 0] r_tanh_data_in1;
    reg r_tanh_datavalid;
    always@(posedge i_clk) begin
        if(r_i_datavalid) begin
            r_tanh_data_in1 <= is_sign ? (~(r_tanh_data_in)+1) : r_tanh_data_in; 
            r_tanh_datavalid <= 1'b1;
        end
        else r_tanh_datavalid <= 1'b0;
    end
    wire [OUT_DATA_WIDTH-1 : 0] w_tanh_interpolated_out;
    wire w_tanh_data_valid;
    tanh_interpolator_engine_lut #(
        .DATA_WIDTH(OUT_DATA_WIDTH),
        .LUT_SIZE(LUT_SIZE),
        .FP_BITS(FP_BITS)
    ) tanh_engine_lut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data_valid(r_tanh_datavalid),
        .i_data(r_tanh_data_in1),
        .o_data_valid(w_tanh_data_valid),
        .o_data(w_tanh_interpolated_out)
    );

    // Pipeline registers for sign bit
    reg r_sign;
    genvar i;
    generate
        for (i = 0; i <= 7; i = i + 1) begin : pipeline_regs_sign
            reg sign;
            if(i == 0) begin
                always @(posedge i_clk) sign <= is_sign; 
            end 
            else if(i==7) begin
                always @(posedge i_clk) r_sign <= pipeline_regs_sign[i-1].sign;
            end
            else begin
                always @(posedge i_clk) sign <= pipeline_regs_sign[i-1].sign;
            end
        end
    endgenerate

    // Post-processing of tanh interpolator engine output
    wire signed [OUT_DATA_WIDTH - 1 : 0] w_tanh_data_out;
    assign w_tanh_data_out = r_sign ? (~(w_tanh_interpolated_out)+1) : w_tanh_interpolated_out;
    always@(posedge i_clk) begin
        if(w_tanh_data_valid) begin
            o_data_out <= i_tanh_sigmoid ? (w_tanh_data_out+65535)>>>1 : w_tanh_data_out;
            o_data_valid <= 1;
        end
        else o_data_valid <= 0;
    end

endmodule
