
module gen_bram_resize #(
    parameter W_DATA = 8,
    parameter W_ADDR = 6
)(
    input  clk,
    input  wr_en,
    input  [W_ADDR-1:0]  wr_addr,   // column index
    input  [W_DATA-1:0]  wr_data,
    input  rd_en,
    input  [W_ADDR-1:0]  rd_addr,   // column index
    output [W_DATA-1:0]  rd_data
);

    simple_dpram #(
        .W_DATA (W_DATA),
        .W_ADDR (W_ADDR)
    ) row_buffer_bram (
        .clk      (clk),
        .we       (wr_en),
        .re       (rd_en),
        .waddr    (wr_addr),
        .raddr    (rd_addr),
        .wdata_a  (wr_data),
        .rdata_b  (rd_data)
    );

endmodule







// module upsample_bram_array #(
//     parameter N_BRAM_UPSAMPLE = 32,
//     parameter ELEMENTS = 2,
//     parameter CHANNELS = 16,
//     parameter W_DATA = 8,
//     parameter W_ADDR = 10
// )(
//     input  i_clk,
//     input  [N_BRAM_UPSAMPLE - 1 : 0] i_wr_en,
//     input  [W_ADDR-1:0] i_wr_addr,
//     input  [N_BRAM_UPSAMPLE*W_DATA-1:0] i_wr_data,
//     input  [N_BRAM_UPSAMPLE - 1 : 0] i_rd_en,
//     input  [W_ADDR-1:0] i_rd_addr,
//     output [N_BRAM_UPSAMPLE*W_DATA-1:0] i_rd_data
// );
//
// // localparam W_BRAM = 
// integer i;
// genvar i;
//
// generate 
//   for(i = 0; i < N_BRAM_UPSAMPLE; i = i + 1)
//     simple_dpram#(
//       .W_ADDR(W_ADDR),
//       .W_DATA(W_DATA)
//     ) bram_inst (
//       .clk(i_clk),
//       .wdata_a(i_wr_data[((N_BRAM_UPSAMPLE - i) * W_DATA) - 1 -: W_DATA]),
//       .waddr(i_wr_addr[((N_BRAM_UPSAMPLE - i) * (W_ADDR + 1)) - 1 -: (W_ADDR + 1)]),
//       .we(i_wr_en[N_BRAM_UPSAMPLE - i - 1 : 0]),
//       .re(i_rd_en[N_BRAM_UPSAMPLE - i - 1 :0]),
//       .r_addr(i_rd_addr[(N_BRAM_UPSAMPLE - i) * (W_ADDR + 1) - 1 -: (W_ADDR + 1)]),
//       .rdata_b(i_rd_data[((N_BRAM_UPSAMPLE - i) * W_DATA) - 1 -: W_DATA])
//     );
//   end
// endgenerate
// endmodule























// `include "../common/simple_dpram.v"
// module gen_bram #(
//     parameter CHANNELS = 16,
//     parameter ELEMENTS = 2,
//     parameter W_DATA   = 8,
//     parameter W_ADDR   = 8,
//     parameter N_BRAM   = 32
// )
// (
//     input  clk,
//     input  [CHANNELS-1:0] we,
//     input  [N_BRAM-1:0] re,
//     input  [((W_ADDR + 1)*CHANNELS)-1:0] waddr,
//     input  [((W_ADDR + 1)*N_BRAM)-1:0] raddr,
//     input  [(2*CHANNELS*ELEMENTS*W_DATA)-1:0] data_in, // 512 bits
//     input  bram_sel,
//     output [(CHANNELS*ELEMENTS*W_DATA)-1:0] data_out   // 256 bits
// );
//
//     localparam W_BRAM = ELEMENTS * W_DATA; // 16 bits
//
//     wire [(CHANNELS*W_BRAM)-1:0] r_data_out_a;
//     wire [(CHANNELS*W_BRAM)-1:0] r_data_out_b;
//
//     assign data_out = bram_sel ? r_data_out_b : r_data_out_a;
//
//     genvar i;
//     generate
//         for(i = 0; i < CHANNELS; i = i + 1) begin : GEN_BRAM
//             simple_dpram #(
//                 .W_ADDR(W_ADDR),
//                 .W_DATA(W_BRAM)
//             ) a_bram_dut (
//                 .clk(clk),
//                 .wdata_a(data_in[ (2*CHANNELS*W_BRAM) - (W_BRAM*i) - 1 -: W_BRAM ]),
//                 .re(re[i]),
//                 .we(we[i]),
//                 .rdata_b(r_data_out_a[ (CHANNELS*W_BRAM) - (W_BRAM*i) - 1 -: W_BRAM ]),
//                 .waddr( waddr[ ((W_ADDR + 1)*(CHANNELS-i)) - 1 -: (W_ADDR + 1) ]),
//                 .raddr( raddr[ ((W_ADDR + 1)*(N_BRAM-i)) - 1 -: (W_ADDR + 1) ])
//             );
//
//             simple_dpram #(
//                 .W_ADDR(W_ADDR),
//                 .W_DATA(W_BRAM)
//             ) b_bram_dut (
//                 .clk(clk),
//                 .wdata_a( data_in[ (CHANNELS*W_BRAM) - (W_BRAM*i) - 1 -: W_BRAM ]),
//                 .re(re[i + CHANNELS]),
//                 .we(we[i]),
//                 .rdata_b( r_data_out_b[ (CHANNELS*W_BRAM) - (W_BRAM*i) - 1 -: W_BRAM ]),
//                 .waddr( waddr[ ((W_ADDR + 1)*(CHANNELS-i)) - 1 -: (W_ADDR + 1) ]),
//                 .raddr( raddr[ ((W_ADDR + 1)*(N_BRAM-(i+CHANNELS))) - 1 -: (W_ADDR + 1) ])
//             );
//         end
//     endgenerate
//
// endmodule





// module gen_bram #(
//     parameter CHANNELS = 16,
//     parameter ELEMENTS = 2,
//     parameter W_DATA = 8,
//     parameter W_ADDR = 8,
//     parameter N_BRAM = 32)
//     (
//         input  clk,
//         input  [CHANNELS-1:0] we,
//         input  [N_BRAM-1:0] re,
//         input  [((W_ADDR + 1)*CHANNELS)-1:0] waddr,
//         input  [((W_ADDR + 1)*N_BRAM)-1:0] raddr,
//         input  [(2*CHANNELS*ELEMENTS*W_DATA)-1:0] data_in,
//         input  bram_sel,
//         output [(N_BRAM*W_DATA)-1:0] data_out
//     );
//
//     wire [(N_BRAM*W_DATA)-1:0] r_data_out_a;
//     wire [(N_BRAM*W_DATA)-1:0] r_data_out_b;
//     assign data_out = bram_sel ? r_data_out_a : r_data_out_b;
//     genvar i;
//
//         generate
//             for(i=0; i<N_BRAM; i=i+1) begin
//                 if(i<CHANNELS) begin
//                     simple_dpram #(.W_ADDR(W_ADDR*2), .W_DATA(W_DATA)) a_bram_dut(
//                         .clk(clk),
//                         .wdata_a(data_in[(2*CHANNELS*ELEMENTS*W_DATA) - (W_DATA*i) - 1 -:W_DATA]),
//                         .re(re[i]),
//                         .we(we[i]),
//                         .rdata_b(r_data_out_a[(W_DATA*(N_BRAM-i))-1 -:W_DATA]),
//                         .waddr(waddr[((W_ADDR + 1)*(CHANNELS-i))-1 -:(W_ADDR)]),
//                         .raddr(raddr[((W_ADDR + 1)*(N_BRAM-i))-1 -:(W_ADDR)])
//                     );
//                 end
//
//                 else begin
//                     simple_dpram #(.W_ADDR(W_ADDR*2), .W_DATA(W_DATA)) b_bram_dut(
//                         .clk(clk),
//                         .wdata_a(data_in[(CHANNELS*ELEMENTS*W_DATA) - (W_DATA*(i-CHANNELS)) - 1 -:W_DATA]),
//                         .re(re[i]),
//                         .we(we[i-CHANNELS]),
//                         .rdata_b(r_data_out_b[(W_DATA*(N_BRAM-i))-1 -:W_DATA]),
//                         .waddr(waddr[((W_ADDR + 1)*(CHANNELS-(i-CHANNELS)))-1 -:(W_ADDR)]),
//                         .raddr(raddr[((W_ADDR + 1)*(N_BRAM-i))-1 -:(W_ADDR)])
//                     );
//                 end
//             end
//       endgenerate
//
// endmodule
