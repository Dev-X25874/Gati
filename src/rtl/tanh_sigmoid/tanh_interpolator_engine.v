module tanh_interpolator_engine#(
    parameter DATA_WIDTH    = 32,
    parameter LUT_SIZE      = 128,
    parameter FP_BITS       = 16
)
(
    input i_clk,
    input i_rst,

    input i_data_valid,
    input [DATA_WIDTH-1:0] i_data,

    output reg o_data_valid,
    output reg [DATA_WIDTH-1:0] o_data
);

    wire [DATA_WIDTH-1:0] w_data;
    wire w_data_valid;
    wire [1:0] w_select;
    wire w_saturate_region;
    wire w_interpolate_region;
    wire w_pass_region;

    input_range_decoder#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    input_range_decoder_inst(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_data),
        .i_data_valid(i_data_valid),
        .o_data_valid(w_data_valid),
        .o_data(w_data),
        .o_select(w_select),
        .o_saturate_region(w_saturate_region),
        .o_interpolate_region(w_interpolate_region),
        .o_pass_region(w_pass_region)
    );

    wire [DATA_WIDTH-1:0] w_pass_through_data;
    wire w_pass_through_data_valid;
    pass_region#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    pass_region_inst(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_pass_region(w_pass_region),
        .i_data_valid(w_data_valid),
        .o_data_valid(w_pass_through_data_valid)
    );

    wire [DATA_WIDTH-1:0] w_saturated_data;
    wire w_saturated_data_valid;
    saturate_region#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    saturate_region_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_saturate(w_saturate_region),
        .o_saturate_data(w_saturated_data),
        .o_saturate_data_valid(w_saturated_data_valid)
    );

    wire [DATA_WIDTH-1:0] w_interpolated_data;
    wire w_interpolated_data_valid;
    interpolator_engine#(
        .DATA_WIDTH(DATA_WIDTH),
        .LUT_SIZE(LUT_SIZE),
        .FP_BITS(FP_BITS)
    )
    interpolator_engine_inst(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_interpolate_region(w_interpolate_region),
        .i_interpolator_datavalid(w_data_valid),
        .i_interpolator_data(w_data),
        .o_interpolated_datavalid(w_interpolated_data_valid),
        .o_interpolated_data(w_interpolated_data),

        .o_pass_data(w_pass_through_data)
    );

    // Output selection based on region
    // Pipeline registers for select signal
    reg [1:0] r_select;
    genvar i;
    generate
        for (i = 0; i <= 5; i = i + 1) begin : pipeline_regs_select
            reg [1:0] delayed_select;
            if(i == 0) begin
                always @(posedge i_clk) delayed_select <= w_select; 
            end 
            else if(i==5) begin
                always @(posedge i_clk) r_select <= pipeline_regs_select[i-1].delayed_select;
            end
            else begin
                always @(posedge i_clk) delayed_select <= pipeline_regs_select[i-1].delayed_select;
            end
        end
    endgenerate

    // pipeline registers for pass region and saturated region data
    reg [DATA_WIDTH-1:0] r_pass_data;
    reg r_pass_data_valid;
    reg [DATA_WIDTH-1:0] r_saturated_data;
    reg r_saturated_data_valid;

    genvar j;
    generate
        for (j = 0; j <= 4; j = j + 1) begin : pipeline_regs
            reg delayed_pass_data_valid;
            reg delayed_saturated_data_valid;
            if(j == 0) begin
                always @(posedge i_clk) begin
                    delayed_pass_data_valid <= w_pass_through_data_valid;
                    delayed_saturated_data_valid <= w_saturated_data_valid;
                end 
            end 
            else if(j==4) begin
                always @(posedge i_clk) begin
                    r_pass_data_valid <= pipeline_regs[j-1].delayed_pass_data_valid;
                    r_saturated_data_valid <= pipeline_regs[j-1].delayed_saturated_data_valid;
                end
            end
            else begin
                always @(posedge i_clk) begin
                    delayed_pass_data_valid <= pipeline_regs[j-1].delayed_pass_data_valid;
                    delayed_saturated_data_valid <= pipeline_regs[j-1].delayed_saturated_data_valid;
                end
            end
        end
    endgenerate

    // Output selection logic
    always@(*) begin
        case (r_select)
            2'b00: begin
                o_data = w_pass_through_data;
                o_data_valid = r_pass_data_valid;
            end
            2'b01: begin
                o_data = 32'd65535; // Saturated value (1.0)
                o_data_valid = r_saturated_data_valid;
            end
            2'b10: begin
                o_data = w_interpolated_data;
                o_data_valid = w_interpolated_data_valid;
            end
            default: begin
                o_data = {DATA_WIDTH{1'b0}};
                o_data_valid = 1'b0;
            end
        endcase
    end
    
endmodule


module tanh_interpolator_engine_lut#(
    parameter DATA_WIDTH    = 32,
    parameter LUT_SIZE      = 128,
    parameter FP_BITS       = 16
)
(
    input i_clk,
    input i_rst,

    input i_data_valid,
    input [DATA_WIDTH-1:0] i_data,

    output reg o_data_valid,
    output reg [DATA_WIDTH-1:0] o_data
);

    wire [DATA_WIDTH-1:0] w_data;
    wire w_data_valid;
    wire [1:0] w_select;
    wire w_saturate_region;
    wire w_interpolate_region;
    wire w_pass_region;

    input_range_decoder#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    input_range_decoder_inst(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_data),
        .i_data_valid(i_data_valid),
        .o_data_valid(w_data_valid),
        .o_data(w_data),
        .o_select(w_select),
        .o_saturate_region(w_saturate_region),
        .o_interpolate_region(w_interpolate_region),
        .o_pass_region(w_pass_region)
    );

    wire [DATA_WIDTH-1:0] w_pass_through_data;
    wire w_pass_through_data_valid;
    pass_region#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    pass_region_inst(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_pass_region(w_pass_region),
        .i_data_valid(w_data_valid),
        .o_data_valid(w_pass_through_data_valid)
    );

    wire [DATA_WIDTH-1:0] w_saturated_data;
    wire w_saturated_data_valid;
    saturate_region#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    saturate_region_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_saturate(w_saturate_region),
        .o_saturate_data(w_saturated_data),
        .o_saturate_data_valid(w_saturated_data_valid)
    );

    wire [DATA_WIDTH-1:0] w_interpolated_data;
    wire w_interpolated_data_valid;
    interpolator_engine_lut#(
        .DATA_WIDTH(DATA_WIDTH),
        .LUT_SIZE(LUT_SIZE),
        .FP_BITS(FP_BITS)
    )
    interpolator_engine_inst_lut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_interpolate_region(w_interpolate_region),
        .i_interpolator_datavalid(w_data_valid),
        .i_interpolator_data(w_data),
        .o_interpolated_datavalid(w_interpolated_data_valid),
        .o_interpolated_data(w_interpolated_data),

        .o_pass_data(w_pass_through_data)
    );

    // Output selection based on region
    // Pipeline registers for select signal
    reg [1:0] r_select;
    genvar i;
    generate
        for (i = 0; i <= 5; i = i + 1) begin : pipeline_regs_select
            reg [1:0] delayed_select;
            if(i == 0) begin
                always @(posedge i_clk) delayed_select <= w_select; 
            end 
            else if(i==5) begin
                always @(posedge i_clk) r_select <= pipeline_regs_select[i-1].delayed_select;
            end
            else begin
                always @(posedge i_clk) delayed_select <= pipeline_regs_select[i-1].delayed_select;
            end
        end
    endgenerate

    // pipeline registers for pass region and saturated region data
    reg [DATA_WIDTH-1:0] r_pass_data;
    reg r_pass_data_valid;
    reg [DATA_WIDTH-1:0] r_saturated_data;
    reg r_saturated_data_valid;

    genvar j;
    generate
        for (j = 0; j <= 4; j = j + 1) begin : pipeline_regs
            reg delayed_pass_data_valid;
            reg delayed_saturated_data_valid;
            if(j == 0) begin
                always @(posedge i_clk) begin
                    delayed_pass_data_valid <= w_pass_through_data_valid;
                    delayed_saturated_data_valid <= w_saturated_data_valid;
                end 
            end 
            else if(j==4) begin
                always @(posedge i_clk) begin
                    r_pass_data_valid <= pipeline_regs[j-1].delayed_pass_data_valid;
                    r_saturated_data_valid <= pipeline_regs[j-1].delayed_saturated_data_valid;
                end
            end
            else begin
                always @(posedge i_clk) begin
                    delayed_pass_data_valid <= pipeline_regs[j-1].delayed_pass_data_valid;
                    delayed_saturated_data_valid <= pipeline_regs[j-1].delayed_saturated_data_valid;
                end
            end
        end
    endgenerate

    // Output selection logic
    always@(*) begin
        case (r_select)
            2'b00: begin
                o_data = w_pass_through_data;
                o_data_valid = r_pass_data_valid;
            end
            2'b01: begin
                o_data = 32'd65535; // Saturated value (1.0)
                o_data_valid = r_saturated_data_valid;
            end
            2'b10: begin
                o_data = w_interpolated_data;
                o_data_valid = w_interpolated_data_valid;
            end
            default: begin
                o_data = {DATA_WIDTH{1'b0}};
                o_data_valid = 1'b0;
            end
        endcase
    end
    
endmodule
