module bram_wr_ctrl_resize #(
    parameter FIFO_NO = 32,
    parameter DATA_WIDTH = 8,
    parameter N_SA = 4,
    parameter RESIZE_IW_WIDTH = 10,
    parameter RESIZE_IH_WIDTH = 10,
    parameter W_ADDR = 9,
    parameter MOD2 = 8
)(
    input                             clk,
    input                             rst,
    input                             i_resize_start,
    input                             i_data_valid,
    input [(DATA_WIDTH*MOD2) - 1 : 0] i_data,
    input [RESIZE_IW_WIDTH-1:0]       i_image_width,
    input [RESIZE_IH_WIDTH-1:0]       i_image_height,

    output reg                        o_wr_en,
    output reg [W_ADDR-1:0]           o_wr_addr,
    output reg [DATA_WIDTH-1:0]       o_wr_data,
    output reg                        o_busy,
    output reg                        o_done,
    output reg                        o_send_read,
    output                            o_start_rd
);


    localparam IDLE       = 2'd0;
    localparam WAIT       = 2'd1;
    localparam WRITE      = 2'd2;
    localparam WAIT_VALID = 2'd3;

    reg [1:0] state;

    reg [(MOD2*DATA_WIDTH)-1:0] data_latch;
    reg [$clog2(MOD2):0]        byte_cnt;
    reg [RESIZE_IW_WIDTH-1:0]   col_counter;
    reg [RESIZE_IH_WIDTH-1:0]   row_counter;
    
    // start pulse for read controller when 1 row has been written into BRAM.
     assign o_start_rd = (row_counter == 1);

    always @(posedge clk) begin
        if(!rst) begin
            state       <= IDLE;
            o_wr_en     <= 1'b0;
            o_wr_addr   <= 'd0;
            o_wr_data   <= 'd0;
            o_busy      <= 1'b0;
            o_done      <= 1'b0;
            o_send_read <= 1'b0;
            byte_cnt    <= 'd0;
            col_counter <= 'd0;
            row_counter <= 'd0;
            data_latch  <= 'd0;
        end 
        else begin
            o_send_read <= 1'b0;

            case(state)
            IDLE: begin
                o_busy          <= 1'b0;
                o_done          <= 0;
                if (i_resize_start) begin
                    o_wr_addr   <= 'd0;
                    col_counter <= 'd0;
                    row_counter <= 'd0;
                    state       <= WAIT;

                end
            end

            WAIT: begin
                o_busy      <= 1'b0;
                o_send_read <= 1'b1;
                state       <= WAIT_VALID;
            end

            WAIT_VALID: begin
              o_send_read       <= 1'b0;
                if(i_data_valid) begin
                    data_latch  <= i_data;
                    byte_cnt    <= 0;
                    state       <= WRITE;
                    o_send_read <= 0;
                end
              end

            WRITE: begin
                o_busy      <= 1'b1;  // busy when a row is being written
                o_wr_en     <= 1'b1;
                o_wr_data   <= data_latch[((MOD2-byte_cnt)*DATA_WIDTH) -1 -: DATA_WIDTH];
                o_wr_addr   <= o_wr_addr + 1;
                byte_cnt    <= byte_cnt + 1;
                if((row_counter == i_image_height-1) && (col_counter == i_image_width)) begin
                  o_done    <= 1'b1;
                  state     <= IDLE;
                  o_wr_en   <= 1'b0;
                end 
                // all the bytes from present input have been written       
                else if(byte_cnt == MOD2) begin
                  state             <= WAIT;
                  byte_cnt          <= 0;
                  o_wr_en           <= 1'b0;
                  o_wr_addr         <= o_wr_addr;
                  if(col_counter == i_image_width) begin
                    col_counter     <= 0;
                    row_counter     <= row_counter + 1;
                  end 
                  else col_counter  <= col_counter + 1;
                end

                else if(col_counter == i_image_width) begin
                  col_counter       <= 0;
                  row_counter       <= row_counter + 1;
                end
                else col_counter    <= col_counter + 1;
            end

            default: state <= IDLE;
            endcase
        end
    end

endmodule
