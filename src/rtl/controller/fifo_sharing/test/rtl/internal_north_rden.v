// module sa_weight_ff_rden(
//     input i_clk,
//     input i_rst,
//     input i_start,
//     input i_done,
//     input i_layer_done,
//     input i_sel_1,
//     input [(N_SA * COL_SA)-1 : 0] i_weight_ff_empty,
//     input [(N_SA * (COL_SA * (W_ADDR+1)))-1 : 0] i_weight_ff_occupants,
//     output [(N_SA * COL_SA)-1  :0] o_weight_ff_read_en,
//     output [N_SA-1 : 0] o_sel
// );

// genvar i;
// generate
//     for(i = 0; i < N_SA; i = i + 1)begin
//         internal_north_rden#(
//             .W_ADDR(W_ADDR),
//             .ROW(ROW),
//             .N_SA(N_SA),
//             .COL_SA(COL_SA),
//             .N_BRAM_BYTES(N_BRAM_BYTES)
//         )weight_fifo_array_rden(
//             .i_clk(i_clk),
//             .i_rst(i_rst),
//             .i_start(i_start),
//             .i_done(i_done),
//             .i_layer_done(i_layer_done),
//             .i_sel_1(i_sel_1),
//             .i_fifo_empty(i_weight_ff_empty[(COL_SA * (N_SA - i))-1 -: COL_SA]),
//             .i_fifo_occupants(i_weight_ff_occupants[((COL_SA * (W_ADDR + 1)) * (N_SA - i))-1 -: (COL_SA * (W_ADDR + 1))]),
//             .o_fifo_read_enable(o_weight_ff_read_en[(COL_SA * (N_SA - i))-1 -: (COL_SA)]),
//             .o_sel(o_sel[i])
//         );
//     end
// endgenerate
    
// endmodule

// module internal_north_rden#(
//     parameter W_ADDR = 8,
//     parameter ROW = 9,
//     parameter N_SA = 4,
//     parameter COL_SA = 4,
//     parameter N_BRAM_BYTES = 32
// )(
//     input i_clk,
//     input i_rst,
//     input i_start,
//     input i_done,
//     input i_layer_done,
//     input i_sel_1,
//     input [COL_SA-1 : 0] i_fifo_empty,
//     input [(COL_SA * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
//     output [COL_SA-1 : 0] o_fifo_read_enable,
//     output o_sel
// );

// localparam S_ROW = ROW[8:0];

// reg [2:0] state = 0;
// reg [4:0] counter = 0;
// reg sel = 1;
// reg [COL_SA-1 : 0] rden = 0;

// wire w_start;
// one_cycle start_pulse (
//     .a(i_start),
//     .rst(i_rst),
//     .clk(i_clk),
//     .b(w_start)
// );

// assign o_fifo_read_enable = rden;
// assign o_sel = sel;

// always @(posedge i_clk) begin
//     if(i_rst)begin
//         state <= 0;
//         rden <= 0;
//         sel <= 1;
//     end else begin
//         case (state)
//             0:begin
//                 if(w_start)begin
//                     state <= 1;
//                     rden <= 0;
//                     sel <= 1'b1;
//                 end
//             end 

//             1: begin
//                 if(i_sel_1)begin
//                     if((i_fifo_empty == 0) && (i_fifo_occupants >= {COL_SA{S_ROW}}))begin
//                         rden <= {COL_SA{1'b1}};
//                         state <= 2;
//                     end
//                 end
//             end

//             2: begin
//                 if(counter == ROW-1)begin
//                     state <= 3;
//                     counter <= 0;
//                     rden <= 0;
//                     sel <= sel;
//                 end else begin
//                     counter <= counter + 1;
//                 end
//             end

//             3: begin
//                 if(i_done)begin
//                     if((COL_SA * N_SA) < N_BRAM_BYTES)
//                         sel <= ~sel;
//                     else
//                         sel <= ~sel;
//                     state <= 4;
//                 end
//             end

//             4: begin
//                 if(i_layer_done)begin
//                     state <= 0;
//                     sel <= 1'b1;
//                 end else begin
//                     state <= 1;
//                     sel <= sel;
//                 end
//             end

//             default: state <= 0;
//         endcase
//     end
// end

// endmodule