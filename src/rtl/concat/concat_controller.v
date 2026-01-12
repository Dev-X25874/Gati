module concat_controller #
(
  parameter DATA_WIDTH = 32,
  parameter AXI_DATA_WIDTH = 256,
  parameter AXI_ADDRESS_WIDTH = 32,
  parameter QUANT_OP_FIFO = 1 
)
(
  input  wire                          i_clk,
  input  wire                          i_rst,
  // Control
  input  wire                          i_start, 
  input  wire [AXI_ADDRESS_WIDTH-1:0]  i_data_size,    // image length in BYTES
  // DRAM FIFO (256-bit)
  input  wire [AXI_DATA_WIDTH-1:0]     i_concat_data,
  input  wire                          concat_fifo_empty,
  output reg                           concat_read_enable,
  // 32-bit FIFO
  output reg  [AXI_DATA_WIDTH-1:0]     o_concat_data,
  output reg                           o_concat_dv,
  input  wire                          fifo32_full,
  // Status
  output reg                           o_done,
  input wire                           i_dram_fifo_dv,
  input [QUANT_OP_FIFO -1 : 0]         quant_op_fifo_full

);

  reg         buf_valid;

  reg [31:0]  total_words_remaining;  // image + padding for (256-bit aligned)

  // Total input size alligned to 256 bit in bytes
  
  // Input total words is calculated based on the KN and OH OW provided from the instruction which might not be aligned to 256 thus those needs to be done as we will read data in 256 bit alignment due to previous layers zero padder.

  wire [31:0] total_words ;
  assign total_words = ((i_data_size + 31) >> 5) << 5;


  reg [1:0] IDLE       = 2'b00;
  reg [1:0] READ       = 2'b01;
  reg [1:0] WRITE      = 2'b11;
  reg [1:0] DONE       = 2'b10;
  reg [1:0] state      = 2'b00; 

  always @(posedge i_clk ) begin
    if (i_rst) begin
      concat_read_enable        <= 1'b0;
      o_concat_dv     <= 1'b0;
      o_concat_data             <= 32'd0;
      total_words_remaining     <= 32'd0;
      buf_valid                 <= 1'b0;
      o_done                    <= 1'b0;
      state                     <= IDLE;  
    end else begin
      concat_read_enable        <= 1'b0;
      o_concat_dv               <= 1'b0;
      o_done                    <= 1'b0;

      case (state)

        // --------------------------
        IDLE: begin
          if (i_start) begin
            total_words_remaining <= total_words;
            buf_valid             <= 1'b0;
            state                 <= READ;
          end
          else state <= IDLE;
        end

    
        READ: begin

          if ((total_words_remaining == 0))
             state = DONE;
          else begin  
          if (!concat_fifo_empty && !quant_op_fifo_full) begin
            concat_read_enable <= 1'b1;
            buf_valid          <= 1'b1;
            state              <= WRITE;
          end
          else state <= READ;
          end
        end


        WRITE: begin
          concat_read_enable <= 1'b0;
          if ((total_words_remaining == 0))
             state = DONE;
          else begin
            if (i_dram_fifo_dv && (total_words_remaining != 0)) begin
              o_concat_data         <= i_concat_data;
              o_concat_dv           <= 1'b1;
              total_words_remaining <= total_words_remaining - 32;
              state <= READ ;
            end
            else state <= WRITE;
          end
        end

        // --------------------------
        DONE: begin
          o_done <= 1'b1;
          state <= IDLE;
        end

      endcase
    end
  end

endmodule
