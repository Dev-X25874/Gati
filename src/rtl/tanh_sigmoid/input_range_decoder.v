module input_range_decoder#(
    parameter DATA_WIDTH = 32
)
(
    input i_clk,
    input i_rst,
    input [DATA_WIDTH-1 : 0] i_data,
    input i_data_valid,

    output o_data_valid,
    output [DATA_WIDTH-1 : 0] o_data,
    output [1:0] o_select,

    output o_saturate_region,
    output o_interpolate_region,
    output o_pass_region
);

    reg [DATA_WIDTH-1 : 0] data_sample_min;
    reg [DATA_WIDTH-1 : 0] data_sample_max;
    
    // floating point precision = 16 bits
    initial begin
        data_sample_min = 32'd19661; // 0.3 * 2^16
        data_sample_max = 32'd229373; // 3.5 * 2^16
    end

    reg [DATA_WIDTH-1 : 0] r_data;
    reg r_data_valid;

    reg [1:0] r_select;
    reg r_saturate_region;
    reg r_interpolate_region;
    reg r_pass_region;

    always @(posedge i_clk) begin
        if(!i_rst) begin
            r_data_valid <= 1'b0;
            r_data <= 0;
            r_select <= 2'b00;
            r_saturate_region <= 1'b0;
            r_interpolate_region <= 1'b0;
            r_pass_region <= 1'b0;
        end
        else begin
            if(i_data_valid) begin
                r_data_valid <= 1'b1;
                r_data       <= i_data;

                if(i_data < data_sample_min) begin
                    r_select <= 2'b00; // Pass Region
                    r_saturate_region <= 1'b0;
                    r_interpolate_region <= 1'b0;
                    r_pass_region <= 1'b1;
                end
                else if(i_data > data_sample_max) begin
                    r_select <= 2'b01; // Saturation Region
                    r_saturate_region <= 1'b1;
                    r_interpolate_region <= 1'b0;
                    r_pass_region <= 1'b0;
                end
                else begin
                    r_select <= 2'b10; // Interpolate Region
                    r_saturate_region <= 1'b0;
                    r_interpolate_region <= 1'b1;
                    r_pass_region <= 1'b0;
                end
            end
            else begin
                r_data_valid <= 1'b0;
                r_data <= 0;
                r_select <= 2'b00;
                r_saturate_region <= 1'b0;
                r_interpolate_region <= 1'b0;
                r_pass_region <= 1'b0;
            end                
        end
    end

    assign o_data_valid = r_data_valid;
    assign o_data = r_data;
    assign o_select = r_select;
    assign o_saturate_region = r_saturate_region;
    assign o_interpolate_region = r_interpolate_region;
    assign o_pass_region = r_pass_region;

endmodule
