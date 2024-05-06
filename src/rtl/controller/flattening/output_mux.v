/*
    Receives data from multiple BRAM together, and send one byte
    as output at a time. This is done beacuase image in fully connected
    is broadcasted to all the PE blocks, hence, all the PE blocks should
    receive one same byte per clock cycle. 
*/
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
reg r_dv = 0;
reg [W_DATA-1 : 0] r_data = 0;
assign o_data = r_data;
assign data_valid = r_dv;
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
        r_data <= 0;
    end else begin
            if((i_rden!=0) && (i_bank_en!=0))begin
                r_data <= i_data[((W_DATA) * ((N_BRAM * N_BANK) - select))-1 -: W_DATA];
                r_dv <= 1;
            end else begin
                r_data <= r_data;
                r_dv <= 0;
            end
        end
end
    
endmodule