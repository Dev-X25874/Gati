/*
    When each fifo in the array has a data, 
    the read enable signal of image fifo array is asserted.
*/
module image_fifo_array_rden_pool#(
    parameter ROW = 9,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter N_MOD_STAGES = 8,
    parameter I_OP_SIZE_WIDTH = 16
)(
	input i_clk,
    input i_trigger,
    input pool_stall,
    input i_rstn,
    input [ROW-1:0] i_fifo_empty,
    input [ROW-1:0] i_fifo_almost_empty,
    input [I_OP_SIZE_WIDTH-1:0] i_img_dim_Op,
    input im2col_done, 
    output o_read_enable
);

reg rden = 0;

assign o_read_enable = rden;

reg valid_sq_delay = 0;
reg [$clog2(N_MOD_STAGES)-1 : 0 ] counter = 0;

always @(posedge i_clk) begin
    if(~i_rstn) begin
        counter <= 0;
        valid_sq_delay <= 0;
    end
    else begin
        if(im2col_done) begin
            counter <= counter + 1'b1;
        end else if (counter == (N_MOD_STAGES - 1)) begin
            counter <= 0;
            valid_sq_delay <= 1;
        end else if (counter != 0) begin
            counter <=  counter + 1'b1;
            valid_sq_delay <= 0;
        end else if (|i_fifo_empty) begin
            counter <=  0;
            valid_sq_delay <= 0;
        end  else begin
            counter <=  counter;
            valid_sq_delay <= valid_sq_delay;
        end
    end
end

always @(posedge i_clk)begin
    if(~i_rstn)begin
        rden <= 0;
    end else begin
        if(i_trigger)begin
           if(i_img_dim_Op < (N_MOD_STAGES - 1)) begin
             if(|(i_fifo_almost_empty) & rden) rden <= 1'b0;
            else begin
                if((i_fifo_empty == 0) && valid_sq_delay)
                    rden <= 1'b1;
                else
                    rden <= 1'b0;
            end
           end else begin
             if(|(i_fifo_almost_empty) & rden) rden <= 1'b0;
            else begin
                if((i_fifo_empty == 0) &&  (~pool_stall))
                    rden <= 1'b1;
                else
                    rden <= 1'b0;
            end
           end
        end
    end
end
endmodule