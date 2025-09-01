// this module is used to control the start and stall of the systolic array
// the stall logic is needed for accomodating stride > 1
// more about this can be read on the GATI github issue page ISSUE number #203
`include "../common/instructions.vh"

module sa_start_stall_ctrl #(
    parameter CONV_IH_WIDTH = 8,
    parameter CONV_IW_WIDTH = 8,
    parameter CONV_PAD_WIDTH = 3,
    parameter CONV_STRIDE_WIDTH = 3,
    parameter IMAGE_DIM = 32,
    parameter CONV_Pfetch_WIDTH = 1,
    parameter CONV_TYPE_WIDTH = 2,
    parameter COL_SA = 1,
    parameter CONV_KW_WIDTH = 4,
    parameter IM2COL_FIFO_DEPTH = 1024
) (
    input                           sa_image_fifo_almost_empty_flag,
    input                           sa_image_fifo_almost_full_flag,
    input                           im2col_global_start,
    input                           im2col_done,
    input                           SA_done,
    input                           i_clk,
    input                           i_rst,
    input [      CONV_IH_WIDTH-1:0] input_img_height,
    input [      CONV_IW_WIDTH-1:0] input_img_width,
    input [     CONV_PAD_WIDTH-1:0] conv_zeropad,
    input [CONV_Pfetch_WIDTH - 1:0] CONV_Im2colPrefetch,
    input [    CONV_TYPE_WIDTH-1:0] conv_type,
    input [  CONV_STRIDE_WIDTH-1:0] stride,
    input [          IMAGE_DIM-1:0] row,
    input [          IMAGE_DIM-1:0] col,
    input [      CONV_KW_WIDTH-1:0] kernel_width,

    output reg istolic_stall,
    output reg systolic_array_trigger
);


  // internal flages to control the start and stall of the systolic array
  reg       istolic_array_stall = 0;
  reg       sa_start_flag = 0;
  // main loop for generation of start and stall flags

  reg [2:0] state;
  reg [2:0] IDLE = 3'b000;
  reg [2:0] P_FETCH = 3'b001;
  reg [2:0] SA_STALL_START = 3'b011;
  reg [2:0] IM2COL_DONE = 3'b010;
  generate

    if(COL_SA == 1)
    // this gets generated for 16 1 16 arch 
    begin

      always @(posedge i_clk) begin
        if (!i_rst) begin
          istolic_array_stall <= 0;
          sa_start_flag <= 0;
        end else begin
            
            if(conv_type == `CONV_TYPE_PW) begin
                istolic_array_stall <= 0;
                if (input_img_height == 1) sa_start_flag <= im2col_global_start;
                else begin
                    if(row == 1 && col == input_img_height/2) begin
                        sa_start_flag <= 1;
                    end
                    else begin 
                        sa_start_flag <= 0;
                    end
                end
            end

            else begin
                if (CONV_Im2colPrefetch == 1) begin
                    istolic_array_stall <= 0;
                    if (input_img_height == 1) sa_start_flag <= im2col_global_start;
                    else if (row == (input_img_height + conv_zeropad) && col == 1) begin
                        sa_start_flag <= 1;
                    end else sa_start_flag <= 0;
                end else if (CONV_Im2colPrefetch == 0) begin
                case (state)
                    IDLE: begin
                        if (im2col_global_start) state <= P_FETCH;
                        else state <= IDLE;
                    end

                    P_FETCH: begin
                        if (sa_image_fifo_almost_full_flag) begin
                            sa_start_flag <= 1;
                            state <= SA_STALL_START;
                        end else state <= P_FETCH;
                    end

                    SA_STALL_START: begin
                        sa_start_flag <= 0;
                        if (sa_image_fifo_almost_empty_flag) begin
                            istolic_array_stall <= 1;
                        end else if (sa_image_fifo_almost_full_flag) begin
                            istolic_array_stall <= 0;
                        end
                        if (im2col_done) state <= IM2COL_DONE;
                        else state <= SA_STALL_START;
                    end

                    IM2COL_DONE: begin
                        istolic_array_stall <= 0;
                        if (SA_done) begin
                            state <= IDLE;
                        end
                    end
                    default: state <= IDLE;
                endcase
                end else begin
                    istolic_array_stall <= 0;
                    sa_start_flag <= 0;
                end
            end
        end
      end
    end  
    
    // this gets generated for the 988 or 944 architecture 
    else begin
      /* if the input image is larger then 256 then we cannot prefetch the 2*(Kh-1) row for it to work,
         so we have to follow the prefetch and stall logic for that as well thus we will first check 
         this and then choose which method we will use for starting the systolic array
      */
      /* generating a flag which will let us know the input size is bigger, this should be calculated 
        based on the IM2col fifo depth the kernal size and input image width
      */
      wire f_big_input;

      assign f_big_input = (IM2COL_FIFO_DEPTH <=(2 * (kernel_width - 1)* input_img_width)) ? 1:0;

      // now if the f_big_input is one we will go by the prefetch method otherwise normal method is fine

      wire prefetch_method;
      assign prefetch_method = (stride >= 2) ? 1'b1 : (f_big_input) ? 1'b1 : 1'b0;

      always @(posedge i_clk) begin
        if (!i_rst) begin
          istolic_array_stall <= 0;
          sa_start_flag <= 0;
          state <= IDLE;
        end else begin

          // prefetch method 1
          if (!prefetch_method) begin
            istolic_array_stall <= 0;
            if (input_img_height <= 4) begin
              if (row == (input_img_height + conv_zeropad - 1) && col == 1) begin
                sa_start_flag <= 1;
              end else sa_start_flag <= 0;
            end else begin
              if (row == ((2'd2 * (kernel_width - 1'b1)) + 1'b1) && col == 1) begin
                sa_start_flag <= 1;
              end else sa_start_flag <= 0;
            end
          end  // prefetch method 2
          else if (prefetch_method) begin
            if (CONV_Im2colPrefetch == 1) begin
              istolic_array_stall <= 0;
              if (row == (input_img_height + conv_zeropad) && col == 1) begin
                sa_start_flag <= 1;
              end else sa_start_flag <= 0;
            end else if (CONV_Im2colPrefetch == 0) begin
              case (state)
                IDLE: begin
                  if (im2col_global_start) state <= P_FETCH;
                  else state <= IDLE;
                end

                P_FETCH: begin
                  if (sa_image_fifo_almost_full_flag) begin
                    sa_start_flag <= 1;
                    state <= SA_STALL_START;
                  end else state <= P_FETCH;
                end

                SA_STALL_START: begin
                  sa_start_flag <= 0;
                  if (sa_image_fifo_almost_empty_flag) begin
                    istolic_array_stall <= 1;
                  end else if (sa_image_fifo_almost_full_flag) begin
                    istolic_array_stall <= 0;
                  end
                  if (im2col_done) state <= IM2COL_DONE;
                  else state <= SA_STALL_START;
                end

                IM2COL_DONE: begin
                  istolic_array_stall <= 0;
                  if (SA_done) state <= IDLE;
                end
                default: state <= IDLE;
              endcase
            end

          end else begin
            istolic_array_stall <= 0;
            sa_start_flag <= 0;
          end
        end

      end
    end
  endgenerate


  /// new state machine based approch

  // genrating the final stall trigger from the flags

  always @(posedge i_clk) begin
    if (!i_rst) begin
      istolic_stall <= 0;
    end else begin
      if (istolic_array_stall) istolic_stall <= 1;
      else istolic_stall <= 0;
    end

  end

  // genrating the start trigger for the systolic array

  always @(posedge i_clk) begin
    if (!i_rst) systolic_array_trigger <= 1'b0;
    else begin
      if (sa_start_flag) systolic_array_trigger <= 1'b1;
      else systolic_array_trigger <= 0;
    end
  end

endmodule
