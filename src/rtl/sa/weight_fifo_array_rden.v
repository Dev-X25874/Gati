/*
    When each fifo in the array has at least ROW number of occupants,
    the read enable signal of weight fifo array is asserted.
    A counter will begin counting ROW times when the read enable signal is high 
    once the ROW number of occupants have been written into every fifo. 
    The read enable is deasserted once the counter hits (ROW-1), 
    and it will continue until all of the fifo in the array are filled, 
    with at least ROW number of occupants again.
*/
module weight_fifo_array_rden#(
    parameter COL = 4,
    parameter W_ADDR = 8,
    parameter ROW = 9,
    parameter N_SA = 4,
    parameter N_BRAM_BYTES = 32
)(
    input i_clk,
    input i_rstn,
    input i_im2col_start,
    input i_start,
    input i_done,
    input i_layer_done,
    input [COL-1 : 0] i_fifo_empty,
    input [(COL * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output o_fifo_read_enable,
    output o_sel,
    output o_enable_image_rden_ctrl
);

/*
    The occupanct signal size in FIFO is 9 bits, 
    and the parameter size is 32 bits until explicitly mentioned. 
    So, just 9 bits of the ROW parameter are taken to match the size of the occupants signal 
    in order to concatinate and check that the occupants are at least equal to ROW.
*/
localparam S_ROW = ROW[W_ADDR:0];

reg r_start;
always @(posedge i_clk) begin
    if(!i_rstn) r_start <= 0;
    else begin
        if(i_start) r_start <= 1;
        else if(i_done || i_layer_done) r_start <= 0;
        else r_start <= r_start;
    end
end

reg [2:0] state = 0;
reg [4:0] counter = 0;
reg sel = 1;
reg read_img = 0;
reg rden = 0;

assign o_enable_image_rden_ctrl = read_img;
assign o_fifo_read_enable = rden;
assign o_sel = sel;

always @(posedge i_clk) begin
    if(~i_rstn)begin
        state <= 0;
        rden <= 0;
        read_img <= 0;
        sel <= 1;
    end else begin
        case (state)
            0: begin
                read_img <= 0;
                if(i_layer_done)begin
                    sel <= 1'b1;
                end
				else if (i_im2col_start) begin
					state<=1;
				end
				else begin 
					state<=0;
				end
				rden<=0;
			end
            1: begin
                //Checking for number of occupants in each fifo in array to be atleast equal to ROW
                if((i_fifo_empty == 0))begin            //(i_fifo_occupants >= {COL{S_ROW}})
                    rden <= 1'b1;
                    state <= 2;
                end
            end

            2: begin
                if(counter == ROW-1)begin
                    state <= 3;
                    counter <= 0;
                    rden <= 0;
                    sel <= sel;
                    read_img <= 1'b0;
                end else begin
                    counter <= counter + 1;
                end
            end

            3: begin
                if(r_start) begin
                    read_img <= 1'b1;
                    rden <= 1'b0;
                    state <= 4;
                end else begin
                    read_img <= 1'b0;
                    rden <= 1'b0;
                    state <= 3;
                end
            end

            4: begin
                if(i_done)begin
                    read_img <= 1'b0;
                    if((COL * N_SA) < N_BRAM_BYTES)
                        sel <= ~sel;
                    else
                        sel <= sel;
                    state <= 0;
                end
            end

           default: state <= 0;
        endcase
    end
end

endmodule
