// module fifo_mux_ctrl#(
//     parameter W_DATA = 8,
//     parameter COL = 32
// )(
//     input i_clk,
//     input i_sel_1,
//     input i_rst,
//     input [COL-1 : 0] i_fc_fifo_empty,
//     input [COL-1 : 0] i_sa_fifo_empty,
//     output o_fc_fifo_rden,
//     output o_sa_fifo_rden,
//     output o_sel_mux
// );

// reg fc_rden = 0;
// reg mux_sel = 0;

// assign o_fc_fifo_rden = fc_rden;
// assign o_sel_mux = mux_sel;

// always @(posedge i_clk)begin
//     if(i_rst)begin
//         fc_rden <= 0;
//         sa_rden <= 0;
//     end else begin
//         if(i_fifo_empty == 0)begin
//             if(~i_sel_1)begin    //sel = 1, for conv, sel = 0 for fc
//                 fc_rden <= 1'b1;
//                 sa_rden <= 1'b0;
//                 mux_sel <= 1'b1;
//             end else if(i_sel_1)begin
//                 sa_rden <= 1'b1;
//                 fc_rden <= 1'b0;
//                 mux_sel <= 1'b0;
//             end
//         end
//     end
// end
    
// endmodule