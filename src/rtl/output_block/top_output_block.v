
module top_output_block #(
    parameter DRAM_BW        = 32,
    parameter DATA_WIDTH_ACC = 32,
    parameter N              = 8,
    parameter COL_SA         = 8,
    parameter FIFO_NO        = 8,
    parameter TOGGLE         = 0,
    parameter W_ADDR         = 9,
    parameter OUT_DATA_WIDTH = 32,
    parameter NO_PORT=1,
    parameter I_ACC_SIZE_WIDTH = 16,
    parameter OW_WIDTH = 10,     // Bit-width of the row counter of img
    parameter OH_WIDTH = 10     // Bit-width of the column counter of img
) (
    input                                 top_clk,
    input [I_ACC_SIZE_WIDTH-1:0]          i_img_dim_Acc,
    input [(OW_WIDTH - 1) : 0]            OW,          // Total number of rows (width)
    input [(OH_WIDTH - 1) : 0]            OH,          // Total number of columns (height)
    input  [             FIFO_NO-1:0]     top_wr_en,
    input  [(DATA_WIDTH_ACC*FIFO_NO)-1:0] top_data_in, //previous accumulnats from ddr
    input                                 vector_add_enable,
    input   [                (N)-1:0]     empty_sa,
    input   [                (N)-1:0]     almost_empty_sa,
    input                                 op_full,
    // input                             sel_mux,
    output [  (OUT_DATA_WIDTH*N)-1:0] top_data_out,
    input  [      (DATA_WIDTH_ACC*N)-1:0] top_data_in_adder_tree,
    input                             rst,
    input                             Iteration_Done,
    output [             FIFO_NO-1:0] w_empty_flag,
    output [             FIFO_NO-1:0] w_almost_empty_flag,
    input  [                   N-1:0] top_in_data_valid,
    output [                   N-1:0] top_out_data_valid,
    output [((W_ADDR+1)*FIFO_NO)-1:0] fifo_occupants
);


wire [(DATA_WIDTH_ACC*FIFO_NO)-1:0] w_data_out;
wire [      (DATA_WIDTH_ACC*N)-1:0] w_data_in_fifo;
wire [                 FIFO_NO-1:0] w_rd_en;

wire [                 FIFO_NO-1:0] w_valid_fifo;

reg [(DATA_WIDTH_ACC*FIFO_NO)-1:0] data_in_mux;

wire [FIFO_NO-1:0] empty_flag;
wire [FIFO_NO-1:0] almost_empty_flag;

assign w_empty_flag = empty_flag;
assign w_almost_empty_flag = almost_empty_flag;

wire [FIFO_NO-1:0] acc_fifo_rd_en;

generate

  reg [(OW_WIDTH - 1) : 0] count = 0;
  wire [FIFO_NO-1:0] diff;
  reg [FIFO_NO-1:0] r_en;
  reg [FIFO_NO-1:0] count_diff = 0;
  reg valid_diff = 0;
  reg [1:0] state = 0;
  reg sig_en = 0;

  assign diff = (i_img_dim_Acc - (OH * OW));

  if(TOGGLE) begin

    assign acc_fifo_rd_en = ((&empty_sa)? ((sig_en)? r_en : {FIFO_NO{1'b0}}) : (w_rd_en));

    always @(posedge top_clk) begin
      if((&top_in_data_valid) & vector_add_enable) begin
        count <= count + 1;
        valid_diff <= 0;
      end
      else begin
        if(count == (OH * OW)) begin
          count <= 0;
          if(count == i_img_dim_Acc) begin
            valid_diff <= 0;
          end
          else  begin
            valid_diff <= 1;
          end
        end
        else begin
          valid_diff <= 0;
        end
      end
    end

    always @(posedge top_clk) begin
      case(state) 
      0: begin
        r_en <= 0;
        count_diff <= 0;
        sig_en <= 0;
        if(valid_diff) begin
            state <= 1;
        end
        else begin
            state <= 0;
        end
      end
      1: begin
        if(count_diff < diff) begin
              r_en[((N * NO_PORT) - (count_diff * N) - 1) -: N] <= {N{1'b1}};
              count_diff <= count_diff + 1;
              sig_en <= 1;
              state <= 1;
          end
          else begin
            count_diff <= 0;
            r_en <= 0;
            state <= 0;
            sig_en <= 0;
          end
      end
      endcase
    end
  end 
  else begin
    assign acc_fifo_rd_en = ((&empty_sa) || (|(empty_flag))) ? 0 : w_rd_en;
  end

endgenerate

dram_fifo #(
      .DIMENSION(FIFO_NO),
      .W_DATA(DATA_WIDTH_ACC),
      .W_ADDR(W_ADDR),
      .RAM_DEPTH(1 << W_ADDR)
  
      ) fifo_vector_add (
      .i_clk(top_clk),
      .i_rst(rst),
      .i_data(top_data_in),
      .i_read_enable(acc_fifo_rd_en),
      .i_write_enable(top_wr_en),
      .o_data(w_data_out),
      .o_fifo_empty(empty_flag),
      .o_fifo_almost_empty(almost_empty_flag),
      .o_fifo_full(full),
      .o_fifo_dv(w_valid_fifo),
      .o_occupants(fifo_occupants)
  );
  wire [FIFO_NO -1:0] full;
//   wire [(W_ADDR+1)*FIFO_NO -1:0] occ;

  wire [(DATA_WIDTH_ACC*N)-1:0] mux_out;
  wire [NO_PORT-1:0] sel;
  wire [N-1:0] valid_mux;

  generate
    if(TOGGLE) begin
      vector_mux_param #(
        .PORT_SIZE(N*DATA_WIDTH_ACC),
        .NO_PORT(NO_PORT)
      ) mux_data (
          .in(data_in_mux),
          .out(mux_out),
          .sel(sel)
      );

      vector_mux_param #(
        .PORT_SIZE(N),
        .NO_PORT(NO_PORT)
      ) mux_valid (
        .in (w_valid_fifo),
        .out(valid_mux),
        .sel(sel)
      );
    end
    else begin
      assign mux_out = data_in_mux;
      assign valid_mux = w_valid_fifo;
    end
  endgenerate
  

 /*
  bias_controller #(
    .DRAM_BW(DRAM_BW),
    .FIFO_NO(FIFO_NO),
    .NO_PORT(NO_PORT)
  ) vector_add_controller (
    .clk(top_clk),
    .rst(rst),
    .enable(vector_add_enable),
    .empty_fifo(empty_flag),
    .data_valid_tree(&(top_in_data_valid)),
    .sel(sel),
    .valid_rd_en(w_rd_en)
  );
*/
  
  acc_fifo_rden #(
      .FIFO_NO(FIFO_NO),
      .TOGGLE(TOGGLE),
      .N(N),
      .COL_SA(COL_SA),
      .NO_PORT(NO_PORT))
   controller 
  (
      .clk(top_clk),
      .rst(rst&(~Iteration_Done)),
	    .empty_fifo(empty_flag),
      .almost_empty_fifo(almost_empty_flag),
      .empty_sa(empty_sa),
      .almost_empty_sa(almost_empty_sa),
      .enable(vector_add_enable),
      .data_valid_tree(&(top_in_data_valid)),
      .select(sel),
      .op_full(op_full),
      .valid_rd_en(w_rd_en)
  );
  

  localparam APPEND = OUT_DATA_WIDTH - DATA_WIDTH_ACC;
  wire [(DATA_WIDTH_ACC*N)-1:0] data_in_accumulant;
  genvar i;
  generate
    for(i=0;i<N;i=i+1) begin
      assign data_in_accumulant[(DATA_WIDTH_ACC*(N-i)-1) -: DATA_WIDTH_ACC] = 
      {{APPEND{mux_out[(DATA_WIDTH_ACC*(N-i)-1)]}} ,mux_out[(DATA_WIDTH_ACC*(N-i)-1) -: DATA_WIDTH_ACC]};
    end
  endgenerate

  // Pipeline stage for acc_fifo data to synchronize with adder tree output.
  genvar j;
  generate
    if(COL_SA>1) begin
      for(j=0;j<$clog2(COL_SA);j=j+1) begin:REG
        reg [(DATA_WIDTH_ACC*FIFO_NO)-1:0] data_reg;
        if(j==0) begin
          always@(posedge top_clk) begin
            data_reg <= (!rst)? 0 : w_data_out;
          end
        end

        else if(j==($clog2(COL_SA)-1)) begin
          always@(posedge top_clk) begin
            data_in_mux <= (!rst)? 0 : REG[j-1].data_reg;
          end
        end

        else begin
          always@(posedge top_clk) begin
            data_reg <= (!rst)? 0 : REG[j-1].data_reg;
          end
        end
      end
    end
    else begin
      always@(*) begin //Todo: check if this is data is arriving on the same clock cycle of adder tree output. If not, then we need to add a pipeline stage or connect the data directly using assign statement.
        data_in_mux = w_data_out;
      end
    end
  endgenerate

  wire [(DATA_WIDTH_ACC*N)-1:0] data_in_adder_tree;
  wire [N-1:0] adder_in_data_valid;

  reg [(DATA_WIDTH_ACC*N)-1:0] r_data_in_adder_tree;
  reg [N-1:0] r_adder_in_data_valid;

  generate
    if(TOGGLE) begin
      always@(posedge top_clk) begin
        r_data_in_adder_tree <= top_data_in_adder_tree;
        r_adder_in_data_valid <= top_in_data_valid;
      end
      assign data_in_adder_tree = r_data_in_adder_tree;
      assign adder_in_data_valid = r_adder_in_data_valid;
    end
    else begin
      assign data_in_adder_tree = top_data_in_adder_tree;
      assign adder_in_data_valid = top_in_data_valid;
    end
  endgenerate

  adder_gen #(
      .DATA_WIDTH(DATA_WIDTH_ACC),
      .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
      .N(N)
  ) adder_gen_mod (
      .gen_data_in_adder_tree(data_in_adder_tree),
      .gen_data_in_fifo(data_in_accumulant),
      .gen_clk(top_clk),
      .vector_add_enable(vector_add_enable),
      .gen_data_valid_fifo(adder_in_data_valid),
      .gen_data_in_valid(adder_in_data_valid),
      .gen_data_out_valid(top_out_data_valid),
      .gen_data_out_adder(top_data_out)
  );



endmodule
