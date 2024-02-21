module bias #(parameter DATA_WIDTH = 18 )(
    
    input[DATA_WIDTH-1:0]           i_data,
    input[DATA_WIDTH-1:0]           i_data_bias,
    input                           i_valid,
    input                           clk,
    output [DATA_WIDTH-1:0]         o_data,
    output [DATA_WIDTH-1:0]         o_valid
 
);
    reg [DATA_WIDTH-1:0]            r_o_data;
    reg                             r_o_valid;
    
    assign o_valid = r_o_valid;
    assign o_data = r_o_data;
    
    always @(posedge clk) begin
        if (i_valid) begin
            r_o_data <= i_data + i_data_bias;
            r_o_valid <= i_valid;
        end else 
        r_o_valid <= 0;
    end 
endmodule