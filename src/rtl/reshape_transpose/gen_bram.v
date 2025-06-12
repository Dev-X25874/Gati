module gen_bram #(
    parameter AXI_DATA_BYTES = 32,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter N_BRAM = 32)
    (
        input  clk,
        input  [N_BRAM-1:0] we,
        input  [N_BRAM-1:0] re,
        input  [(W_ADDR*N_BRAM) - 1:0] waddr,
        input  [(W_ADDR*N_BRAM) - 1:0] raddr,
        input  [(AXI_DATA_BYTES*W_DATA)-1:0] data_in,
        output [(AXI_DATA_BYTES*W_DATA)-1:0] data_out
    );

    genvar i;
     
    generate
        for(i=0; i<N_BRAM; i=i+1) begin
            //if(i<CHANNELS) begin
                simple_dpram #(.W_ADDR(W_ADDR), .W_DATA(W_DATA)) a_bram_dut(
                    .clk(clk),
                    .wdata_a(data_in[(W_DATA*(AXI_DATA_BYTES-i))-1 -:W_DATA]),
                    .re(re[N_BRAM-1-i]),
                    .we(we[N_BRAM-1-i]),
                    .rdata_b(data_out[(W_DATA*(AXI_DATA_BYTES-i))-1 -:W_DATA]),
                    .waddr(waddr[((W_ADDR*(N_BRAM-i))-1) -:W_ADDR]),
                    .raddr(raddr[((W_ADDR*(N_BRAM-i))-1) -:W_ADDR])
                );
            end

            // else begin
                // sdpram #(.W_ADDR(W_ADDR), .W_DATA(W_DATA)) b_bram_dut(
                    // .clk(clk),
                    // .wdata_a(data_in[(W_DATA*(CHANNELS-(i-CHANNELS)))-1 -:W_DATA]),
                    // .re(re[i]),
                    // .we(we[i-CHANNELS]),
                    // .rdata_b(data_out[(W_DATA*(N_BRAM-i))-1 -:W_DATA]),
                    // .waddr(waddr[((W_ADDR + 1)*(CHANNELS-(i-CHANNELS)))-1 -:(W_ADDR + 1)]),
                    // .raddr(raddr[((W_ADDR + 1)*(N_BRAM-i))-1 -:(W_ADDR + 1)])
                // );
            // end
        //end
    endgenerate

endmodule