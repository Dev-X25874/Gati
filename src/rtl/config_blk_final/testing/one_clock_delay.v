//delay input signal by 1 clock
module one_clock_delay#(parameter DATA_WIDTH=8)(
    input clkin,
    input[DATA_WIDTH-1:0] i_data,
    output reg[DATA_WIDTH-1:0]o_data
);
reg [DATA_WIDTH-1:0]delay_reg;
always @(posedge clkin) begin
    delay_reg<=i_data;
    o_data<=delay_reg;
end
endmodule