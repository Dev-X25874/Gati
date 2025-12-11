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
    wire w_select;
    wire w_interpolate_region;

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
        .o_interpolate_region(w_interpolate_region)
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
        .o_interpolated_data(w_interpolated_data)
    );

    // Pipeline registers for select signal
    reg r_select;
    genvar i;
    generate
        for (i = 0; i <= 5; i = i + 1) begin : pipeline_regs_select
            reg delayed_select;
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

    // Output selection logic
    always@(*) begin
      if(r_select) begin
        o_data       <= w_interpolated_data;
        o_data_valid <= w_interpolated_data_valid;
      end else begin
        o_data       <= 0;
        o_data_valid <= 1'b0;
      end
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
    wire w_select;
    wire w_interpolate_region;

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
        .o_interpolate_region(w_interpolate_region)
    );


    wire [DATA_WIDTH-1:0] w_interpolated_data;
    wire w_interpolated_data_valid;
    interpolator_engine_lut#(
        .DATA_WIDTH(DATA_WIDTH),
        .LUT_SIZE(LUT_SIZE),
        .FP_BITS(FP_BITS)
    )
    interpolator_engine_inst_lut(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_interpolate_region(w_interpolate_region),
        .i_interpolator_datavalid(w_data_valid),
        .i_interpolator_data(w_data),
        .o_interpolated_datavalid(w_interpolated_data_valid),
        .o_interpolated_data(w_interpolated_data)
    );

    // Pipeline registers for select signal
    reg r_select;
    genvar i;
    generate
        for (i = 0; i <= 5; i = i + 1) begin : pipeline_regs_select
            reg delayed_select;
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

    // Output selection logic
    always@(*) begin
      if(r_select) begin
        o_data       <= w_interpolated_data;
        o_data_valid <= w_interpolated_data_valid;
      end else begin
        o_data       <= 0;
        o_data_valid <= 1'b0;
      end
    end
    
endmodule

