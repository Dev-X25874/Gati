module bram_bank_array#(
    parameter N_BANK = 4,       //number of banks of bram
    parameter N_BRAM = 8, //total brams in one bank
    parameter W_ADDR = 9,       //bram address width
    parameter W_DATA = 8        //bram data width
)(
    input clk,
    input [N_BANK-1 : 0] i_bank_en,
    input [(N_BANK * N_BRAM)-1 : 0] we,
    input [N_BRAM-1 : 0] re,
    // input [(N_BANK * N_BRAM)-1 : 0] re,
    input [((W_DATA * N_BRAM) * N_BANK)-1 : 0] i_data,
    input [((W_ADDR + 1) * N_BANK)-1 : 0] w_addr,
    input [((W_ADDR + 1) * N_BANK)-1 : 0] r_addr,
    output [((W_DATA * N_BRAM) * N_BANK)-1 : 0] o_data,
    output [(N_BANK * N_BRAM)-1 : 0] read_valid
);

genvar i;
generate
    for(i = 0; i < N_BANK; i = i + 1)begin
        bram_array#(
            .W_DATA(W_DATA),
            .W_ADDR(W_ADDR),
            .N_BRAM(N_BRAM)  //number of brams in one bank
        )bank_inst(
            .clk(clk),
            .bank_en(i_bank_en[i]),
            .we(we[(N_BRAM * (N_BANK - i))-1 -: (N_BRAM)]),
            .re(re),
            // .re(re[(N_BRAM * (N_BANK - i))-1 -: (N_BRAM)]),
            .i_data(i_data[((W_DATA * N_BRAM) * (N_BANK - i))-1 -: (N_BRAM * W_DATA)]),
            .w_addr(w_addr[((W_ADDR + 1) * (N_BANK - i))-1 -: (W_ADDR + 1)]),
            .r_addr(r_addr[((W_ADDR + 1) * (N_BANK - i))-1 -: (W_ADDR + 1)]),
            .o_data(o_data[((W_DATA * N_BRAM) * (N_BANK - i))-1 -: (N_BRAM * W_DATA)]),
            .read_valid(read_valid[(N_BRAM * (N_BANK - i))-1 -: N_BRAM])
        );
    end
endgenerate
    
endmodule

module bram_array#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_BRAM = 8  //number of brams in one bank
)(
    input clk,
    input bank_en,
    input [N_BRAM-1 : 0] we,
    input [N_BRAM-1 : 0] re,
    input [(W_DATA * N_BRAM)-1 : 0] i_data,
    input [(W_ADDR + 1)-1 : 0] w_addr,
    input [(W_ADDR + 1)-1 : 0] r_addr,
    output [(N_BRAM * W_DATA)-1 : 0] o_data,
    output [N_BRAM-1 : 0] read_valid
);
wire [63:0] temp_data;
assign o_data = temp_data + 64'd12;

genvar i;
generate
    for (i = 0; i < N_BRAM; i = i + 1) begin
        bram bram_wrapper(
            .re(rden[i]),
            .we(we[i]),
            .waddr(w_addr),
            .raddr(r_addr),
            .wdata_a(i_data[(W_DATA * (N_BRAM - i))-1 -: W_DATA]),
            .rdata_b(temp_data[(W_DATA * (N_BRAM - i))-1 -: W_DATA]),
            .clk(clk)
        );
        
    end
endgenerate
wire [N_BRAM-1 : 0] rden;
assign rden = (bank_en) ? re : 8'd0;
assign read_valid = re;

endmodule