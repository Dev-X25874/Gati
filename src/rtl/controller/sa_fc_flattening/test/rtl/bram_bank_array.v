module bram_bank_array#(
    parameter N_BANK = 4,       //number of banks of bram
    parameter BRAM_BANK_FF = 8, //total brams in one bank
    parameter W_ADDR = 9,       //bram address width
    parameter W_DATA = 8        //bram data width
)(
    input clk,
    input [(N_BANK * BRAM_BANK_FF)-1 : 0] we,
    input [(BRAM_BANK_FF * N_BANK)-1 : 0] re,
    input [((W_DATA * BRAM_BANK_FF) * N_BANK)-1 : 0] i_data,
    input [((BRAM_BANK_FF * (W_ADDR + 1)) * N_BANK)-1 : 0] i_address,
    output [((W_DATA * BRAM_BANK_FF) * N_BANK)-1 : 0] o_data
);

genvar i;
generate
    for(i = 0; i < N_BANK; i = i + 1)begin
        bram_array#(
            .W_DATA(W_DATA),
            .W_ADDR(W_ADDR),
            .BRAM_BANK_FF(BRAM_BANK_FF)  //number of brams in one bank
        ) bram_bank(
            .clk(clk),
            .we(we[(BRAM_BANK_FF * (N_BANK - i))-1 -: BRAM_BANK_FF]),
            .re(re[(BRAM_BANK_FF * (N_BANK - i))-1 -: BRAM_BANK_FF]),
            .i_data(i_data[((BRAM_BANK_FF * W_DATA) * (N_BANK - i)) -: (BRAM_BANK_FF * W_DATA)]),
            .i_addr(i_address[((BRAM_BANK_FF * (W_ADDR + 1)) * (N_BANK - i))-1 -: (BRAM_BANK_FF * (W_ADDR + 1))]),
            .o_data(o_data[((BRAM_BANK_FF * W_DATA) * (N_BANK - i)) -: (BRAM_BANK_FF * W_DATA)])
        ); 
    end
endgenerate
    
endmodule

module bram_array#(
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter BRAM_BANK_FF = 8  //number of brams in one bank
)(
    input clk,
    input [BRAM_BANK_FF-1 : 0] we,
    input [BRAM_BANK_FF-1 : 0] re,
    input [(W_DATA * BRAM_BANK_FF)-1 : 0] i_data,
    input [(BRAM_BANK_FF * (W_ADDR + 1))-1 : 0] i_addr,
    output [(BRAM_BANK_FF * W_DATA)-1 : 0] o_data
);

genvar i;
generate
    for (i = 0; i < BRAM_BANK_FF; i = i + 1) begin
        bram bram_wrapper(
            .re(re[i]),
            .we(we[i]),
            .addr(i_addr[((W_ADDR + 1) * (i + 1))-1 -: (W_ADDR + 1)]),
            .wdata_a(i_data[(W_DATA * (BRAM_BANK_FF - i))-1 -: W_DATA]),
            .rdata_a(o_data[(W_DATA * (BRAM_BANK_FF - i))-1 -: W_DATA]),
            .clk(clk)
        );
    end
endgenerate
    
endmodule