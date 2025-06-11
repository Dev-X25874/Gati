// this module is used to control the start and stall of the systolic array 
// the stall logic is needed for accomodating stride > 1 
// more about this can be read on the GATI github issue page ISSUE number #203


module sa_start_stall_ctrl #(
    parameter CONV_IH_WIDTH = 8,
    parameter CONV_PAD_WIDTH = 3,
    parameter CONV_STRIDE_WIDTH = 3,
    parameter IMAGE_DIM = 32,
    parameter CONV_Im2colPrefetch_WIDTH = 1

    
) ( 
    input sa_image_fifo_almost_empty_flag,
    input sa_image_fifo_almost_full_flag,
    input im2col_global_start,
    input im2col_done,
    input SA_done,
    input i_clk,
    input i_rst,
    input [CONV_IH_WIDTH-1 : 0] input_img_height,  
    input [CONV_PAD_WIDTH-1:0] conv_zeropad,
    input [CONV_Im2colPrefetch_WIDTH - 1 : 0] CONV_Im2colPrefetch,
    input [CONV_STRIDE_WIDTH-1:0]  stride,
    input [$clog2(IMAGE_DIM)-1:0]      row,   
    input [$clog2(IMAGE_DIM)-1:0]      col,


    output reg istolic_stall,
    output reg systolic_array_trigger
);
    

  // internal flages to control the start and stall of the systolic array
  reg istolic_array_stall=0;
  reg stall_flag = 0;
  reg sa_start_flag = 0;
  reg sa_running_flag = 0;
  reg sa_flag = 0;
  reg stage_1_flag = 0;
  reg stage_2_flag = 0;
  reg stage_3_flag = 0;
  

 // main loop for generation of start and stall flags 

  always @ (posedge i_clk) begin
    if(!i_rst) begin
      istolic_array_stall <= 0;
      sa_start_flag <= 0;
      sa_flag <= 0;
      stage_1_flag <= 0;
      stage_2_flag <= 0;
      stage_3_flag <= 0;
    end
    else begin
      if(stride == 0) begin
        istolic_array_stall <= 0 ;
        stall_flag <= 0;
        if(input_img_height < 4) begin
          if (row == (input_img_height + conv_zeropad -1) && col==1) begin
            sa_start_flag <= 1;
          end
          else begin 
            sa_start_flag <= 0;
          end 
        end
        else begin
          if(row == 5 && col==1) begin
            sa_start_flag <=1;
            end
          else begin 
            sa_start_flag <= 0;
          end
        end 
      end
      else if (stride >= 1) begin
        if (CONV_Im2colPrefetch == 1) begin 
          istolic_array_stall <= 0;
          stall_flag <= 0;
          if(row == (input_img_height + conv_zeropad -1) && col==1) begin
            sa_start_flag <= 1;
          end
          else begin 
            sa_start_flag <= 0;
          end 

        end 
        //// the new logic for stride > 1

        else if (CONV_Im2colPrefetch == 0) begin

          if (im2col_global_start)begin
            stage_1_flag <= 1;
            stage_2_flag <= 0;
            stage_3_flag <= 0;
          end
          // stage 1 
          if (stage_1_flag)begin
            if (sa_image_fifo_almost_full_flag)begin
              sa_start_flag <= 1;
              sa_running_flag <= 1;
              stall_flag <= 0;
              istolic_array_stall <= 0;
              stage_1_flag <= 0;
              stage_2_flag <= 1;
            end
          end
          // stage 2 
          else if (stage_2_flag)begin
            sa_start_flag <= 0;
            stage_1_flag <= 0;

            if (sa_image_fifo_almost_empty_flag)begin 
              stall_flag <= 1;
              istolic_array_stall <= 1;
              sa_start_flag <= 0;
            end 
            else if (sa_image_fifo_almost_full_flag)begin 
              stall_flag <= 0;
              istolic_array_stall <= 0;
              sa_start_flag <= 0;
            end
          end
          // stage 3
          if (im2col_done)begin 
            stage_1_flag <= 0;
            stage_2_flag <= 0;
            stage_3_flag <= 1;
          end 

          else if (stage_3_flag)begin
            stall_flag <= 0;
            istolic_array_stall <= 0;
            if(SA_done) begin
              stage_1_flag <= 0;
              stage_2_flag <= 0;
              stage_3_flag <= 0;
            end
          end

        end

      end
      else begin
        istolic_array_stall <= 0;
        stall_flag <= 0;
        sa_start_flag <= 0;
      end
    end
      
  end


  // genrating the final stall trigger from the flags 

  always @(posedge i_clk) begin
    if(!i_rst) begin
      istolic_stall <= 0;
    end
    else begin
      if(stall_flag && istolic_array_stall) begin
        istolic_stall <= 1;
      end
      else begin
        istolic_stall <= 0;
      end
    end
    
  end

  // genrating the start trigger for the systolic array

  always@(posedge i_clk) begin
    if(!i_rst) begin
      systolic_array_trigger <= 1'b0;
    end
    else begin
      if(sa_start_flag) begin
			  systolic_array_trigger <= 1'b1;
		  end
        else systolic_array_trigger <= 0;
    end
  end

endmodule