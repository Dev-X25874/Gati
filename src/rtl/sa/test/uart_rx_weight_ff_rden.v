/*
    This fsm controls the read enable signal of uart rx weight fifo array.
    The read enable signal is only asserted when each fifo in array has atleast 
    (ROW * COL) numbers of occupants. Hence, (ROW * COL) number of weights 
    are streamed at once from all the fifo in array to SA.
*/
module uart_rx_weight_ff_rden#(
    parameter N_SA = 2,
    parameter W_ADDR = 8,
    parameter ROW = 9,
    parameter COL = 4
)(
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_fifo_empty,
    input [(N_SA * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output [N_SA-1 : 0] o_fifo_read_enable
);
localparam N_ELEMENTS = (ROW * COL);
/*
    The occupanct signal size in FIFO is 9 bits, 
    and the parameter size is 32 bits until explicitly mentioned. 
    So, just 9 bits of the N_ELEMENTS parameter are taken to match the size of the occupants signal 
    in order to concatinate and check that the occupants are at least equal to ROW.
*/
localparam S_ELEMENTS = N_ELEMENTS[8:0];

reg [N_SA-1 : 0] rden = 0;
reg [1:0] state = 0;
assign o_fifo_read_enable = rden;

always @(posedge i_clk) begin
if(i_rst)begin
    rden <= 0;
    state <= 0;
end else begin
    case (state)
    0:begin
        if(i_fifo_empty == 0)begin
            //Checking for number of occupants in each fifo in array to be atleast equal to (ROW * COL)
            if(i_fifo_occupants >= {N_SA{S_ELEMENTS}})begin
                rden <= {N_SA{1'b1}};
                state <= 1;
            end
        end
    end 
    1: begin
        if(i_fifo_occupants == 0)begin
            state <= 0;
            rden <= {N_SA{1'b0}};
        end
    end
    default: state <= 0;
endcase 
end
end
endmodule