`timescale 1ns/1ns
`include "../../rtl/tanh_sigmoid/input_range_decoder.v"
`include "../../rtl/tanh_sigmoid/saturate_region.v"
`include "../../rtl/tanh_sigmoid/pass_region.v"
`include "../../rtl/tanh_sigmoid/interpolator_engine.v"
`include "../../rtl/tanh_sigmoid/tanh_interpolator_engine.v"
`include "../../rtl/tanh_sigmoid/top_Tanh_Sigmoid_Engine.v"

module tb_tanh_sigmoid();

    // Inputs
    reg i_clk;
    reg i_rst;

    reg signed [23:0] i_data;
    reg i_data_valid;
    reg i_tanh_sigmoid;

    // Outputs
    wire [31:0] o_tanh;
    wire o_tanh_valid;

    // Clock generation
    initial i_clk = 1;
    always #5 i_clk = ~i_clk; // 100 MHz clock
    
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
    localparam LUT_SIZE = 128;
    localparam FP_BITS = 16;
    localparam SCALE_WIDTH = 32;
    localparam OUT_DATA_WIDTH = 32;

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
    
    top_Tanh_Sigmoid_Engine # (
        .DATA_WIDTH(DATA_WIDTH),
        .SCALE_WIDTH(SCALE_WIDTH),
        .FP_BITS(FP_BITS),
        .LUT_SIZE(LUT_SIZE),
        .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
    )
    top_Tanh_Sigmoid_Engine_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        // .i_input_scale(input_scale),
        .i_data_valid(i_data_valid),
        .scaled_data_in(i_data),
        .i_tanh_sigmoid(i_tanh_sigmoid),
        .o_data_valid(o_tanh_valid),
        .o_data_out(o_tanh)
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

    wire signed [31:0] input_scale, output_scale;
    assign input_scale = 41569;
    assign output_scale = 127;

    initial begin
        f1 = $fopen("tanh_sigmoid_input.txt", "w");
        f2 = $fopen("tanh_sigmoid_output.txt", "w");
        if (f1 == 0 || f2 == 0) begin
            $display("Error opening output files.");
            $finish;
        end

        $dumpfile("tanh_sigmoid.vcd");
        $dumpvars(0);

        $display("Starting simulation...");
        // Initialize inputs
        i_rst = 0;
        i_data = 0;
        i_data_valid = 0;
        i_tanh_sigmoid = 1;

        // Release reset after some time
        #10;
        i_rst = 1;

        // Test cases
        #10;
        i_data = 0;
        i_data_valid = 1;
        #10 i_data = 2;
        #10 i_data = -2;
        #10 i_data = -10;
        #10 i_data = 9;
        #10 i_data = 1;
        #10 i_data = 5;
        #10 i_data = -128;
        #10 i_data = 120;
        #10 i_data = 20;
        #10 i_data = -30;
        #10 i_data = -2;
        #10 i_data =  8;
        #10 i_data_valid = 0; // Stop data valid signal

      #200; // Wait for some time to observe outputs
        
        $display("Simulation finished.");
        $fclose(f1);
        $fclose(f2);

        // Analyze results
        f1 = $fopen("tanh_sigmoid_input.txt", "r");
        f2 = $fopen("tanh_sigmoid_output.txt", "r");
        $display("Analyzing results from files...");
        while (!$feof(f1) && !$feof(f2)) begin
            $fscanf(f1, "%h\n", r_i_data);
            $fscanf(f2, "%h\n", r_o_tanh);
            // Compare expected and actual outputs
            expected = i_tanh_sigmoid? sigmoid_expected(r_i_data*input_scale) : tanh_expected(r_i_data*input_scale);
            if (r_o_tanh === 32'hx) begin
                $display("Output is undefined for input %h", r_i_data);
            end 
            else if ($abs(expected - (r_o_tanh/2**16.0)) > 0.001) begin
                $display("Mismatch at input %f: Expected %f, got %f", ((r_i_data*input_scale)/2**16.0), expected, (r_o_tanh/2**16.0));
            end 
            else begin
                $display("Match at input %f: Output %f", (r_i_data*input_scale/2**16.0), (r_o_tanh/2**16.0));
            end
        end

        $finish;
    end

    initial begin
        $monitor("Time: %0t, i_data: %h, o_tanh: %h, o_tanh_valid: %b", $time, i_data, o_tanh, o_tanh_valid);
    end
    
    always @(posedge i_clk) begin
        if (i_data_valid) begin
            $fwrite(f1, "%h\n", i_data); // Write input data to file
        end
    end

    always @(posedge i_clk) begin
        if (o_tanh_valid) begin
            $fwrite(f2, "%h\n", o_tanh); // Write output data to file
        end
    end


endmodule
