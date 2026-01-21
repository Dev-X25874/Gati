module bram_rd_ctrl_resize #(
    parameter FIFO_NO = 32,
    parameter DATA_WIDTH = 8,
    parameter N_SA = 4,
    parameter RESIZE_IW_WIDTH = 10,
    parameter RESIZE_IH_WIDTH = 10,
    parameter W_ADDR = 9,
    parameter MOD2 = 8

) (
    input                         clk,
    input                         rst,
    input                         i_resize_start,
    input [RESIZE_IW_WIDTH-1:0]   i_image_width,
    input [RESIZE_IH_WIDTH-1:0]   i_image_height,
    output reg                    o_rd_en,
    output reg [W_ADDR-1:0]       o_rd_addr,
    // output reg                 o_busy, // currently not required
    output reg                    o_done
);

  localparam IDLE       = 2'd0;
  localparam READ       = 2'd1;
  localparam ROW_REPEAT = 2'd2;

  reg [1:0] state;
  reg r_element_rep = 0;
  reg r_row_rep = 0;
  reg [RESIZE_IW_WIDTH-1:0] col_counter = 0;
  reg [RESIZE_IH_WIDTH-1:0] row_counter = 0;

  always@(posedge clk) begin 
    if(!rst)begin
      state     <= IDLE;
      o_rd_en   <= 1'b0;
      o_rd_addr <= 0;
      o_done    <= 1'b0;
    end 
    else begin
      case(state)
      IDLE: begin
        o_rd_addr     <= 0;
        col_counter   <= 0;
        row_counter   <= 0;
        r_element_rep <= 1'b0;
        r_row_rep     <= 1'b0;
        o_done        <= 0;
        o_rd_en       <= 0;
        if(i_resize_start) begin
          state       <= READ;
          o_rd_en     <= 1'b1;
          o_rd_addr   <= 'd1;
        end
        else state    <= IDLE;
      end
      
      READ: begin
        o_rd_en <= 1'b1;
        if(!r_element_rep) begin
          r_element_rep <= 1'b1;
        end 
        else begin
          r_element_rep <= 1'b0;
          o_rd_addr     <= o_rd_addr + 1;
          col_counter   <= col_counter + 1;
        end 
        if(col_counter == i_image_width-1) begin
          col_counter   <= 0;
          state         <= ROW_REPEAT;
        end 
      end

      ROW_REPEAT: begin
        // reset the read address to exactly one row behind.
        if(!r_row_rep) begin
          r_row_rep       <= 1'b1;
          o_rd_addr       <= o_rd_addr - i_image_width + 1;
          state           <= READ;
          r_element_rep   <= 1'b0;
        end 
        else begin
          r_row_rep       <= 1'b0;
          row_counter     <= row_counter + 1;
          if(row_counter == i_image_height-1)begin
            o_done        <= 1'b1;
            state         <= IDLE;
          end 
          else begin
            o_rd_addr     <= o_rd_addr + 1;
            state         <= READ;
            r_element_rep <= 1'b0;
          end
        end
      end

      default: state <= IDLE;
      endcase
    end
  end

endmodule


