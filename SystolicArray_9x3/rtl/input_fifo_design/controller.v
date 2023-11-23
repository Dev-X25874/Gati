/*
    Controlls read enable signal of array of fifo that loads
    weights into columns of systolc array and handles select signal
    of systolic array.
*/
module controller #(
   parameter COL = 3,
   parameter ROW = 9
) (
   input i_clk,
   input i_trigger,
   input [(COL * 32) -1 : 0] i_data,
   input [COL-1:0] i_fifo_empty,
   output [COL-1:0] o_fifo_read_enable,
   output o_select,
   output [(COL * 32) -1 :  0] o_data
);
    
   reg [COL-1:0] rden = 0;
   reg [2:0] state = 0;
   reg sel = 0;
   reg [4:0] counter = 0;
   reg [95:0] data = 0;

   assign o_fifo_read_enable = rden;
   assign o_select = sel;

/*
    A PE block has 2 registers, one stores 32 bits of output 
    and another stores weights. 
    To ensure that weights are loaded in correct register, 
    thry're loaded in alternate clock cycle into systolic array. 
*/
   assign o_data = (~counter[0]) ? 96'd0 : i_data;
    
always @(posedge i_clk)begin
    case(state)
    
        0: begin
            rden <= 3'd0;
            sel <= 0;
            counter <= 5'd0;
            if(i_trigger)
                state <= 1;
            else
                state <= 0;
        end

        1: begin
            if(~i_fifo_empty[2] && ~i_fifo_empty[1] && ~i_fifo_empty[0])begin
                sel <= 1'b1;
                if(~counter[0])begin
                    rden <= 3'd0;
                end else begin
                    rden <= 3'd7;
                end
                counter <=  counter + 1;

                if( counter == (2 * ROW) + 1)begin
                    counter <= 5'd0;
                    state <= 0;
                    sel <= 1'b0;
                end else begin
                    state <= 1;
                end

            end else begin
                counter <=  counter;
                sel <= 1'b0;
                rden <= 3'd0;
                state <= 1;
            end
        end

    endcase
end

endmodule
