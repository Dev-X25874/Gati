module output_mux#(
    parameter N_BANK = 4,
    parameter N_BRAM = 8,
    parameter W_DATA = 8
)(
    input clk,
    input rst,
    input [N_BRAM-1 : 0] i_rden,
    input [N_BANK-1 : 0] i_bank_en,
    input [(N_BANK * (N_BRAM * W_DATA))-1 : 0] i_data,
    output [W_DATA-1 : 0] o_data,
    output data_valid
);
reg dv = 0;
reg [W_DATA-1 : 0] data = 0;
assign o_data = data;
assign data_valid = dv;
localparam BIN_WIDTH_RDEN = $clog2(N_BRAM);
localparam BIN_WIDTH_BANK_EN = $clog2(N_BANK);
localparam BIN_WIDTH = BIN_WIDTH_RDEN + BIN_WIDTH_BANK_EN;

wire [BIN_WIDTH_RDEN-1 : 0] read_en_bin;
onehot_to_bin#(
    .ONEHOT_WIDTH(N_BRAM)
)read_en(
    .onehot(i_rden),
    .bin(read_en_bin)
);

wire [BIN_WIDTH_BANK_EN-1 : 0] bank_en_bin;
onehot_to_bin#(
    .ONEHOT_WIDTH(N_BANK)
)bank_en(
    .onehot(i_bank_en),
    .bin(bank_en_bin)
);

wire [BIN_WIDTH-1 : 0] select;
assign select = {bank_en_bin, read_en_bin};

always @(posedge clk) begin
    if(rst)begin
        data <= 0;
    end else begin
            if(i_rden!=0)begin
                data <= i_data[((W_DATA) * ((N_BRAM * N_BANK) - select))-1 -: W_DATA];
                dv <= 1'b1;
            end else begin
                data <= data;
                dv <= 1'b0;
            end
        end
end
    
endmodule