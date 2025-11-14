`timescale 1ns/1ns
`include "../../rtl/element_wise_op/element_wise_op.v"
`include "../../rtl/tanh_sigmoid/input_range_decoder.v"
`include "../../rtl/tanh_sigmoid/saturate_region.v"
`include "../../rtl/tanh_sigmoid/pass_region.v"
`include "../../rtl/tanh_sigmoid/interpolator_engine.v"
`include "../../rtl/tanh_sigmoid/tanh_interpolator_engine.v"
`include "../../rtl/tanh_sigmoid/top_Tanh_Sigmoid_Engine.v"
`include "../../rtl/common/instructions.vh"
`include "../../rtl/dram_fifo/dram_fifo.v"
`include "../../rtl/op_write_demux/Demux_param.v"
`include "../../rtl/common/demux_param1.v"
`include "../../rtl/ip/sync_fifo/sync_fifo.v"
`include "../../rtl/common/arch_param.vh"

module tb_tanh_sigmoid_elementwise();

    // Inputs
    reg clkin;
    reg rst;
    // reg tanh_switch;
    reg signed [7:0] LeftOperand;
    reg signed [7:0] RightOperand = 0;
    reg data_valid;
    reg signed [ELTWISE_SCALE_WIDTH-1:0] RightOperand_Scale = 0;

    reg [7:0] LeftOperand_zero_point = 0;
    reg [7:0] RightOperand_zero_point = 0;
    reg [3:0] EltWise_type = `ELTWISE_TANH;
    // Outputs
    wire [31:0] EltWise_out;
    wire EltWise_valid;

    // Clock generation
    initial clkin = 1;
    always #5 clkin = ~clkin; // 100 MHz clock

    /* -------------- Unoptimized Module Instantiation -------------- */
    /*
    tanh_sigmoid  tanh_sigmoid_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_data),
        .i_data_valid(i_data_valid),
        .o_tanh(o_tanh),
        .o_tanh_valid(o_tanh_valid)
    );
    */

    /* -------------- Optimized Module Instantiation -------------- */
    // Parameters for the tanh interpolator engine

    localparam DATA_WIDTH = 8;
    localparam ELTWISE_TYPE_WIDTH = 4;
    localparam ELTWISE_SCALE_WIDTH = 32;
    localparam ELTWISE_ZEROPOINT_WIDTH = 8;
    localparam DATA_WIDTH_OB = 32;

    /* ----------------- Tanh Interpolator Engine ----------------- */
    /*
    tanh_interpolator_engine # (
        .DATA_WIDTH(DATA_WIDTH),
        .LUT_SIZE(LUT_SIZE),
        .FP_BITS(FP_BITS)
    )
    tanh_interpolator_engine_inst (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data_valid(i_data_valid),
      .i_data(i_data),
      .o_data_valid(o_tanh_valid),
      .o_data(o_tanh)
    );
    */

    /* ------------------ Tanh_Sigmoid Engine --------------------- */

    element_wise_op # (
        .DATA_WIDTH(DATA_WIDTH),
        .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
        .ELTWISE_SCALE_WIDTH(ELTWISE_SCALE_WIDTH-14),
        .ELTWISE_ZEROPOINT_WIDTH(ELTWISE_ZEROPOINT_WIDTH),
        .DATA_WIDTH_OB(DATA_WIDTH_OB)
    )
    element_wise_op_inst_ (
        .clkin(clkin),
        .rst(rst),
        .LeftOperand(LeftOperand),
        .RightOperand(RightOperand),
        .data_valid(data_valid),
        .LeftOperand_Scale(input_scale[ELTWISE_SCALE_WIDTH-15:0]),
        .RightOperand_Scale(RightOperand_Scale[ELTWISE_SCALE_WIDTH-15:0]),
        .LeftOperand_zero_point(LeftOperand_zero_point),
        .RightOperand_zero_point(RightOperand_zero_point),
        .EltWise_type(EltWise_type),
        // .tanh_switch(tanh_switch),
        .EltWise_out(EltWise_out),
        .EltWise_valid(EltWise_valid)
    );


    function real tanh_expected(input signed [31:0] data);
        real x;
        x = data/2**16.0; // Convert to floating point
        tanh_expected = ($exp(x)-$exp(-x))/($exp(x)+$exp(-x)); // Calculate tanh
    endfunction

    function real sigmoid_expected(input signed [31:0] data);
        real x;
        x = data/2**16.0;
        sigmoid_expected = (1+tanh_expected(data/2.0)) / 2.0;
    endfunction

    integer f1, f2;
    reg signed [7:0] r_i_data;
    reg signed [31:0] r_o_tanh;
    real expected;

    wire signed [ELTWISE_SCALE_WIDTH-1:0] input_scale,output_scale;
    assign input_scale = 51407;
    assign output_scale = 127;

    initial begin
        f1 = $fopen("tanh_sigmoid_input_element.txt", "w");
        f2 = $fopen("tanh_sigmoid_output_element.txt", "w");
        if (f1 == 0 || f2 == 0) begin
            $display("Error opening output files.");
            $finish;
        end

        $dumpfile("tanh_sigmoid_element.vcd");
        $dumpvars(0);

        $display("Starting simulation...");
        // Initialize inputs
        // i_rst = 0;
        // i_data = 0;
        // i_data_valid = 0;
        // i_tanh_sigmoid = 0;

        rst = 0;
        LeftOperand = 0;
        RightOperand = 0;
        data_valid = 0;
        RightOperand_Scale = 0;
        LeftOperand_zero_point = 0;
        RightOperand_zero_point = 0;
        EltWise_type = `ELTWISE_SIG;
        #10;
        rst = 1;

        // Test cases
        #10;
        LeftOperand = 0;
        data_valid = 1;
        #10 LeftOperand = 252;
        #10 LeftOperand = 251;
        #10 LeftOperand = 250;
        #10 LeftOperand = 0;
        #10 LeftOperand = -128;
        #10 LeftOperand = 8'h0;
        #10 LeftOperand = 8'h08;
        #10 LeftOperand = -4;
        #10 LeftOperand = 8'hfc;
        #10 LeftOperand = 8'hfb;
        #10 LeftOperand = 8'hfa;
        #10 LeftOperand = 8'hfb;
        #10 data_valid = 0; // Stop data valid signal

        #200; // Wait for some time to observe outputs

        $display("Simulation finished.");
        $fclose(f1);
        $fclose(f2);

        // Analyze results
        f1 = $fopen("tanh_sigmoid_input_element.txt", "r");
        f2 = $fopen("tanh_sigmoid_output_element.txt", "r");
        $display("Analyzing results from files...");
        while (!$feof(f1) && !$feof(f2)) begin
            $fscanf(f1, "%h\n", r_i_data);
            $fscanf(f2, "%h\n", r_o_tanh);
            // Compare expected and actual outputs
            expected = (EltWise_type == `ELTWISE_SIG) ? sigmoid_expected(r_i_data*input_scale) : tanh_expected(r_i_data*input_scale);
            if (r_o_tanh === 32'hx) begin
                $display("Output is undefined for input %h", r_i_data);
            end 
            else if ($abs(expected - (r_o_tanh/2**16.0)) > 0.001) begin
                $display("Mismatch at input %f, (hex: %h): Expected %f, got %f, (hex: %h)", ((r_i_data*input_scale)/2**16.0), (r_i_data), expected, (r_o_tanh/2**16.0), (r_o_tanh));
            end 
            else begin
                $display("Match at input %f, (hex: %h): Output %f, (hex: %h), expected: %f", (r_i_data*input_scale/2**16.0), r_i_data, (r_o_tanh/2**16.0), r_o_tanh, expected);
            end
        end

        $finish;
    end

    // initial begin
    //     $monitor("Time: %0t, LeftOperand : %h, EltWise_out: %h, EltWise_valid: %b", $time, LeftOperand, EltWise_out, EltWise_valid);
    // end

    always @(posedge clkin) begin
        if (data_valid) begin
            $fwrite(f1, "%h\n", LeftOperand); // Write input data to file
        end
    end

    always @(posedge clkin) begin
        if (EltWise_valid) begin
            $fwrite(f2, "%h\n", EltWise_out); // Write output data to file
        end
    end


endmodule
