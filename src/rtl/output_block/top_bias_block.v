

module top_bias_block #(
    parameter BIAS=1,
    parameter DATA_WIDTH     = 32,
    parameter N              = 4,
    parameter FIFO_NO        = 8,
    parameter W_ADDR         = 9,
    parameter OUT_DATA_WIDTH = 32,
    parameter TOGGLE=1,
    parameter NO_PORT=2


) (
    input                             top_clk,
    input  [             FIFO_NO-1:0] top_wr_en,
    input  [(DATA_WIDTH*FIFO_NO)-1:0] top_data_in,
    input                             vector_add_enable,
    input                             CONV_FC,
    // input                             sel_mux,
    output [  (OUT_DATA_WIDTH*N)-1:0] top_data_out,
    input  [      (DATA_WIDTH*N)-1:0] top_data_in_adder_tree,
    input                             rst,
    input                             channel_done,
    output [             FIFO_NO-1:0] w_empty_flag,
    input  [                   N-1:0] top_in_data_valid,
    output [                   N-1:0] top_out_data_valid,
    output [((W_ADDR+1)*FIFO_NO)-1:0] fifo_occupants
);





  wire [(DATA_WIDTH*FIFO_NO)-1:0] w_data_out;
  wire [      (DATA_WIDTH*N)-1:0] w_data_in_fifo;
  wire [             FIFO_NO-1:0] w_rd_en;
  
  wire [             FIFO_NO-1:0] w_valid_fifo;

 wire [FIFO_NO-1:0] empty_flag;


assign w_empty_flag=empty_flag;


  dram_fifo #(
      .DIMENSION(FIFO_NO),
      .W_DATA(DATA_WIDTH),
      .W_ADDR(W_ADDR),
      .RAM_DEPTH(1 << W_ADDR)
  
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
//   wire [(W_ADDR+1)*FIFO_NO -1:0] occ;

  wire [(DATA_WIDTH*N)-1:0] mux_out;
  wire [$clog2(NO_PORT)-1:0] sel;
  wire [N-1:0] valid_mux;
  wire [NO_PORT-1:0] sel_mux;
  assign sel_mux = 1 << sel;
  vector_mux_param #(
      .PORT_SIZE(N * DATA_WIDTH),
      .NO_PORT(NO_PORT)
  ) mux_data (
      .in (w_data_out),
      .out(mux_out),
      .sel(sel_mux)
  );

  vector_mux_param #(
      .PORT_SIZE(N),
      .NO_PORT(NO_PORT)
  ) mux_valid (
      .in (w_valid_fifo),
      .out(valid_mux),
      .sel(sel_mux)
  );


  new_controller #(
      .FIFO_NO(FIFO_NO),
      .BIAS(BIAS),
      .TOGGLE(1))
   controller 
  (
      .clk(top_clk),
      .rst(rst),
      .CONV_FC(CONV_FC),
	  .empty_fifo(empty_flag),
      .channel_done(channel_done),
      .enable(vector_add_enable),
      .mux_toggle(sel),
      .data_valid_tree(top_in_data_valid[0]),
      .valid_rd_en(w_rd_en)
  );
 

 /* Delay for data_valid_input and the input data to synchronize with bias fifo read data */

reg [N-1:0] r_dtr_valid,t_dtr_valid,i_dtr_valid;
reg [(DATA_WIDTH*N)-1:0] r_dtr_data,t_dtr_data,i_dtr_data;
always@(posedge top_clk) begin
    t_dtr_valid<=top_in_data_valid;
    t_dtr_data<=top_data_in_adder_tree;
    
    i_dtr_valid<=t_dtr_valid;	
    i_dtr_data<=t_dtr_data; 

    r_dtr_data<=i_dtr_data;
    r_dtr_valid<=i_dtr_valid;
end

  adder_gen #(
      .DATA_WIDTH(DATA_WIDTH),
      .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
      .N(N)
  ) adder_gen_mod (
      .gen_data_in_adder_tree(r_dtr_data),
      .gen_data_in_fifo(mux_out),
      .gen_clk(top_clk),
      .vector_add_enable(vector_add_enable),
      .gen_data_valid_fifo(valid_mux),
      .gen_data_in_valid(r_dtr_valid),
      .gen_data_out_valid(top_out_data_valid),
      .gen_data_out_adder(top_data_out)
  );



endmodule
