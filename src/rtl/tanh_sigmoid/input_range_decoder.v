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
    output o_select,

    output o_interpolate_region
);

    // floating point precision = 16 bits
    localparam DATA_SAMPLE_MIN = 32'd0; // 0.0 * 2^16
    localparam DATA_SAMPLE_MAX = 32'd229376; // 3.5 * 2^16

    reg [DATA_WIDTH-1 : 0] r_data;
    reg r_data_valid;

    reg r_select;
    reg r_interpolate_region;

    always @(posedge i_clk) begin
        if(!i_rst) begin
            r_data_valid <= 1'b0;
            r_data <= 0;
            r_select <= 1'b0;
            r_interpolate_region <= 1'b0;
        end
        else begin
            if(i_data_valid) begin
                r_data_valid <= 1'b1;
                r_data       <= i_data;
                
                if(i_data > DATA_SAMPLE_MAX) begin
                    r_select <= 1'b1;
                    r_interpolate_region <= 1'b1;
                    r_data <= DATA_SAMPLE_MAX; //input clamped at 3.5
                end
                else begin
                    r_select <= 1'b1; // Interpolate Region
                    r_interpolate_region <= 1'b1;
                end
            end
            else begin
                r_data_valid <= 1'b0;
                r_data <= 0;
                r_select <= 1'b1;
                r_interpolate_region <= 1'b0;
            end                
        end
    end

    assign o_data_valid = r_data_valid;
    assign o_data = r_data;
    assign o_select = r_select;
    assign o_interpolate_region = r_interpolate_region;

endmodule
