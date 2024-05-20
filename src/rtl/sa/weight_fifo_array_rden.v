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
    input i_start,
    input i_done,
    input i_layer_done,
    input [COL-1 : 0] i_fifo_empty,
    input [(COL * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output [COL-1 : 0] o_fifo_read_enable,
    output o_sel,
    output o_enable_image_rden_ctrl
);

/*
    The occupanct signal size in FIFO is 9 bits, 
    and the parameter size is 32 bits until explicitly mentioned. 
    So, just 9 bits of the ROW parameter are taken to match the size of the occupants signal 
    in order to concatinate and check that the occupants are at least equal to ROW.
*/
localparam S_ROW = ROW[8:0];

wire w_start;
//Generates one pulse from trigger sent externally
pulse_gen start_pulse (
    .a(i_start),
    .i_rstn(i_rstn),
    .clk(i_clk),
    .b(w_start)
);

reg [2:0] state = 0;
reg [4:0] counter = 0;
reg sel = 1;
reg read_img = 0;
reg [COL-1 : 0] rden = 0;

assign o_enable_image_rden_ctrl = read_img;
assign o_fifo_read_enable = rden;
assign o_sel = sel;

always @(posedge i_clk) begin
    if(~i_rstn)begin
        state <= 0;
        rden <= 0;
        sel <= 1;
    end else begin
        case (state)
            0: begin
                if(w_start)begin
                    state <= 1;
                    rden <= 0;
                    sel <= 1'b1;
                end
            end 

            1: begin
                //Checking for number of occupants in each fifo in array to be atleast equal to ROW
                if((i_fifo_empty == 0) && (i_fifo_occupants >= {COL{S_ROW}}))begin
                    rden <= {COL{1'b1}};
                    state <= 2;
                end
            end

            2: begin
                if(counter == ROW-1)begin
                    state <= 3;
                    counter <= 0;
                    rden <= 0;
                    sel <= sel;
                    read_img <= 1'b1;
                end else begin
                    counter <= counter + 1;
                end
            end

            3: begin
                if(i_done)begin
                    read_img <= 1'b0;
                   if((COL * N_SA) < N_BRAM_BYTES)
                        sel <= ~sel;
                    else
                        sel <= sel;
                    state <= 4;
                end
            end

            4: begin
                if(i_layer_done)begin
                    state <= 0;
                    sel <= 1'b1;
                end else begin
                    state <= 1;
                    sel <= sel;
                end
            end

            default: state <= 0;
        endcase
    end
end

endmodule
