module concat_length_switcher #
(
  parameter MAX_INPUTS = 4
)
(
  input  wire        i_clk,
  input  wire        i_rst,

  // Sequence control
  input  wire        i_start_seq,   // 1-cycle pulse to start sequence
  input  wire [1:0]  i_input_num,   // number of valid inputs: 1..4

  // Length inputs (bytes)
  input  wire [31:0] i_len0,
  input  wire [31:0] i_len1,
  input  wire [31:0] i_len2,
  input  wire [31:0] i_len3,

  // Handshake from processing block
  input  wire        i_done,         // asserted when current length is done

  // Outputs to processing block
  output reg         o_start_en,      // 1-cycle pulse
  output reg [31:0]  o_length,        // latched length

  // Optional status
  output reg         o_all_done
);

  // --------------------------------------------------
  // Internal state
  // --------------------------------------------------
  reg [1:0] curr_idx;   // current input index
  reg       active;     // sequence active

  // --------------------------------------------------
  // Length select mux
  // --------------------------------------------------
  wire [31:0] next_length;

  assign next_length =
      (curr_idx == 2'd0) ? i_len0 :
      (curr_idx == 2'd1) ? i_len1 :
      (curr_idx == 2'd2) ? i_len2 :
                           i_len3;

  // --------------------------------------------------
  // Control logic
  // --------------------------------------------------
  always @(posedge i_clk ) begin
    if (i_rst) begin
      curr_idx   <= 2'd0;
      active     <= 1'b0;
      o_start_en <= 1'b0;
      o_length   <= 32'd0;
      o_all_done <= 1'b0;
    end else begin
      // defaults
      o_start_en <= 1'b0;
      o_all_done <= 1'b0;

      // ------------------------------------------------
      // Start a new sequence
      // ------------------------------------------------
      if (i_start_seq && !active) begin
        curr_idx   <= 2'b01;
        o_length   <= i_len0;   // latch first length
        o_start_en <= 1'b1;     // pulse start
        active     <= 1'b1;
      end

      // ------------------------------------------------
      // Current input finished
      // ------------------------------------------------
      else if (active && i_done) begin
        // Last input?
        if (curr_idx == (i_input_num)) begin
          active     <= 1'b0;
          o_all_done <= 1'b1;
        end else begin
          curr_idx   <= curr_idx + 1'b1;
          o_length   <= next_length;
          o_start_en <= 1'b1;
          active     <= 1'b1;
        end
      end
    end
  end

endmodule
