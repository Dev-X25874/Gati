module output_mux#(
    parameter N_BANK = 4,
    parameter N_BRAM = 8,
    parameter W_DATA = 8
)(
    input clk,
    input rst,
    input [(N_BANK * (N_BRAM * W_DATA))-1 : 0] i_data,
    input [(N_BANK * N_BRAM)-1 : 0] i_rden,
    output [W_DATA-1 : 0] o_data,
    output data_valid
);
reg dv = 0;
reg [W_DATA-1 : 0] data = 0;
assign o_data = data;
assign data_valid = dv;
localparam BIN_WIDTH = $clog2(N_BANK * N_BRAM);
wire [BIN_WIDTH-1 : 0] bin;
onehot_to_bin#(
    .ONEHOT_WIDTH(N_BANK * N_BRAM)
)onehot_to_binary(
    .onehot(i_rden),
    .bin(bin)
);

always @(posedge clk) begin
    if(rst)begin
        data <= 0;
    end else begin
            if(i_rden!=0)begin
                data <= i_data[((W_DATA) * (bin + 1))-1 -: W_DATA];
                dv <= 1'b1;
            end else begin
                data <= data;
                dv <= 1'b0;
            end
        end
end
    
endmodule