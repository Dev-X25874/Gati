/*
    When each fifo in the array has at least ROW number of occupants,
    the read enable signal of weight fifo array is asserted.
    A counter will begin counting ROW times when the read enable signal is high 
    once the ROW number of occupants have been written into every fifo. 
    The read enable is deasserted once the counter hits (ROW-1), 
    and it will continue until all of the fifo in the array are filled, 
    with at least ROW number of occupants again.
*/
module weight_fifo_aray_rden#(
   parameter COL = 1,
   parameter ROW = 9,
   parameter W_ADDR = 8,
   parameter W_DATA = 8
) (
   input i_clk,
   input i_rst,
   input i_trigger,
   input [COL-1:0] i_fifo_empty,
   output [COL-1:0] o_fifo_read_enable,
   input [((W_ADDR + 1) * COL)-1 : 0] i_fifo_occupants
);

/*
    The occupanct signal size in FIFO is 9 bits, 
    and the parameter size is 32 bits until explicitly mentioned. 
    So, just 9 bits of the ROW parameter are taken to match the size of the occupants signal 
    in order to concatinate and check that the occupants are at least equal to ROW.
*/
localparam S_ROW = ROW[8:0];
wire w_trigger;

//Generates one pulse from trigger sent externally
pulse_gen one_pulse (
    .a(i_trigger),
    .rst(i_rst),
    .clk(i_clk),
    .b(w_trigger)
);

reg [COL-1:0] rden = 0;
reg [2:0] state = 0;
reg sel = 0;
reg [($clog2(COL * 32))-1 : 0] counter = 0;
reg [((W_ADDR+1) * COL) -1 : 0] replicated_value = 0;

assign o_fifo_read_enable = rden;

always @(posedge i_clk)begin
    if(i_rst)begin
        rden <= 0;
        state <= 0;
        counter <= 0;
    end else begin
        case(state)
            0: begin
                if(w_trigger) begin
                    if(i_fifo_empty == 0)begin
                        //Checking for number of occupants in each fifo in array to be atleast equal to ROW
                        if(i_fifo_occupants >= {COL{S_ROW}}) begin
                            rden <= {COL{1'd1}}; 
                            state <= 1;
                        end
                    end
                end 
            end    

            1: begin
                if(counter == (ROW-1))begin
                    rden <= 0;
                    counter <= 0;
                    state <= 0;
                end 
                else 
                begin
                    counter <= counter + 1;
                end
            end

            default : begin
                state <= 0;
            end
        endcase
    end
end
endmodule