//`include "fifo.v"
//`include "mux.v"
//`include "adder.v"
//`include "controller_fifo.v"

module top_bias_fc #(

    parameter DATA_WIDTH     = 8,
    parameter ADDR_WIDTH     = 8,
    parameter DRAM_BW=32,
    parameter N              = 4,
    parameter FIFO_NO        = 8,
    parameter OUT_DATA_WIDTH = 8,
    parameter NO_PORT=2


) (
    input                             top_clk,
    input  [             FIFO_NO-1:0] top_wr_en,
    input  [(DATA_WIDTH*FIFO_NO)-1:0] top_data_in,
    input                             vector_add_enable,
    // input                             sel_mux,
    output [  (OUT_DATA_WIDTH*N)-1:0] top_data_out,
    input  [      (DATA_WIDTH*N)-1:0] top_data_in_adder_tree,
    input                             rst,
   // input channel_done,
    output [             FIFO_NO-1:0] w_empty_flag,
    input  [                   N-1:0] top_in_data_valid,
    output [                   N-1:0] top_out_data_valid,
    output [((ADDR_WIDTH+1)*FIFO_NO)-1:0] fifo_occupants
);





  wire [(DATA_WIDTH*FIFO_NO)-1:0] w_data_out;
  wire [      (DATA_WIDTH*N)-1:0] w_data_in_fifo;
  wire [             FIFO_NO-1:0] w_rd_en;
  
  wire [             FIFO_NO-1:0] w_valid_fifo;

 wire [FIFO_NO-1:0] empty_flag;
    wire [NO_PORT-1:0]sel;

assign w_empty_flag=empty_flag;


  dram_fifo #(
      .DIMENSION(FIFO_NO),
      .W_DATA(DATA_WIDTH),
      .W_ADDR(ADDR_WIDTH),
      .RAM_DEPTH(1 << ADDR_WIDTH)
  
      ) fifo_vector_add (
      .i_clk(top_clk),
      .i_rst(rst),
      .i_data(top_data_in),
      .i_read_enable(w_rd_en),
      .i_write_enable(top_wr_en),
      .o_data(w_data_out),
      .o_fifo_empty(empty_flag),
      .o_fifo_full(full),
      .o_fifo_dv(w_valid_fifo),
      .o_occupants(fifo_occupants)
  );
  wire [FIFO_NO -1:0] full;
//   wire [(ADDR_WIDTH+1)*FIFO_NO -1:0] occ;

  wire [(DATA_WIDTH*N)-1:0] mux_out;

  wire [N-1:0] valid_mux;
  vector_mux_param #(
      .PORT_SIZE(N * DATA_WIDTH),

      .NO_PORT(NO_PORT)
  ) mux_data (
     // .clk(top_clk),
      .in (w_data_out),
      .out(mux_out),
      .sel(sel)
  );

  vector_mux_param #( 
      .PORT_SIZE(N),

      .NO_PORT(NO_PORT)
  ) mux_valid (
     // .clk(top_clk),
      .in (w_valid_fifo),
      .out(valid_mux),
      .sel(sel)
  );


 bias_controller #(
    .FIFO_NO(FIFO_NO),
    .DRAM_BW(DRAM_BW),
    .NO_PORT(NO_PORT)
  )
   controller 
  (
      .clk(top_clk),
      .rst(rst),
      .empty_fifo(empty_flag),
      .enable(vector_add_enable),
      .data_valid_tree(top_in_data_valid[0]),
      .valid_rd_en(w_rd_en),
      .sel(sel)
  );
 

  adder_gen #(
      .DATA_WIDTH(DATA_WIDTH),
      .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
      .N(N)
  ) adder_gen_mod (
      .gen_data_in_adder_tree(top_data_in_adder_tree),
      .gen_data_in_fifo(mux_out),
      .gen_clk(top_clk),
      .vector_add_enable(vector_add_enable),
      .gen_data_valid_fifo(valid_mux),
      .gen_data_in_valid(top_in_data_valid),
      .gen_data_out_valid(top_out_data_valid),
      .gen_data_out_adder(top_data_out)
  );



endmodule
