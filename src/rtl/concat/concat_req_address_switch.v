module concat_address_switcher #
( parameter ADD_WIDTH = 32
)
(
  input  wire        i_clk,
  input  wire        i_rst,
  // Sequence control
  input  wire        i_start_seq,   // 1-cycle pulse to start sequence
  input  wire [1:0]  i_input_num,//TODO:Number of valid inputs: 1..4
  // All input address 
  input  wire [ADD_WIDTH -1 :0] i_start_add0,
  input  wire [ADD_WIDTH -1 :0] i_start_add1,
  input  wire [ADD_WIDTH -1 :0] i_start_add2,
  input  wire [ADD_WIDTH -1 :0] i_start_add3,
  input  wire [ADD_WIDTH -1 :0] i_stop_add0,
  input  wire [ADD_WIDTH -1 :0] i_stop_add1,
  input  wire [ADD_WIDTH -1 :0] i_stop_add2,
  input  wire [ADD_WIDTH -1 :0] i_stop_add3,
  // Handshake from processing block
  input  wire                   i_done, // asserted when current length is done
  output reg                    o_start_en, // 1-cycle pulse
  output reg [ADD_WIDTH -1 :0]  o_start_add,   // latched address 
  output reg [ADD_WIDTH -1 :0]  o_stop_add,
  output reg                    o_all_done
);

  // --------------------------------------------------
  // Internal state
  // --------------------------------------------------
  reg [1:0] curr_idx;   // current input index
  reg       active =0;     // sequence active

  // --------------------------------------------------
  // Length select mux
  // --------------------------------------------------
  wire [ADD_WIDTH-1 :0] next_start_add;
  wire [ADD_WIDTH-1 :0] next_stop_add;

  assign next_start_add =
      (curr_idx == 2'd0) ? i_start_add0 :
      (curr_idx == 2'd1) ? i_start_add1 :
      (curr_idx == 2'd2) ? i_start_add2 :
                           i_start_add3;
  assign next_stop_add =
      (curr_idx == 2'd0) ? i_stop_add0 :
      (curr_idx == 2'd1) ? i_stop_add1 :
      (curr_idx == 2'd2) ? i_stop_add2 :
                           i_stop_add3;


  // --------------------------------------------------
  // Control logic
  // --------------------------------------------------
  always @(posedge i_clk) begin
    if (i_rst) begin
      curr_idx   <= 2'd0;
      active     <= 1'b0;
      o_start_en <= 1'b0;
      o_start_add   <= 32'd0;
      o_stop_add   <= 32'd0;
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
        o_start_add   <= i_start_add0;   // latch first length
        o_stop_add    <= i_stop_add0;
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
          o_start_add      <= next_start_add;
          o_stop_add       <= next_stop_add ;
          o_start_en <= 1'b1;
          active     <= 1'b1;
        end
      end
    end
  end

endmodule
