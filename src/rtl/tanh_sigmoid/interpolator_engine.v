module interpolator_engine#(
    parameter DATA_WIDTH = 32,
    parameter LUT_SIZE   = 128,
    parameter FP_BITS    = 16
)
(
    input i_clk,
    input i_rst,

    input i_interpolate_region,
    input i_interpolator_datavalid,
    input [DATA_WIDTH-1:0] i_interpolator_data,

    output reg o_interpolated_datavalid,
    output reg [DATA_WIDTH-1:0] o_interpolated_data,

    output [DATA_WIDTH-1:0] o_pass_data
);

    // reg [DATA_WIDTH-1 : 0] data_sample_min;
    // reg [DATA_WIDTH-1 : 0] data_sample_max;
    localparam DATA_SAMPLE_MIN = 32'd19661;
    localparam DATA_SAMPLE_MAX = 32'd229373;
    // initial begin
    //     data_sample_min = 32'd19661; // 0.3 * 2^16
    //     data_sample_max = 32'd229373; // 3.5 * 2^16
    // end

    // LUTs for data_samples, slope_vaues, and tanh values
    (*syn_ramstyle = "block_ram"*) reg [DATA_WIDTH-1:0] data_samples_lut [0:127];
    (*syn_ramstyle = "block_ram"*) reg [DATA_WIDTH-1:0] slope_values_lut [0:127];
    (*syn_ramstyle = "block_ram"*) reg [DATA_WIDTH-1:0] tanh_values_lut [0:127];

    initial begin
        // Initialize data_samples, slope_values, and tanh_values
        $readmemh("rtl/Gati/src/rtl/tanh_sigmoid/data_samples.txt", data_samples_lut,0,127);
        $readmemh("rtl/Gati/src/rtl/tanh_sigmoid/slope_values.txt", slope_values_lut,0,127);
        $readmemh("rtl/Gati/src/rtl/tanh_sigmoid/tanh_values.txt", tanh_values_lut,0,127);
    end

    /*
        LUT index calculation carried out in two cycles:
        1. Determine the segment of LUT in which the i/p sample falls in by 
           taking the difference b/n i/p inetrpolator sample and data_sample_min
        2. Multiply the offset segment with step size (i.e., N/(data_sample_max-data_sample_min))
        Here, N = 128, data_sample_min = 0.3, data_sample_max = 3.5. Hence the step_size = 40.0
        This can be implemented with a shift and add operation instead of multiplier.
    */

    wire [DATA_WIDTH-1:0] segment;
    assign segment = i_interpolator_data - DATA_SAMPLE_MIN;
    reg [$clog2(LUT_SIZE)-1:0] data_sample_index;
    reg [DATA_WIDTH-1:0] scaled_segment;
    reg valid_segment;
    wire [DATA_WIDTH-1:0] segment1;
    
    /* 
        segment_index = (x-x_min)/l , l = (x_max-x_min)/n
        Here, n = 128, x_min = 0.3, x_max = 3.5
        l = (3.5-0.3)/128 = 40
    */

    assign segment1 = (segment << 5) + (segment << 3);

    always@(posedge i_clk) begin
        if(!i_rst) begin
            scaled_segment <= 0;
            valid_segment <= 1'b0;
        end
        else begin
            if(i_interpolator_datavalid & i_interpolate_region) begin
                scaled_segment <= (segment1 + (1<<FP_BITS-1)) >> FP_BITS;
                valid_segment <= 1'b1;
            end
            else begin
                valid_segment <= 1'b0;
            end
        end
    end


    reg valid_index;
    always@(posedge i_clk) begin
        data_sample_index <= valid_segment ? scaled_segment : 0;
        valid_index <= valid_segment;
    end
    // Read values from LUTs
    reg signed [DATA_WIDTH -11 -1:0] data_sample; // reduced width to save resources
    reg signed [DATA_WIDTH - 15 -1:0] slope_value;
    reg signed [DATA_WIDTH-15 -1:0] tanh_value;
    reg valid_lut_data;
    always@(posedge i_clk) begin
        if(valid_index) begin
            data_sample <= data_samples_lut[data_sample_index][DATA_WIDTH-11-1:0];
            slope_value <= slope_values_lut[data_sample_index][DATA_WIDTH-15-1:0];
            tanh_value <= tanh_values_lut[data_sample_index][DATA_WIDTH-15-1:0];
            valid_lut_data <= 1'b1;
        end
        else valid_lut_data <= 1'b0;
    end

    // Interpolation calculation
    // pipeline registers to synchronize the input data with the read data from LUTs
    reg [DATA_WIDTH-1:0] r_interpolator_data;
    reg r_interpolator_datavalid;
    genvar i;
    generate
        for (i = 0; i <= 2; i = i + 1) begin : pipeline_regs
            reg [DATA_WIDTH-1:0] delay_data_reg;
            reg delay_valid_reg;
            if(i == 0) begin
                always @(posedge i_clk) begin
                    delay_data_reg <= i_interpolator_data;
                    delay_valid_reg <= i_interpolator_datavalid;
                end 
            end 
            else if(i==2) begin
                always @(posedge i_clk) begin
                    r_interpolator_data <= pipeline_regs[i-1].delay_data_reg;
                    r_interpolator_datavalid <= pipeline_regs[i-1].delay_valid_reg;
                end
            end
            else begin
                always @(posedge i_clk) begin
                    delay_data_reg <= pipeline_regs[i-1].delay_data_reg;
                    delay_valid_reg <= pipeline_regs[i-1].delay_valid_reg;
                end
            end
        end
    endgenerate

    reg [DATA_WIDTH-1:0] r_scaled_data; // reduced from 2*DATA_WIDTH to save resources.
    reg r_valid_scaled_data;

    /*
        After reading the LUT information, interpolated output is calculated as follows:
            o/p = tanh_value_lut + slope * (i/p_sample - data_sample_lut)

        This is carried out in 3 pipeline stages:
            1. Subtract i/p sample and data_sample from lut
            2. multiply with the corresponding slope value
            3. Add the multiplier result of step 2 with corrsponding tanh_value from lut
    */

    reg signed [DATA_WIDTH/2 -1:0] diff_data;
    reg diff_valid;
    always@(posedge i_clk) begin
        if(r_interpolator_datavalid & valid_lut_data) begin
            diff_data <= r_interpolator_data - data_sample;
            diff_valid <= 1'b1;
        end
        else diff_valid <= 1'b0;
    end
    reg signed [DATA_WIDTH/2 -1:0] r_slope_value;
    always@(posedge i_clk) r_slope_value <= slope_value;

    // Scale the offset difference by the slope value
    always@(posedge i_clk) begin
        if(diff_valid) begin
            r_scaled_data <= (diff_data * r_slope_value) >>> FP_BITS;
            r_valid_scaled_data <= 1'b1;
        end
        else r_valid_scaled_data <= 1'b0;
    end
    reg [DATA_WIDTH-1:0] r_tanh_value, r_tanh_value1;
    always@(posedge i_clk) begin 
        r_tanh_value1 <= tanh_value;
        r_tanh_value <= r_tanh_value1;
    end

    always@(posedge i_clk) begin
        if(r_valid_scaled_data) begin
            o_interpolated_data <= r_tanh_value + $signed(r_scaled_data);
            o_interpolated_datavalid <= 1'b1;
        end
        else o_interpolated_datavalid <= 1'b0;
    end
    
    // Output data for pass region
    // This is added here to avoid additional pipeleine registers in the top_module
    reg [DATA_WIDTH-1:0] r_pass_data;
    reg [DATA_WIDTH-1:0] r_interpolator_data1, r_interpolator_data2;
    always@(posedge i_clk) begin
        r_interpolator_data1 <= r_interpolator_data;
        r_interpolator_data2 <= r_interpolator_data1;
        r_pass_data <= r_interpolator_data2;
    end
    assign o_pass_data = r_pass_data;

endmodule

module interpolator_engine_lut#(
    parameter DATA_WIDTH = 32,
    parameter LUT_SIZE   = 128,
    parameter FP_BITS    = 16
)
(
    input i_clk,
    input i_rst,

    input i_interpolate_region,
    input i_interpolator_datavalid,
    input [DATA_WIDTH-1:0] i_interpolator_data,

    output reg o_interpolated_datavalid,
    output reg [DATA_WIDTH-1:0] o_interpolated_data,

    output [DATA_WIDTH-1:0] o_pass_data
);

    // reg [DATA_WIDTH-1 : 0] data_sample_min;
    // reg [DATA_WIDTH-1 : 0] data_sample_max;
    localparam DATA_SAMPLE_MIN = 32'd19661;
    localparam DATA_SAMPLE_MAX = 32'd229373;
    // initial begin
    //     data_sample_min = 32'd19661; // 0.3 * 2^16
    //     data_sample_max = 32'd229373; // 3.5 * 2^16
    // end

    // LUTs for data_samples, slope_vaues, and tanh values
    (*syn_ramstyle = "block_ram"*) reg [DATA_WIDTH-1:0] data_samples_lut [0:127];
    (*syn_ramstyle = "block_ram"*) reg [DATA_WIDTH-1:0] slope_values_lut [0:127];
    (*syn_ramstyle = "block_ram"*) reg [DATA_WIDTH-1:0] tanh_values_lut [0:127];

    initial begin
        // Initialize data_samples, slope_values, and tanh_values
        $readmemh("data_samples.txt", data_samples_lut,0,127);
        $readmemh("slope_values.txt", slope_values_lut,0,127);
        $readmemh("tanh_values.txt", tanh_values_lut,0,127);
    end

    /*
        LUT index calculation carried out in two cycles:
        1. Determine the segment of LUT in which the i/p sample falls in by 
           taking the difference b/n i/p inetrpolator sample and data_sample_min
        2. Multiply the offset segment with step size (i.e., N/(data_sample_max-data_sample_min))
        Here, N = 128, data_sample_min = 0.3, data_sample_max = 3.5. Hence the step_size = 40.0
        This can be implemented with a shift and add operation instead of multiplier.
    */

    wire [DATA_WIDTH-1:0] segment;
    assign segment = i_interpolator_data - DATA_SAMPLE_MIN;
    
    reg [$clog2(LUT_SIZE)-1:0] data_sample_index;
    reg [DATA_WIDTH-1:0] scaled_segment;
    reg valid_segment;
    wire [DATA_WIDTH-1:0] segment1;
    
    /* 
        segment_index = (x-x_min)/l , l = (x_max-x_min)/n
        Here, n = 128, x_min = 0.3, x_max = 3.5
        l = (3.5-0.3)/128 = 40
    */

    assign segment1 = (segment << 5) + (segment << 3);

    always@(posedge i_clk) begin
        if(!i_rst) begin
            scaled_segment <= 0;
            valid_segment <= 1'b0;
        end
        else begin
            if(i_interpolator_datavalid & i_interpolate_region) begin
                scaled_segment <= (segment1 + (1<<FP_BITS-1)) >> FP_BITS;
                valid_segment <= 1'b1;
            end
            else begin
                valid_segment <= 1'b0;
            end
        end
    end


    reg valid_index;
    always@(posedge i_clk) begin
        data_sample_index <= valid_segment ? scaled_segment : 0;
        valid_index <= valid_segment;
    end
    // Read values from LUTs
    reg signed [DATA_WIDTH -11 -1:0] data_sample; // reduced width to save resources
    reg signed [DATA_WIDTH - 15 -1:0] slope_value;
    reg signed [DATA_WIDTH-15 -1:0] tanh_value;
    reg valid_lut_data;
    always@(posedge i_clk) begin
        if(valid_index) begin
            data_sample <= data_samples_lut[data_sample_index][DATA_WIDTH-11-1:0];
            slope_value <= slope_values_lut[data_sample_index][DATA_WIDTH-15-1:0];
            tanh_value <= tanh_values_lut[data_sample_index][DATA_WIDTH-15-1:0];
            valid_lut_data <= 1'b1;
        end
        else valid_lut_data <= 1'b0;
    end

    // Interpolation calculation
    // pipeline registers to synchronize the input data with the read data from LUTs
    reg [DATA_WIDTH-1:0] r_interpolator_data;
    reg r_interpolator_datavalid;
    genvar i;
    generate
        for (i = 0; i <= 2; i = i + 1) begin : pipeline_regs
            reg [DATA_WIDTH-1:0] delay_data_reg;
            reg delay_valid_reg;
            if(i == 0) begin
                always @(posedge i_clk) begin
                    delay_data_reg <= i_interpolator_data;
                    delay_valid_reg <= i_interpolator_datavalid;
                end 
            end 
            else if(i==2) begin
                always @(posedge i_clk) begin
                    r_interpolator_data <= pipeline_regs[i-1].delay_data_reg;
                    r_interpolator_datavalid <= pipeline_regs[i-1].delay_valid_reg;
                end
            end
            else begin
                always @(posedge i_clk) begin
                    delay_data_reg <= pipeline_regs[i-1].delay_data_reg;
                    delay_valid_reg <= pipeline_regs[i-1].delay_valid_reg;
                end
            end
        end
    endgenerate

    (* syn_use_dsp = "no" *) reg [DATA_WIDTH-1:0] r_scaled_data; // reduced from 2*DATA_WIDTH to save resources.
    reg r_valid_scaled_data;

    /*
        After reading the LUT information, interpolated output is calculated as follows:
            o/p = tanh_value_lut + slope * (i/p_sample - data_sample_lut)

        This is carried out in 3 pipeline stages:
            1. Subtract i/p sample and data_sample from lut
            2. multiply with the corresponding slope value
            3. Add the multiplier result of step 2 with corrsponding tanh_value from lut
    */

    reg signed [DATA_WIDTH/2 -1:0] diff_data;
    reg diff_valid;
    always@(posedge i_clk) begin
        if(r_interpolator_datavalid & valid_lut_data) begin
            diff_data <= r_interpolator_data - data_sample;
            diff_valid <= 1'b1;
        end
        else diff_valid <= 1'b0;
    end
    reg signed [DATA_WIDTH/2 -1:0] r_slope_value;
    always@(posedge i_clk) r_slope_value <= slope_value;

    // Scale the offset difference by the slope value
    always@(posedge i_clk) begin
        if(diff_valid) begin
            r_scaled_data <= (diff_data * r_slope_value) >>> FP_BITS;
            r_valid_scaled_data <= 1'b1;
        end
        else r_valid_scaled_data <= 1'b0;
    end
    reg [DATA_WIDTH-1:0] r_tanh_value, r_tanh_value1;
    always@(posedge i_clk) begin 
        r_tanh_value1 <= tanh_value;
        r_tanh_value <= r_tanh_value1;
    end

    always@(posedge i_clk) begin
        if(r_valid_scaled_data) begin
            o_interpolated_data <= r_tanh_value + $signed(r_scaled_data);
            o_interpolated_datavalid <= 1'b1;
        end
        else o_interpolated_datavalid <= 1'b0;
    end
    
    // Output data for pass region
    // This is added here to avoid additional pipeleine registers in the top_module
    reg [DATA_WIDTH-1:0] r_pass_data;
    reg [DATA_WIDTH-1:0] r_interpolator_data1, r_interpolator_data2;
    always@(posedge i_clk) begin
        r_interpolator_data1 <= r_interpolator_data;
        r_interpolator_data2 <= r_interpolator_data1;
        r_pass_data <= r_interpolator_data2;
    end
    assign o_pass_data = r_pass_data;

endmodule
